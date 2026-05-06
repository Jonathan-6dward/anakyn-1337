# 🔍 Deep Eye — Estudo e Aplicação

> Scanner de vulnerabilidades orientado a IA com 45+ vetores de ataque, reconhecimento OSINT e relatórios profissionais.
> Repositório original: [zakirkun/deep-eye](https://github.com/zakirkun/deep-eye)

---

## `> o que é`

Deep Eye é um framework de pentest e scanning de vulnerabilidades **orientado a IA**, que integra múltiplos providers (OpenAI, Claude, Grok, OLLAMA) para geração de payloads inteligentes, análise de contexto e relatórios executivos.

**Por que está aqui:** ferramenta de apoio para análise ofensiva controlada, threat research e Purple Team — visão de como o atacante opera, aplicada diretamente na melhoria de detecção no SOC.

---

## `> arquitetura interna`

```
deep-eye/
├── deep_eye.py          # Entrypoint principal (CLI)
├── setup.py             # Instalação como pacote
├── requirements.txt     # Dependências Python
│
├── core/                # Motor central de scanning
│   ├── scanner.py       # Orquestração do fluxo de scan
│   ├── crawler.py       # Crawling de URLs e endpoints
│   └── session.py       # Gerenciamento de sessão e estado
│
├── ai_providers/        # Integração com LLMs
│   ├── openai_provider.py
│   ├── claude_provider.py
│   ├── grok_provider.py
│   ├── ollama_provider.py
│   └── openrouter_provider.py
│
├── modules/             # Módulos de ataque (45+ vetores)
│   ├── sqli.py          # SQL Injection
│   ├── xss.py           # Cross-Site Scripting
│   ├── ssrf.py          # Server-Side Request Forgery
│   ├── lfi_rfi.py       # Local / Remote File Inclusion
│   ├── ssti.py          # Server-Side Template Injection
│   ├── api_security.py  # OWASP API Top 10 (2023)
│   ├── graphql.py       # GraphQL-specific attacks
│   ├── file_upload.py   # File upload vulnerabilities
│   └── business_logic.py
│
├── utils/               # Funções utilitárias
│   ├── recon.py         # Reconhecimento / OSINT
│   ├── dns_enum.py      # Enumeração de DNS
│   ├── reporter.py      # Geração de relatórios
│   └── notifier.py      # Alertas (Email, Slack, Discord)
│
├── config/              # Configuração
│   ├── config.example.yaml
│   └── config.yaml      # (não versionar — contém API keys)
│
├── templates/           # Templates de relatório (PDF/HTML)
├── examples/            # Exemplos de uso
├── scripts/             # Scripts de instalação
│   ├── install.sh       # Linux/Mac
│   └── install.ps1      # Windows
└── docs/                # Documentação oficial
```

---

## `> módulos de ataque — mapeamento MITRE`

| Módulo | Vetor | MITRE ATT&CK (tática) |
|---|---|---|
| SQLi | Injeção em queries SQL | T1190 — Exploit Public-Facing App |
| XSS | Injeção de scripts no cliente | T1059.007 — JS execution |
| SSRF | Req. forjadas pelo servidor | T1090 — Proxy |
| LFI/RFI | Inclusão de arquivos | T1083 — File Discovery |
| SSTI | Injeção em template engine | T1190 |
| API Security | OWASP API Top 10 2023 | T1190, T1078 |
| GraphQL | Introspection / injection | T1590 — Gather Target Info |
| File Upload | Bypass de validação | T1105 — Ingress Tool Transfer |
| Business Logic | Fluxos de negócio exploráveis | T1078 — Valid Accounts |
| Recon / OSINT | Enumeração passiva e ativa | T1590, T1591, T1596 |

---

## `> fluxo de execução`

```
[Entrada: URL / Config]
        │
        ▼
[Reconhecimento OSINT]
   └── DNS, WHOIS, subdomains, headers, tech fingerprint
        │
        ▼
[Crawling de endpoints]
   └── Mapeamento de superfície de ataque
        │
        ▼
[Seleção de módulos]
   └── Quick Scan ou Full Scan
        │
        ▼
[Geração de payloads via AI]
   └── Provider envia contexto → recebe payloads adaptados
        │
        ▼
[Execução dos testes]
   └── Módulos paralelos por thread
        │
        ▼
[Relatório final]
   └── PDF / HTML / JSON com dados OSINT + findings + score
```

---

## `> providers de AI — quando usar cada um`

| Provider | Modelo padrão | Melhor para |
|---|---|---|
| OpenAI | gpt-4o | Payloads elaborados, contexto longo |
| Claude (Anthropic) | claude-3-5-sonnet | Análise de lógica, relatórios detalhados |
| Grok (xAI) | grok-beta | Alternativa rápida, menor custo |
| OLLAMA | llama2 / mistral | Ambiente offline / air-gapped |
| OpenRouter | openai/gpt-4o | Roteamento entre providers por custo |

> Para lab isolado sem internet: usar **OLLAMA com llama2 ou mistral** — nenhuma API key necessária.

---

## `> setup — ambiente de lab`

### 1. Clonar e instalar

```bash
git clone https://github.com/zakirkun/deep-eye.git
cd deep-eye

# Linux/Mac
chmod +x scripts/install.sh
./scripts/install.sh

# Ou manual
pip install -r requirements.txt
```

### 2. Configurar providers

```bash
cp config/config.example.yaml config/config.yaml
# Editar config.yaml com as API keys desejadas
```

### 3. Executar

```bash
# Scan básico
python deep_eye.py -u https://alvo-autorizado.com

# Scan completo com AI e relatório PDF
python deep_eye.py -u https://alvo-autorizado.com --ai-provider claude --full-scan --format pdf -o report.pdf

# Só reconhecimento OSINT
python deep_eye.py -u https://alvo-autorizado.com --recon --output recon_report.html

# Via proxy (Burp Suite / ZAP)
python deep_eye.py -u https://alvo-autorizado.com --proxy http://127.0.0.1:8080
```

### Parâmetros principais

| Flag | Função |
|---|---|
| `-u` | URL alvo |
| `-d` | Profundidade de crawl (padrão: 2) |
| `-t` | Threads paralelas |
| `--ai-provider` | `openai` / `claude` / `grok` / `ollama` |
| `--recon` | Ativa módulo OSINT |
| `--full-scan` | Todos os módulos ativos |
| `--quick-scan` | Apenas vetores principais |
| `-o` | Arquivo de saída |
| `--format` | `pdf` / `html` / `json` |
| `--proxy` | Proxy para interceptação |

---

## `> integração com o lab SOC`

### Uso ofensivo → melhoria defensiva (Purple Team)

```
Deep Eye detecta SQLi em endpoint X
        │
        ▼
Gera payload + relatório com contexto
        │
        ▼
Verificar se Wazuh/SIEM capturou o evento
        │
        ▼
Se não capturou → criar regra de detecção
        │
        ▼
Re-executar teste → validar detecção
```

### Pontos de integração com Wazuh

- Logs dos scans → ingerir no Wazuh como fonte de eventos
- Correlacionar findings com regras existentes (SQLi, path traversal, etc.)
- Usar relatórios OSINT do Deep Eye para enriquecer contexto de alertas

---

## `> notas de segurança`

```
⚠️  USO EXCLUSIVO EM AMBIENTE CONTROLADO

  ├── Nunca executar contra alvos sem autorização explícita
  ├── Sempre usar em lab isolado ou com escopo definido
  ├── Não versionar config.yaml (contém API keys)
  ├── Para testes em infra própria: documentar escopo antes
  └── Ambiente recomendado: VM isolada ou rede de lab dedicada
```

---

## `> status deste estudo`

| Etapa | Status |
|---|---|
| Análise de arquitetura | ✅ Concluído |
| Setup em lab local | 🔄 Em andamento |
| Mapeamento de módulos → MITRE | ✅ Concluído |
| Testes em ambiente controlado | 📌 Planejado |
| Integração com pipeline Wazuh | 📌 Planejado |
| Notas de detecção (Blue Team) | 📌 Planejado |

---

*Documentação de estudo pessoal — uso em ambiente de laboratório controlado.*
