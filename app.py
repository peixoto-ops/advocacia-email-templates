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
