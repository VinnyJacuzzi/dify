#!/bin/bash

set -e

# Ensure PORT is set to the Cloud Run assigned port
PORT=${PORT:-8080}

if [[ "${MIGRATION_ENABLED}" == "true" ]]; then
  echo "Running migrations"
  flask upgrade-db
fi

if [[ "${MODE}" == "worker" ]]; then
  celery -A app.celery worker -P ${CELERY_WORKER_CLASS:-gevent} -c ${CELERY_WORKER_AMOUNT:-1} --loglevel INFO \
    -Q ${CELERY_QUEUES:-dataset,generation,mail}
elif [[ "${MODE}" == "beat" ]]; then
  celery -A app.celery beat --loglevel INFO
else
  if [[ "${DEBUG}" == "true" ]]; then
    flask run --host=${DIFY_BIND_ADDRESS:-0.0.0.0} --port=${PORT} --debug
  else
    gunicorn \
      --bind "${DIFY_BIND_ADDRESS:-0.0.0.0}:${PORT}" \
      --workers ${SERVER_WORKER_AMOUNT:-1} \
      --worker-class ${SERVER_WORKER_CLASS:-gevent} \
      --timeout ${GUNICORN_TIMEOUT:-200} \
      --preload \
      app:app
  fi
fi
