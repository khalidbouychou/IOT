#!/bin/bash

mkdir -p ~/iot-gitlab/config ~/iot-gitlab/logs ~/iot-gitlab/data
docker run -d \
  --name gitlab-local \
  --hostname localhost \
  -p 8081:80 \
  --restart always \
  --env GITLAB_OMNIBUS_CONFIG=" \
    external_url 'http://localhost:8081'; \
    puma['worker_processes'] = 0; \
    sidekiq['max_concurrency'] = 5; \
    prometheus_monitoring['enable'] = false; \
    grafana['enable'] = false;" \
  -v ~/iot-gitlab/config:/etc/gitlab \
  -v ~/iot-gitlab/logs:/var/log/gitlab \
  -v ~/iot-gitlab/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:latest

  kubectl create namespace gitlab