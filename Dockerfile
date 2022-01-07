# Use an official Python runtime based on Debian 10 "buster" as a parent image.
#FROM python:3.8.1-slim-buster
FROM nginx/unit:1.26.1-python3.9
LABEL maintainer="ben@mebmc.uk"

# Add user that will be used in the container.
#RUN useradd wagtail

RUN mkdir -p /opt/app && chown unit.unit /opt/app

# Port used by this container to serve HTTP.
EXPOSE 8000

# Set environment variables.
# 1. Force Python stdout and stderr streams to be unbuffered.
# 2. Set Django environment
# 3. Set location for Python Venv
# 4. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
#    command.
ENV PYTHONUNBUFFERED=1 \
    DJANGO_ENV="dev" \
    VIRTUAL_ENV="/opt/venv" \
    PORT=8000

RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install system packages required by Wagtail and Django.
#RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
#    build-essential \
#    libpq-dev \
#    libmariadbclient-dev \
#    libjpeg62-turbo-dev \
#    zlib1g-dev \
#    libwebp-dev \
# && rm -rf /var/lib/apt/lists/*

# Use /app folder as a directory where the source code is stored.
WORKDIR /opt/app

# Install the project requirements.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the source code of the project into the container.
COPY --chown=unit:unit . .

# Collect static files.
#RUN python manage.py collectstatic --noinput --clear

COPY .ops/unit.d/* /docker-entrypoint.d/

