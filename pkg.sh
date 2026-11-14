#!/bin/sh
# Administrador unificado de paquetes (instalar, borrar, buscar)
. ./imp.sh
definirPaquetes() {
	cliSistema="exfatprogs ntfs-3g dosfstools fatresize e2fsprogs fdisk parted gvfs usbtop smartmontools testdisk udisks2 tree mc nano rsync par2 zip unzip xz bzip2 binutils coreutils cronutils moreutils mtools net-tools diffutils network-manager wpasupplicant aria2 wget yt-dlp ntp ntpsec iptables fail2ban"
	cliDesarrollo="build-essential gcc automake cmake make dkms git python3 python3-pip nodejs npm"
	cliHerramientas="font-terminus htop btop"
	cliMultimedia="cmus ffmpeg flac pavucontrol pulseaudio"
	guiOpenbox="openbox feh lxappearance obconf tint2 xinit xorg"
	guiEntorno="gsmartcontrol dbus network-manager-applet pcmanfm qpdfview viewnior gnome-disk-utility gparted mpv xterm lxterminal xarchiver"
	guiMultimedia="vlc spek soundconverter pulsemixer"
	guiOficina="firefox libreoffice cups"
}
hasCmd() { command -v "$1" >/dev/null 2>&1; }
execSudo() { hasCmd sudo && sudo "$@" || "$@"; }
admPkg() {
	_op="$1" ; _p="$2" ; _targetLog="$3"
	case "$_op" in
		buscar_inst)
			case "$soTarget" in
				void) hasCmd xbps-query && xbps-query -l 2>/dev/null | grep -q " ${_p}-" ;;
				debian) hasCmd dpkg-query && dpkg-query -W -f='${Status}' "$_p" 2>/dev/null | grep -q "ok installed" ;;
				freebsd) hasCmd pkg && pkg info -e "$_p" >/dev/null 2>&1 ;;
			esac ;;
		buscar_repo)
			case "$soTarget" in
				void) hasCmd xbps-query && xbps-query -Rs "^${_p}-[0-9]" >/dev/null 2>&1 ;;
				debian) hasCmd apt-cache && apt-cache show "$_p" >/dev/null 2>&1 ;;
				freebsd) hasCmd pkg && pkg search -qx "^${_p}$" >/dev/null 2>&1 ;;
			esac ;;
		instalar)
			case "$soTarget" in
				void)
					execSudo xbps-install -y "$_p" 2>&1 | tee "$_targetLog"
					xbps-remove -O; xbps-remove -o;
					;;
				debian)
					execSudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$_p" 2>&1 | tee "$_targetLog"
					apt clean; apt autoclean; autoremove -y;
					;;
				freebsd)
					execSudo pkg install -y "$_p" 2>&1 | tee "$_targetLog"
					pkg clean -y; pkg autoremove -y;
					;;
			esac ;;
		borrar)
			case "$soTarget" in
				void) execSudo xbps-remove -y "$_p" 2>&1 | tee "$_targetLog" ;;
				debian) execSudo apt-get remove -y "$_p" 2>&1 | tee "$_targetLog" ;;
				freebsd) execSudo pkg delete -y "$_p" 2>&1 | tee "$_targetLog" ;;
			esac ;;
	esac
}
updateRepo() {
	impMsg "$AMA" "Sincronizando repositorios remotos..."
	case "$soTarget" in
		void) execSudo xbps-install -S >/dev/null 2>&1 || true ;;
		debian) execSudo apt-get update -y >/dev/null 2>&1 || true ;;
		freebsd) execSudo pkg update >/dev/null 2>&1 || true ;;
	esac
}
