FROM python:3.10.4

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR=/usr/src/poetry_cache/ 

# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

COPY pyproject.toml poetry.lock ./

# install Python Packages
RUN poetry install  --no-interaction --no-ansi --no-root