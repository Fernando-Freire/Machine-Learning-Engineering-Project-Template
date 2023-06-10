FROM python:3.10.4

ENV PYTHONUNBUFFERED=1 \
    API_GROUP="api" \
    API_USER="api" \
    API_HOME_DIR="/home/api" \
    API_DIR="/usr/src/api" \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR=/usr/src/poetry_cache/

WORKDIR ${API_DIR}

#Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Install Packages
ADD pyproject.toml poetry.lock ./
RUN poetry install  --no-interaction --no-ansi --no-root

# Add all api files to the container
ADD . .

# Build arguments to set non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create non-root user api and give appropriate permissions
RUN groupadd -g ${GROUP_ID} ${API_GROUP} \
  && useradd -u ${USER_ID} -g ${API_GROUP} ${API_USER} \
  && mkdir ${API_HOME_DIR} \
  && chown ${USER_ID}:${GROUP_ID} ${API_HOME_DIR}

# Set non-root user scritps to run JupyterLab
USER ${USER_ID}:${GROUP_ID}

ENTRYPOINT ["python"]
