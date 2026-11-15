#!/bin/sh
set -e
clear
sync
arch='ntp'
ping 1.1.1.1 -c5 -D -s1024 | tee "${arch}"
ntpd -gq | tee -a "${arch}"
ntpdate -u ntp.metas.ch | tee -a "${arch}"
ntpdate -u time.nist.gov | tee -a "${arch}"
ntpdate -u ntp.inti.gob.ar | tee -a "${arch}"
ntpq -p | tee -a "${arch}"
ntpq -pn | tee -a "${arch}"
sync
exit 0
