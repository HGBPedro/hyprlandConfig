#!/usr/bin/env bash
# Lista dispositivos de saída (sinks) e entrada (sources) em JSON,
# marcando o padrão, e reemite quando algo muda.
# Requer: pipewire-pulse (pactl) e jq

last=""
emit() {
    def_sink=$(pactl get-default-sink)
    def_source=$(pactl get-default-source)

    sinks=$(pactl -f json list sinks | jq -c --arg d "$def_sink" \
        '[.[] | {name, desc: .properties."device.description", default: (.name == $d)}]')

    # ignora os ".monitor" (que não são microfones de verdade)
    sources=$(pactl -f json list sources | jq -c --arg d "$def_source" \
        '[.[] | select(.name | endswith(".monitor") | not)
              | {name, desc: .description, default: (.name == $d)}]')

    json=$(jq -nc --argjson s "${sinks:-[]}" --argjson m "${sources:-[]}" \
        '{sinks: $s, sources: $m}')
    if [ "$json" != "$last" ]; then
        echo "$json"
        last=$json
    fi
}

emit
pactl subscribe 2>/dev/null \
    | grep --line-buffered -E "'(new|remove|change)' on (sink|source|server)" \
    | while read -r _; do emit; done
