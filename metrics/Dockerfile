FROM python:3.10.4

ENV PYTHONUNBUFFERED=1 \
    METRICS_GROUP="metrics" \
    METRICS_USER="metrics" \
    METRICS_HOME_DIR="/home/metrics" \
    METRICS_DIR="/usr/src/metrics" \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR=/usr/src/poetry_cache/

WORKDIR ${metrics_DIR}

#Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Install Packages
ADD pyproject.toml poetry.lock ./
RUN poetry install  --no-interaction --no-ansi --no-root

# Add all metrics files to the container
ADD . .

# Build arguments to set non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create non-root user metrics and give appropriate permissions
RUN groupadd -g ${GROUP_ID} ${METRICS_GROUP} \
  && useradd -u ${USER_ID} -g ${METRICS_GROUP} ${METRICS_USER} \
  && mkdir ${METRICS_HOME_DIR} \
  && chown ${USER_ID}:${GROUP_ID} ${METRICS_HOME_DIR} 

# Set non-root user scritps to run JupyterLab
USER ${USER_ID}:${GROUP_ID}

ENTRYPOINT ["python"]
