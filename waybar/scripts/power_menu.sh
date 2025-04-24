#!/bin/bash

export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
chosen=$(echo -e "⏾ Suspend\n🌙 Hibernate\n⏻ Shutdown\n Reboot" | rofi -dmenu -i -p "Power Menu" -theme ~/.config/rofi/power_menu.rasi)

case "$chosen" in
  *Suspend) systemctl suspend ;;
  *Hibernate) systemctl hibernate ;;
  *Shutdown) systemctl poweroff ;;
  *Reboot) systemctl reboot ;;
esac

