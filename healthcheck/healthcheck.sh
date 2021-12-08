#!/usr/bin/env bash
set -euo pipefail

NUM_REPLICAS="${NUM_REPLICAS:-2}"
SLEEP_TIME="${SLEEP_TIME:-300}"

if [[ -z "${PATRONI_URL:-}" ]]; then
  >&2 echo "Error: Please set PATRONI_URL"
  exit 1
fi

if [[ -z "${HEALTHCHECK_URL:-}" ]]; then
  >&2 echo "Error: Please set HEALTHCHECK_URL"
  exit 1
fi

success() {
  >&2 echo "ok"
  curl -fsS -m 10 --retry 5 "$HEALTHCHECK_URL" >/dev/null
}

fail() {
  local message="$1"

  >&2 echo "$message"
  curl -fsS -m 10 --retry 5 --data-raw "$message" "$HEALTHCHECK_URL/fail" >/dev/null
}

main() {
  while true; do
    running="ok"
    result="$(curl -s "$PATRONI_URL")" || running=no
    if [[ "$running" != "ok" ]]; then
      fail "curl request failed"
    else
      state="$(echo "$result" | jq -r .state | grep -q running && echo ok)"
      num_streaming="$(echo "$result" | jq -r .replication[].state | grep -c streaming || echo 0)"

      if [[ "$state" == "ok" && "$num_streaming" == "$NUM_REPLICAS" ]]; then
        success
      else
        fail "$result"
      fi
    fi

    sleep "$SLEEP_TIME"
  done
}

main
