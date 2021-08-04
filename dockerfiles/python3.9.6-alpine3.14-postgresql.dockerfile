FROM surister/django-meinheld-gunicorn:base-python3.9.6-alpine3.14

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    python3-dev \
    musl-dev \
    postgresql-dev \
    && pip install --no-cache-dir psycopg2 django \
    && apk del --no-cache .build-deps

RUN apk --no-cache add libpq

ENV VARIABLE_NAME="application"
ENV MODULE_NAME=${MODULE_NAME}
