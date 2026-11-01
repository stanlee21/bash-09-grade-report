#!/bin/bash

{
    read -r header

    while read -r line; do
        IFS=',' read -r name html css bash_score git_score <<< "$line"

        echo "Name: $name | HTML: $html | CSS: $css | Bash: $bash_score | Git: $git_score"
    done
} < grades.csv