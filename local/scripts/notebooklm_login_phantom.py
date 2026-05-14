#!/usr/bin/env python3
"""
Login alternativo para NotebookLM — contorna erros do `notebooklm login` no Windows:
- "Target closed" (navegador fechado antes do load)
- "Navigation interrupted by another navigation to notebooklm.google.com" (perfil já logado)

Fluxo:
1. Abre o navegador; você faz login (se o Google pedir, aprove no celular).
2. Quando a página do NotebookLM estiver carregada, pressione ENTER (ou use --auto).
3. A sessão é salva e copiada para data/notebooklm_auth.json do projeto.

Uso:
  python scripts/notebooklm_login_phantom.py              # interativo: ENTER para salvar
  python scripts/notebooklm_login_phantom.py --auto      # salva automaticamente após ~15s na página
  python scripts/notebooklm_login_phantom.py --clear-cache  # limpa perfil do Chromium e força login novo

Requer: pip install "notebooklm-py[browser]" e playwright install chromium
"""
from __future__ import annotations

import argparse
import os
import shutil
import sys
import time

NOTEBOOKLM_URL = "https://notebooklm.google.com/"

# Pasta do projeto (raiz = pai de scripts/)
def _project_root() -> str:
    return os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))


def _copy_to_project(storage_path: str, dest_rel: str = "data/notebooklm_auth.json") -> str | None:
    """Copia storage_state.json para a pasta do projeto. Retorna caminho destino ou None."""
    root = _project_root()
    dest = os.path.join(root, dest_rel.replace("/", os.sep))
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        shutil.copy2(storage_path, dest)
        return dest
    except Exception as e:
        print(f"Aviso: não foi possível copiar para o projeto: {e}", file=sys.stderr)
        return None


def main() -> None:
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("Instale: pip install 'notebooklm-py[browser]'", file=sys.stderr)
        sys.exit(1)

    parser = argparse.ArgumentParser(description="Login NotebookLM e cópia da sessão para o projeto")
    parser.add_argument(
        "--auto",
        action="store_true",
        help="Salvar automaticamente após ~15s na página do NotebookLM (útil após aprovar no celular)",
    )
    parser.add_argument(
        "--wait",
        type=int,
        default=15,
        metavar="SEGUNDOS",
        help="Com --auto, segundos de espera na página antes de salvar (padrão: 15)",
    )
    parser.add_argument(
        "--clear-cache",
        action="store_true",
        help="Limpa o perfil do Chromium (cookies/cache) antes de abrir; força login novo no Google/NotebookLM",
    )
    args = parser.parse_args()

    home = os.path.expanduser("~")
    profile_dir = os.path.join(home, ".notebooklm", "browser_profile")
    storage_path = os.path.join(home, ".notebooklm", "storage_state.json")

    os.makedirs(os.path.dirname(storage_path), exist_ok=True)

    if args.clear_cache:
        if os.path.isdir(profile_dir):
            try:
                shutil.rmtree(profile_dir)
                print("Perfil do Chromium limpo (cookies e cache removidos). Será criado um perfil novo.\n")
            except Exception as e:
                print(f"Erro ao limpar perfil: {e}", file=sys.stderr)
                print("Feche qualquer janela do Chromium que use esse perfil e tente de novo.", file=sys.stderr)
                sys.exit(1)
        else:
            print("Perfil ainda não existia; será criado limpo.\n")

    if not os.path.isdir(profile_dir):
        os.makedirs(profile_dir, exist_ok=True)

    print("Abrindo navegador com seu perfil...")
    print("1. Faça login com sua conta Google (se pedir, aprove no celular).")
    print("2. Espere carregar a página do NotebookLM.")
    if args.auto:
        print(f"3. Com --auto: aguardando {args.wait}s na página para salvar e copiar automaticamente.\n")
    else:
        print("3. Volte aqui e pressione ENTER para salvar a sessão e copiar para o projeto.\n")

    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            profile_dir,
            headless=False,
            channel=None,
            args=[
                "--disable-blink-features=AutomationControlled",
                "--password-store=basic",
            ],
            ignore_default_args=["--enable-automation"],
        )
        try:
            page = context.pages[0] if context.pages else context.new_page()
            try:
                page.goto(NOTEBOOKLM_URL, wait_until="commit", timeout=60_000)
            except Exception as e:
                if "interrupted" in str(e).lower() or "notebooklm.google.com" in str(e):
                    print("(Navegação detectada para NotebookLM — continuando.)")
                else:
                    print(f"Aviso: {e}")

            if args.auto:
                print(f"Aguardando {args.wait}s para você concluir o login (ex.: aprovar no celular)...")
                time.sleep(args.wait)
            else:
                input("[Pressione ENTER quando estiver na página do NotebookLM] ")

            context.storage_state(path=storage_path)
            print(f"Sessão salva em: {storage_path}")

            dest = _copy_to_project(storage_path)
            if dest:
                print(f"Cópia no projeto: {dest}")
                print("Reinicie o backend para usar a nova sessão (NOTEBOOKLM_AUTH_JSON_FILE=data/notebooklm_auth.json).")
            else:
                print("Copie manualmente o conteúdo de storage_state.json para data/notebooklm_auth.json")
        finally:
            context.close()


if __name__ == "__main__":
    main()
