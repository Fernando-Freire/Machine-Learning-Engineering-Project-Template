FROM python:3.10.4

ENV PYTHONUNBUFFERED=1 \
    TRAIN_GROUP="train" \
    TRAIN_USER="train" \
    TRAIN_HOME_DIR="/home/train" \
    TRAIN_DIR="/usr/src/train" \
    PIP_NO_CACHE_DIR=off \
    POETRY_VERSION=1.2.2 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR=/usr/src/poetry_cache/

WORKDIR ${TRAIN_DIR}

#Install Poetry
RUN pip install "poetry==$POETRY_VERSION"

# Install Packages
ADD pyproject.toml poetry.lock ./
RUN poetry install  --no-interaction --no-ansi --no-root

# Add all train files to the container
ADD . .

# Build arguments to set non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create non-root user train and give appropriate permissions
RUN groupadd -g ${GROUP_ID} ${TRAIN_GROUP} \
  && useradd -u ${USER_ID} -g ${TRAIN_GROUP} ${TRAIN_USER} \
  && mkdir ${TRAIN_HOME_DIR} \
  && chown ${TRAIN_ID}:${GROUP_ID} ${TRAIN_HOME_DIR}

# Set non-root user scritps to run 
USER ${USER_ID}:${GROUP_ID}

ENTRYPOINT ["python"]


