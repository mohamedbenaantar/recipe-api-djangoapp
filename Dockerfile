FROM python:3.9-alpine3.13

## recommanded when you run python in docker container
ENV PYTHONBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app

## expose to a port in our machine 
EXPOSE 8000

## docker compose is going to update the config argument
ARG DEV=false
## instead of create every run command  will create new layer each time and to avoid that to keep our images lightweight

## create new virtual env

## Upgrade pip the package manager inside our virtual env

## Add new user inside the image not use the root user as best practice

## DON'T run the application using the root user

RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    apk add --upgrade --no-cache postgresql-client &&  \
    apk add --upgrade --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev &&  \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \    
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    chown -R django-user /app

## update the path inside the environment
ENV PATH="/py/bin:$PATH"

## switch into django-user
USER django-user
