#!/usr/bin/env bash
# Brilho de monitor externo via DDC/CI (ddcutil).
#
# ddcutil é lento (~100-300 ms por chamada), então o valor fica guardado num
# arquivo de estado: a interface lê o arquivo (instantâneo) e as escritas no
# monitor rodam em segundo plano, aplicando só o valor mais recente quando o
# slider é arrastado rápido.
#
# Uso: brightness.sh listen | get | set <0-100> | up | down
# Opcional: export DDC_BUS=N (veja `ddcutil detect`) deixa tudo mais rápido.

state="${XDG_RUNTIME_DIR:-/tmp}/eww-brightness"
applied="$state.applied"
maxfile="$state.max"
lock="$state.lock"
step=5

ddc() {
    ddcutil ${DDC_BUS:+--bus "$DDC_BUS"} --noverify --sleep-multiplier 0.5 "$@" 2>/dev/null
}

# lê o brilho real do monitor e salva no estado
read_hw() {
    # saída: "VCP 10 C <atual> <máximo>"
    read -r _ _ _ cur max < <(ddc getvcp 10 --brief)
    [ -z "$max" ] || [ "$max" -eq 0 ] && max=100
    echo "$max" > "$maxfile"
    pct=$(( ${cur:-0} * 100 / max ))
    echo "$pct" > "$state"
    echo "$pct" > "$applied"
}

get() {
    [ -f "$state" ] || read_hw
    cat "$state"
}

apply() {
    exec 9>"$lock"
    flock -n 9 || exit 0          # já tem um aplicando; ele pega o valor novo
    max=$(cat "$maxfile" 2>/dev/null || echo 100)
    while :; do
        want=$(<"$state")
        [ "$want" = "$(cat "$applied" 2>/dev/null)" ] && break
        ddc setvcp 10 $(( want * max / 100 )) && echo "$want" > "$applied"
    done
}

set_pct() {
    v=${1%%.*}                    # o slider pode mandar decimais
    (( v < 0 )) && v=0
    (( v > 100 )) && v=100
    echo "$v" > "$state"
    apply &
}

case "$1" in
    listen)
        read_hw
        last=""
        while :; do
            cur=$(cat "$state" 2>/dev/null)
            [ "$cur" != "$last" ] && echo "$cur" && last=$cur
            sleep 0.2
        done ;;
    get)  get ;;
    set)  set_pct "$2" ;;
    up)   set_pct $(( $(get) + step )) ;;
    down) set_pct $(( $(get) - step )) ;;
    *)    echo "uso: $0 listen|get|set N|up|down" >&2; exit 1 ;;
esac
