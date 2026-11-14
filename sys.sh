#!/bin/sh
run() { sudo "$@"; }
so_call() { case "$SO" in
	void) case "$1" in
		upd) xbps-install -S >/dev/null 2>&1 ;;
		chk) xbps-query -l | grep -q " ${2}-" ;;
		rep) xbps-query -Rs "^${2}-[0-9]" ;;
		ins) run xbps-install -y "$2" ;;
		ntp) [ -f "/etc/ntp.conf" ] && run ln -sf /etc/sv/ntpd /var/service/ ;;
		fw_save) run mkdir -p "/etc/$2"; run sh -c "$2-save > /etc/$2/rules.v$3" ;;
		kbd) if [ -f /etc/rc.conf ]; then run sed -i 's/^KEYMAP=.*/KEYMAP="es"/' /etc/rc.conf; grep -q "^KEYMAP=" /etc/rc.conf || printf 'KEYMAP="es"\n' | run tee -a /etc/rc.conf >/dev/null; fi ;;
	esac ;;
	debian) case "$1" in
		upd) run apt-get update -y >/dev/null 2>&1 ;;
		chk) dpkg-query -W -f='${Status}' "$2" 2>/dev/null | grep -q "ok installed" ;;
		rep) apt-cache search "^${2}$" ;;
		ins) run DEBIAN_FRONTEND=noninteractive apt-get install -y "$2" ;;
		ntp) if [ -f "/etc/ntpsec/ntp.conf" ]; then run sed -i '/^pool /d; /^server /d' /etc/ntpsec/ntp.conf; printf "server %s iburst\n" "ntp.inti.gob.ar" | run tee -a /etc/ntpsec/ntp.conf >/dev/null; fi ;;
		fw_save) if [ -d /etc/iptables ]; then run sh -c "$2-save > /etc/iptables/rules.v$3"; fi ;;
		kbd) if [ -f /etc/default/keyboard ]; then run sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard; fi ;;
	esac ;;
	freebsd) case "$1" in
		upd) run pkg update -q >/dev/null 2>&1 ;;
		chk) pkg info -e "$2" ;;
		rep) pkg search -qx "^${2}$" ;;
		ins) run pkg install -y "$2" ;;
		ntp) run sed -i '' '/^pool /d; /^server /d' /etc/ntp.conf; printf "server %s iburst\n" "ntp.inti.gob.ar" | run tee -a /etc/ntp.conf >/dev/null; run sysrc ntpd_enable="YES" >/dev/null 2>&1 ;;
		fw_save) out msg "[Aviso] FreeBSD usa PF/IPFW nativo." ;;
		kbd) run sysrc keymap="spanish.iso.acc" >/dev/null 2>&1 ;;
	esac ;;
esac; }
configurar_firewall() { [ "$SO" = "freebsd" ] && return 0; [ "$SO" = "debian" ] && so_call ins "iptables-persistent" >/dev/null 2>&1
for cmd in iptables ip6tables; do if command -v "$cmd" >/dev/null 2>&1; then out msg "-> Reglas para $cmd..."
	for f in -F -X "-t nat -F" "-t nat -X" "-t mangle -F" "-t mangle -X"; do run $cmd $f 2>/dev/null || true; done
	run $cmd -P INPUT DROP; run $cmd -P FORWARD DROP; run $cmd -P OUTPUT ACCEPT; run $cmd -A INPUT -i lo -j ACCEPT; run $cmd -A OUTPUT -o lo -j ACCEPT; run $cmd -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT; run $cmd -A INPUT -p tcp --dport 22 -j ACCEPT; run $cmd -A INPUT -p tcp --dport 80 -j ACCEPT; run $cmd -A INPUT -p tcp --dport 443 -j ACCEPT
	if [ "$cmd" = "iptables" ]; then run $cmd -A INPUT -p icmp --icmp-type echo-request -j ACCEPT; so_call fw_save "iptables" "4" >/dev/null 2>&1
	else run $cmd -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT; so_call fw_save "ip6tables" "6" >/dev/null 2>&1; fi
	run $cmd -A INPUT -j REJECT; run $cmd -A FORWARD -j REJECT
fi; done; }
configurar_openbox() { out msg "-> Configurando Openbox..."; u_h="${HOME}"; [ -n "${SUDO_USER}" ] && u_h=$(getent passwd "${SUDO_USER}" | cut -d: -f6); o_d="${u_h}/.config/openbox"; mkdir -p "$o_d" /usr/share/backgrounds/
autostart="xrandr --output HDMI-1 --mode 1280x720 --rate 50.00 &\nfeh --bg-scale /usr/share/backgrounds/img.png &\ndunst &\ntint2 &\nnm-applet &\nxset s off -dpms &\n"; printf "$autostart" >> "${o_d}/autostart"
[ ! -f "${u_h}/.xinitrc" ] && printf "exec openbox-session\n" > "${u_h}/.xinitrc"
[ -n "${SUDO_USER}" ] && run chown -R "${SUDO_USER}:" "${u_h}/.config" "${u_h}/.xinitrc" 2>/dev/null; return 0; }
configurar_teclado() { out msg "-> Configurando teclado..."; u_h="${HOME}"; [ -n "${SUDO_USER}" ] && u_h=$(getent passwd "${SUDO_USER}" | cut -d: -f6); xi="${u_h}/.xinitrc"
if [ -f "$xi" ] && ! grep -q "setxkbmap" "$xi"; then tmp=$(mktemp); printf "setxkbmap es &\n" > "$tmp"; cat "$xi" >> "$tmp"; cat "$tmp" > "$xi"; rm -f "$tmp"
elif [ ! -f "$xi" ]; then printf "setxkbmap es &\nexec openbox-session\n" > "$xi"; fi
[ -n "${SUDO_USER}" ] && run chown "${SUDO_USER}:" "$xi" 2>/dev/null; so_call kbd >/dev/null 2>&1; }
