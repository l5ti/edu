#!/bin/bash
BASE_URL="$1"

# Liste: "Host-Header Erwarteter-Status"
# Nutze '4xx' als Platzhalter für jeden Client-Fehler
TESTS=(
  "$BASE_URL 200"
  "any 200"
  "anyX 4xx"
  "Xany 4xx"
  "${BASE_URL}X 4xx"
  "X${BASE_URL} 4xx"
  "${BASE_URL/./X} 4xx"
)

echo "RESULT  | URL                          | HOST HEADER          | EXP | GOT"
echo "--------------------------------------------------------------------------"

for entry in "${TESTS[@]}"; do
  read -r HOST EXPECTED <<< "$entry"
  URL="https://$BASE_URL"

  # Curl Call
  GOT=$(curl -sL -o /dev/null -w "%{http_code}" -H "Host: $HOST" "$URL")

  # Logik für 4xx Validierung
  if [[ "$EXPECTED" == "4xx" ]]; then
    [[ "$GOT" =~ ^4 ]] && RES="OK" || RES="FAILED"
  else
    [[ "$GOT" == "$EXPECTED" ]] && RES="OK" || RES="FAILED"
  fi

  # Ausgabe mit printf für saubere Spalten
  printf "%-7s | %-28s | %-20s | %-3s | %s\n" "$RES" "$URL" "$HOST" "$EXPECTED" "$GOT"
done