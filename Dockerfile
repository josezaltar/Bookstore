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

# Instalar dependências e o Poetry
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential
RUN pip install poetry
RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2-binary
WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./
COPY README.md ./
COPY . .
RUN poetry install --without dev
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]