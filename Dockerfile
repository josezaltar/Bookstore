# Usa a imagem oficial do Python, que é leve e otimizada
FROM python:3.13-slim as python-base

# Define variáveis de ambiente para garantir que Python e Poetry funcionem corretamente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # Configurações do pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # Configurações do Poetry
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    \
    # Caminhos para o projeto
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"
# Adiciona os binários do Poetry e do venv ao PATH do sistema
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala as dependências do sistema e o Poetry
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
    && pip install poetry # Instala o Poetry globalmente dentro do contêiner

# Instala as dependências do PostgreSQL (libpq-dev e gcc)
# Estas são necessárias para o pacote psycopg2-binary
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2-binary

# Define o diretório de trabalho principal e copia os arquivos de configuração do Poetry
# A ordem de cópia é importante para o cache do Docker
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Instala as dependências Python via Poetry
# "--without dev": não instala dependências de desenvolvimento
# "--no-root": evita instalar o próprio projeto como um pacote
RUN poetry install --without dev --no-root

# Agora, copia o restante do código da aplicação
# Esta é a última camada, então o Docker pode usar o cache da instalação de dependências
# se apenas o código da aplicação mudar.
COPY . .

# Expor a porta que o Django vai usar
EXPOSE 8000

# O comando de inicialização é removido daqui.
# No Render, você definirá o "Start Command" no painel,
# o que permite maior flexibilidade e automação de tarefas de deploy.
# O comando a ser usado no Render será:
# poetry run python manage.py collectstatic --noinput && poetry run python manage.py migrate && poetry run gunicorn bookstore.wsgi:application --bind 0.0.0.0:$PORT
