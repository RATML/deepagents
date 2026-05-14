"""
Script de teste para validar configuração de SSL e conectividade com Google API
"""
import os
import sys

print("="*80)
print("TESTE DE CONFIGURAÇÃO - Google Gemini API")
print("="*80)

# 1. Verifica variáveis de ambiente
print("\n1. Verificando variáveis de ambiente:")
print("-"*80)

cert_vars = ['REQUESTS_CA_BUNDLE', 'SSL_CERT_FILE', 'CURL_CA_BUNDLE']
for var in cert_vars:
    value = os.environ.get(var)
    if value:
        exists = os.path.exists(value) if value else False
        status = "✓ OK" if exists else "✗ ARQUIVO NÃO ENCONTRADO"
        print(f"{var:25} = {value}")
        print(f"{'':25}   {status}")
    else:
        print(f"{var:25} = ✗ NÃO CONFIGURADO")

proxy_vars = ['HTTP_PROXY', 'HTTPS_PROXY', 'http_proxy', 'https_proxy']
print("\nProxy:")
for var in proxy_vars:
    value = os.environ.get(var)
    if value:
        print(f"{var:25} = {value}")

# 2. Testa conexão HTTPS básica
print("\n2. Testando conexão HTTPS com requests:")
print("-"*80)

try:
    import requests
    
    # Força o uso do certificado se estiver configurado
    cert_path = os.environ.get('REQUESTS_CA_BUNDLE') or os.environ.get('SSL_CERT_FILE')
    verify_param = cert_path if cert_path and os.path.exists(cert_path) else True
    
    print(f"Usando certificado: {verify_param}")
    
    response = requests.get(
        'https://generativelanguage.googleapis.com',
        timeout=10,
        verify=verify_param
    )
    
    print(f"✓ Status: {response.status_code}")
    print(f"✓ Servidor: {response.headers.get('Server', 'N/A')}")
    print("✓ SSL validado com sucesso!")
    
except requests.exceptions.SSLError as e:
    print(f"✗ ERRO SSL: {e}")
    print("\nSolução:")
    print("1. Verifique se corporate-ca.crt existe no projeto")
    print("2. Feche e reabra o terminal do Cursor")
    print("3. Execute: $env:REQUESTS_CA_BUNDLE")
    sys.exit(1)
    
except requests.exceptions.ConnectionError as e:
    print(f"✗ ERRO DE CONEXÃO: {e}")
    print("\nPossíveis causas:")
    print("1. Proxy não configurado corretamente")
    print("2. Firewall bloqueando a conexão")
    print("3. Sem acesso à internet")
    sys.exit(1)
    
except Exception as e:
    print(f"✗ ERRO: {e}")
    sys.exit(1)

# 3. Testa importação do google-generativeai
print("\n3. Testando importação do google-generativeai:")
print("-"*80)

try:
    import google.generativeai as genai
    print("✓ Biblioteca google-generativeai importada com sucesso")
    
    # Verifica se a API key está configurada
    api_key = os.environ.get('GOOGLE_API_KEY')
    if api_key and api_key != 'your-api-key-here':
        print(f"✓ GOOGLE_API_KEY configurada (comprimento: {len(api_key)})")
        
        # Tenta configurar a API
        try:
            genai.configure(api_key=api_key)
            print("✓ API configurada com sucesso")
            
            # Tenta listar modelos (teste real de conectividade)
            print("\n4. Testando conectividade com API:")
            print("-"*80)
            models = list(genai.list_models())
            print(f"✓ Conectividade OK! {len(models)} modelos disponíveis:")
            for model in models[:3]:  # Mostra apenas os 3 primeiros
                print(f"  - {model.name}")
            if len(models) > 3:
                print(f"  ... e mais {len(models) - 3} modelos")
                
        except Exception as e:
            print(f"✗ Erro ao conectar com API: {e}")
            print("\nVerifique:")
            print("1. GOOGLE_API_KEY está correta")
            print("2. Você tem acesso à internet")
            print("3. O certificado SSL está configurado")
    else:
        print("⚠ GOOGLE_API_KEY não configurada")
        print("  Configure no arquivo .env para testar a API")
        
except ImportError:
    print("✗ google-generativeai não instalado")
    print("  Execute: pip install google-generativeai")
    sys.exit(1)
except Exception as e:
    print(f"✗ Erro: {e}")
    sys.exit(1)

# Resumo final
print("\n" + "="*80)
print("RESUMO DO TESTE")
print("="*80)
print("✓ Configuração de SSL: OK")
print("✓ Conectividade HTTPS: OK")
print("✓ Biblioteca instalada: OK")

api_key = os.environ.get('GOOGLE_API_KEY')
if api_key and api_key != 'your-api-key-here':
    print("✓ API Key configurada: OK")
    print("\n🎉 Tudo pronto! Você pode usar a API do Gemini.")
else:
    print("⚠ API Key: Não configurada")
    print("\n⚠ Configure GOOGLE_API_KEY no arquivo .env para usar a API.")

print("="*80)
