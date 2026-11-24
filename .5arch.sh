#!/bin/sh
. ./.5lib_imp.sh
. ./.5lib_sys.sh
. ./.5rgx.sh
sanitizarNombresDirectorio() {
	rtaDirObj=$(obtenerRutaAbsoluta "$1")
	[ -z "$rtaDirObj" ] && return 1
	case "$rtaDirObj" in
		/) rtaObj="/" ;;
		*) rtaObj="${rtaDirObj}/" ;;
	esac
	totalRenombrados=0
	for itemRuta in "$rtaDirObj"/*; do
		[ ! -f "$itemRuta" ] && continue
		validarExclusionEcosistema "$itemRuta" || continue
		archActual=$(basename -- "$itemRuta")
		case "$archActual" in
			*" "*)
				archNuevo=$(normalizarNombreArchivo "$archActual")
				if [ "$archActual" != "$archNuevo" ]; then
					rtaArchNuevo="${rtaObj}${archNuevo}"
					if [ -e "$rtaArchNuevo" ]; then
						mAdb "Omitido (ya existe): $rtaArchNuevo"
					else
						mv -- "$itemRuta" "$rtaArchNuevo"
						mOk "Renombrado: '$archActual' -> '$archNuevo'"
						totalRenombrados=$((totalRenombrados + 1))
					fi
				fi
				;;
		esac
	done
	if [ "$totalRenombrados" -gt 0 ]; then
		mInf "Archivos normalizados: $totalRenombrados"
	fi
}
cumpleFiltroExtension() {
	archFiltro=$(basename -- "$1")
	extFiltro="$2"
	[ -z "$extFiltro" ] && return 0
	case "$archFiltro" in
		*."$extFiltro") return 0 ;;
		*) return 1 ;;
	esac
}
contarArchivos() {
	extFiltro="$1"
	rtaDirObj=$(obtenerRutaAbsoluta "$2")
	[ -z "$rtaDirObj" ] && { printf "0"; return 1; }
	totalValidos=0
	for itemRuta in "$rtaDirObj"/*; do
		[ ! -f "$itemRuta" ] && continue
		validarExclusionEcosistema "$itemRuta" || continue
		validarArchivoRegex "$itemRuta" || continue
		cumpleFiltroExtension "$itemRuta" "$extFiltro" || continue
		totalValidos=$((totalValidos + 1))
	done
	printf "%s" "$totalValidos"
}




