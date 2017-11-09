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