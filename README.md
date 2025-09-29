# 📨 Templates de E-mail para Escritório de Advocacia

Templates éticos, compatíveis com **OAB** e **LGPD**, prontos para uso com **Jinja2 + Flask**.

## ✅ Recursos
- Templates para clientes, colegas e marketing
- Formulário de consentimento LGPD
- Sistema de descadastro automático
- Rodapé com dados obrigatórios da OAB

## ▶️ Como Usar
1. `pip install -r requirements.txt`
2. `python app.py`
3. Acesse http://localhost:5000/consentimento

> Em produção, use banco de dados e variáveis de ambiente.

## ⚠️ Importante - Segurança

### Configuração de Dados Sensíveis
Este projeto requer um arquivo `config.json` com dados sensíveis do advogado e escritório.

1. Copie `config.json.example` para `config.json`:
   ```bash
   cp config.json.example config.json
   ```

2. Preencha com suas informações reais.

3. **Nunca commite `config.json`** — ele está no `.gitignore`.

### Para Submódulo
Como este repositório é usado como **submódulo** em outros projetos:
- O arquivo `config.json` **deve ser criado e gerenciado no repositório pai**
- Use variável de ambiente `ADVOCACIA_CONFIG` para definir o caminho:
  ```bash
  export ADVOCACIA_CONFIG="/caminho/para/config.json"
  ```

Em produção, falha se `config.json` estiver ausente.