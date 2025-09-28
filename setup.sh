# Cria diretórios
mkdir -p templates/cliente templates/marketing templates/colega templates/consentimento static data preview

# app.py
cat > app.py << 'EOF'
import os
import json
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash
from jinja2 import Environment, FileSystemLoader

app = Flask(__name__)
app.secret_key = 'sua-chave-secreta-aqui'

DATA_DIR = os.path.join(os.path.dirname(__file__), 'data')
PROSPECTS_FILE = os.path.join(DATA_DIR, 'prospects.json')

os.makedirs(DATA_DIR, exist_ok=True)
if not os.path.exists(PROSPECTS_FILE):
    with open(PROSPECTS_FILE, 'w') as f:
        json.dump([], f)

def load_prospects():
    with open(PROSPECTS_FILE, 'r') as f:
        return json.load(f)

def save_prospects(data):
    with open(PROSPECTS_FILE, 'w') as f:
        json.dump(data, f, indent=2)

BASE_CONTEXT = {
    "advogado": {"nome": "Dra. Juliana Almeida", "oab": "98765", "estado": "RJ"},
    "escritorio": {
        "nome": "Almeida & Associados Advogados",
        "endereco": "Rua do Ouvidor, 50 - Centro, Rio de Janeiro/RJ",
        "telefone": "(21) 3333-4444",
        "email": "contato@almeidaadvocacia.com.br",
        "site": "https://almeidaadvocacia.com.br",
        "logo_url": None
    },
    "now": datetime.now()
}

@app.route('/')
def index():
    return redirect(url_for('consent_form'))

@app.route('/consentimento', methods=['GET', 'POST'])
def consent_form():
    areas = ["Direito Civil", "Direito Empresarial", "Direito do Trabalho", "Direito de Família", "Direito Tributário", "LGPD e Proteção de Dados"]
    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        area = request.form.get('area', '')
        consent = request.form.get('consent') == 'on'

        if not email or '@' not in email:
            flash('Por favor, informe um e-mail válido.', 'error')
            return render_template('consentimento/formulario.html', areas=areas)
        if not consent:
            flash('É necessário aceitar o tratamento de dados.', 'error')
            return render_template('consentimento/formulario.html', areas=areas)

        prospects = load_prospects()
        if not any(p['email'] == email for p in prospects):
            prospects.append({"email": email, "area_interesse": area, "data_consentimento": datetime.now().isoformat(), "ativo": True})
            save_prospects(prospects)
            flash('Obrigado! Seu cadastro foi realizado com sucesso.', 'success')
        else:
            flash('Este e-mail já está cadastrado.', 'info')
        return redirect(url_for('consent_form'))
    return render_template('consentimento/formulario.html', areas=areas)

@app.route('/unsubscribe')
def unsubscribe():
    email = request.args.get('email', '').strip().lower()
    if not email:
        return "E-mail não informado.", 400
    prospects = load_prospects()
    for p in prospects:
        if p['email'] == email and p['ativo']:
            p['ativo'] = False
            p['data_descadastro'] = datetime.now().isoformat()
            save_prospects(prospects)
            return "<h2>Você foi removido da nossa lista com sucesso.</h2>"
    return "<h2>E-mail não encontrado ou já descadastrado.</h2>"

@app.route('/preview/<template_name>')
def preview(template_name):
    context = {**BASE_CONTEXT, "cliente": {"nome": "Carlos Souza"}, "processo": {"numero": "0001234-56.2023.8.19.0001", "ultima_atualizacao": "Decisão publicada no DJE."}, "data_atualizacao": datetime.now(), "destinatario": {"tipo": "cliente"}}
    if template_name == "newsletter":
        context.update({
            "area_interesse": "LGPD",
            "lei": {"numero": "14.432/2022"},
            "artigo": {"url": "https://almeidaadvocacia.com.br/artigos/lgpd-2024"},
            "destinatario": {"tipo": "prospect"},
            "unsubscribe_url": url_for('unsubscribe', email='exemplo@dominio.com', _external=True)
        })
    try:
        return render_template(f"marketing/{template_name}.html", **context)
    except:
        return render_template(f"cliente/{template_name}.html", **context)

if __name__ == '__main__':
    app.run(debug=True)
EOF

# requirements.txt
echo "Flask==3.0.3
Jinja2==3.1.4" > requirements.txt

# .gitignore
echo "__pycache__/
*.pyc
.env" > .gitignore

# README.md
cat > README.md << 'EOF'
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
EOF

# static/style.css
mkdir -p static
cat > static/style.css << 'EOF'
body { font-family: Arial, sans-serif; background: #f5f7fa; margin: 0; padding: 20px; }
.container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
h1 { color: #2c3e50; }
label { display: block; margin: 15px 0 5px; font-weight: bold; }
input, select, button { width: 100%; padding: 10px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
.checkbox-group { display: flex; gap: 10px; align-items: flex-start; margin: 15px 0; }
.checkbox-group input { width: auto; margin-top: 4px; }
.checkbox-group label { font-weight: normal; margin: 0; }
.checkbox-group a { color: #2980b9; text-decoration: underline; }
button { background: #2980b9; color: white; font-weight: bold; cursor: pointer; }
button:hover { background: #1c5980; }
.alert { padding: 12px; margin-bottom: 20px; border-radius: 4px; }
.alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
.alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 13px; color: #666; text-align: center; }
EOF

# templates/base.html
cat > templates/base.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{ subject or 'Comunicação Jurídica' }}</title>
</head>
<body style="font-family: Arial, sans-serif; font-size: 16px; line-height: 1.5; color: #333; background-color: #f9f9f9; margin: 0; padding: 0;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f9f9f9;">
    <tr>
      <td align="center" style="padding: 20px 10px;">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
          <tr>
            <td style="padding: 20px; text-align: center; background-color: #ffffff; border-bottom: 1px solid #eee;">
              {% if escritorio.logo_url %}
                <img src="{{ escritorio.logo_url }}" alt="{{ escritorio.nome }}" width="180" style="max-width: 180px; height: auto;">
              {% else %}
                <h2 style="margin: 0; color: #2c3e50;">{{ escritorio.nome }}</h2>
              {% endif %}
            </td>
          </tr>
          <tr>
            <td style="padding: 30px;">
              {% block content %}{% endblock %}
            </td>
          </tr>
          <tr>
            <td style="padding: 20px; font-size: 13px; color: #666; background-color: #fafafa; border-top: 1px solid #eee; text-align: center;">
              <p style="margin: 0 0 10px;">
                {{ advogado.nome }} | OAB/{{ advogado.estado }} {{ advogado.oab }}<br>
                {{ escritorio.endereco }}<br>
                {{ escritorio.telefone }} | {{ escritorio.email }}<br>
                {% if escritorio.site %}<a href="{{ escritorio.site }}" style="color: #2980b9;">{{ escritorio.site }}</a>{% endif %}
              </p>
              {% if destinatario.tipo == "prospect" %}
                <p style="margin: 10px 0; font-size: 12px; color: #888;">
                  Você recebeu este e-mail porque se inscreveu em nosso informativo jurídico.<br>
                  {% if unsubscribe_url %}
                    <a href="{{ unsubscribe_url }}" style="color: #888; text-decoration: underline;">Clique aqui para cancelar sua inscrição</a>.
                  {% endif %}
                </p>
              {% endif %}
              <p style="margin-top: 15px; font-size: 11px; color: #999;">
                Este e-mail é confidencial.<br>
                © {{ now.year }} {{ escritorio.nome }}. Todos os direitos reservados.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
EOF

# templates/cliente/atualizacao_processo.html
cat > templates/cliente/atualizacao_processo.html << 'EOF'
{% extends "base.html" %}
{% block content %}
<p>Prezado(a) <strong>{{ cliente.nome }}</strong>,</p>
<p>Esperamos que esta mensagem o(a) encontre bem.</p>
<p>Gostaríamos de informar que, em relação ao processo nº <strong>{{ processo.numero }}</strong>, houve o seguinte andamento em <strong>{{ data_atualizacao.strftime('%d/%m/%Y') }}</strong>:</p>
<blockquote style="border-left: 3px solid #2980b9; padding-left: 15px; margin: 15px 0; color: #2c3e50;">
  {{ processo.ultima_atualizacao | safe }}
</blockquote>
<p>Caso tenha dúvidas, fico à disposição.</p>
<p>Atenciosamente,<br><strong>{{ advogado.nome }}</strong></p>
{% endblock %}
EOF

# templates/marketing/newsletter.html
cat > templates/marketing/newsletter.html << 'EOF'
{% extends "base.html" %}
{% block content %}
<p>Olá,</p>
<p>Você está recebendo este informativo porque demonstrou interesse em <strong>{{ area_interesse }}</strong>.</p>
<h3 style="color: #2c3e50;">Novidade legislativa</h3>
<p>Na última semana, entrou em vigor a <strong>Lei nº {{ lei.numero }}</strong>.</p>
<p>Em nosso artigo mais recente, explicamos os principais pontos:</p>
<p style="text-align: center; margin: 20px 0;">
  <a href="{{ artigo.url }}" style="background-color: #2980b9; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; display: inline-block;">
    Leia o artigo completo
  </a>
</p>
<p>Atenciosamente,<br>Equipe {{ escritorio.nome }}</p>
{% endblock %}
EOF

# templates/consentimento/formulario.html
cat > templates/consentimento/formulario.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Informativo Jurídico – {{ escritorio.nome }}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
  <div class="container">
    <h1>Informativo Jurídico</h1>
    <p>Receba conteúdos exclusivos sobre direito e atualizações legislativas.</p>
    {% with messages = get_flashed_messages(with_categories=true) %}
      {% if messages %}
        {% for category, message in messages %}
          <div class="alert {{ 'alert-success' if category == 'success' else 'alert-error' }}">
            {{ message }}
          </div>
        {% endfor %}
      {% endif %}
    {% endwith %}
    <form method="POST">
      <label for="email">Seu e-mail profissional:</label>
      <input type="email" id="email" name="email" required>
      <label for="area">Área de interesse:</label>
      <select id="area" name="area" required>
        <option value="">Selecione</option>
        {% for area in areas %}
          <option value="{{ area }}">{{ area }}</option>
        {% endfor %}
      </select>
      <div class="checkbox-group">
        <input type="checkbox" id="consent" name="consent" required>
        <label for="consent">
          Li e aceito o <a href="#" target="_blank">tratamento dos meus dados pessoais</a> conforme a LGPD,
          para receber informativos jurídicos do {{ escritorio.nome }}. Poderei cancelar a qualquer momento.
        </label>
      </div>
      <button type="submit">Receber Informativos</button>
    </form>
    <footer>
      <p>{{ advogado.nome }} | OAB/{{ advogado.estado }} {{ advogado.oab }}<br>{{ escritorio.endereco }}</p>
    </footer>
  </div>
</body>
</html>
EOF