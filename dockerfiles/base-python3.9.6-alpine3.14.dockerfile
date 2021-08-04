FROM python:3.9.6-alpine3.14

LABEL maintainer="Iván Sánchez <surister@gmail.com>"
# Original Image:
# https://github.com/tiangolo/meinheld-gunicorn-docker/blob/master/docker-images/python3.8-alpine3.11.dockerfile
#
# As of 2021-08-04 it has not been updated for 15 months,
# meaning the image is lacking several Python CVE fixes (CVE-2021-3177), mainheld bug fixes,
# cryptographic package new rust dependency.. hence this updated image.
# Thanks tiangolo for all your work.

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    && pip install --no-cache-dir meinheld gunicorn \
    && apk del --no-cache .build-deps

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Meinheld
CMD ["/start.sh"]