# Notas de Detecção — Blue Team

> O que o Deep Eye gera e como detectar no SIEM

---

## Assinaturas por módulo

### SQLi
```
Padrões nos logs de acesso:
  - ' OR '1'='1
  - UNION SELECT
  - --  (comentário SQL inline)
  - %27 (URL-encoded quote)

Wazuh rule ID a criar:
  - group: web_attack, sqli
  - regex: UNION\s+SELECT|OR\s+'1'='1|--\s*$
```

### XSS
```
Padrões:
  - <script>, alert(, onerror=
  - %3Cscript%3E (URL-encoded)
  - javascript: em parâmetros

Wazuh:
  - group: web_attack, xss
  - regex: <script|javascript:|onerror=|onload=
```

### SSRF
```
Padrões:
  - Requisições para 169.254.169.254 (AWS metadata)
  - Requisições para 127.0.0.1 / localhost via parâmetro
  - file:// ou dict:// em parâmetros de URL

Wazuh:
  - group: web_attack, ssrf
  - Monitorar outbound para IPs internos vindos de processo web
```

### Path Traversal / LFI
```
Padrões:
  - ../../../etc/passwd
  - %2e%2e%2f (URL-encoded)
  - ../ repetido em parâmetro de arquivo

Wazuh:
  - group: web_attack, lfi
  - regex: \.\.\/|%2e%2e%2f|etc\/passwd
```

### Scan de headers / fingerprint
```
User-Agent característico do Deep Eye ou scanners genéricos
Alto volume de requisições com User-Agents variados
Requisições OPTIONS / HEAD em sequência rápida
```

---

## Indicadores gerais de scan automatizado

```
├── Alto volume de 404/403/500 em curto intervalo
├── Crawling sequencial de endpoints (padrão de spider)
├── Múltiplos parâmetros testados no mesmo endpoint
├── User-Agent contendo: python-requests, scanner, deepeye
└── Intervalo entre requisições < 100ms (threshold humano)
```

---

## KQL para Microsoft Sentinel

```kql
// Detectar possível SQLi nos logs de WAF ou IIS
AzureDiagnostics
| where Category == "ApplicationGatewayFirewallLog"
| where action_s == "Blocked" or ruleSetType_s contains "OWASP"
| where details_message_s contains "SQL" or details_message_s contains "UNION"
| summarize Count = count() by clientIp_s, requestUri_s, bin(TimeGenerated, 1h)
| where Count > 10
```

```kql
// Alto volume de 4xx de um mesmo IP (possível scan)
W3CIISLog
| where scStatus between (400 .. 499)
| summarize ReqCount = count() by cIP, bin(TimeGenerated, 5m)
| where ReqCount > 50
| order by ReqCount desc
```

---

## Regras Wazuh (exemplo)

```xml
<!-- SQLi Detection -->
<rule id="100200" level="10">
  <if_matched_sid>31103</if_matched_sid>
  <regex>UNION.SELECT|OR.'1'='1|--\s*$|%27|%3D</regex>
  <description>Possible SQL Injection attempt detected</description>
  <group>web_attack,sqli,pci_dss_6.5.1,</group>
</rule>

<!-- Path Traversal -->
<rule id="100201" level="10">
  <if_matched_sid>31103</if_matched_sid>
  <regex>\.\.\/|\.\.\\|%2e%2e%2f|etc\/passwd|proc\/self</regex>
  <description>Possible Path Traversal / LFI attempt</description>
  <group>web_attack,lfi,pci_dss_6.5.1,</group>
</rule>
```

---

*Atualizar conforme testes no lab evoluem.*
