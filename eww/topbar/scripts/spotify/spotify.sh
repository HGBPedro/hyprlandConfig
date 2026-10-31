#!/usr/bin/env bash
# Segue o Spotify via MPRIS e emite JSON com status, música, artista e capa.
# Requer: playerctl, jq, curl

cache="${XDG_CACHE_HOME:-$HOME/.cache}/eww/spotify"
mkdir -p "$cache"
sep=$'\x1f'

stopped='{"status":"Stopped","title":"","artist":"","art":""}'
echo "$stopped"

playerctl --player=spotify --follow metadata \
    --format "{{status}}${sep}{{title}}${sep}{{artist}}${sep}{{mpris:artUrl}}" 2>/dev/null \
| while IFS="$sep" read -r status title artist art_url; do
    # linha vazia = Spotify foi fechado
    if [ -z "$status" ]; then
        echo "$stopped"
        continue
    fi

    art=""
    if [[ $art_url == http* ]]; then
        file="$cache/$(basename "$art_url").jpg"
        [ -f "$file" ] || curl -sfL "$art_url" -o "$file"
        [ -f "$file" ] && art="$file"
    fi

    jq -nc --arg s "$status" --arg t "$title" --arg a "$artist" --arg i "$art" \
        '{status: $s, title: $t, artist: $a, art: $i}'
done
