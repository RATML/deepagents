# Scripts do projeto

## Rodar todos os testes

- **CMD:** `local\scripts\run_tests.bat`
- **PowerShell:** `.\local\scripts\run_tests.ps1`  
  Com instalação prévia de dependências: `.\local\scripts\run_tests.ps1 -InstallDeps`

## Verificar Node.js no PATH

- **CMD:** `local\scripts\check_node_install.bat`
- **PowerShell:** `.\local\scripts\check_node_install.ps1`

## Relatório de cobertura (HTML)

Para gerar o relatório HTML e ver **o que está descoberto** (linhas sem testes):

- **No Cursor/VS Code:** `Ctrl+Shift+P` → "Tasks: Run Task" → **"Backend: coverage report (HTML)"**
- **No terminal (raiz do projeto):**
  ```bash
  python -m coverage run -m pytest backend/tests/ -v --tb=short
  python -m coverage html
  ```
  Depois abra **`htmlcov/index.html`** no navegador. Cada arquivo mostra linhas em verde (cobertas) e vermelho (descobertas).

---

## Erro: "A execução de scripts foi desabilitada" (PowerShell)

No Windows, o PowerShell pode estar com a política de execução **Restricted**, que bloqueia scripts `.ps1`.

### Opção 1 – Rodar só esta vez (Bypass)

```powershell
powershell -ExecutionPolicy Bypass -File .\local\scripts\check_node_install.ps1
```

(ou o caminho completo do script)

### Opção 2 – Liberar para seu usuário (recomendado)

Abra o PowerShell **como administrador** (ou não, se usar `-Scope CurrentUser`) e execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- **RemoteSigned:** scripts locais (`.ps1` no seu PC) podem rodar; scripts baixados da internet precisam ser assinados.
- Depois disso, `.\local\scripts\check_node_install.ps1` e `.\local\scripts\run_tests.ps1` passam a funcionar normalmente.

### Opção 3 – Usar o .bat em vez do .ps1

Para o check do Node, use no CMD ou no PowerShell:

```cmd
local\scripts\check_node_install.bat
```

Assim você não depende da política de execução do PowerShell.

---

## Instalar dependências do frontend (npm install)

Se o script de testes avisar que `node_modules` não foi encontrado:

- **No CMD:**
  ```cmd
  cd frontend
  npm install
  ```
  ou em uma linha: `cd frontend && npm install`

- **No PowerShell:**
  ```powershell
  cd frontend; npm install
  ```
  No PowerShell o operador para encadear comandos é `;` (não `&&`).

Depois rode o script de testes de novo.
