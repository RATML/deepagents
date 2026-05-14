#!/usr/bin/env python3
"""Deep Agents Chat - Interface rica via SDK Python
Funciona com Ollama Cloud (SSL desabilitado, igual ao Cursor)
"""

from __future__ import annotations

import json
import os
import sys
import threading
from datetime import datetime
from pathlib import Path
from typing import Any

# Carregar .env antes de qualquer import pesado
def load_env(filepath: str | Path) -> None:
    path = Path(filepath)
    if not path.exists():
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip()

_repo_root = Path(__file__).resolve().parent.parent
_local_dir = Path(__file__).resolve().parent
load_env(_repo_root / ".env")

# Configurar Ollama Cloud como OpenAI-compatível
if os.environ.get("OLLAMA_HOST") and os.environ.get("OLLAMA_HOST") != "http://localhost:11434":
    os.environ["OPENAI_API_KEY"] = os.environ["OLLAMA_API_KEY"]
    os.environ["OPENAI_BASE_URL"] = os.environ["OLLAMA_HOST"]

# Desabilitar SSL verification
import urllib3
urllib3.disable_warnings()
import httpx
original_client = httpx.Client
class NoVerifyClient(httpx.Client):
    def __init__(self, *args: Any, **kwargs: Any):
        kwargs["verify"] = False
        super().__init__(*args, **kwargs)
httpx.Client = NoVerifyClient

from langchain_openai import ChatOpenAI
from deepagents import create_deep_agent

# Diretórios (persistência dentro de local/)
CONVERSATIONS_DIR = _local_dir / "conversations"
CONVERSATIONS_DIR.mkdir(exist_ok=True)
CONFIG_FILE = _local_dir / ".chat_config.json"

AVAILABLE_MODELS = [
    "minimax-m2.7:cloud",
    "kimi-k2.6:cloud",
    "glm-5.1:cloud",
    "deepseek-v4-pro:cloud",
]


class ChatSession:
    """Gerencia uma sessão de chat com persistência"""

    def __init__(self) -> None:
        self.messages: list[dict[str, str]] = []
        self.model_name = self._load_config().get("model", "minimax-m2.7:cloud")
        self.agent = self._create_agent()
        self.conversation_id = datetime.now().strftime("%Y%m%d_%H%M%S")

    def _load_config(self) -> dict[str, Any]:
        if CONFIG_FILE.exists():
            return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
        return {"model": "minimax-m2.7:cloud"}

    def _save_config(self) -> None:
        CONFIG_FILE.write_text(
            json.dumps({"model": self.model_name}, indent=2),
            encoding="utf-8",
        )

    def _create_agent(self) -> Any:
        model = ChatOpenAI(model=self.model_name, timeout=60)
        return create_deep_agent(model=model)

    def switch_model(self, model_name: str) -> bool:
        if model_name not in AVAILABLE_MODELS:
            print(f"Modelo invalido. Disponiveis: {', '.join(AVAILABLE_MODELS)}")
            return False
        self.model_name = model_name
        self._save_config()
        self.agent = self._create_agent()
        print(f"Modelo trocado para: {model_name}")
        return True

    def send(self, text: str) -> str:
        self.messages.append({"role": "user", "content": text})
        out = self.agent.invoke({"messages": self.messages})
        msg = out["messages"][-1]
        response = msg.content if hasattr(msg, "content") else str(msg)
        self.messages.append({"role": "assistant", "content": response})
        return response

    def clear(self) -> None:
        self.messages.clear()
        self.conversation_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        print("Conversa limpa.")

    def save(self) -> Path:
        data = {
            "id": self.conversation_id,
            "model": self.model_name,
            "timestamp": datetime.now().isoformat(),
            "messages": self.messages,
        }
        filepath = CONVERSATIONS_DIR / f"chat_{self.conversation_id}.json"
        filepath.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
        print(f"Salvo em: {filepath}")
        return filepath

    def load(self, filepath: str) -> bool:
        path = Path(filepath)
        if not path.exists():
            print(f"Arquivo nao encontrado: {filepath}")
            return False
        data = json.loads(path.read_text(encoding="utf-8"))
        self.messages = data.get("messages", [])
        self.conversation_id = data.get("id", self.conversation_id)
        print(f"Carregado: {len(self.messages)} mensagens do arquivo {filepath}")
        return True


def list_conversations() -> list[Path]:
    files = sorted(CONVERSATIONS_DIR.glob("chat_*.json"), key=lambda p: p.stat().st_mtime, reverse=True)
    return files


def format_response(text: str) -> str:
    """Formatação básica de markdown para terminal"""
    lines = text.splitlines()
    result = []
    for line in lines:
        if line.startswith("```"):
            result.append(line)  # code fence
        elif line.startswith("# "):
            result.append(f"\n---\n{line[2:].upper()}\n---")
        elif line.startswith("## "):
            result.append(f"\n{line[3:]}")
        else:
            result.append(line)
    return "\n".join(result)


def print_banner() -> None:
    print("\n" + "=" * 60)
    print("  Deep Agents Chat (Ollama Cloud)")
    print("=" * 60)
    print()


def print_menu() -> None:
    print()
    print("Comandos disponiveis:")
    print("  /model          - Escolher modelo")
    print("  /save           - Salvar conversa")
    print("  /load <arquivo> - Carregar conversa")
    print("  /list           - Listar conversas salvas")
    print("  /clear          - Limpar conversa atual")
    print("  /hist           - Mostrar historico da sessao")
    print("  /info           - Informacoes da sessao")
    print("  sair, exit, q   - Encerrar")
    print()


def choose_model(session: ChatSession) -> None:
    print("\nModelos disponiveis:")
    for i, m in enumerate(AVAILABLE_MODELS, 1):
        marker = " [ATUAL]" if m == session.model_name else ""
        print(f"  {i}. {m}{marker}")
    try:
        choice = input("\nEscolha o numero (ou Enter para cancelar): ").strip()
        if not choice:
            return
        idx = int(choice) - 1
        if 0 <= idx < len(AVAILABLE_MODELS):
            session.switch_model(AVAILABLE_MODELS[idx])
        else:
            print("Opcao invalida.")
    except ValueError:
        print("Entrada invalida.")


def main() -> None:
    print_banner()

    session = ChatSession()
    print(f"Modelo: {session.model_name}")
    print(f"Host:   {os.environ.get('OLLAMA_HOST', 'default')}")
    print("\nDigite '/help' para comandos ou 'sair' para encerrar.\n")

    try:
        while True:
            try:
                user_input = input("Voce: ").strip()
            except (EOFError, KeyboardInterrupt):
                print("\nAte mais!")
                break
            if not user_input:
                continue

            lower = user_input.lower()

            # Comandos
            if lower in ("sair", "exit", "quit", "q"):
                print("Ate mais!")
                break
            elif lower == "/help":
                print_menu()
                continue
            elif lower == "/model":
                choose_model(session)
                continue
            elif lower == "/clear":
                session.clear()
                continue
            elif lower == "/save":
                session.save()
                continue
            elif lower == "/list":
                files = list_conversations()
                if not files:
                    print("Nenhuma conversa salva.")
                else:
                    print(f"\nConversas ({len(files)}):")
                    for i, f in enumerate(files[:10], 1):
                        size = f.stat().st_size
                        print(f"  {i}. {f.name} ({size} bytes)")
                continue
            elif lower.startswith("/load "):
                arg = user_input[6:].strip()
                if arg.isdigit():
                    files = list_conversations()
                    idx = int(arg) - 1
                    if 0 <= idx < len(files):
                        session.load(str(files[idx]))
                    else:
                        print("Indice invalido.")
                else:
                    path = CONVERSATIONS_DIR / arg if not Path(arg).is_absolute() else Path(arg)
                    session.load(str(path))
                continue
            elif lower == "/hist":
                print(f"\nHistorico da sessao ({len(session.messages)} mensagens):")
                for msg in session.messages:
                    role = msg.get("role", "?")
                    content = msg.get("content", "")[:100]
                    print(f"  [{role}] {content}...")
                continue
            elif lower == "/info":
                print(f"\nSessao: {session.conversation_id}")
                print(f"Modelo: {session.model_name}")
                print(f"Mensagens: {len(session.messages)}")
                print(f"Diretorio: {CONVERSATIONS_DIR}")
                continue

            # Enviar mensagem ao agente
            print("Agente: ", end="", flush=True)
            try:
                response = session.send(user_input)
                print(format_response(response))
            except Exception as e:
                print(f"[ERRO: {type(e).__name__}: {e}]")
    finally:
        # Auto-save ao sair se houver mensagens
        if session.messages:
            filepath = session.save()
            print(f"Auto-salvo: {filepath.name}")


if __name__ == "__main__":
    main()
