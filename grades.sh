#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <grades.csv>" >&2
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found." >&2
    exit 1
fi

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    echo "$value"
}

line_number=1
skipped=0
valid_count=0
class_total=0

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

{
    if ! read -r _; then
        echo "Error: CSV file is empty." >&2
        exit 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do

        ((line_number++))
        line="${line%$'\r'}"

        if [[ -z "$(trim "$line")" ]]; then
            continue
        fi

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

        ((valid_count++))
        ((class_total += total))
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

        echo "$average|$name|$total|$html|$css|$bash_score|$git_score|$mention" >> "$tmp"
    done
} < "$1"

echo "========================================================================"
echo "                    STUDENT GRADE REPORT"
echo "========================================================================"

printf "%-5s %-15s %-5s %-5s %-5s %-5s %-7s %-8s %s\n" \
"RANK" "NAME" "HTML" "CSS" "BASH" "GIT" "TOTAL" "AVERAGE" "MENTION"

echo "---------------------------------------------------------------"

position=0
rank=0
previous_average=""

sort -t'|' -k1,1 -rn "$tmp" | while IFS='|' read -r average name total html css bash_score git_score mention; do
    ((position++))

    if [[ "$average" != "$previous_average" ]]; then
        rank=$position
    fi

    previous_average="$average"

    printf "%-5s %-15s %-5s %-5s %-5s %-5s %-7s %-8s %s\n" \
    "$rank" "$name" "$html" "$css" "$bash_score" "$git_score" "$total" "$average" "$mention"
done

class_average=$(awk -v total="$class_total" -v count="$valid_count" 'BEGIN {
    if (count > 0)
        printf "%.2f", total / (count * 4)
    else
        printf "0.00"
}')

echo "---------------------------------------------------------------"
printf "Class Average: %.2f\n" "$class_average"
printf "Skipped Records: %d\n" "$skipped"
echo "==============================================================="