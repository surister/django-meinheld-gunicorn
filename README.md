# WIP

## Tags:

- base-python3.9.6-alpine3.14.dockerfile
- python3.9.6-alpine3.14.dockerfile
- python3.9.6-alpine3.14-postgresql.dockerfile

### Using: python3.9.6-alpine3.14.dockerfile

# This image comes with django already installed: 


We create a folder for our testing projects.

`$ mkdir django-test`

We start a django project called 'sampletest'

`$ django-admin startproject sampletest`

We run the project attaching the source files in a volume.

`$ sudo docker run -v ~/django-test/sampletest/:/app/ -e MODULE_NAME=sampletest.wsgi --rm -d --name sampletest -p 8000:80 surister/django-meinheld-gunicorn:python3.9.6-alpine3.14 `

We curl the port

`$ curl localhost:8000`

```html
> <!doctype html>

<html lang="en-us" dir="ltr">
    <head>
        <meta charset="utf-8">
        <title>The install worked successfully! Congratulations!</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" type="text/css" href="/static/admin/css/fonts.css">
```


It is recommended that you extend an image and add the necessary packages, for example:

```dockerfile
FROM surister/django-meinheld-gunicorn:python3.9.6-alpine3.14
 
RUN apk add --no-cache --virtual .build-deps [package1] [package2] [package3] ... [packageN] \
    && pip install -r requirements.txt \
    && apk del -build-deps [package1] [package2] [package3] ... [packageN]

```