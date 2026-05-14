# 🔐 Certificado Corporativo - Setup Obrigatório

## ⚠️ IMPORTANTE

O arquivo `local/certs/corporate-ca.crt` atual é apenas um **exemplo**. Você precisa substituí-lo pelo certificado **real** da sua empresa para o OAuth funcionar!

---

## 🚀 Método Rápido (PowerShell)

Execute o script automático:

```powershell
.\local\scripts\extract_certificate.ps1
```

Este script tentará extrair o certificado automaticamente do site do Google.

---

## 🔧 Método Manual (Navegador)

### Passo 1: Abrir o Navegador

1. Abra **Chrome** ou **Edge**
2. Acesse: https://generativelanguage.googleapis.com

### Passo 2: Ver Certificado

1. Clique no **cadeado 🔒** na barra de endereço
2. Clique em **"Certificado"** ou **"A conexão é segura"**
3. Clique em **"Certificado (válido)"**

### Passo 3: Encontrar Certificado Raiz

1. Vá na aba **"Caminho de Certificação"**
2. Você verá uma árvore de certificados:
   ```
   [Certificado Raiz da Empresa]  ← ESTE É O QUE VOCÊ QUER!
   └── [Certificado Intermediário]
       └── [generativelanguage.googleapis.com]
   ```
3. Selecione o certificado do **TOPO** (raiz)
4. Clique em **"Exibir Certificado"**

### Passo 4: Exportar Certificado

1. Vá na aba **"Detalhes"**
2. Clique em **"Copiar para Arquivo..."**
3. Assistente de Exportação:
   - Formato: **"X.509 codificado em Base-64 (.CER)"**
   - Nome do arquivo: `corporate-ca.crt`
   - Salvar em: `c:\Repos\ProjectGem\certs\`

### Passo 5: Verificar Arquivo

Abra o arquivo `certs\corporate-ca.crt` e verifique se tem este formato:

```
-----BEGIN CERTIFICATE-----
MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJ
... (várias linhas de código Base64) ...
-----END CERTIFICATE-----
```

### Passo 6: Rebuildar Container

```bash
docker-compose down
docker-compose up --build -d
```

---

## 🔍 Como Saber Qual Certificado Usar?

### Opção 1: Perguntar ao TI

Entre em contato com o departamento de TI e peça:
- "Certificado raiz da empresa para SSL inspection"
- "CA certificate para desenvolvimento"

### Opção 2: Verificar no Windows

1. Pressione **Win + R**
2. Digite: `certmgr.msc`
3. Vá em **"Autoridades de Certificação Raiz Confiáveis"** → **"Certificados"**
4. Procure por certificados com nomes como:
   - Zscaler
   - Netskope
   - BlueCoat
   - Forcepoint
   - Nome da sua empresa
5. Clique com botão direito → **"Todas as Tarefas"** → **"Exportar..."**
6. Formato: **"X.509 codificado em Base-64 (.CER)"**

---

## 🐛 Troubleshooting

### Erro: "certificate verify failed"

**Causa**: O certificado em `local/certs/corporate-ca.crt` é o exemplo, não o real.

**Solução**: Substitua pelo certificado real da sua empresa.

### Erro: "self-signed certificate in certificate chain"

**Causa**: Sua empresa usa SSL inspection (proxy intercepta HTTPS).

**Solução**: Use o certificado raiz do proxy (Zscaler, Netskope, etc.).

### Como saber se está correto?

Execute dentro do container:

```bash
docker-compose exec gemini-app curl -I https://generativelanguage.googleapis.com
```

Se retornar `HTTP/2 200`, o certificado está correto! ✅

---

## 📊 Estrutura do Certificado

### Exemplo (placeholder) ❌
```
-----BEGIN CERTIFICATE-----
PLACE YOUR CORPORATE CA CERTIFICATE HERE
-----END CERTIFICATE-----
```

### Real (sua empresa) ✅
```
-----BEGIN CERTIFICATE-----
MIIDdzCCAl+gAwIBAgIEAgAAuTANBgkqhkiG9w0BAQUFADBaMQswCQYDVQQGEwJJ
RVMxEjAQBgNVBAoTCVpzY2FsZXIgSW5jLjEQMA4GA1UECxMHWnNjYWxlcjEVMBMG
... (muitas linhas) ...
-----END CERTIFICATE-----
```

---

## 🔒 Segurança

### ✅ É seguro?

Sim! O certificado corporativo é:
- Público (não é secreto)
- Necessário para validar SSL
- Usado apenas para confiar na inspeção SSL da empresa

### ❌ NÃO versionar

O `.gitignore` já está configurado para não versionar:
```
local/certs/*.crt
local/certs/*.pem
```

Mas o certificado corporativo **pode** ser versionado se for um projeto interno da empresa.

---

## 🎯 Resumo

### Estado Atual ❌
```
local/certs/corporate-ca.crt = EXEMPLO (não funciona)
```

### Estado Desejado ✅
```
local/certs/corporate-ca.crt = CERTIFICADO REAL da empresa
```

### Como Corrigir
```
1. Extrair certificado real (script ou manual)
2. Salvar em: local/certs/corporate-ca.crt
3. Rebuildar: docker-compose up --build -d
4. Testar OAuth: http://localhost:8501
```

---

## 📚 Referências

- **Script automático**: `local/scripts/extract_certificate.ps1`
- **Documentação SSL**: `docs/SSL_DOCKER_BUILD.md`
- **Troubleshooting**: `docs/troubleshooting/TROUBLESHOOTING_DOCKER.md`

---

**Execute o script ou extraia manualmente o certificado real!** 🔐✨
