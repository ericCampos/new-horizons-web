#!/usr/bin/env bash
# Who wrote the production code? Counts lines in src by `git blame` author.
# KPI of the learning project: Eric must own >= 30 % of production lines (see README "Authorship").
set -euo pipefail
cd "$(dirname "$0")/.."
DIR="${1:-src}"
git ls-files "$DIR" | while read -r f; do git blame --line-porcelain -- "$f" | grep '^author ' ; done \
  | sed 's/^author //' | sort | uniq -c | sort -rn \
  | awk '{n=$1; $1=""; total+=n; a[NR]=n; b[NR]=$0} END {for(i=1;i<=NR;i++) printf "%6d  %5.1f%%  %s\n", a[i], 100*a[i]/total, b[i]; printf "%6d  total lines in %s\n", total, "'"$DIR"'"}'
