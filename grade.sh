#!/bin/bash

{
    read -r _

    while read -r line; do
        IFS=',' read -r name html css bash_score git_score <<< "$line"

        total=$((html + css + bash_score + git_score))

        average=$(awk -v total="$total" 'BEGIN { printf "%.2f", total / 4 }')

        echo "Name: $name | Total: $total | Average: $average"
    done
} < grades.csv