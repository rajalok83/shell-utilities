#!/bin/bash
min_bat_threshold=12
max_bat_threshold=98
charging_status="NOT CHARGING"
battery_status="FULL"
log_tag="BATTERY"
export DISPLAY=:0
XAUTHORITY=${HOME}/.Xauthority
log_file="${HOME}/Desktop/logs/cron.log"
if [ -r "${HOME}/.dbus/Xdbus" ]; then
    . "${HOME}/.dbus/Xdbus"
fi
now=`date '+%Y%m%d-%H%M'`
today=`echo ${now} | cut -d- -f1`
count=`cat ${log_file} | grep ${today} | wc -l`
if [ ${count} -eq 0 ] 
then
 > ${log_file}
fi
ac_power_status=`cat /sys/class/power_supply/AC0/online`
battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
if [[ ${battery_level} -le ${min_bat_threshold} ]]
then
    battery_status="LOW"
else
    if [[ ${battery_level} -ge ${max_bat_threshold} ]]
    then
       battery_status="FULL"
    else
       battery_status="OK"
    fi
fi
if [[ "${ac_power_status}" == "1" ]]
then
    charging_status="CHARGING    "
fi
log_txt="${now}:BATTERY=${battery_level}:CHARGING=${charging_status}:MIN_THRESHOLD=${min_bat_threshold}:MAX_THRESHOLD=${max_bat_threshold}"
echo "${log_txt}:BATTERY=${battery_status}" >> ${log_file}
if [[ ${battery_level} -le ${min_bat_threshold} && "${ac_power_status}" == "0" ]] || [[ ${battery_level} -gt ${max_bat_threshold} && "${ac_power_status}" == "1" ]]
then
    eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
    /usr/bin/notify-send -u critical -t 200000 -a "Battery" "Battery level is ${battery_level}(${battery_status})%!" 
fi
