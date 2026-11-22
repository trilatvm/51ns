#!/bin/sh
. ./.5lib_imp.sh
. ./.5lib_sys.sh
obtenerComandoHash() {
	case "$1" in
		sha256) tieneComando sha256sum && printf "sha256sum" || { tieneComando shasum && printf "shasum -a 256"; } ;;
		sha512) tieneComando sha512sum && printf "sha512sum" || { tieneComando shasum && printf "shasum -a 512"; } ;;
		sha1)   tieneComando sha1sum && printf "sha1sum" || { tieneComando shasum && printf "shasum -a 1"; } ;;
		md5)    tieneComando md5sum && printf "md5sum" || { tieneComando md5 && printf "md5 -r"; } ;;
		b2)     tieneComando b2sum && printf "b2sum" ;;
	esac
}
detectarAlgoritmosSistema() {
	listaAlgoritmos=""
	for algoritmoItem in sha256 sha512 sha1 md5 b2; do
		if [ -n "$(obtenerComandoHash "$algoritmoItem")" ]; then
			if [ -z "$listaAlgoritmos" ]; then
				listaAlgoritmos="$algoritmoItem"
			else
				listaAlgoritmos="$listaAlgoritmos $algoritmoItem"
			fi
		fi
	done
	printf "%s" "$listaAlgoritmos"
}
procesarHashArchivo() {
	descomponerRutaArchivo "$1" || return 1
	algoritmoHash="$2"
	politicaEjecucion="${3:-sobrescribir}"
	rtaDirHash="${rta}hash"
	archHash="${arch}.${algoritmoHash}"
	rtaArchHash="${rtaDirHash}/${archHash}"
	comandoHash=$(obtenerComandoHash "$algoritmoHash")
	if [ -z "$comandoHash" ]; then
		mErr "Herramienta no disponible para: $algoritmoHash"
		return 1
	fi
	mkdir -p "$rtaDirHash"
	if [ "$politicaEjecucion" = "verificar_si_existe" ] && [ -f "$rtaArchHash" ]; then
		printf "\n"
		mInf "[HASH:$algoritmoHash] Existe -> Verificando: $rtaArchHash"
		if verificarHashArchivo "$rtaArch" "$algoritmoHash"; then
			mOk "[HASH:$algoritmoHash] VERIFICADO OK: $rtaArch"
			return 0
		else
			mErr "[HASH:$algoritmoHash] FALLO DE INTEGRIDAD: $rtaArch"
			return 1
		fi
	fi
	textoAccion="Calculando"
	[ -f "$rtaArchHash" ] && textoAccion="Sobrescribiendo"
	printf "\n"
	mInf "[HASH:$algoritmoHash] $textoAccion -> $rtaArchHash"
	rm -f -- "$rtaArchHash" 2>/dev/null
	if (
		cd -- "$rta" || exit 1
		$comandoHash "$arch" > "$rtaArchHash"
	); then
		mOk "[HASH:$algoritmoHash] GUARDADO OK: $rtaArchHash"
		return 0
	else
		mErr "[HASH:$algoritmoHash] ERROR al calcular: $rtaArch"
		return 1
	fi
}
verificarHashArchivo() {
	descomponerRutaArchivo "$1" || return 1
	algoritmoHash="$2"
	rtaArchHash="${rta}hash/${arch}.${algoritmoHash}"
	if [ ! -f "$rtaArchHash" ]; then
		printf "\n"
		mAdb "[HASH:$algoritmoHash] Sin firma en ${rta}hash/ para: $arch"
		return 2
	fi
	comandoHash=$(obtenerComandoHash "$algoritmoHash")
	[ -z "$comandoHash" ] && return 1
	(
		cd -- "$rta" || exit 1
		$comandoHash -c "$rtaArchHash" >/dev/null 2>&1
	)
}
gestionarHuerfanosHash() {
	rtaDirObj=$(obtenerRutaAbsoluta "$1")
	modoGestion="$2"
	[ -z "$rtaDirObj" ] && return 1
	case "$rtaDirObj" in
		/) rtaObj="/" ;;
		*) rtaObj="${rtaDirObj}/" ;;
	esac
	rtaDirHash="${rtaObj}hash"
	if [ ! -d "$rtaDirHash" ]; then
		mAdb "No existe subcarpeta hash/ en: $rtaObj"
		return 0
	fi
	totalHuerfanos=0
	for rtaArchFirma in "$rtaDirHash"/*; do
		[ ! -f "$rtaArchFirma" ] && continue
		archFirma=$(basename -- "$rtaArchFirma")
		archFuente="${archFirma%.*}"
		rtaArchFuente="${rtaObj}${archFuente}"
		if [ ! -f "$rtaArchFuente" ]; then
			totalHuerfanos=$((totalHuerfanos + 1))
			if [ "$modoGestion" = "borrar" ]; then
				rm -f -- "$rtaArchFirma"
				mOk "[HUERFANO BORRADO] $rtaArchFirma (falta '$rtaArchFuente')"
			else
				mAdb "[HUERFANO DETECTADO] $rtaArchFirma (falta '$rtaArchFuente')"
			fi
		fi
	done
	if [ "$totalHuerfanos" -eq 0 ]; then
		mOk "No se encontraron hashes huerfanos en: $rtaDirHash"
	else
		mInf "Total de hashes huerfanos ($modoGestion): $totalHuerfanos"
	fi
}



