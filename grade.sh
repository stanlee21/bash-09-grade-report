#!/bin/bash

{
    read -r _

    while read -r line; do
        IFS=',' read -r name html css bash_score git_score <<< "$line"

        total=$((html + css + bash_score + git_score))

        average=$(awk -v total="$total" 'BEGIN { printf "%.2f", total / 4 }')

        if [ "$total" -ge 64 ]; then
            mention="Très bien"
        elif [ "$total" -ge 56 ]; then
            mention="Bien"
        elif [ "$total" -ge 48 ]; then
            mention="Assez bien"
        elif [ "$total" -ge 40 ]; then
            mention="Passable"
        else
            mention="Échec"
        fi

        echo "Name: $name | Total: $total | Average: $average | Mention: $mention"
    done
} < grades.csv