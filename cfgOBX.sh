#!/bin/sh
# Estructuracion automatica del entorno visual de usuario
. ./imp.sh
confAutostart='
#
#
setxkbmap es &												# idioma teclado
xset s off -dpms &											# apagar gestor de energía
#xrandr --output HDMI-1 --mode 1920x1080 --rate 60.00 &		# 1080p
xrandr --output HDMI-1 --mode 1280x720 --rate 50.00 &		#  720p
#xrandr --output HDMI-1 --mode 800x600 --rate 50.00 &		#  600p
feh --bg-scale /usr/share/backgrounds/img.png &				# fondo de pantalla
dunst &														# gestor de notificaciones 
tint2 &														# barra de tareas
#lxpanel --profile Openbox &									# barra de tareas
#picom &													# ventanas
lxpolkit &													# agente de autenticación wifi
/usr/libexec/polkit-gnome-authentication-agent-1 &			# polkit gnome
nm-applet &													# ícono de red (network-manager-gnome)
#nm-tray &													# ícono de red (nm-tray)
#
#
'
configurarOpenbox() {
	impMsg "$VER" "Crear la carpeta de configuración openbox en usuario"
	mkdir -p ~/.config/openbox
	mkdir -p /usr/share/backgrounds/
	impMsg "$VER" "Copiar los archivos plantilla del sistema"
	cp -v /etc/xdg/openbox/rc.xml ~/.config/openbox/	# rc.xml: Configuración de atajos de teclado, comportamiento de ventanas y mouse.
	cp -v /etc/xdg/openbox/menu.xml ~/.config/openbox/ 	# menu.xml: Contenido menu clic derecho en el escritorio.
	cp -v /etc/xdg/openbox/autostart ~/.config/openbox/	# autostart: Programas que se abren solos al iniciar sesión (Wi-Fi, fondo de pantalla, barra, etc.).
	echo "$confAutostart" | tee -a ~/.config/openbox/autostart

}
obtenerHome() {
	_uHome="${HOME}"
	if [ -n "${SUDO_USER}" ] && hasCmd getent; then
		_uHome=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
	fi
	printf "%s" "$_uHome"
}
configurarTeclado() {
	impMsg "$CIA" "Localizando mapa de entrada al idioma 'es'..."
	_uHome=$(obtenerHome) ; _xInit="${_uHome}/.xinitrc"
	if [ -f "${_xInit}" ]; then
		if ! grep -q "setxkbmap" "${_xInit}" 2>/dev/null; then
			_tFile=$(mktemp 2>/dev/null || printf "/tmp/xinit_tmp")
			printf "setxkbmap es &\n" > "$_tFile"
			cat "${_xInit}" >> "$_tFile" 2>/dev/null
			cat "$_tFile" > "${_xInit}" 2>/dev/null ; rm -f "$_tFile" 2>/dev/null
		fi
	else
		printf "setxkbmap es &\nexec openbox-session\n" > "${_xInit}" 2>/dev/null
	fi
	[ -n "${SUDO_USER}" ] && execSudo chown "${SUDO_USER}:" "${_xInit}" 2>/dev/null
	
	case "$soTarget" in
		debian) [ -f /etc/default/keyboard ] && execSudo sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard 2>/dev/null || true ;;
		void) [ -f /etc/rc.conf ] && { execSudo sed -i 's/^KEYMAP=.*/KEYMAP="es"/' /etc/rc.conf 2>/dev/null || true; grep -q "^KEYMAP=" /etc/rc.conf 2>/dev/null || printf 'KEYMAP="es"\n' | execSudo tee -a /etc/rc.conf >/dev/null; } ;;
		freebsd) execSudo sysrc keymap="spanish.iso.acc" >/dev/null 2>&1 || true ;;
	esac
}


