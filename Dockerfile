FROM python:3.13-slim as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instalar dependências do sistema e o Poetry
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
    && pip install --no-cache-dir poetry \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar dependências do PostgreSQL (libpq-dev e psycopg2-binary)
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install --no-cache-dir psycopg2-binary \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Definir o diretório de trabalho principal e copiar os arquivos de configuração do Poetry
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./
COPY env.dev ./

# Instalar as dependências Python via Poetry *aqui*
RUN poetry install --no-root

# Agora, copiar o restante do código da aplicação
# Isso garante que a camada de instalação de dependências possa ser cacheada
# se apenas o código da aplicação mudar e não as dependências.
COPY . .

# Expor a porta que o Django vai usar
EXPOSE 8000

# Comando para iniciar o servidor Django usando Poetry
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]
