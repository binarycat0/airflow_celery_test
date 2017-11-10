# airflow_celery_test
Test docker-compose project for demonstrate how to use airflow with celery

### Required
- docker [https://docs.docker.com/engine/installation/]
- docker-compose [https://docs.docker.com/compose/]

### First run
```
git clone https://github.com/catbinary/airflow_celery_test.git ~/airflow_celery_test

cd ~/airflow_celery_test
docker-compose build
docker-compose up
```

### Web ui airflow instance

`http://127.0.0.1:8080/admin/`

### Web ui flower instance

`http://127.0.0.1:8081/monitor`

## Environments

### use .env file

```
SQL_ALCHEMY_CONN=postgresql://airflow:airflow@db/airflow
SECRET_KEY=SECRET_KEY_0

CELERY_RESULT_BACKEND=redis://redis/1
BROKER_URL=redis://redis/0

DAG_ORIENTATION = BT
```

## Volumes

### dockerdata/logs:/logs

```
.
└── dockerdata
    └── logs
        ├── flower
        ├── scheduler
        ├── web
        └── worker
```

## Dockerfile

```
FROM python:2
ENV AIRFLOW_HOME=/airflow

# Default for airflow. We replace it in compose environments
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=sqlite:////airflow/airflow.db
ENV AIRFLOW__CORE__EXECUTOR=CeleryExecutor
ENV AIRFLOW__CORE__BASE_LOG_FOLDER=/logs
# We already have one
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__CORE__DAGS_FOLDER=/airflow/dags

ENV AIRFLOW__WEBSERVER__SECRET_KEY=SECRET_KEY
ENV AIRFLOW__WEBSERVER__DEMO_MODE=False
ENV AIRFLOW__WEBSERVER__EXPOSE_CONFIG=True
ENV AIRFLOW__WEBSERVER__DAG_ORIENTATION=LR

ENV AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY=/logs/scheduler

# Default for us. u can replace it in compose environments, or when u start your container
ENV AIRFLOW__CELERY__BROKER_URL=redis://redis/1
ENV AIRFLOW__CELERY__CELERY_RESULT_BACKEND=redis://redis/0
# need for Celery_Flower
ENV AIRFLOW__CELERY__C_FORCE_ROOT=True

ENV WORKER_DAEMON_LOGFILE=/logs/worker/worker_daemon.log
ENV SCHEDULER_DAEMON_LOGFILE=/logs/scheduler/scheduler_daemon.log
ENV FLOWER_DAEMON_LOGFILE=/logs/flower/flower_daemon.log
ENV WEB_DAEMON_LOGFILE=/logs/web/web_daemon.log

ENV WEB_PID=/tmp/web.pid
ENV SCHEDULER_PID=/tmp/scheduler.pid
ENV FLOWER_PID=/tmp/flower.pid
ENV WORKER_PID=/tmp/worker.pid

#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get -y -q install postgresql-client-9.6

#
RUN ["/bin/bash", "-c", "pip install redis"]
RUN ["/bin/bash", "-c", "pip install 'airflow[celery, postgres, redis]'"]

#
RUN mkdir /airflow
RUN mkdir /logs
VOLUME /airflow
VOLUME /logs

COPY ./src /airflow
WORKDIR /airflow

EXPOSE 8080 8081
```

## docker-compose

```yml
version: '3'
services:
  web:
    build: .
    restart: "always"
    ports:
      - '8080:8080'
    environment:
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=${SQL_ALCHEMY_CONN}
      - AIRFLOW__WEBSERVER__DAG_ORIENTATION=${DAG_ORIENTATION}
      - AIRFLOW__WEBSERVER__SECRET_KEY=${SECRET_KEY}
    volumes:
      - '${PWD}/dockerdata/logs:/logs'
    links:
      - db
    entrypoint:
      - /airflow/airflow_web.sh

  scheduler:
    build: .
    restart: "always"
    environment:
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=${SQL_ALCHEMY_CONN}
    volumes:
      - '${PWD}/dockerdata/logs:/logs'
    links:
      - db
      - redis
      - worker
    entrypoint:
      - /airflow/airflow_scheduler.sh

  worker:
    build: .
    restart: "always"
    environment:
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=${SQL_ALCHEMY_CONN}
      - C_FORCE_ROOT=True
    volumes:
      - '${PWD}/dockerdata/logs:/logs'
    links:
      - db
      - redis
    entrypoint:
      - /airflow/airflow_worker.sh

  flower:
    build: .
    restart: "always"
    environment:
      - AIRFLOW__CORE__SQL_ALCHEMY_CONN=${SQL_ALCHEMY_CONN}
    volumes:
      - '${PWD}/dockerdata/logs:/logs'
    ports:
      - '8081:8081'
    links:
      - db
      - redis
    entrypoint:
      - /airflow/airflow_flower.sh

  db:
    image: 'postgres:9.6'
    hostname: db
    restart: always
    volumes:
      - '${PWD}/dockerdata/pgdata:/var/lib/postgresql/data'
    environment:
      - POSTGRES_USER=airflow
      - POSTGRES_PASSWORD=airflow
      - POSTGRES_DB=airflow

  redis:
    image: 'redis:3.2'
    hostname: redis
    restart: "always"
    volumes:
      - '${PWD}/dockerdata/redis:/data'

```