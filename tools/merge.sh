#!/bin/bash

# Merge two JSON files

shopt -s dotglob
find apps/* -prune -type d | while IFS= read -r d; do 
    APP_NAME=$(echo "${d}" |cut -d / -f 2)
    echo "${APP_NAME}"
    jq -s add "out/${APP_NAME}/summary.json" "apps/${APP_NAME}/summary.json" | tee "out/${APP_NAME}/summary.json"
done