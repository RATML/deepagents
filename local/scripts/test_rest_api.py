"""
Teste rápido para verificar se REST API funciona
"""
import os
import sys

# Adiciona o diretório raiz ao path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

print("=" * 60)
print("🧪 TESTE: Google Gemini API com REST Transport")
print("=" * 60)

# 1. Verificar variáveis de ambiente
print("\n📋 1. Variáveis de Ambiente:")
print(f"   GOOGLE_API_KEY: {'✓ Configurada' if os.environ.get('GOOGLE_API_KEY') else '✗ Não encontrada'}")
print(f"   HTTP_PROXY: {os.environ.get('HTTP_PROXY', 'Não configurado')}")
print(f"   HTTPS_PROXY: {os.environ.get('HTTPS_PROXY', 'Não configurado')}")
print(f"   SSL_CERT_FILE: {os.environ.get('SSL_CERT_FILE', 'Não configurado')}")
print(f"   GRPC_DEFAULT_SSL_ROOTS_FILE_PATH: {os.environ.get('GRPC_DEFAULT_SSL_ROOTS_FILE_PATH', 'Não configurado')}")

# 2. Testar import
print("\n📦 2. Importando biblioteca...")
try:
    import google.generativeai as genai
    print("   ✓ google.generativeai importado com sucesso")
except ImportError as e:
    print(f"   ✗ Erro ao importar: {e}")
    sys.exit(1)

# 3. Configurar API com REST
print("\n⚙️  3. Configurando API com REST transport...")
try:
    api_key = os.environ.get('GOOGLE_API_KEY')
    if not api_key:
        print("   ✗ GOOGLE_API_KEY não encontrada!")
        sys.exit(1)
    
    # CRÍTICO: Usar transport='rest' em vez de gRPC
    genai.configure(
        api_key=api_key,
        transport='rest'
    )
    print("   ✓ API configurada com REST transport")
except Exception as e:
    print(f"   ✗ Erro ao configurar: {e}")
    sys.exit(1)

# 4. Criar modelo
print("\n🤖 4. Criando modelo...")
try:
    # Usa o modelo mais recente disponível
    model = genai.GenerativeModel('gemini-2.5-flash')
    print(f"   ✓ Modelo 'gemini-2.5-flash' criado")
except Exception as e:
    print(f"   ✗ Erro ao criar modelo: {e}")
    sys.exit(1)

# 5. Testar geração de conteúdo
print("\n💬 5. Testando geração de conteúdo...")
try:
    response = model.generate_content("Responda apenas: OK")
    print(f"   ✓ Resposta recebida: {response.text}")
except Exception as e:
    print(f"   ✗ Erro ao gerar conteúdo: {e}")
    print(f"   Tipo do erro: {type(e).__name__}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

# 6. Listar modelos (opcional)
print("\n📋 6. Listando modelos disponíveis...")
try:
    models = list(genai.list_models())
    print(f"   ✓ {len(models)} modelos disponíveis")
    for model in models[:3]:  # Mostra apenas os 3 primeiros
        print(f"      - {model.name}")
except Exception as e:
    print(f"   ⚠️  Aviso ao listar modelos: {e}")
    print("   (Isso não é crítico, a API pode estar funcionando mesmo assim)")

print("\n" + "=" * 60)
print("✅ SUCESSO! API REST funcionando corretamente!")
print("=" * 60)
