#!/bin/sh
. ./.5lib_imp.sh
. ./.5lib_tmp.sh
. ./.5lib_sys.sh
calcularBloque() {
	tamBytes="$1"
	[ -z "$tamBytes" ] && tamBytes=0
	if [ "$tamBytes" -le 4096 ]; then
		printf "4096"
		return 0
	fi
	tamBloque=$(( tamBytes / 1024 ))
	[ "$tamBloque" -lt 4096 ] && tamBloque=4096
	[ "$tamBloque" -gt 16777216 ] && tamBloque=16777216
	restoAlineacion=$(( tamBloque % 4 ))
	if [ "$restoAlineacion" -ne 0 ]; then
		tamBloque=$(( tamBloque + (4 - restoAlineacion) ))
	fi
	printf "%s" "$tamBloque"
}
calcularMemoriaRAM() {
	memoriaKb=0
	if [ -r /proc/meminfo ]; then
		memoriaKb=$(awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo 2>/dev/null)
		if [ -z "$memoriaKb" ] || [ "$memoriaKb" -eq 0 ]; then
			memoriaKb=$(awk '/^MemFree:/ {print $2; exit}' /proc/meminfo 2>/dev/null)
		fi
	elif tieneComando sysctl; then
		paginasLibres=$(sysctl -n vm.stats.vm.v_free_count 2>/dev/null)
		tamPagina=$(sysctl -n hw.pagesize 2>/dev/null)
		if [ -n "$paginasLibres" ] && [ -n "$tamPagina" ]; then
			memoriaKb=$(( (paginasLibres * tamPagina) / 1024 ))
		fi
	fi
	[ -z "$memoriaKb" ] && memoriaKb=0
	memoriaMb=$(( memoriaKb / 1024 ))
	mitadMemoriaMb=$(( memoriaMb / 2 ))
	[ "$mitadMemoriaMb" -lt 64 ] && mitadMemoriaMb=64
	printf "%s" "$mitadMemoriaMb"
}
calcularNucleos() {
	cantidadNucleos=""
	if tieneComando nproc; then
		cantidadNucleos=$(nproc 2>/dev/null)
	elif [ -r /proc/cpuinfo ]; then
		cantidadNucleos=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)
	elif tieneComando sysctl; then
		cantidadNucleos=$(sysctl -n hw.ncpu 2>/dev/null)
	fi
	cantidadNucleos=$(printf "%s" "$cantidadNucleos" | tr -cd '0-9')
	if [ -z "$cantidadNucleos" ] || [ "$cantidadNucleos" -lt 1 ]; then
		cantidadNucleos=1
	else
		cantidadNucleos=$(( cantidadNucleos -1 ))
	fi
	printf "%s" "$cantidadNucleos"
}
procesarPar2Archivo() {
	descomponerRutaArchivo "$1" || return 1
	porcentajeRedundancia="${2:-10}"
	politicaEjecucion="${3:-sobrescribir}"
	if ! tieneComando par2; then
		mErr "Comando 'par2' no instalado en el sistema"
		return 1
	fi
	rtaDirPar="${rta}par"
	archPar="${arch}.par2"
	rtaArchPar="${rtaDirPar}/${archPar}"
	mkdir -p "$rtaDirPar"
	if [ "$politicaEjecucion" = "verificar_si_existe" ] && [ -f "$rtaArchPar" ]; then
		printf "\n"
		mInf "[PAR2] Existe -> Verificando: $rtaArchPar"
		if verificarPar2Archivo "$rtaArch"; then
			mOk "[PAR2] VERIFICADO OK: $rtaArch"
			return 0
		else
			mErr "[PAR2] FALLO DE PARIDAD: $rtaArch"
			return 1
		fi
	fi
	textoAccion="Creando"
	if [ -f "$rtaArchPar" ]; then
		textoAccion="Sobrescribiendo"
		rm -f -- "$rtaDirPar/${arch}".*par2 2>/dev/null
	fi
	tamBytes=$(wc -c < "$rtaArch" | tr -cd '0-9')
	[ -z "$tamBytes" ] && tamBytes=0
	tamBloque=$(calcularBloque "$tamBytes")
	memoriaAsignada=$(calcularMemoriaRAM)
	nucleosAsignados=$(calcularNucleos)
	printf "\t%b%61s%b [%b B%b]        Masa\n\t%b%61s%b [%b %%%b] Redundancia \n\t%b%61s%b [%b B%b]      Bloque\n\t%b%61s%b [%b C%b]     Nucleos\n\t%b%61s%b [%bMB%b]       RAM/2\n" \
	"$VER" "$tamBytes" "$RES" "$VER" "$RES" "$AMA" "$porcentajeRedundancia" "$RES" "$AMA" "$RES" "$MAG" "$tamBloque" "$RES" "$MAG" "$RES" "$ROJ" "$nucleosAsignados" "$RES" "$ROJ" "$RES" "$ROJ" "$memoriaAsignada" "$RES" "$ROJ" "$RES"
# Ejemplo Visual
#	                                                         5065 [ B]        Masa
#	                                                           20 [ %] Redundancia 
#	                                                         4096 [ B]      Bloque
#	                                                            4 [ C]     Nucleos
#	                                                          790 [MB]       RAM/2
	printf "\t[%b%-15s%b][%b%60s%b]\n" "$MAG" "$textoAccion" "$RES" "$MAG" "$rtaArchPar" "$RES"
#	[Sobrescribiendo][                                         /home/notC.txt.par2]
	printf "%b[%s]%b" "$AMA" "$(obtenerFechaLegible)" "$ROJ"
	if par2 create -B"$rtaDir" -s"$tamBloque" -r"$porcentajeRedundancia" -m"$memoriaAsignada" -t"$nucleosAsignados" "$rtaArchPar" "$rtaArch" 2>&1; then	# >/dev/null -q
		printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$RES"
		mOk "[PAR2] GUARDADO OK: $rtaArchPar"
		return 0
	elif par2 c -B"$rtaDir" -s"$tamBloque" -r"$porcentajeRedundancia" -m"$memoriaAsignada" "$rtaArchPar" "$rtaArch" 2>&1; then	# >/dev/null create -q
		printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$RES"
		mOk "[PAR2] GUARDADO OK: $rtaArchPar"
		return 0
	else
		mErr "[PAR2] ERROR al crear paridad: $rtaArch"
		return 1
	fi
	printf "\n[%s]%b\n" "$RES" "$(obtenerFechaLegible)"
}
verificarPar2Archivo() {
	descomponerRutaArchivo "$1" || return 1
	rtaArchPar="${rta}par/${arch}.par2"
	if [ ! -f "$rtaArchPar" ]; then
		printf "\n"
		mAdb "[PAR2] Sin archivo .par2 en ${rta}par/ para: $arch"
		return 2
	fi
	tieneComando par2 || return 1
	memoriaAsignada=$(calcularMemoriaRAM)
	nucleosAsignados=$(calcularNucleos)
	printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$ROJ"
	par2 verify -q -B"$rtaDir" -m"$memoriaAsignada" -t"$nucleosAsignados" "$rtaArchPar" 2>&1 || \
		par2 v -B"$rtaDir" -m"$memoriaAsignada" "$rtaArchPar" 2>&1
	printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$ROJ"
}
repararPar2Archivo() {
	descomponerRutaArchivo "$1" || return 1
	rtaArchPar="${rta}par/${arch}.par2"
	if [ ! -f "$rtaArchPar" ]; then
		printf "\n"
		mAdb "[PAR2] Sin archivo .par2 en ${rta}par/ para reparar: $arch"
		return 2
	fi
	tieneComando par2 || return 1
	memoriaAsignada=$(calcularMemoriaRAM)
	nucleosAsignados=$(calcularNucleos)
	printf "\n"
#	mInf "[PAR2] Verificando estado de: $rtaArch antes de reparar..."
	imp "Verificando" "$rtaArch"
	printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$ROJ"
	if par2 verify -B"$rtaDir" -m"$memoriaAsignada" -t"$nucleosAsignados" "$rtaArchPar" 2>&1 || \
	   par2 v -B"$rtaDir" -m"$memoriaAsignada" "$rtaArchPar" 2>&1; then
		printf "%b[%s]%b\n" "$AMA" "$(obtenerFechaLegible)" "$ROJ"
#		mOk "[PAR2] El archivo esta integro, no requiere reparacion: $rtaArch"
		imp "CORRECTO" "$rtaArch"
		return 0
	fi
#	mAdb "[ADV] Se detectaron danos en: $rtaArch"
	mAdb "[ADV] Se detectaron danos"
	printf "\t¿REPARAR '%s' usando '%s'? (s/N) [No]: " "$rtaArch" "$rtaArchPar"
	read -r respuestaUsuario
	case "$respuestaUsuario" in
		[sS]|[sS][iI])
			mInf "[INF] Ejecutando reparacion (RAM: ${memoriaAsignada}MB | Nucleos: ${nucleosAsignados})..."
			if par2 repair -q -B"$rtaDir" -m"$memoriaAsignada" -t"$nucleosAsignados" "$rtaArchPar" >/dev/null 2>&1 || \
			   par2 repair -q -B"$rtaDir" -m"$memoriaAsignada" "$rtaArchPar" >/dev/null 2>&1; then
				mOk "[PAR2] REPARACION EXITOSA: $rtaArch"
				return 0
			else
				mErr "[ERR] NO SE PUDO REPARAR (bloques insuficientes): $rtaArch"
				return 1
			fi
			;;
		*)
			mAdb "[ADV] Reparacion omitida por el usuario (por defecto No): $rtaArch"
			return 2
			;;
	esac
}




