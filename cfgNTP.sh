#!/bin/sh
# Provisionamiento NTP modular
. ./imp.sh
. ./cfgSV.sh
confNTPserver='
server ntp.metas.ch iburst
server ntp11.metas.ch
server ntp12.metas.ch
server ntp13.metas.ch
server time.nist.gov
server ntp.ign.gob.ar
server ntp.inti.gob.ar
'
configurarNtp() {
	impMsg "$CIA" "Ajustando daemon de red NTP..."
	case "$soTarget" in
		void) [ -f "/etc/ntp.conf" ] && { execSudo ln -sf /etc/sv/ntpd /var/service/ 2>/dev/null; execSudo sv up ntpd >/dev/null 2>&1 || true; } ;;
		debian)
			_ntpConf="/etc/ntpsec/ntp.conf"
			if [ -f "$_ntpConf" ]; then
				execSudo sed -i '/^pool /d; /^server /d' "$_ntpConf" 2>/dev/null
				printf "${confNTPserver}" | execSudo tee -a "$_ntpConf" >/dev/null
				execSudo systemctl restart ntpsec >/dev/null 2>&1 || execSudo systemctl restart ntp >/dev/null 2>&1 || true
			fi ;;
		freebsd)
			_ntpConf="/etc/ntp.conf"
			execSudo sed -i '' '/^pool /d; /^server /d' "$_ntpConf" 2>/dev/null || true
			printf "server ntp.inti.gob.ar iburst\n" | execSudo tee -a "$_ntpConf" >/dev/null
			execSudo sysrc ntpd_enable="YES" >/dev/null 2>&1
			execSudo service ntpd restart >/dev/null 2>&1 || true ;;
	esac
	crearSvNTP
}
