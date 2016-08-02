# Django base image

[hub.docker.com/r/telling/django](https://hub.docker.com/r/telling/django)

Based on the official python images.

Simplifying developing django applications by providing a few shorthands for manage.py:

- `runserver host:port`
    - Waits for the database to be ready, then runs `migrate`, `collectstatic` and lastly `runserver`.
- `nomigrate host:port`
  - Waits for the database to be ready, then runs `collectstatic` followed by `runserver`.
- `makemigrations` and `loadtestdata`
  - Waits for the database to be ready, then runs `makemigrations` or `loadtestdata`.

If environment variables `DJANGO_SUPERUSER_*` are set, `runserver` and `nomigrate` will attempt to create the superuser. Likewise, if the `DJANGO_DB_*` variables are set, it will wait for the database upon starting the container, the image uses [dockerize](https://github.com/jwilder/dockerize) to wait for the database. Other then that it behaves like the official python images, with the environment variable `PYTHONUNBUFFERED` set, django and a few extra packages installed.

# Environment variables

- `DJANGO_DB_HOST`
- `DJANGO_DB_PORT`
- `DJANGO_SUPERUSER_NAME`
- `DJANGO_SUPERUSER_MAIL`
- `DJANGO_SUPERUSER_PASS`
- `DOCKERIZE_VERSION`
- `PYTHONUNBUFFERED`
- `DJANGO_VERSION`

# Usage

To start a new project and create a new app:

```bash
docker run --rm --log-driver none -v $(pwd):/code telling/django:1.9.7-py3 django-admin startproject mysite

docker run --rm --log-driver none -v $(pwd)/mysite:/code telling/django:1.9.7-py3 python manage.py startapp polls
```

# docker-compose

I've recently used this to get a local development environment for the [bornhack](https://github.com/bornhack/bornhack-website) website, see below.

I created a very simple dockerfile, which simply copies the requirements.txt files, and installs said requirements, _Dockerfile_: 

```dockerfile
FROM telling/django:1.9.7-py2

COPY requirements/base.txt base.txt
COPY requirements/development.txt development.txt
RUN pip install -r development.txt

CMD ["runserver", "0.0.0.0:8000"]
```

Then using the dockerfile in _docker-compose.yml_:

```yaml
version: "2"

services:
  postgres:
    image: postgres:9.5
    container_name: bornhack-postgres
    environment:
      - POSTGRES_PASSWORD=bornhack
      - POSTGRES_USER=bornhack
      - POSTGRES_DB=bornhack_dev

  django:
    build: .
    volumes:
      - .:/code
    container_name: bornhack-django
    ports:
      - "8000:8000"
    environment:
      - DJANGO_DB_NAME=bornhack_dev
      - DJANGO_DB_USER=bornhack
      - DJANGO_DB_PASS=bornhack
      - DJANGO_DB_HOST=postgres
      - DJANGO_DB_PORT=5432
      - DJANGO_SUPERUSER_NAME=bornhack
      - DJANGO_SUPERUSER_PASS=bornhack
      - DJANGO_SUPERUSER_MAIL=bornhack@mail.com
      - DJANGO_SETTINGS_MODULE=bornhack.settings.development

```

We end with a tree structure like:

```
.
├── Dockerfile
├── Makefile
├── README.md
├── bornhack
├── camps
├── docker-compose.yml
├── graphics
├── manage.py
├── news
├── profiles
├── requirements
├── shop
├── utils
├── vendor
└── villages
```

Then we can start hacking on the bornhack website by simply doing:

- docker-compose up -d

Go to [localhost:8000](localhost:8000) and see the bornhack website in all its beauty.