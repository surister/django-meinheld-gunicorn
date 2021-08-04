FROM surister/django-meinheld-gunicorn:base-python3.9.6-alpine3.14

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    && pip install --no-cache-dir django \
    && apk del --no-cache .build-deps

ENV VARIABLE_NAME="application"
ENV MODULE_NAME=${MODULE_NAME}
