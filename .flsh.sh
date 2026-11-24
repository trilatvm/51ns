#!/bin/sh
set -eu
ESC=$(printf '\033')
ROJ="${ESC}[1;31m"; VER="${ESC}[1;32m"; AMA="${ESC}[1;33m"; MAG="${ESC}[1;35m"; CIA="${ESC}[1;36m"; BLA="${ESC}[1;37m"; GRI="${ESC}[0;37m"; RES="${ESC}[0m"
GRL_FS="exfatprogs ntfs-3g dosfstools e2fsprogs btrfs-progs"
GRL_HDD="fdisk parted smartmontools testdisk"
GRL_TOO="tree mc nano rsync zip unzip bzip2 mtools"
GRL_NET="iptables fail2ban wpasupplicant aria2 wget yt-dlp gpsd ipv6calc sipcalc"
GRL_DEV="git octave cmake"
GRL_FNT="fontconfig fontforge"
GRL_CLI="htop btop qrencode stockfish cmus ffmpeg flac pavucontrol putty putty-doc"
GRL_G1="openbox feh jgmenu obconf picom tint2 papirus-icon-theme adwaita-icon-theme"
GRL_G2="pcmanfm qpdfview viewnior gparted mpv xterm lxterminal xarchiver"
GRL_G3="gpredict mypaint soundconverter vlc dia geany geany-plugins librecad libreoffice cups cups-pdf tuxpaint"
GRL_NOAA="libfftw3-dev libvolk-dev libpng-dev libtiff-dev libjemalloc-dev librtlsdr-dev libhackrf-dev libairspy-dev rtl-sdr sox libvolk2-dev libnng-dev libzstd-dev libtiff-dev libjemalloc-dev libcurl4-openssl-dev"
DEB_ARM="linux-headers-current-rockchip"
DEB_FS="fatresize zfsutils-linux hfsprogs apfs-fuse apfsprogs ntfs2btrfs"
DEB_HDD="gvfs gvfs-backends gvfs-fuse udisks2 policykit-1 gsmartcontrol gnome-disk-utility lm-sensors"
DEB_TOO="par2 xz-utils binutils coreutils moreutils net-tools diffutils kmod numlockx"
DEB_NET="firmware-linux firmware-linux-nonfree usb-modeswitch network-manager network-manager-gnome ntpsec ntpsec-ntpdate ntpsec-doc ntpsec-ntpviz pps-tools fake-hwclock"
DEB_DEV="python3-full python3-pip python3-setuptools python3-wheel python3-crcmod python3-cryptography python3-ntplib python3-numexpr python3-numpy python3-numpy-stl python3-openssl python3-matplotlib default-jre openjdk-17-jre default-jdk openjdk-17-jdk postgresql nodejs npm"
DEB_CMP="build-essential bc bison flex perl libssl-dev libelf-dev liblz4-tool lzop u-boot-tools device-tree-compiler libncurses-dev tar gcc g++ automake make dkms pkg-config"
DEB_FNT="fonts-firacode fonts-terminus xfonts-terminus fonts-terminus-otb font-manager"
DEB_CLI="qalculate-gtk pulseaudio pulseaudio-utils pulsemixer pulseaudio-equalizer"
DEB_GUI="lxappearance-obconf obconf-qt librsvg2-common libgdk-pixbuf-2.0-0 xinit xorg lightdm lightdm-gtk-greeter policykit-1-gnome dbus-x11 x264 x265 cubicsdr imagemagick spek pavucontrol-qt geany-plugin-editorconfig firefox-esr tuxpaint-data qalculate-qt winetricks"
VOI_FS="fatsort exfat-utils fuse-exfat zfs zfs-lts zfsbootmenu hfsprogs apfs-fuse ntfs2btrfs"
VOI_HDD="gvfs gvfs-afc gvfs-afp gvfs-cdda gvfs-devel gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-smb usbtop udisks2 polkit elogind gsmartcontrol gnome-disk-utility"
VOI_TOO="par2cmdline xz binutils coreutils cronutils moreutils net-tools diffutils kmod kmon xtools"
VOI_NET="linux-firmware linux-firmware-network usb_modeswitch NetworkManager network-manager-applet nm-tray lxpanel lxpolkit ntp openntpd pps-tools gpsg-tools socklog-void"
VOI_DEV="python3 python3-pip python3-setuptools python3-wheel python3-crcmod python3-cryptography python3-cryptography_vectors python3-ntplib python3-numexpr python3-numpy python3-numpy-stl python3-openssl python3-matplotlib openjdk8-jre openjdk17-jre openjdk8 openjdk17 postgresql-full nodejs"
VOI_CMP="base-devel bc bison flex perl openssl-devel elfutils-devel lz4 lzop uboot-mkimage dtc ncurses-devel tar gcc automake make dkms"
VOI_FNT="font-fira-otf font-fira-ttf font-firacode font-terminus font-termsyn grub-terminus terminus-font termsyn-font fontmanager fontmatrix"
VOI_CLI="qalculate bitcoin cmus-flac cmus-pulseaudio pulseaudio pulseaudio-utils pulsemixer pulseaudio-equalizer-ladspa"
VOI_GUI="lxappearance-obconf obconf-qt obmenu-generator tint2conf librsvg gdk-pixbuf xinit xorg lightdm lightdm-gtk-greeter polkit-gnome dbus x264 x265 CubicSDR ImageMagick spek alsa-plugins-ffmpeg alsa-plugins-pulseaudio apulse gpsd-qt pavucontrol-qt pulseaudio-qt geany-editorconfig-plugin geany-plugins-extra python3-matplotlib-inline firefox-esr tuxpaint-stamps bitcoin-qt protontricks qalculate-qt wine-mono winetricks"
BSD_FS="fusefs-exfat fusefs-ntfs fusefs-hfsfuse fusefs-apfs openzfs"
BSD_HDD="gvfs udisks2 polkit gsmartcontrol"
BSD_TOO="par2cmdline xz binutils coreutils moreutils diffutils"
BSD_NET="usb_modeswitch networkmgr ntp pps-tools"
BSD_DEV="python3 py311-pip py311-setuptools py311-wheel py311-crcmod py311-cryptography py311-ntplib py311-numexpr py311-numpy py311-openssl py311-matplotlib openjdk8-jre openjdk17-jre openjdk8 openjdk17 postgresql16-server postgresql16-client node npm"
BSD_CMP="gmake gcc automake bison flex perl5 lz4 lzop u-boot-tools dtc ncurses gtar"
BSD_FNT="firacode terminus-font font-manager"
BSD_CLI="libqalculate bitcoin pulseaudio pulsemixer"
BSD_GUI="lxappearance obconf-qt librsvg2 gdk-pixbuf2 xinit xorg lightdm lightdm-gtk-greeter polkit-gnome dbus x264 x265 ImageMagick spek pavucontrol-qt firefox-esr tuxpaint-stamps bitcoin-qt qalculate-qt wine-mono winetricks"
getTS() { date +"%Y%m%d%H%M%S" ;}
getOS() {
	if [ -f /etc/os-release ]; then . /etc/os-release; case "$ID" in debian|ubuntu|armbian|raspbian) printf "debian" ;; void) printf "void" ;; freebsd) printf "freebsd" ;; *) printf "no" ;; esac
	elif [ "$(uname -s)" = "FreeBSD" ]; then printf "freebsd"
	else printf "no"; fi ;}
prog() {
	pct=$(( ($1 * 100) / $2 )); ll=$(( (pct * 25) / 100 )); bar=""; i=0
	while [ "$i" -lt "$ll" ]; do bar="${bar}#"; i=$((i + 1)); done
	while [ "$i" -lt 25 ]; do bar="${bar}-"; i=$((i + 1)); done
	printf "    ${CIA}[%s]${RES} ${BLA}%3d%%${RES} (%d/%d) | %b : ${BLA}%s${RES}\n" "$bar" "$pct" "$1" "$2" "$3" "$4" ;}
chk_inst() {
	case "$OS" in
		debian) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed" ;;
		void) xbps-query "$1" >/dev/null 2>&1 ;;
		freebsd) pkg info -e "$1" >/dev/null 2>&1 ;; esac ;}
chk_repo() {
	case "$OS" in
		debian) apt-cache show "$1" >/dev/null 2>&1 ;;
		void) xbps-query -R "$1" >/dev/null 2>&1 ;;
		freebsd) pkg rquery '%n' "$1" >/dev/null 2>&1 ;; esac ;}
do_inst2() {
	case "$OS" in
		debian) DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$1" > "${DIR}/${1}" 2>&1 ;;
		void) xbps-install -y "$1" > "${DIR}/${1}" 2>&1 ;;
		freebsd) pkg install -y "$1" > "${DIR}/${1}" 2>&1 ;; esac ;}
do_inst() {
	case "$OS" in
		debian) DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$1" | tee "${DIR}/${1}" 2>&1 ;;
		void) xbps-install -y "$1" | tee "${DIR}/${1}" 2>&1 ;;
		freebsd) pkg install -y "$1" | tee "${DIR}/${1}" 2>&1 ;; esac ;}
do_srch() {
	case "$OS" in
		debian) apt-cache search "$1" > "$2" 2>&1 || true ;;
		void) xbps-query -Rs "$1" > "$2" 2>&1 || true ;;
		freebsd) pkg search "$1" > "$2" 2>&1 || true ;; esac ;}
proc_pkg() {
	if chk_inst "$1"; then prog "$2" "$3" "${GRI}SALTAR (Instalado)${RES}" "$1"; return 0; fi
	if ! chk_repo "$1"; then prog "$2" "$3" "${AMA}NO EXISTE EN REPO${RES}" "$1"; printf "%s\n" "$1" >> "$NOREPO"; return 0; fi
	prog "$2" "$3" "${VER}INSTALANDO...${RES}" "$1"
	do_inst "$1" || printf "        ${ROJ}[!] Error al instalar %s (ver %s/%s)${RES}\n" "$1" "$DIR" "$1" ;}
buscar_faltantes() {
	[ ! -s "$NOREPO" ] && { printf "\n${VER}[OK] Todos los paquetes existian en los repositorios.${RES}\n"; return 0 ;}
	printf "\n${MAG}BUSCANDO ALTERNATIVAS PARA PAQUETES NO ENCONTRADOS EN REPO${RES}\n"
	while IFS= read -r p || [ -n "$p" ]; do
		[ -z "$p" ] && continue; out="${DIR}/_${p}"
		printf "    ${CIA}-> Buscando:${RES} ${BLA}%s${RES} -> ${GRI}%s${RES}\n" "$p" "$out"
		do_srch "$p" "$out"
		[ ! -s "$out" ] && printf "Sin coincidencias en repositorio para: %s\n" "$p" > "$out"
	done < "$NOREPO" ;}
main() {
	[ "$(id -u)" -ne 0 ] && { printf "${ROJ}Error: Ejecuta como root (sudo sh %s).${RES}\n" "$0"; exit 1 ;}
	OS=$(getOS); [ "$OS" = "no" ] && { printf "${ROJ}Error: Sistema operativo no soportado.${RES}\n"; exit 1 ;}
	DIR="./$(getTS)"; mkdir -p "$DIR" || { printf "${ROJ}Error: No se pudo crear %s.${RES}\n" "$DIR"; exit 1 ;}
	NOREPO="${DIR}/0_no_repo"; : > "$NOREPO"
	printf "${BLA}Sistema:${RES} ${VER}%s${RES} | ${BLA}Sesion:${RES} ${AMA}%s${RES}\n" "$OS" "$DIR"
	L_GRL="$GRL_FS $GRL_HDD $GRL_TOO $GRL_NET $GRL_DEV $GRL_FNT $GRL_CLI $GRL_G1 $GRL_G2 $GRL_G3 $GRL_NOAA"
	case "$OS" in
#		debian) apt-get update > "${DIR}/0_update" 2>&1; L_FIN="$L_GRL $DEB_FS $DEB_HDD $DEB_TOO $DEB_NET $DEB_DEV $DEB_CMP $DEB_FNT $DEB_CLI $DEB_GUI" ;;
		debian) apt-get update | tee "${DIR}/0_update" 2>&1; L_FIN="$L_GRL $DEB_FS $DEB_HDD $DEB_TOO $DEB_NET $DEB_DEV $DEB_CMP $DEB_FNT $DEB_CLI $DEB_GUI" ;;
		void) xbps-install -S > "${DIR}/0_update" 2>&1; L_FIN="$L_GRL $VOI_FS $VOI_HDD $VOI_TOO $VOI_NET $VOI_DEV $VOI_CMP $VOI_FNT $VOI_CLI $VOI_GUI" ;;
		freebsd) pkg update > "${DIR}/0_update" 2>&1; L_FIN="$L_GRL $BSD_FS $BSD_HDD $BSD_TOO $BSD_NET $BSD_DEV $BSD_CMP $BSD_FNT $BSD_CLI $BSD_GUI" ;; esac
	set -- $L_FIN; TOT=$#; CNT=0
	printf "${BLA}Procesando %d paquetes...${RES}\n" "$TOT"
	for pkg in $L_FIN; do CNT=$((CNT + 1)); proc_pkg "$pkg" "$CNT" "$TOT"; done
	buscar_faltantes
	printf "${VER}Finalizado. Logs en: ${BLA}%s${RES}\n" "$DIR"
	exit 0 ;}
# ------------------- #
clear
printf "${VER}SCRIPT INICIO\n"
main "$@"
sync
printf "${VER}SCRIPT FIN\n"
exit 0



