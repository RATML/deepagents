# Ferramentas locais (fork / ambiente corporativo)

Esta pasta agrupa **scripts e notas que não fazem parte do upstream** do monorepo Deep Agents, mas são úteis neste clone (proxy SSL, Ollama Cloud, Cursor/VS Code, etc.).

| Conteúdo | Descrição |
|----------|-----------|
| `scripts/` | Scripts auxiliares (testes locais, certificados, OAuth, etc.). |
| `certs/` | Documentação e exemplos de CA corporativa; ficheiros `.crt`/`.pem` reais ficam ignorados pelo `.gitignore` da pasta. |
| `deepagents-chat.py` | Cliente de chat mínimo via SDK (workaround quando o CLI ainda não cobria TLS). |
| `deepagents-launcher.ps1` | Arranque do `deepagents` com `.env` na raiz do repo. |
| `test-ollama-connection.ps1` | Teste rápido de ligação. |
## VS Code / Cursor

Para uma tarefa que arranca o CLI com `uv` a partir de `libs/cli`, copie o fragmento em `local/examples/vscode-tasks.json` para o seu `.vscode/tasks.json` (ou use **Tasks: Configure Task** e mescle o JSON).


A configuração suportada pelo produto está documentada em:

`libs/cli/docs/provider-http-tls.md`

Use `~/.deepagents/config.toml` com `[models.providers.openai.http]` em vez de depender só destes scripts, quando possível.

## Caminhos

Os scripts assumem a **raiz do repositório** um nível acima desta pasta (`local/..`) para encontrar `.env`, salvo indicação em contrário no próprio ficheiro.
