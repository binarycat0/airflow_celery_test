#!/bin/bash

airflow flower -p 8081 --stdout $FLOWER_DAEMON_LOGFILE --stderr $FLOWER_DAEMON_LOGFILE -l $FLOWER_DAEMON_LOGFILE -D
