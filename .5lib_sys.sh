#!/bin/sh
. ./.5lib_imp.sh
tieneComando() {
	command -v "$1" >/dev/null 2>&1
}
obtenerRutaAbsoluta() {
	(
		cd -- "$1" 2>/dev/null && pwd -P
	)
}
descomponerRutaArchivo() {
	rtaEntrada="$1"
	rtaDirRel=$(dirname -- "$rtaEntrada")
	arch=$(basename -- "$rtaEntrada")
	rtaDir=$(obtenerRutaAbsoluta "$rtaDirRel")
	[ -z "$rtaDir" ] && return 1
	case "$rtaDir" in
		/) rta="/" ;;
		*) rta="${rtaDir}/" ;;
	esac
	case "$arch" in
		*.*)
			nbr="${arch%.*}"
			ext="${arch##*.}"
			;;
		*)
			nbr="$arch"
			ext=""
			;;
	esac
	rtaArch="${rta}${arch}"
	return 0
}
ejecutarSudo() {
	if tieneComando sudo; then
		sudo "$@"
	elif tieneComando doas; then
		doas "$@"
	else
		"$@"
	fi
}
detectarSO() {
	soObjetivo=""
	if [ -f /etc/os-release ]; then
		soObjetivo=$( (
			. /etc/os-release
			if [ "$ID" = "void" ]; then
				printf "void"
			elif [ "$ID" = "debian" ] || [ "$ID_LIKE" = "debian" ]; then
				printf "debian"
			else
				case " $ID_LIKE " in
					*" debian "*) printf "debian" ;;
				esac
			fi
		) )
	fi
	if [ -z "$soObjetivo" ] && [ "$(uname 2>/dev/null)" = "FreeBSD" ]; then
		soObjetivo="freebsd"
	fi
	if [ -z "$soObjetivo" ]; then
		mErr "SO no soportado"
		exit 1
	fi
	mInf "SO Detectado: $soObjetivo"
}
limpiarCacheSO() {
	if [ "$(id -u)" -eq 0 ] && [ -f /proc/sys/vm/drop_caches ]; then
		sync
		sh -c "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null || true
	fi
}



