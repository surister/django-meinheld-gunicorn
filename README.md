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

```
With a tree project like this:

```
├── Dockerfile
├── manage.py
└── django-test
    ├── +
    ├── asgi.py
    ├── __init__.py
    ├── settings.py
    ├── urls.py
    └── wsgi.py
```
```bash
$ sudo docker build -t django-test .
```

```bash
$ sudo docker run -e MODULE_NAME=django-test.wsgi -p 8000:80 django-test
```

### Installing extra packages.
The images come with Gunicorn, Meinheld and Django installed, besides this, depending on the flavor they may have extra
packages. 

For example `python3.9.6-alpine3.14-postgresql` comes with postgreSQL psycopg2 support out of the box.

Even though it is great to have these packages already installed it is nearly not enough for a modern Django project.

We need `a lot of packages`.

You can use this docker image to wrap your project and install extra packages:

```dockerfile
FROM surister/django-meinheld-gunicorn:python3.9.6-alpine3.14-postgresql

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    && apk del --no-cache .build-deps
    
COPY . /app/
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt
```

Now, this will work for some packages but odds are that they some will fail at build time because of missing
dependencies. 

There is no generic Dockerfile that will build every package while being small, you will have to 
tweak it to find the correct build for you.

Let me walk you trough a real world example.

Let's take for example this Pipfile:
```yaml
[packages]
django = "*"
django-cors-headers = "*"
djangorestframework = "*"
django-filter = "*"
markdown = "*"
celery = "*"
paho-mqtt = "*"
psycopg2 = "*"
django-allauth = "*"
django-debug-toolbar = "*"
dj-rest-auth = "*"

[dev-packages]
flake8 = "*"
flake8-import-order = "*"
requests = "*"
factory-boy = "*"
faker = "*"
django-extensions = "*"
drf-yasg = "*"
flake8-django = "*"
coverage = "*"
pygraphviz = "*"
```

Using pipenv we turn it into a `requirements.txt`

```bash
$ pipenv run pip freeze > requirements.txt
```

`requirements.txt` Note that this also have dev packages, in production we wouldn't want packages such as flake8, coverage, drf-yasg but
for training purposes it is alright.

```yaml
amqp==5.0.6
asgiref==3.4.1
billiard==3.6.4.0
celery==5.1.2
certifi==2021.5.30
cffi==1.14.6
chardet==4.0.0
charset-normalizer==2.0.4
click==7.1.2
click-didyoumean==0.0.3
click-plugins==1.1.1
click-repl==0.2.0
coreapi==2.3.3
coreschema==0.0.4
coverage==5.5
cryptography==3.4.7
cycler==0.10.0
defusedxml==0.7.1
dj-rest-auth==2.1.10
Django==3.2.6
django-allauth==0.45.0
django-cors-headers==3.7.0
django-debug-toolbar==3.2.1
django-extensions==3.1.3
django-filter==2.4.0
djangorestframework==3.12.4
drf-yasg==1.20.0
factory-boy==3.2.0
Faker==8.10.3
flake8==3.9.2
flake8-django==1.1.2
flake8-import-order==0.18.1
idna==3.2
inflection==0.5.1
itypes==1.2.0
Jinja2==3.0.1
kiwisolver==1.3.1
kombu==5.1.0
Markdown==3.3.4
MarkupSafe==2.0.1
mccabe==0.6.1
numpy==1.21.0
oauthlib==3.1.1
packaging==21.0
paho-mqtt==1.5.1
prompt-toolkit==3.0.19
psycopg2==2.9.1
pycodestyle==2.7.0
pycparser==2.20
pyflakes==2.3.1
pygraphviz==1.7
PyJWT==2.1.0
pyparsing==2.4.7
python-dateutil==2.8.2
python3-openid==3.2.0
pytz==2021.1
requests==2.26.0
requests-oauthlib==1.3.0
ruamel.yaml==0.17.10
ruamel.yaml.clib==0.2.6
six==1.16.0
sqlparse==0.4.1
text-unidecode==1.3
uritemplate==3.0.1
urllib3==1.26.6
vine==5.0.0
wcwidth==0.2.5
```

The first problem we find is with `cryptography==3.4.7`. 

It outputs: `Fatal error: ffi.h: No such file or directory` with a quick Google search I find that `ffi.h` lives in
the package `libffi-dev`

We add it to our build and try again.

```dockerfile
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    libffi-dev // <----
```

You probably get the deal by now: rinse and repeat.

We find new missing dependencies: 
- `cryptographic` is missing `rust`, `cargo` and `openssl-dev`

- `kiwisolver` is missing `g++`

- `pygraphviz` is missing `graphviz`


## License

This project is licensed under the terms of the MIT license.

You can find the license here: https://github.com/surister/django-meinheld-gunicorn/blob/master/license.md
