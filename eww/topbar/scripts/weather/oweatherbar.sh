#!/bin/bash
    #read the conf file for the needed info
    read a b c lat lon<<< $(tr '\n' ' ' <$HOME/.config/eww/topbar/scripts/weather/wbar.conf)
    #get current weather info from OWM, use jq to strip it down to main temp and the icon id, then strip linebreaks and quotes from it
    read d <<< $(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$b&units=$c" | jq -r '.main.temp' | tr '\n' ' ' | sed "s/\"//g")
    #round the current temp to an integer
    t=$(printf %.0f "${d/./,}")
echo "$t°C" #put em together
