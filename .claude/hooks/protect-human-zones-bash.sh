#!/usr/bin/env bash
# PreToolUse (Bash): cierra la puerta trasera. El matcher Edit|Write no ve `sed -i`, `>`, `cp`… desde Bash.
# Heurística, no sandbox: si el comando menciona el ancla de una zona humana (o la configuración de
# guardia) Y contiene una operación de escritura, se bloquea. Leer (cat, grep, git diff, tests) sí se puede.
# Falsos positivos posibles (p. ej. un '>' en un mensaje de commit): reformular el comando.
set -uo pipefail
input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[ -z "$cmd" ] && exit 0
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Quita redirecciones inofensivas antes de buscar escrituras.
clean=$(sed -E 's/[0-9]?>&[0-9]//g; s#[0-9]?>+ */dev/null##g' <<<"$cmd")
writes='(^|[^0-9>&-])>|\btee\b|\bsed\b[^|;&]*[[:space:]]-[a-zA-Z]*i|\bperl\b[^|;&]*[[:space:]]-[a-zA-Z]*i|\b(mv|cp|rm|truncate|dd|install|ln|touch|patch|chmod|rsync)\b|\bgit[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(checkout|restore|reset|stash|apply|mv|rm|am|cherry-pick|revert)\b|\b(python3?|node|ruby|awk|gawk)\b'
grep -Eq "$writes" <<<"$clean" || exit 0

anchors=(".claude/hooks" ".claude/settings.json" "human-zones.txt")
for zf in "$root"/.claude/human-zones.txt "$root"/*/.claude/human-zones.txt; do
  [ -f "$zf" ] || continue
  while IFS= read -r line; do
    [[ "$line" == *"|"* ]] || continue
    [[ "$line" == \#* ]] && continue
    a=$(sed 's/^.*|[[:space:]]*//; s/[[:space:]]*$//' <<<"$line")
    [ -n "$a" ] && anchors+=("$a")
  done < "$zf"
done

for a in "${anchors[@]}"; do
  if [[ "$clean" == *"$a"* ]]; then
    echo "Bloqueado: el comando escribe o mueve algo que coincide con '$a' (zona humana o configuración" \
         "de guardia). Eso lo hace Eric. Si solo querías leer, usa Read/cat sin redirecciones." >&2
    exit 2
  fi
done
exit 0
