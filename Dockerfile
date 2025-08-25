# Usa uma imagem base Python slim para um tamanho menor
FROM python:3.13-slim AS python-base

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
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    PYSETUP_PATH="/opt/pysetup"
ENV PATH="$POETRY_HOME/bin:$PATH"

# Instala dependências do sistema e o Poetry
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential \
        libpq-dev \
        gcc \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir poetry

# Define o diretório de trabalho principal e copia os arquivos de configuração do Poetry
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Configura o Poetry para não criar um ambiente virtual e instala as dependências
RUN poetry config virtualenvs.create false && \
    poetry install --no-root --only main

# Agora, copia o restante do código da aplicação
COPY . .

# Expor a porta que o Django vai usar
EXPOSE 8000

# Comando para iniciar o servidor Django
# Agora, podemos usar 'python' diretamente em vez de 'poetry run'
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]