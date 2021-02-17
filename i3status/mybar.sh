#!/bin/sh

# i3 config in ~/.config/i3/config :
# bar {
#   status_command exec /home/shane/repos/i3status/i3status/mybar.sh
# }

bg_bar_color="#000000"

# Print a left caret separator
# @params {string} $1 text color, ex: "#FF0000"
# @params {string} $2 background color, ex: "#FF0000"
separator() {
  echo -n "{"
  echo -n "\"full_text\":\"\"," # CTRL+Ue0b2
  echo -n "\"separator\":false,"
  echo -n "\"separator_block_width\":0,"
  echo -n "\"border\":\"$bg_bar_color\","
  echo -n "\"border_left\":0,"
  echo -n "\"border_right\":0,"
  echo -n "\"border_top\":2,"
  echo -n "\"border_bottom\":2,"
  echo -n "\"color\":\"$1\","
  echo -n "\"background\":\"$2\""
  echo -n "}"
}

common() {
  echo -n "\"border\": \"$bg_bar_color\","
  echo -n "\"separator\":false,"
  echo -n "\"separator_block_width\":0,"
  echo -n "\"border_top\":2,"
  echo -n "\"border_bottom\":2,"
  echo -n "\"border_left\":0,"
  echo -n "\"border_right\":0"
}

host() {
  local bg="#FFD180"
  separator $bg $bg_bar_color
  echo -n ",{"
  echo -n "\"name\":\"id_crypto\","
  echo -n "\"full_text\":\"$(whoami)  \","
  echo -n "\"color\":\"$bg_bar_color\","
  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
}

myvpn_on() {
  local bg="#424242" # grey darken-3
  local icon=""
  if [ -d /proc/sys/net/ipv4/conf/proton0 ]; then
    bg="#E53935" # rouge
    icon=""
  fi
  separator $bg "#FFD180" # background left previous block
  bg_separator_previous=$bg
  echo -n ",{"
  echo -n "\"name\":\"id_vpn\","      
  echo -n "\"full_text\":\" ${icon} VPN \","
  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
}

myip_local() {
  local bg="#2E7D32" # vert
  separator $bg $bg_separator_previous
  echo -n ",{"
  echo -n "\"name\":\"ip_local\","
  echo -n "\"full_text\":\"  $(ip route get 1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p') :: $(awk 'NR==3 {print $3+"\b"}''' /proc/net/wireless)% \","
  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
}

disk_usage() {
  local bg="#3949AB"
  separator $bg "#2E7D32"
  echo -n ",{"
  echo -n "\"name\":\"id_disk_usage\","
  echo -n "\"full_text\":\"  $(df -BG | awk '{if($6 == "/") {print $5+"\b"}}')%\","
  echo -n "\"background\":\"$bg\","
  common
  echo -n "}"
}

memory() {
  echo -n ",{"
  echo -n "\"name\":\"id_memory\","
  echo -n "\"full_text\":\"  $(free --human | awk '{if ($1=="Mem:"){print $3,"/",$2}}')\","
  echo -n "\"background\":\"#3949AB\","
  common
  echo -n "}"
}

cpu_usage() {
  echo -n ",{"
  echo -n "\"name\":\"id_cpu_usage\","
  echo -n "\"full_text\":\" 🖥️ $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}') \","
  echo -n "\"background\":\"#3949AB\","
  common
  echo -n "},"
}

meteo() {
  local bg="#546E7A"
  separator $bg "#3949AB"
  bluetooth_status=$(bluetoothctl show | grep Powered | awk '{if($2 == "yes"){print "true"}else{print "false"}}')
  connected_device=$(bluetoothctl info | perl -n -e '/.+Name: (.+)/ && print $1')
  echo -n ",{"
  echo -n "\"name\":\"id_meteo\","

  if [ $bluetooth_status == "true" ]; then
    if [[ -z $connected_device ]]; then
      echo -n "\"full_text\":\"  \","
    else
      echo -n "\"full_text\":\"  $connected_device \","
    fi
  else
    echo -n "\"full_text\":\"  \","
  fi

  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
}

mydate() {
  local bg="#E0E0E0"
  separator $bg "#546E7A"
  echo -n ",{"
  echo -n "\"name\":\"id_time\","
  echo -n "\"full_text\":\"  $(date "+%a %d/%m %H:%M") \","
  echo -n "\"color\":\"#000000\","
  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
}

battery0() {
  if [ -f /sys/class/power_supply/BAT0/uevent ]; then
    prct=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_CAPACITY=" | cut -d'=' -f2)
    charging=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_STATUS" | cut -d'=' -f2) # POWER_SUPPLY_STATUS=Discharging|Charging

    if (( $prct < 20 )); then
	temp_bg='#680101'
    else
	temp_bg='#D69E2E'
    fi

    local bg=$temp_bg
    separator $bg "#E0E0E0"
    bg_separator_previous=$bg
    icon=""
    if [ "$charging" == "Charging" ]; then
      icon=""
    fi
    echo -n ",{"
    echo -n "\"name\":\"battery0\","
    echo -n "\"full_text\":\" ${icon} ${prct}% \","
    echo -n "\"color\":\"#000000\","
    echo -n "\"background\":\"$bg\","
    common
    echo -n "},"
  else
    bg_separator_previous="#E0E0E0"
  fi
}

volume() {
  local bg="#673AB7"
  separator $bg $bg_separator_previous  
  vol=$(awk -F"[][]" '/dB/ { print $2+'\b' }' <(amixer sget Master))
  echo -n ",{"
  echo -n "\"name\":\"id_volume\","
  if [ $vol -le 0 ]; then
    echo -n "\"full_text\":\"  ${vol}% \","
  else
    echo -n "\"full_text\":\"  ${vol}% \","
  fi
  echo -n "\"background\":\"$bg\","
  common
  echo -n "},"
  separator $bg_bar_color $bg
}

logout() {
  echo -n ",{"
  echo -n "\"name\":\"id_logout\","
  echo -n "\"full_text\":\"  \""
  echo -n "}"
}

# https://github.com/i3/i3/blob/next/contrib/trivial-bar-script.sh
echo '{ "version": 1, "click_events":true }'     # Send the header so that i3bar knows we want to use JSON:
echo '['                    # Begin the endless array.
echo '[]'                   # We send an empty first array of blocks to make the loop simpler:

# Now send blocks with information forever:
(while :;
do
	echo -n ",["
  host
  myvpn_on
  myip_local
  disk_usage
  memory
  cpu_usage
  meteo
  mydate
  battery0
  volume
  logout
  echo "]"
	sleep 2
done) &

# click events
while read line;
do
  # echo $line > /home/you/gitclones/github/i3/tmp.txt
  # {"name":"id_vpn","button":1,"modifiers":["Mod2"],"x":2982,"y":9,"relative_x":67,"relative_y":9,"width":95,"height":22}

  terminal_emulator=$(ps -p $(ps -p $$ -o ppid=) o args=)
  # VPN click
  if [[ $line == *"name"*"id_vpn"* ]]; then
    # $terminal_emulator -e /home/shane/repos/i3status/i3status/click_vpn.sh &
    echo "efr"

  # CPU
  elif [[ $line == *"name"*"id_cpu_usage"* ]]; then
    $terminal_emulator -e htop &

  # TIME
  elif [[ $line == *"name"*"id_time"* ]]; then
    $terminal_emulator -e /home/shane/repos/i3status/i3status/click_time.sh &

  # METEO
  elif [[ $line == *"name"*"id_meteo"* ]]; then
    xdg-open https://openweathermap.org/city/2986140 > /dev/null &

  # CRYPTO
  elif [[ $line == *"name"*"id_crypto"* ]]; then
    xdg-open https://www.livecoinwatch.com/ > /dev/null &

  # VOLUME
  elif [[ $line == *"name"*"id_volume"* ]]; then
    $terminal_emulator -e alsamixer &

  # LOGOUT
  elif [[ $line == *"name"*"id_logout"* ]]; then
    i3-nagbar -t warning -m 'Log out ?' -b 'yes' 'i3-msg exit' > /dev/null &

  fi  
done
