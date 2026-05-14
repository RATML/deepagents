"""
Lista todos os modelos disponíveis na API
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

print("=" * 60)
print("📋 Listando Modelos Disponíveis")
print("=" * 60)

import google.generativeai as genai

# Configurar API com REST
api_key = os.environ.get('GOOGLE_API_KEY')
genai.configure(api_key=api_key, transport='rest')

print("\n🔍 Buscando modelos...")
try:
    models = list(genai.list_models())
    print(f"\n✓ {len(models)} modelos encontrados:\n")
    
    for model in models:
        print(f"📦 {model.name}")
        print(f"   Display Name: {model.display_name}")
        print(f"   Supported Methods: {', '.join(model.supported_generation_methods)}")
        print()
        
except Exception as e:
    print(f"✗ Erro: {e}")
    import traceback
    traceback.print_exc()
