#!/bin/bash

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    echo "$value"
}

line_number=1
skipped=0

{
    read -r _

    while read -r line; do

        ((line_number++))
        line="${line%$'\r'}"
        line="${line%$'\r'}"

        IFS=',' read -r name html css bash_score git_score <<< "$line"

        name=$(trim "$name")
        html=$(trim "$html")
        css=$(trim "$css")
        bash_score=$(trim "$bash_score")
        git_score=$(trim "$git_score")

        if [[ -z "$name" ]]; then
            echo "Warning: Missing student name on line $line_number" >&2
            ((skipped++))
            continue
        fi

        if [[ ! "$html" =~ ^[0-9]+$ ]] || \
            [[ ! "$css" =~ ^[0-9]+$ ]] || \
            [[ ! "$bash_score" =~ ^[0-9]+$ ]] || \
            [[ ! "$git_score" =~ ^[0-9]+$ ]]; then

            echo "Warning: Invalid record on line $line_number" >&2
            ((skipped++))
            continue
        fi

        if (( html > 20 || css > 20 || bash_score > 20 || git_score > 20 )); then
            echo "Warning: Score above 20 on line $line_number" >&2
            ((skipped++))
            continue
        fi

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

echo "Skipped records: $skipped"