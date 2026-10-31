#!/usr/bin/env bash
# Emite o volume atual como JSON sempre que ele muda.
# Uso: volume.sh sink   (saída / alto-falante)
#      volume.sh source (entrada / microfone)
# Requer: wireplumber (wpctl) e pipewire-pulse (pactl)

if [ "$1" = "source" ]; then
    dev="@DEFAULT_AUDIO_SOURCE@"
else
    dev="@DEFAULT_AUDIO_SINK@"
fi

last=""
emit() {
    out=$(wpctl get-volume "$dev" 2>/dev/null)          # ex: "Volume: 0.45 [MUTED]"
    level=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$out")
    muted=false
    [[ $out == *MUTED* ]] && muted=true
    json=$(printf '{"level":%s,"muted":%s}' "${level:-0}" "$muted")
    if [ "$json" != "$last" ]; then
        echo "$json"
        last=$json
    fi
}

emit
pactl subscribe 2>/dev/null \
    | grep --line-buffered -E "'change' on (sink|source|server)" \
    | while read -r _; do emit; done
