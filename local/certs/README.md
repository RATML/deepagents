# 🔒 Certificados SSL Corporativos

## 📋 O que é esta pasta?

Esta pasta contém os certificados SSL necessários para ambientes corporativos com **SSL Inspection** (Netskope, Zscaler, etc.).

---

## 📁 Arquivos

### `corporate-ca.crt` (SEU CERTIFICADO)
- **Status**: ❌ Não commitado (está no .gitignore)
- **Obrigatório**: ✅ Sim, para ambientes corporativos
- **Como obter**: Veja instruções abaixo ⬇️

### `corporate-ca.crt.example`
- **Status**: ✅ Exemplo (commitado)
- **Propósito**: Template/referência
- **Não usar**: Este é apenas um exemplo

---

## 🚀 Como Obter Seu Certificado

### Método 1: PowerShell (Windows) - RECOMENDADO

```powershell
# Execute no PowerShell (na raiz do projeto)
$tcpClient = New-Object System.Net.Sockets.TcpClient("generativelanguage.googleapis.com", 443)
$sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false)
$sslStream.AuthenticateAsClient("generativelanguage.googleapis.com")
$cert = $sslStream.RemoteCertificate
[System.IO.File]::WriteAllBytes("local/certs/corporate-ca.crt", $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert))
$sslStream.Close()
$tcpClient.Close()
Write-Host "✓ Certificado salvo em local/certs/corporate-ca.crt"
```

### Método 2: OpenSSL (Linux/Mac)

```bash
# Extrair certificado
echo | openssl s_client -showcerts -servername generativelanguage.googleapis.com \
  -connect generativelanguage.googleapis.com:443 2>/dev/null | \
  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > local/certs/corporate-ca.crt

echo "✓ Certificado salvo em local/certs/corporate-ca.crt"
```

### Método 3: Navegador (Manual)

1. Acesse https://generativelanguage.googleapis.com no navegador
2. Clique no cadeado 🔒 na barra de endereço
3. "Certificado" ou "Certificate"
4. Vá para a aba "Detalhes" ou "Details"
5. Selecione o certificado **raiz** (Root CA)
6. Exportar como `.crt` ou `.pem`
7. Salve como `local/certs/corporate-ca.crt`

---

## ⚙️ Configuração

### 1. Arquivo `.env`

O `.env` já está configurado para usar a pasta `local/certs/`:

```bash
# SSL Certificate Configuration
REQUESTS_CA_BUNDLE=./local/certs/corporate-ca.crt
SSL_CERT_FILE=./local/certs/corporate-ca.crt
CURL_CA_BUNDLE=./local/certs/corporate-ca.crt
```

### 2. Docker Compose

O `docker-compose.yaml` monta o certificado automaticamente:

```yaml
volumes:
  - ./local/certs/corporate-ca.crt:/usr/local/share/ca-certificates/corporate-ca.crt:ro
```

### 3. VS Code / Cursor

O `.vscode/settings.json` usa o caminho correto:

```json
"terminal.integrated.env.windows": {
  "SSL_CERT_FILE": "${workspaceFolder}\\local\\certs\\corporate-ca.crt",
  "REQUESTS_CA_BUNDLE": "${workspaceFolder}\\local\\certs\\corporate-ca.crt"
}
```

---

## ✅ Verificar Instalação

### Verificar se o arquivo existe

```bash
# Windows (PowerShell)
Test-Path local/certs/corporate-ca.crt

# Linux/Mac
ls -la local/certs/corporate-ca.crt
```

### Verificar conteúdo do certificado

```bash
# Windows (certutil)
certutil -dump local/certs/corporate-ca.crt

# Linux/Mac (openssl)
openssl x509 -in local/certs/corporate-ca.crt -text -noout
```

---

## 🐛 Troubleshooting

### Erro: "SSL Certificate Verify Failed"

**Causa**: Certificado não configurado ou inválido

**Solução**:
1. Verifique se `local/certs/corporate-ca.crt` existe
2. Extraia novamente usando os métodos acima
3. Reinicie o Docker: `docker-compose restart`

### Erro: "File not found"

**Causa**: Certificado não está na pasta correta

**Solução**:
```bash
# Verifique o caminho
ls local/certs/

# Deve mostrar: corporate-ca.crt
```

### Certificado Expirado

**Causa**: Certificado corporativo foi renovado

**Solução**:
1. Delete o certificado antigo: `rm local/certs/corporate-ca.crt`
2. Extraia novamente usando Método 1 ou 2
3. Reinicie: `docker-compose restart`

---

## 🔒 Segurança

### ✅ Boas Práticas

- ✅ Certificado está no `.gitignore` (não será commitado)
- ✅ Montado como read-only (`:ro`) no Docker
- ✅ Usado apenas para validação SSL
- ✅ Não contém informações sensíveis

### ⚠️ Importante

- **NÃO** commite `corporate-ca.crt` no Git
- **NÃO** compartilhe o certificado publicamente
- **SIM** extraia novamente se expirar
- **SIM** use o certificado correto da sua empresa

---

## 📚 Documentação Relacionada

- **[docs/GRPC_SSL_FIX.md](../docs/GRPC_SSL_FIX.md)** - Fix de SSL com gRPC
- **[docs/NETSKOPE_GRPC.md](../docs/NETSKOPE_GRPC.md)** - Netskope específico
- **[docs/SSL_DOCKER_BUILD.md](../docs/SSL_DOCKER_BUILD.md)** - SSL no Docker build
- **[docs/PROXY_CONFIGURATION.md](../docs/PROXY_CONFIGURATION.md)** - Configuração de proxy

---

## 🎯 Estrutura da Pasta

```
local/certs/
├── README.md                       # Este arquivo
├── corporate-ca.crt                # SEU certificado (não commitado)
├── corporate-ca.crt.example        # Exemplo (commitado)
└── .gitignore                      # Ignora *.crt (exceto .example)
```

---

## 🔗 Links Úteis

- **Documentação SSL**: https://docs.python.org/3/library/ssl.html
- **Requests CA Bundle**: https://requests.readthedocs.io/en/latest/user/advanced/#ssl-cert-verification
- **Docker Certificates**: https://docs.docker.com/engine/security/certificates/

---

**Última Atualização**: 2026-02-11  
**Status**: ✅ Organizado
