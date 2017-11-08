#!/bin/bash

airflow initdb
airflow webserver -p 8080 --stdout $WEB_DAEMON_LOGFILE --stderr $WEB_DAEMON_LOGFILE
