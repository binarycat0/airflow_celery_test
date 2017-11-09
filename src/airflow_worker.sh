#!/bin/bash

airflow worker --stdout $WORKER_DAEMON_LOGFILE --stderr $WORKER_DAEMON_LOGFILE -l $WORKER_DAEMON_LOGFILE -D
