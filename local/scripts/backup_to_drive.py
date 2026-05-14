"""
Script para fazer backup das conversas no Google Drive via API do backend.

Requer o backend rodando (docker-compose up ou uvicorn backend.main:app).

Execute: python scripts/backup_to_drive.py [--url BASE_URL]
"""
import argparse
import sys

try:
    import requests
except ImportError:
    print("Instale: pip install requests")
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Backup das conversas no Google Drive via API")
    parser.add_argument("--url", default="http://localhost:8000", help="URL base do backend")
    args = parser.parse_args()
    base = args.url.rstrip("/")

    print("=" * 80)
    print("BACKUP PARA GOOGLE DRIVE (via API)")
    print("=" * 80)
    print()

    # Health
    try:
        r = requests.get(f"{base}/api/health", timeout=10)
        if r.status_code != 200:
            print(f"❌ Backend retornou {r.status_code}. Inicie com: docker-compose up")
            return 1
    except requests.RequestException as e:
        print(f"❌ Backend inacessível em {base}. Inicie com: docker-compose up")
        print(f"   Erro: {e}")
        return 1

    # Status do Drive
    try:
        r = requests.get(f"{base}/api/drive/status", timeout=10)
        status = r.json() if r.status_code == 200 else {}
        if not status.get("authenticated", False):
            print("❌ Google Drive não autenticado. Faça login na interface (http://localhost:3000).")
            return 1
    except Exception as e:
        print(f"❌ Erro ao verificar status do Drive: {e}")
        return 1

    # Dispara backup
    print("☁️ Fazendo backup...")
    try:
        r = requests.post(f"{base}/api/drive/backup", timeout=60)
        data = r.json() if r.status_code == 200 else {}
        if r.status_code != 200:
            print(f"❌ Falha no backup: {data.get('detail', r.text)}")
            return 1
        saved = data.get("saved_count", 0)
        print(f"✓ Backup realizado com sucesso! ({saved} sessão(ões) enviada(s))")
        if data.get("items"):
            for item in data["items"][:5]:
                print(f"  — {item.get('filename', item.get('file_id', ''))}")
    except requests.RequestException as e:
        print(f"❌ Erro ao chamar backup: {e}")
        return 1

    # Lista backups
    print()
    print("📂 Backups no Google Drive")
    print("-" * 80)
    try:
        r = requests.get(f"{base}/api/drive/backups", timeout=10)
        if r.status_code == 200:
            data = r.json()
            backups = data.get("items", [])
            if backups:
                for i, b in enumerate(backups[:10], 1):
                    name = b.get("name", b.get("id", "—"))
                    print(f"{i}. {name}")
            else:
                print("Nenhum backup listado.")
        else:
            print("Não foi possível listar backups.")
    except Exception:
        pass

    print()
    print("=" * 80)
    print("✓ Concluído.")
    print("=" * 80)
    return 0


if __name__ == "__main__":
    sys.exit(main())
