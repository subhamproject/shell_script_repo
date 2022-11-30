#!/bin/bash

cd /usr/share/grafana

grafana-cli admin reset-admin-password admin

grafana-cli admin reset-admin-password <new pass>
