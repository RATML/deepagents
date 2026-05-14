"""
Validação de setup: proxy, SSL e conectividade com o backend.

Requer o backend rodando (docker-compose up ou uvicorn backend.main:app).
Usa backend.config quando possível; testes de API via HTTP.
"""
import os
import sys
import logging
from pathlib import Path
from typing import Dict, Any

# Raiz do repositório (este ficheiro está em local/scripts/)
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(_REPO_ROOT))

logging.basicConfig(level=logging.INFO, format="%(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")


def print_section(title: str) -> None:
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80)


def print_result(test_name: str, passed: bool, message: str = "") -> None:
    status = "[PASS]" if passed else "[FAIL]"
    print(f"{status} - {test_name}")
    if message:
        print(f"       {message}")


def test_environment_variables() -> Dict[str, Any]:
    print_section("TEST 1: Environment Variables")
    results = {}
    http_proxy = os.getenv("HTTP_PROXY") or os.getenv("http_proxy")
    https_proxy = os.getenv("HTTPS_PROXY") or os.getenv("https_proxy")
    results["http_proxy"] = bool(http_proxy)
    print_result("HTTP_PROXY set", results["http_proxy"], http_proxy or "Not set")
    results["https_proxy"] = bool(https_proxy)
    print_result("HTTPS_PROXY set", results["https_proxy"], https_proxy or "Not set")
    ssl_cert = os.getenv("SSL_CERT_FILE")
    requests_ca = os.getenv("REQUESTS_CA_BUNDLE")
    results["ssl_cert_file"] = bool(ssl_cert)
    print_result("SSL_CERT_FILE set", results["ssl_cert_file"], ssl_cert or "Not set")
    results["requests_ca_bundle"] = bool(requests_ca)
    print_result("REQUESTS_CA_BUNDLE set", results["requests_ca_bundle"], requests_ca or "Not set")
    api_key = os.getenv("GOOGLE_API_KEY")
    results["api_key"] = bool(api_key) and len(api_key or "") > 20
    print_result("GOOGLE_API_KEY set", results["api_key"], f"Length: {len(api_key or '')}")
    return results


def test_ssl_certificate() -> Dict[str, Any]:
    print_section("TEST 2: SSL Certificate")
    results = {}
    cert_paths = [
        "/usr/local/share/ca-certificates/corporate-ca.crt",
        "./corporate-ca.crt",
        str(_REPO_ROOT / "local" / "certs" / "corporate-ca.crt"),
        os.getenv("SSL_CERT_FILE"),
    ]
    cert_found = False
    cert_path = None
    for path in cert_paths:
        if path and os.path.exists(path):
            cert_found = True
            cert_path = path
            break
    results["cert_exists"] = cert_found
    print_result("Certificate file exists", cert_found, cert_path or "Not found")
    if cert_found and cert_path:
        try:
            with open(cert_path) as f:
                content = f.read()
            results["cert_valid"] = "BEGIN CERTIFICATE" in content
            print_result("Certificate format valid", results["cert_valid"])
        except Exception as e:
            results["cert_valid"] = False
            print_result("Certificate readable", False, str(e))
    return results


def test_configuration() -> Dict[str, Any]:
    print_section("TEST 3: Backend Configuration")
    results = {}
    try:
        from backend.config import settings
        results["config_loaded"] = True
        print_result("Config module loaded", True)
        results["proxy_configured"] = bool(settings.proxy_dict)
        print_result("Proxy configured", results["proxy_configured"], str(settings.proxy_dict))
        results["api_key_configured"] = bool(settings.google_api_key)
        print_result("API key configured", results["api_key_configured"])
    except Exception as e:
        results["config_loaded"] = False
        print_result("Config module loaded", False, str(e))
    return results


def test_network_connectivity() -> Dict[str, Any]:
    print_section("TEST 4: Network Connectivity")
    results = {}
    try:
        import requests
        session = requests.Session()
        try:
            from backend.config import settings
            if settings.proxy_dict:
                session.proxies.update(settings.proxy_dict)
            if getattr(settings, "requests_verify_path", None) and os.path.exists(settings.requests_verify_path):
                session.verify = settings.requests_verify_path
        except Exception:
            pass
        try:
            r = session.get("https://www.google.com", timeout=10)
            results["google_reachable"] = r.status_code == 200
            print_result("Google.com reachable", results["google_reachable"], f"Status: {r.status_code}")
        except Exception as e:
            results["google_reachable"] = False
            print_result("Google.com reachable", False, str(e))
        try:
            r = session.get("https://generativelanguage.googleapis.com", timeout=10)
            results["gemini_endpoint_reachable"] = r.status_code in [200, 404]
            print_result("Gemini API endpoint reachable", results["gemini_endpoint_reachable"], f"Status: {r.status_code}")
        except Exception as e:
            results["gemini_endpoint_reachable"] = False
            print_result("Gemini API endpoint reachable", False, str(e))
    except Exception as e:
        results["network_test_failed"] = True
        print_result("Network test", False, str(e))
    return results


def test_backend_health() -> Dict[str, Any]:
    print_section("TEST 5: Backend API Health")
    results = {}
    try:
        import requests
        r = requests.get(f"{BACKEND_URL.rstrip('/')}/api/health", timeout=10)
        data = r.json() if r.status_code == 200 else {}
        results["backend_reachable"] = r.status_code == 200
        print_result("Backend reachable", results["backend_reachable"], f"Status: {r.status_code}")
        results["health_ok"] = data.get("status") == "healthy"
        print_result("Health status healthy", results["health_ok"], str(data.get("status", data)))
    except Exception as e:
        results["backend_reachable"] = False
        results["health_ok"] = False
        print_result("Backend health", False, f"Inicie o backend: docker-compose up. Erro: {e}")
    return results


def test_simple_chat() -> Dict[str, Any]:
    print_section("TEST 6: Chat via API")
    results = {}
    try:
        import requests
        r = requests.post(
            f"{BACKEND_URL.rstrip('/')}/api/chat",
            json={"message": "Say 'Hello' in one word.", "model": "gemini-2.5-flash"},
            timeout=30,
        )
        data = r.json() if r.status_code == 200 else {}
        results["chat_works"] = r.status_code == 200 and bool(data.get("text", "").strip())
        print_result("Chat via API", results["chat_works"], data.get("text", str(data))[:80] if data else r.text[:80])
    except Exception as e:
        results["chat_works"] = False
        print_result("Chat via API", False, str(e))
    return results


def main() -> int:
    print("\n" + "=" * 80)
    print("  GEMINI PHANTOM — SETUP VALIDATION")
    print("  Testing proxy, SSL, and API connectivity")
    print("=" * 80)

    all_results = {}
    all_results["env"] = test_environment_variables()
    all_results["ssl"] = test_ssl_certificate()
    all_results["config"] = test_configuration()
    all_results["network"] = test_network_connectivity()
    all_results["backend"] = test_backend_health()
    all_results["chat"] = test_simple_chat()

    print_section("SUMMARY")
    total_tests = sum(len(r) for r in all_results.values())
    passed_tests = sum(sum(1 for v in r.values() if v) for r in all_results.values())
    print(f"\nTotal Tests: {total_tests}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {total_tests - passed_tests}")
    success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
    print(f"Success Rate: {success_rate:.1f}%")

    if success_rate == 100:
        print("\nAll tests passed! Your setup is ready to use.")
        return 0
    if success_rate >= 80:
        print("\nMost tests passed. Check failed tests above.")
        return 0
    print("\nMultiple tests failed. Please review configuration.")
    print("1. Check .env file and GOOGLE_API_KEY")
    print("2. Verify certificate if in corporate network")
    print("3. Start backend: docker-compose up")
    return 1


if __name__ == "__main__":
    sys.exit(main())
