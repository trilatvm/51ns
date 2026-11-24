#!/bin/sh
. ./.5lib_sys.sh
configurarNtp() {
	mInf "Configurando sincronizacion horaria NTP..."
	if [ "$soObjetivo" = "void" ] && [ -d /etc/sv/ntpd ]; then
		ejecutarSudo ln -sf /etc/sv/ntpd /var/service/ 2>/dev/null || true
	elif [ "$soObjetivo" = "debian" ] && tieneComando timedatectl; then
		ejecutarSudo timedatectl set-ntp true 2>/dev/null || true
	elif [ "$soObjetivo" = "freebsd" ]; then
		ejecutarSudo sysrc ntpd_enable="YES" >/dev/null 2>&1 || true
		ejecutarSudo service ntpd start >/dev/null 2>&1 || true
	fi
}
configurarFakeClock() {
	if [ "$soObjetivo" = "debian" ] && tieneComando fake-hwclock; then
		ejecutarSudo fake-hwclock save 2>/dev/null || true
	fi
}
configurarIptables() {
	mInf "Configurando reglas basicas de firewall..."
	if tieneComando iptables; then
		ejecutarSudo iptables -P INPUT DROP 2>/dev/null || true
		ejecutarSudo iptables -P FORWARD DROP 2>/dev/null || true
		ejecutarSudo iptables -P OUTPUT ACCEPT 2>/dev/null || true
		ejecutarSudo iptables -A INPUT -i lo -j ACCEPT 2>/dev/null || true
		ejecutarSudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
	fi
}
configurarTeclado() {
	mInf "Configurando distribucion de teclado (es)..."
	if [ "$soObjetivo" = "void" ] && [ -f /etc/rc.conf ]; then
		ejecutarSudo sed -i 's/^#*KEYMAP=.*/KEYMAP="es"/' /etc/rc.conf 2>/dev/null || true
	elif [ "$soObjetivo" = "debian" ] && [ -f /etc/default/keyboard ]; then
		ejecutarSudo sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard 2>/dev/null || true
	fi
}
configurarOpenbox() {
	mInf "Configurando perfil base de Openbox..."
	rtaOpenbox="$HOME/.config/openbox"
	mkdir -p "$rtaOpenbox"
	if [ ! -f "$rtaOpenbox/rc.xml" ] && [ -f /etc/xdg/openbox/rc.xml ]; then
		cp /etc/xdg/openbox/rc.xml "$rtaOpenbox/rc.xml"
	fi
	if [ ! -f "$rtaOpenbox/menu.xml" ] && [ -f /etc/xdg/openbox/menu.xml ]; then
		cp /etc/xdg/openbox/menu.xml "$rtaOpenbox/menu.xml"
	fi
	if [ ! -f "$rtaOpenbox/autostart" ]; then
		cat << 'EOF' > "$rtaOpenbox/autostart"
tint2 &
nitrogen --restore &
dunst &
EOF
		chmod +x "$rtaOpenbox/autostart"
	fi
}
configurarX11() {
	mInf "Configurando ~/.xinitrc para Openbox..."
	if [ ! -f "$HOME/.xinitrc" ]; then
		cat << 'EOF' > "$HOME/.xinitrc"
#!/bin/sh
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
setxkbmap es &
exec openbox-session
EOF
		chmod +x "$HOME/.xinitrc"
	fi
}
configurarXterm() {
	mInf "Configurando ~/.Xresources para XTerm..."
	if [ ! -f "$HOME/.Xresources" ]; then
		cat << 'EOF' > "$HOME/.Xresources"
XTerm*background: #111111
XTerm*foreground: #e0e0e0
XTerm*faceName: Monospace
XTerm*faceSize: 11
XTerm*selectToClipboard: true
EOF
	fi
}
configurarPolkit() {
	mInf "Configurando reglas de Polkit..."
	rtaPolkit="/etc/polkit-1/rules.d"
	if [ -d "/etc/polkit-1" ]; then
		ejecutarSudo mkdir -p "$rtaPolkit"
		ejecutarSudo sh -c "cat << 'EOF' > $rtaPolkit/50-default.rules
polkit.addRule(function(action, subject) {
    if (subject.isInGroup(\"wheel\") || subject.isInGroup(\"sudo\")) {
        return polkit.Result.YES;
    }
});
EOF"
	fi
}
crearServiciosRunit() {
	mInf "Habilitando servicios esenciales en runit (Void Linux)..."
	for nbrServicio in dbus polkitd NetworkManager dhcpcd; do
		if [ -d "/etc/sv/$nbrServicio" ] && [ ! -e "/var/service/$nbrServicio" ]; then
			ejecutarSudo ln -sf "/etc/sv/$nbrServicio" /var/service/ 2>/dev/null || true
			mOk "Servicio habilitado: $nbrServicio"
		fi
	done
}




