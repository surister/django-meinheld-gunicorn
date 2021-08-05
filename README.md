Last documentation update: 2021-08-05. This is still a WIP.

# Index

- [Tags](#tags)
- [Links](#interesting-links)
- [About the repository](#about)
- [Why the respository](#why)
- [Environment variables](#environment)
- [Base image explanation](#the-base-image)
- [Running the images](#running-a-basic-django-project)
  - [Simple example](#a-simple-example)
  - [Passing source files at build time](#passing-source-files-at-build-time)
  - [Installing extra packages](#installing-extra-packages)
- [Docker-compose](#docker-compose)
  - [Simple example](#a-simple-django-docker-compose-example)
  - [Simple example with installed packages](#a-django-docker-compose-example-following-the-installing-extra-packagesinstallingpackages)
  - [Complete example (With PostgreSQL and adminer)](#a-more-complete-example-with-postgresql)
- [Image sizes](#image-sizes)
- [License](#license)


## <a name=tags></a> Tags:

- [base-python3.9.6-alpine3.14](https://github.com/surister/django-meinheld-gunicorn/blob/master/dockerfiles/base-python3.9.6-alpine3.14.dockerfile)
- [python3.9.6-alpine3.14](https://github.com/surister/django-meinheld-gunicorn/blob/master/dockerfiles/python3.9.6-alpine3.14.dockerfile)
- [python3.9.6-alpine3.14-postgresql](https://github.com/surister/django-meinheld-gunicorn/blob/master/dockerfiles/python3.9.6-alpine3.14-postgresql.dockerfile)

## <a name=interesting-links></a> Links

- Dockerhub: https://hub.docker.com/r/surister/django-meinheld-gunicorn
- Github: https://github.com/surister/django-meinheld-gunicorn

## <a name=about></a> About: What does this repository offer?

This repository offers Django production-grade docker images with several flavors.

## <a name=why></a> Why this repository?

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

## <a name=the-base-image></a> The base image.

```
$ docker pull surister/django-meinheld-gunicorn:base-python3.9.6-alpine3.14
```

This image is the base of all other alpine images.

This one can also be used with flask, it's like the one you would find
in https://github.com/tiangolo/meinheld-gunicorn-docker
but updated.

All the other images are Django focused.

## <a name=environment></a> Environment variables

  `MODULE_NAME`

## <a name=running-a-basic-django-project></a> Running a basic Django project.

We start a Django project called 'sampletest'

```bash
$ django-admin startproject sampletest
```


### <a name=a-simple-example></a> A simple example

```bash
$ sudo docker run -d --name sampletest -p 8000:80 -v ~/sampletest/:/app/ -e MODULE_NAME=sampletest.wsgi surister/django-meinheld-gunicorn:python3.9.6-alpine3.14
```

What does it do?

- Runs a Django container with gunicorn and mainheld named `sampletest`.
- It is visible trough the port 8000
- The source files are passed at runtime, changes to your local files will affect the container after a restart.
- We pass a `MODULE_NAME` env variable with the name of your main Django folder (The one that holds 
  `urls.py`, `settings.py`, `wsgi.py`...) this is needed for gunicorn.

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

### <a name=passing-source-files-at-build-time></a> Passing source files at build time

If you do not want to pass the source files in an attached volume, you can extend the image and the files at build time:

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

### <a name=installing-extra-packages></a> Installing extra packages.

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

Running this image is the same procedure as running for example: `python3.9.6-alpine3.14-postgresql`

```bash
$ sudo docker run -d --name sampletest -p 8000:80 -v ~/sampletest/:/app/ -e MODULE_NAME=sampletest.wsgi mynewlybuildimage
```

Now, this will work for some packages but odds are that they some will fail at build time because of missing
dependencies.

There is no generic Dockerfile that will build every package while maintaining its small size, you will have to tweak it
to find the correct build for your project.

Let me walk you trough a real world example.

Let's take for example this Pipfile:

```yaml
[ packages ]
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

  [ dev-packages ]
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

`requirements.txt` Note that this also have dev packages, in production we wouldn't want packages such as flake8,
coverage, drf-yasg but for training purposes it is alright.

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

If we try to build it the first problem we find is with `cryptography==3.4.7`.

It outputs: `Fatal error: ffi.h: No such file or directory` with a quick Google search I find that `ffi.h` lives in the
package `libffi-dev`

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

- `pygraphviz` is missing `graphviz-dev`

And we finally manage to build it with:

```dockerfile
FROM surister/django-meinheld-gunicorn:python3.9.6-alpine3.14-postgresql

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    libffi-dev \
    rust \
    cargo \
    g++ \
    graphviz-dev \
    openssl-dev \
 && apk del --no-cache .build-deps
 	    
COPY . /app/
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt
```

## <a name=docker-compose></a> Docker-compose

### <a name=a-simple-django-docker-compose-example></a> A simple Django docker-compose example:

```yaml
version: "3.9"

services:
  django:
    image: surister/django-meinheld-gunicorn:python3.9.6-alpine3.14
    restart: unless-stopped
    ports:
      - 8000:80
    volumes:
      - /home/surister/django-test/django_project:/app/ # Change project path as needed
    environment:
      - MODULE_NAME=django_project.wsgi

```

```bash
$ docker-compose up -d
```

### <a name=a-django-docker-compose-example-following-the-installing-extra-packagesinstallingpackages></a> A Django docker-compose example following the [Installing extra packages](#installing-extra-packages).

Dockerfile

```Dockerfile
FROM surister/django-meinheld-gunicorn:python3.9.6-alpine3.14-postgresql

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    && apk del --no-cache .build-deps
    
COPY . /app/
WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

```

docker-compose.yml

```yaml
version: "3.9"

services:
  django:
    build:
      dockerfile: /home/surister/django-test/django_project/Dockerfile # Change Dockerfile path as needed
      context: /home/surister/django-test/django_project/ # Change context as needed, if your docker-compose.yml 
        # file is in the same folder as the project 
      # just write a dot: 'context: .'
    restart: unless-stopped
    ports:
      - 8000:80
    environment:
      - MODULE_NAME=django_project.wsgi
```

```bash
$ docker-compose up -d
```

If you change your project files you will have to rebuild

```bash
$ docker-compose down
```

and

```bash
$ docker-compose up -d --build
```

### <a name=a-more-complete-example-with-postgresql></a> A more complete example with PostgreSQL.

```yaml
version: "3.9"

services:
  django:
    build:
      dockerfile: /home/surister/django-test/django_project/Dockerfile # Change Dockerfile path as needed
      context: /home/surister/django-test/django_project/ # Change context as needed, if your docker-compose.yml
                                                          # file is in the same folder as the project
                                                          # just write a dot: 'context: .'
    restart: unless-stopped
    ports:
      - 8000:80
    environment:
      - MODULE_NAME=django_project.wsgi

  postgres:
    image: postgres
    volumes:
      - pg_data:/var/lib/postgresql/data

    environment:
      - POSTGRES_PASSWORD=pgpassword
      - POSTGRES_USER=pguser
      - POSTGRES_DB=pgdb

    ports:
      - 5432

  adminer:
    image: adminer
    restart: always
    ports:
      - 8075:8080

volumes:
  pg_data:

```

Bare in mind that you will have to change your `DATABASES` settings

```python
DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql_psycopg2',
    'NAME': 'pgdb',
    'USER': 'pguser',
    'PASSWORD': 'pgpassword',
    'HOST': 'postgres',
    'PORT': '5432',
  }
}
```

## <a name=image-sizes></a> Image sizes

Base image is approximately `53.2MB`.

Django images are `80.2MB` and postgreSQL is `82MB`

Every image removes caches and unused files at build time to ensure minimal size.

The [Simple example with installed packages](#a-django-docker-compose-example-following-the-installing-extra-packagesinstallingpackages)
image is 84.1MB, as you can see images do to grow much when you install a lot of packages.

## TODO

- [x] DONE: Update and test tiangolo's alpine base image
- [x] DONE: Create Django image
- [x] DONE: Create PostgreSQL image
- [ ] PENDING: Create Mysql/Mariadb image
- [ ] PENDING: See if Pillow/Celery image would fit the repository.
- [x] DONE: Write a somewhat comprehensive documentation/readme.
- [x] DONE: Add MIT license
- [x] DONE: Correctly format the readme with links and anchors.
- [ ] PENDING: Port all images to ARM arch

## <a name=license></a> License

This project is licensed under the terms of the MIT license.

You can find the license here: https://github.com/surister/django-meinheld-gunicorn/blob/master/license.md
