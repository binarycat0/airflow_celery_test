FROM python:2
ENV AIRFLOW_HOME=/airflow
#default
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=sqlite:////airflow/airflow.db
ENV AIRFLOW__CORE__EXECUTOR=CeleryExecutor
ENV AIRFLOW__CORE__BASE_LOG_FOLDER=/logs
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False

ENV AIRFLOW__WEBSERVER__SECRET_KEY=SECRET_KEY
ENV AIRFLOW__WEBSERVER__DEMO_MODE=False
ENV AIRFLOW__WEBSERVER__EXPOSE_CINFIG=True
ENV AIRFLOW__WEBSERVER__DAG_ORIENTATION=LR

ENV AIRFLOW__SCHEDULER__CHILD_PROCESS_LOG_DIRECTORY=/logs/scheduler

ENV AIRFLOW__CELERY__BROKER_URL=redis://redis/1
ENV AIRFLOW__CELERY__CELERY_RESULT_BACKEND=redis://redis/0
ENV AIRFLOW__CELERY__C_FORCE_ROOT=True

ENV WORKER_DAEMON_LOGFILE=/logs/worker/worker_daemon.log
ENV SCHEDULER_DAEMON_LOGFILE=/logs/scheduler/scheduler_daemon.log
ENV FLOWER_DAEMON_LOGFILE=/logs/flower/flower_daemon.log
ENV WEB_DAEMON_LOGFILE=/logs/web/web_daemon.log

ENV WEB_PID=$AIRFLOW_HOME/pid/web.pid
ENV SCHEDULER_PID=$AIRFLOW_HOME/pid/scheduler.pid
ENV FLOWER_PID=$AIRFLOW_HOME/pid/flower.pid
ENV WORKER_PID=$AIRFLOW_HOME/pid/worker.pid

#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get -y -q install postgresql-client-9.6

#
RUN ["/bin/bash", "-c", "pip install airflow"]
RUN ["/bin/bash", "-c", "pip install redis"]
RUN ["/bin/bash", "-c", "pip install 'airflow[celery, postgres, redis]'"]

#
RUN mkdir /airflow
VOLUME /airflow
VOLUME /logs
WORKDIR /airflow

EXPOSE 8080 8081