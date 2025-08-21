# Usa uma imagem base Python slim para um tamanho menor
FROM python:3.13-slim as python-base

# Configura variáveis de ambiente
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

# Adiciona o caminho do Poetry e do venv ao PATH
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Instala dependências do sistema e o Poetry
# O comando `rm -rf /var/lib/apt/lists/*` limpa o cache do apt
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir poetry

# Instala dependências do PostgreSQL (libpq-dev e psycopg2-binary)
# O comando `rm -rf /var/lib/apt/lists/*` limpa o cache do apt
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir psycopg2-binary

# Define o diretório de trabalho principal e copia os arquivos de configuração do Poetry
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Instala as dependências Python via Poetry *aqui*
# --without dev: não instala dependências de desenvolvimento
# --no-root: evita instalar o próprio projeto como um pacote, o que é comum para apps Django
RUN poetry install --without dev --no-root

# Agora, copia o restante do código da aplicação
COPY . .

# Expõe a porta que o Django vai usar
EXPOSE 8000

# Comando para iniciar o servidor Django usando Poetry
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]