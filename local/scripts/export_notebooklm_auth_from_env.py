#!/usr/bin/env python3
"""
Extrai NOTEBOOKLM_AUTH_JSON do .env (mesmo quebrado em 2+ linhas) e grava em data/notebooklm_auth.json.
Uso: python scripts/export_notebooklm_auth_from_env.py
Requer: .env na raiz do projeto com NOTEBOOKLM_AUTH_JSON=... (pode ser em várias linhas).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ENV_PATH = ROOT / ".env"
OUT_PATH = ROOT / "data" / "notebooklm_auth.json"


def main() -> int:
    if not ENV_PATH.exists():
        print(f"Arquivo não encontrado: {ENV_PATH}", file=sys.stderr)
        return 1

    lines = ENV_PATH.read_text(encoding="utf-8", errors="replace").splitlines()
    value_lines: list[str] = []
    started = False

    for line in lines:
        if line.strip().startswith("NOTEBOOKLM_AUTH_JSON="):
            started = True
            value_lines.append(line.split("=", 1)[1].strip())
            continue
        if started:
            value_lines.append(line.strip())
            raw = "".join(value_lines)
            try:
                json.loads(raw)
                break
            except json.JSONDecodeError:
                pass

    raw = "".join(value_lines).strip()
    if not raw.startswith("{"):
        print("NOTEBOOKLM_AUTH_JSON não encontrado ou vazio no .env", file=sys.stderr)
        return 1

    try:
        json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"JSON inválido no .env: {e}", file=sys.stderr)
        return 1

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(raw, encoding="utf-8")
    print(f"Escrito em {OUT_PATH}")
    print("No .env adicione: NOTEBOOKLM_AUTH_JSON_FILE=data/notebooklm_auth.json")
    print("(e opcionalmente comente/remova a linha longa NOTEBOOKLM_AUTH_JSON=...)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
