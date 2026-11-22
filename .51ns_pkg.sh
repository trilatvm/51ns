#!/bin/sh
. ./.5lib_sys.sh
actualizarRepositorios() {
	mInf "Actualizando repositorios para $soObjetivo..."
	case "$soObjetivo" in
		void)    ejecutarSudo xbps-install -S >/dev/null 2>&1 || true ;;
		debian)  ejecutarSudo apt-get update -y >/dev/null 2>&1 || true ;;
		freebsd) ejecutarSudo pkg update -q >/dev/null 2>&1 || true ;;
	esac
}
# Recibe el nombre de un paquete ($1) y devuelve 1 si esta instalado o -1 si no lo esta
pqtInstalado() {
	nbrPaquete="$1"
	[ -z "$nbrPaquete" ] && { printf "%s" "-1"; return 1; }
	case "$soObjetivo" in
		void)
			if xbps-query "$nbrPaquete" >/dev/null 2>&1; then
				printf "1"
				return 0
			fi
			;;
		debian)
			if dpkg -s "$nbrPaquete" >/dev/null 2>&1; then
				printf "1"
				return 0
			fi
			;;
		freebsd)
			if pkg info -e "$nbrPaquete" >/dev/null 2>&1; then
				printf "1"
				return 0
			fi
			;;
	esac
	printf "%s" "-1"
	return 1
}
administrarPaquete() {
	accionPkg="$1"
	nbrPaquete="$2"
	rtaArchLogTemp="$3"
	case "$soObjetivo" in
		void)
			case "$accionPkg" in
				buscar_inst) [ "$(pqtInstalado "$nbrPaquete")" = "1" ] ;;
				buscar_repo) xbps-query -R "$nbrPaquete" >/dev/null 2>&1 ;;
				instalar)    ejecutarSudo xbps-install -y "$nbrPaquete" >"$rtaArchLogTemp" 2>&1 ;;
			esac
			;;
		debian)
			case "$accionPkg" in
				buscar_inst) [ "$(pqtInstalado "$nbrPaquete")" = "1" ] ;;
				buscar_repo) apt-cache show "$nbrPaquete" >/dev/null 2>&1 ;;
				instalar)    ejecutarSudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$nbrPaquete" >"$rtaArchLogTemp" 2>&1 ;;
			esac
			;;
		freebsd)
			case "$accionPkg" in
				buscar_inst) [ "$(pqtInstalado "$nbrPaquete")" = "1" ] ;;
				buscar_repo) pkg rquery "%n" "$nbrPaquete" >/dev/null 2>&1 ;;
				instalar)    ejecutarSudo pkg install -y "$nbrPaquete" >"$rtaArchLogTemp" 2>&1 ;;
			esac
			;;
		*)
			return 1
			;;
	esac
}



