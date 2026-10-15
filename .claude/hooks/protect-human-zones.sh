#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit|NotebookEdit): Claude no escribe en las zonas humanas de Eric.
# Por qué un hook y no una instrucción: una instrucción se puede saltar; un hook lo ejecuta Claude Code
# y con exit 2 la escritura no ocurre. La autoría de Eric (KPI del 30 %) depende de esto.
# Zonas: <repo>/.claude/human-zones.txt, una por línea: `glob | ancla` (el ancla la usa el hook de Bash).
# También protege la propia configuración de guardia (hooks, settings, listas de zonas).
set -uo pipefail
input=$(cat)
file=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input")
[ -z "$file" ] && exit 0
file=$(realpath -m "$file")

case "$file" in
  */.claude/hooks/*|*/.claude/settings.json|*/.claude/human-zones.txt)
    echo "Bloqueado: '$file' es configuración de guardia del tutor. Solo la cambia Eric a mano." >&2
    exit 2 ;;
esac

# Sube desde el fichero hasta encontrar el repo que declara zonas humanas (api/ o web/).
dir=$(dirname "$file")
while [ "$dir" != "/" ] && [ ! -f "$dir/.claude/human-zones.txt" ]; do dir=$(dirname "$dir"); done
[ -f "$dir/.claude/human-zones.txt" ] || exit 0
rel="${file#"$dir"/}"

while IFS= read -r line; do
  pattern=$(sed 's/[[:space:]]*|.*$//; s/[[:space:]]*$//' <<<"$line")
  [ -z "$pattern" ] && continue
  [[ "$pattern" == \#* ]] && continue
  # Sin comillas a propósito: es un glob. En [[ == ]] el * cruza '/', así que ** se comporta como se espera.
  if [[ "$rel" == $pattern ]]; then
    echo "Bloqueado: '$rel' es ZONA HUMANA (lo escribe Eric). No busques otro camino: deja un" \
         "'TODO(human): <tarea en una línea>' en un fichero vecino tuyo, explica la tarea y para." >&2
    exit 2
  fi
done < "$dir/.claude/human-zones.txt"
exit 0
