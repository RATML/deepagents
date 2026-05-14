# HTTP/TLS por provider no `config.toml`

Este documento descreve as alterações que permitem configurar o cliente HTTP usado pelo provider **`openai`** no Deep Agents CLI (por exemplo, APIs compatíveis com OpenAI, incluindo **Ollama Cloud**), com foco em ambientes com proxy SSL corporativo (MITM).

## Objetivo

- Sem configuração extra, o comportamento permanece o de sempre (sem clientes `httpx` injetados pelo CLI).
- Com a tabela opcional **`[models.providers.openai.http]`**, o CLI cria `httpx.Client` e `httpx.AsyncClient` e repassa-os ao `langchain-openai` via `init_chat_model`, permitindo:
  - desativar verificação SSL (`verify_ssl = false`), ou
  - usar um bundle de CA customizado (`ca_bundle`), e opcionalmente
  - ajustar `timeout` e `trust_env`.

## Onde configurar

Arquivo padrão do usuário:

`%USERPROFILE%\.deepagents\config.toml` (Windows)  
`~/.deepagents/config.toml` (Unix)

## Schema TOML

### Bloco do provider (ex.: Ollama Cloud como OpenAI-compatible)

```toml
[models]
default = "openai:minimax-m2.7:cloud"

[models.providers.openai]
enabled = true
base_url = "https://ollama.com/v1"
api_key_env = "OLLAMA_API_KEY"
models = [
  "minimax-m2.7:cloud",
  "kimi-k2.6:cloud",
  "glm-5.1:cloud",
  "deepseek-v4-pro:cloud",
]

[models.providers.openai.params]
temperature = 0
# Ollama Cloud não usa a Responses API da OpenAI; desative se o perfil padrão a ativar.
use_responses_api = false
```

### Tabela `http` (opcional)

```toml
[models.providers.openai.http]
verify_ssl = false   # inseguro; use só quando necessário (ex.: MITM sem CA confiável)
# ca_bundle = "C:/caminho/para/corporate-ca.crt"  # alternativa preferível a verify_ssl = false
timeout = 60
trust_env = false
```

| Chave | Tipo | Efeito |
|--------|------|--------|
| `verify_ssl` | bool | Se `false`, `httpx` usa `verify=False`. |
| `ca_bundle` | string (caminho) | Caminho para arquivo PEM de CA; usado como `verify=<caminho>`. Ignorado se `verify_ssl` for `false`. |
| `timeout` | número | Repassado ao `httpx` (`timeout`). |
| `trust_env` | bool | Repassado ao `httpx` (`trust_env`). |

**Precedência:** se `verify_ssl = false`, o CLI define `verify=False` e não usa `ca_bundle` para esse caso.

## Comportamento no código

- **`ModelConfig.get_http_options(provider)`** em `deepagents_cli/model_config.py` devolve o dicionário da sub-tabela `http` do provider, ou `{}` se ausente.
- **`_get_provider_kwargs()`** em `deepagents_cli/config.py` chama **`_apply_provider_http_options`**, que hoje só atua quando `provider == "openai"`. Se houver opções HTTP efetivas, adiciona `http_client` e `http_async_client` ao kwargs do modelo.
- Com `verify_ssl = false`, o CLI registra um **aviso** nos logs: SSL desativado por configuração.

## Variáveis de ambiente

- A chave continua vindo da variável indicada em `api_key_env` (ex.: `OLLAMA_API_KEY`), com a mesma regra de precedência `DEEPAGENTS_CLI_*` já documentada no projeto.

## Testes

Em `libs/cli/tests/unit_tests/test_model_config.py`:

- `TestModelConfigGetHttpOptions` — parsing de `[models.providers.openai.http]`.
- `TestProviderHttpKwargs` — ausência de clientes HTTP por padrão; presença e kwargs quando `verify_ssl = false` (com `httpx` monkeypatched nos asserts).

## Execução e avisos práticos

1. **Python do projeto:** use o interpretador do ambiente onde o `deepagents-cli` está instalado (ex.: `libs/cli/.venv` após `uv sync`), para alinhar dependências com o LangGraph/SDK.
2. **Modo não interativo (`-n`):** em ambientes em que o stdin não é um TTY e fica “aberto”, o CLI pode esperar leitura de pipe; nesses casos, envie EOF explícito, por exemplo no PowerShell: `"" | python -m deepagents_cli -n "..."`.
3. **`verify_ssl = false`:** reduz segurança; prefira `ca_bundle` com a cadeia corporativa correta quando possível.

## Arquivos alterados (referência)

| Arquivo | Alteração |
|---------|-----------|
| `libs/cli/deepagents_cli/model_config.py` | Campo `http` em `ProviderConfig`; método `ModelConfig.get_http_options()`. |
| `libs/cli/deepagents_cli/config.py` | `_http_client_kwargs_from_options`, `_apply_provider_http_options`, chamada em `_get_provider_kwargs`. |
| `libs/cli/tests/unit_tests/test_model_config.py` | Testes para `http` e kwargs HTTP. |

A cópia local de `~/.deepagents/config.toml` do desenvolvedor (Ollama Cloud + `http`) não faz parte do repositório; use os exemplos deste documento para reproduzir.
