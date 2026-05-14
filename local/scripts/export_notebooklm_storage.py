#!/usr/bin/env python3
"""
Exporta storage_state.json a partir do browser_profile do notebooklm.
Use se você já fez login (notebooklm login) mas não pressionou ENTER e só ficou o browser_profile.

Requer: pip install "notebooklm-py[browser]"
Execute na raiz do projeto ou com PYTHONPATH: python scripts/export_notebooklm_storage.py
"""
from __future__ import annotations

import os
import sys

def main() -> None:
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("Instale o Playwright: pip install 'notebooklm-py[browser]'", file=sys.stderr)
        sys.exit(1)

    home = os.path.expanduser("~")
    profile_dir = os.path.join(home, ".notebooklm", "browser_profile")
    out_path = os.path.join(home, ".notebooklm", "storage_state.json")

    if not os.path.isdir(profile_dir):
        print(f"Pasta não encontrada: {profile_dir}", file=sys.stderr)
        print("Rode antes: notebooklm login (e faça login no navegador).", file=sys.stderr)
        sys.exit(1)

    print("Abrindo perfil do navegador (pode abrir uma janela brevemente)...")
    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            profile_dir,
            headless=True,
            args=["--disable-gpu", "--no-sandbox"],
        )
        try:
            context.storage_state(path=out_path)
            print(f"Salvo: {out_path}")
        finally:
            context.close()

if __name__ == "__main__":
    main()
