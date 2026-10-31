#!/usr/bin/env bash
# Texto rolante "artista — música" do Spotify para o eww.
# Se o texto couber em LARGURA caracteres, fica parado; se não, rola.
# A rolagem pausa um pouco no início de cada volta e congela quando a música
# está pausada.
#
# Uso: marquee.sh [LARGURA] [INTERVALO]
#   LARGURA   quantos caracteres cabem no widget (padrão 26)
#   INTERVALO segundos entre cada passo da rolagem (padrão 0.25)

export LC_ALL=C.UTF-8           # para cortar por caractere, não por byte

width=${1:-26}
interval=${2:-0.25}
hold=8                          # passos parados no início de cada volta
gap="     •     "               # separador entre o fim e o recomeço

state="${XDG_RUNTIME_DIR:-/tmp}/eww-spotify-marquee"
: > "$state"

# segue o Spotify em segundo plano e grava "status<US>texto" no arquivo
sep=$'\x1f'
playerctl --player=spotify --follow metadata \
    --format "{{status}}${sep}{{artist}} — {{title}}" 2>/dev/null \
| while IFS= read -r line; do
    printf '%s' "$line" > "$state"
done &
trap 'kill 0' EXIT

text="" status="" offset=0 wait=0 last_out=""
while :; do
    raw=$(<"$state")
    new_status=${raw%%"$sep"*}
    new_text=${raw#*"$sep"}
    [ -z "$raw" ] && new_text=""

    if [ "$new_text" != "$text" ]; then  # música trocou: volta pro início
        text=$new_text
        offset=0
        wait=$hold
    fi
    status=$new_status

    if (( ${#text} <= width )); then
        out=$text
    else
        loop="${text}${gap}"
        len=${#loop}
        double="${loop}${loop}"
        out=${double:offset:width}

        if [ "$status" = "Playing" ]; then
            if (( wait > 0 )); then
                (( wait-- ))
            else
                offset=$(( (offset + 1) % len ))
                (( offset == 0 )) && wait=$hold
            fi
        fi
    fi

    if [ "$out" != "$last_out" ]; then
        echo "$out"
        last_out=$out
    fi
    sleep "$interval"
done
