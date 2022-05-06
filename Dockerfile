FROM python:3.10.4 AS base

ENV PYTHONUNBUFFERED=1 \
    MLE_GROUP="mle" \
    MLE_USER="mle" \
    MLE_HOME_DIR="/home/mle" \
    MLE_DIR="/usr/src/mle" \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.1.13 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR=/usr/src/poetry_cache/

WORKDIR ${MLE_DIR}

#Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Install Packages
ADD pyproject.toml poetry.lock ./
RUN poetry install  --no-interaction --no-ansi --no-root

# Add all mle files to the container
ADD ./mle .

# Build arguments to set non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create non-root user mle and give appropriate permissions
RUN groupadd -g ${GROUP_ID} ${MLE_GROUP} \
  && useradd -u ${USER_ID} -g ${MLE_GROUP} ${MLE_USER} \
  && mkdir ${MLE_HOME_DIR} \
  && chown ${USER_ID}:${GROUP_ID} ${MLE_HOME_DIR} ${MLE_NB_DIR}

# Set non-root user scritps to run JupyterLab
USER ${USER_ID}:${GROUP_ID}

ENTRYPOINT ["python"]
