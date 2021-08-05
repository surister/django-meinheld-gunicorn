Last documentation update: 2021-08-05. This is still a WIP.

## Tags:

- `base-python3.9.6-alpine3.14`
- `python3.9.6-alpine3.14`
- `python3.9.6-alpine3.14-postgresql`

## Links

- Dockerhub: https://hub.docker.com/r/surister/django-meinheld-gunicorn
- Github: https://github.com/surister/django-meinheld-gunicorn

## What does this repository offer?

This repository offers Django production-grade docker images with several flavors.

## Why this repository?

This repository is based on https://github.com/tiangolo/meinheld-gunicorn-docker. As of the time of writing the images
have not been updated for 15 months. This is problematic and several issues arise:

- The top python version that can be used is 3.8.

- Missing CVE patches such as CVE-2021-3137.

- Missing Mainheld and Gunicorn updates/bug fixes

- New cryptographic versions need new dependencies (rust and cargo) that are missing in the alpine image.

- Top Alpine version is 3.11

- Missing arm architecture (Lot of people have raspberry pi's and want to host small websites, some vendors like
  Scaleway offer small arm instances, Apple M1..)

This repository aims to solve those issues.




## The base image.
`$ docker pull surister/django-meinheld-gunicorn:base-python3.9.6-alpine3.14`

This image is the base of all other alpine images. 

This one can also be used with flask, it's like the one you would find in https://github.com/tiangolo/meinheld-gunicorn-docker
but updated.

All the other images are Django focused.

## Running a basic Django project.

We start a Django project called 'sampletest'

`$ django-admin startproject sampletest`

We run the project attaching the source files in a volume.

`$ sudo docker run -d --name sampletest -p 8000:80 -v ~/sampletest/:/app/ -e MODULE_NAME=sampletest.wsgi surister/django-meinheld-gunicorn:python3.9.6-alpine3.14 `

What does it do?
- Runs a Django container with gunicorn and mainheld named `sampletest`.
- It is visible trough the port 8000
- The source files are passed at runtime, changes to your local files will affect the container after a restart.
- We pass a $MODULE_NAME env variable with the name of your main Django folder (The one that hold `urls.py`, `settings.py`, `wsgi.py`...) 
  this is needed for gunicorn.

  
We curl the port

`$ curl localhost:8000`

```html
<!doctype html>

<html lang="en-us" dir="ltr">
<head>
    <meta charset="utf-8">
    <title>The install worked successfully! Congratulations!</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" type="text/css" href="/static/admin/css/fonts.css">
...
```

### Passing source files at build time

If you do not want to pass the source files in a attached volume, you can extend the image and pass them at build time:

```dockerfile
FROM surister/django-meinheld-gunicorn:python3.9.6-alpine3.14
 
COPY . /app/

// WIP WIP WIP

RUN apk add --no-cache --virtual .build-deps [package1] [package2] [package3] ... [packageN] \
    && pip install -r requirements.txt \
    && apk del -build-deps [package1] [package2] [package3] ... [packageN]

```