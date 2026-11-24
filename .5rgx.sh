#!/bin/sh
validarArchivoRegex() {
	archValidar=$(basename -- "$1")
	if printf "%s" "$archValidar" | grep -Eq '^[a-zA-Z0-9._-]+\.[a-zA-Z0-9]+$'; then
		return 0
	else
		return 1
	fi
}
validarExclusionEcosistema() {
	archExcluir=$(basename -- "$1")
	case "$archExcluir" in
		.*|*.par2|*.sha256|*.sha512|*.sha1|*.md5|*.b2) return 1 ;;
		*) return 0 ;;
	esac
}
normalizarNombreArchivo() {
	archOriginal=$(basename -- "$1")
	case "$archOriginal" in
		*.*)
			nbrOriginal="${archOriginal%.*}"
			extOriginal="${archOriginal##*.}"
			;;
		*)
			nbrOriginal="$archOriginal"
			extOriginal=""
			;;
	esac
	nbrLimpio=$(printf "%s" "$nbrOriginal" | sed -E '
		s/[[:space:]]+/_/g;
		s/_+/_/g;
		s/[_-]*-[_-]*/-/g;
		s/^[_-]+//;
		s/[_-]+$//
	')
	[ -z "$nbrLimpio" ] && nbrLimpio="archivo"
	if [ -n "$extOriginal" ]; then
		printf "%s.%s" "$nbrLimpio" "$extOriginal"
	else
		printf "%s" "$nbrLimpio"
	fi
}




