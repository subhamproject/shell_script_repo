#!/bin/bash
containers=(jackett lidarr medusa radarr)
for i in "${containers[@]}"; do
    health=$(/usr/bin/docker inspect "$i" | jq '.' | jq '.[0].State.Health.Status' | sed -e 's/^"//' -e 's/"$//')
    if [[ "${health}" != @(healthy|starting) ]]; then
        "/usr/bin/docker" restart "${i}" ; "/usr/bin/docker" rm "${i}" && "/usr/local/bin/docker-compose" -f "/home/jason/docker/docker-compose.yml" up -d
    fi
done
