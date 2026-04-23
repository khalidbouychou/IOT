#!/bin/bash


# This script sets up a lightweight GitLab instance using Docker on a Mac with limited resources.
mkdir -p /goinfre/$(whoami)/gitlab/config
mkdir -p /goinfre/$(whoami)/gitlab/logs
mkdir -p /goinfre/$(whoami)/gitlab/data

docker run -d \
  --name gitlab-local \
  --hostname localhost \
  -p 8081:80 \
  --env GITLAB_OMNIBUS_CONFIG=" \
    external_url 'http://localhost:8081'; \
    # Disable components removed or changed in v18
    prometheus_monitoring['enable'] = false; \
    sidekiq['max_concurrency'] = 5; \
    puma['worker_processes'] = 0; \
    # Disable other heavy monitoring
    alertmanager['enable'] = false; \
    gitlab_exporter['enable'] = false; \
    node_exporter['enable'] = false; \
    postgres_exporter['enable'] = false; \
    redis_exporter['enable'] = false;" \
  -v /goinfre/$(whoami)/gitlab/config:/etc/gitlab \
  -v /goinfre/$(whoami)/gitlab/logs:/var/log/gitlab \
  -v /goinfre/$(whoami)/gitlab/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:latest