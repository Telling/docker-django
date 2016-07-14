FROM python:2.7.12
MAINTAINER Stephan Telling <st@telling.xyz>

RUN apt-get update && apt-get install -y \
        gcc \
        gettext \
        mysql-client \
        libmysqlclient-dev \
        postgresql-client \
        libpq-dev \
        sqlite3 \
        --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV DOCKERIZE_VERSION v0.2.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN mkdir /code
WORKDIR /code
ENV DJANGO_VERSION 1.9.7
RUN pip install Django==$DJANGO_VERSION

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["python" "manage.py" "runserver" "0.0.0.0:8000"]
