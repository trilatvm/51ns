#!/bin/sh
# Orquestador Master 1 (.5bckp.sh) - 100% POSIX /bin/sh (Sin sudo, rutas absolutas)
. ./.5lib_clr.sh
. ./.5lib_tmp.sh
. ./.5lib_imp.sh
. ./.5lib_sys.sh
. ./.5rgx.sh
. ./.5arch.sh
. ./.5hash.sh
. ./.5par2.sh
rtaDirTrabajo=$(obtenerRutaAbsoluta ".")
redundanciaPar2="20"
pedirFiltroExtension() {
	printf "\n\tSeleccionar Extension [ zip xz txt / ENTER (todos)]:" >&2
	read -r entradaExt
	printf "%s" "$entradaExt" | sed 's/^\.//'
}
pedirAlgoritmosHash() {
	algoritmosDisponibles=$(detectarAlgoritmosSistema)
	if [ -z "$algoritmosDisponibles" ]; then
		mErr "No hay herramientas de hash disponibles en el sistema."
		return 1
	fi
	printf "\n\tSeleccionar Algoritmo(s) [%s / ENTER (todos)]:" "$algoritmosDisponibles" >&2
	read -r algoritmosElegidos
	if [ -z "$algoritmosElegidos" ]; then
		printf "%s" "$algoritmosDisponibles"
	else
		printf "%s" "$algoritmosElegidos"
	fi
}
procesarBucleLote() {
	modoOperacion="$1"
	algoritmoActivo="$2"
	extFiltro="$3"
	politicaEjecucion="${4:-sobrescribir}"
	sanitizarNombresDirectorio "$rtaDirTrabajo"
	totalArchivos=$(contarArchivos "$extFiltro" "$rtaDirTrabajo")
	totalArchivos=$(printf "%s" "$totalArchivos" | tr -cd '0-9')
	[ -z "$totalArchivos" ] && totalArchivos=0
	if [ "$totalArchivos" -eq 0 ]; then
		mAdb "No se encontraron archivos validos (ext: ${extFiltro:-TODOS}) en: $rtaDirTrabajo"
		return 0
	fi
	iniciarCronometro
	archivoActual=0
	conteoExitos=0
	conteoErrores=0
	for itemRuta in "$rtaDirTrabajo"/*; do
		[ ! -f "$itemRuta" ] && continue
		validarExclusionEcosistema "$itemRuta" || continue
		validarArchivoRegex "$itemRuta" || continue
		cumpleFiltroExtension "$itemRuta" "$extFiltro" || continue
		descomponerRutaArchivo "$itemRuta" || continue
		archivoActual=$((archivoActual + 1))
		case "$modoOperacion" in
			calc_hash)
				mostrarProgreso "$archivoActual" "$totalArchivos" "HASH:$algoritmoActivo" "$arch"
				if procesarHashArchivo "$rtaArch" "$algoritmoActivo" "$politicaEjecucion"; then
					conteoExitos=$((conteoExitos + 1))
				else
					conteoErrores=$((conteoErrores + 1))
				fi
				;;
			ver_hash)
				mostrarProgreso "$archivoActual" "$totalArchivos" "VER:$algoritmoActivo" "$arch"
				verificarHashArchivo "$rtaArch" "$algoritmoActivo"
				case "$?" in
					0)
						conteoExitos=$((conteoExitos + 1))
						printf "\n"
						mOk "[HASH:$algoritmoActivo] VERIFICADO OK: $rtaArch"
						;;
					2) ;;
					*)
						conteoErrores=$((conteoErrores + 1))
						printf "\n"
						mErr "[HASH:$algoritmoActivo] CORRUPTO O MODIFICADO: $rtaArch"
						;;
				esac
				;;
			crear_par)
				mostrarProgreso "$archivoActual" "$totalArchivos" "PAR2" "$arch"
				if procesarPar2Archivo "$rtaArch" "$redundanciaPar2" "$politicaEjecucion"; then
					conteoExitos=$((conteoExitos + 1))
				else
					conteoErrores=$((conteoErrores + 1))
				fi
				;;
			ver_par)
				mostrarProgreso "$archivoActual" "$totalArchivos" "VER PAR2" "$arch"
				verificarPar2Archivo "$rtaArch"
				case "$?" in
					0)
						conteoExitos=$((conteoExitos + 1))
						printf "\n"
						mOk "[PAR2] VERIFICADO OK: $rtaArch"
						;;
					2) ;;
					*)
						conteoErrores=$((conteoErrores + 1))
						printf "\n"
						mErr "[PAR2] FALLO DE INTEGRIDAD: $rtaArch"
						;;
				esac
				;;
			rep_par)
				mostrarProgreso "$archivoActual" "$totalArchivos" "REP PAR2" "$arch"
				repararPar2Archivo "$rtaArch"
				case "$?" in
					0) conteoExitos=$((conteoExitos + 1)) ;;
					2) ;;
					*) conteoErrores=$((conteoErrores + 1)) ;;
				esac
				;;
		esac
	done
	printf "\n"
	tiempoTotal=$(finalizarCronometro)
	mOk "Finalizado [$modoOperacion${algoritmoActivo:+:$algoritmoActivo}] en ${tiempoTotal}s | OK: $conteoExitos | Errores: $conteoErrores"
}
submenuHash() {
	while true; do
		printf "\n"
		mOk "=== 1) MODO HASH (Subcarpeta: ${rtaDirTrabajo}/hash/) ==="
		printf "\t1.1) Calcular (Sobrescribe existentes)\n"
		printf "\t1.2) Verificar\n"
		printf "\t1.3) Huerfanos\n"
		printf "\t0) Volver\n"
		printf "\tOpcion: "
		read -r opcionHash
		case "$opcionHash" in
			1.1|1)
				algoritmosSeleccionados=$(pedirAlgoritmosHash) || continue
				extSeleccionada=$(pedirFiltroExtension)
				for algoritmoItem in $algoritmosSeleccionados; do
					procesarBucleLote "calc_hash" "$algoritmoItem" "$extSeleccionada" "sobrescribir"
				done
				stop
				;;
			1.2|2)
				algoritmosSeleccionados=$(pedirAlgoritmosHash) || continue
				extSeleccionada=$(pedirFiltroExtension)
				for algoritmoItem in $algoritmosSeleccionados; do
					procesarBucleLote "ver_hash" "$algoritmoItem" "$extSeleccionada"
				done
				stop
				;;
			1.3|3)
				submenuHuerfanos
				;;
			0) return ;;
			*) mErr "Opcion invalida" ;;
		esac
	done
}
submenuHuerfanos() {
	while true; do
		printf "\n"
		mOk "=== 1.3) HASHES HUERFANOS ==="
		printf "\t1.3.1) Mostrar huerfanos\n"
		printf "\t1.3.2) Borrar huerfanos\n"
		printf "\t0) Volver\n"
		printf "\tOpcion: "
		read -r opcionHuerfano
		case "$opcionHuerfano" in
			1.3.1|1) gestionarHuerfanosHash "$rtaDirTrabajo" "mostrar"
			stop ;;
			1.3.2|2) gestionarHuerfanosHash "$rtaDirTrabajo" "borrar"
			stop ;;
			0) return ;;
			*) mErr "Opcion invalida" ;;
		esac
	done
}
submenuPar() {
	while true; do
		printf "\n"
		mOk "=== 2) MODO PAR2 (Subcarpeta: ${rtaDirTrabajo}/par/) ==="
		printf "\t2.1) Crear (Sobrescribe existentes)\n"
		printf "\t2.2) Verificar\n"
		printf "\t2.3) Reparar (Pregunta confirmacion [No])\n"
		printf "\t0) Volver\n"
		printf "\tOpcion: "
		read -r opcionPar
		case "$opcionPar" in
			2.1|1)
				extSeleccionada=$(pedirFiltroExtension)
				procesarBucleLote "crear_par" "" "$extSeleccionada" "sobrescribir"
				stop
				;;
			2.2|2)
				extSeleccionada=$(pedirFiltroExtension)
				procesarBucleLote "ver_par" "" "$extSeleccionada"
				stop
				;;
			2.3|3)
				extSeleccionada=$(pedirFiltroExtension)
				procesarBucleLote "rep_par" "" "$extSeleccionada"
				stop
				;;
			0) return ;;
			*) mErr "Opcion invalida"
				stop;;
		esac
	done
}
submenuFull() {
	while true; do
		printf "\n"
		mOk "=== 3) MODO FULL (Si ya existe -> solo verifica) ==="
		printf "\t3.1) Calcular y Crear (Hashes + PAR2)\n"
		printf "\t3.2) Verificar y Reparar (Hashes + PAR2 + Reparar [No])\n"
		printf "\t3.3) FULL-FULL (Calcular, Crear, Verificar y Reparar)\n"
		printf "\t0) Volver\n"
		printf "\tOpcion: "
		read -r opcionFull
		case "$opcionFull" in
			3.1|1)
				extSeleccionada=$(pedirFiltroExtension)
				algoritmosSistema=$(detectarAlgoritmosSistema)
				for algoritmoItem in $algoritmosSistema; do
					procesarBucleLote "calc_hash" "$algoritmoItem" "$extSeleccionada" "verificar_si_existe"
				done
				procesarBucleLote "crear_par" "" "$extSeleccionada" "verificar_si_existe"
				sync 2>/dev/null || true
				stop
				;;
			3.2|2)
				extSeleccionada=$(pedirFiltroExtension)
				algoritmosSistema=$(detectarAlgoritmosSistema)
				for algoritmoItem in $algoritmosSistema; do
					procesarBucleLote "ver_hash" "$algoritmoItem" "$extSeleccionada"
				done
				procesarBucleLote "ver_par" "" "$extSeleccionada"
				procesarBucleLote "rep_par" "" "$extSeleccionada"
				sync 2>/dev/null || true
				stop
				;;
			3.3|3)
				extSeleccionada=$(pedirFiltroExtension)
				algoritmosSistema=$(detectarAlgoritmosSistema)
				mInf "=== INICIANDO FULL-FULL ==="
				for algoritmoItem in $algoritmosSistema; do
					procesarBucleLote "calc_hash" "$algoritmoItem" "$extSeleccionada" "verificar_si_existe"
				done
				procesarBucleLote "crear_par" "" "$extSeleccionada" "verificar_si_existe"
				for algoritmoItem in $algoritmosSistema; do
					procesarBucleLote "ver_hash" "$algoritmoItem" "$extSeleccionada"
				done
				procesarBucleLote "ver_par" "" "$extSeleccionada"
				procesarBucleLote "rep_par" "" "$extSeleccionada"
				sync 2>/dev/null || true
				mOk "=== FULL-FULL COMPLETADO ==="
				stop
				;;
			0) return ;;
			*) mErr "Opcion invalida"
				stop;;
		esac
	done
}
menuPrincipal5bckp() {
	while true; do
		clear
		printf "\n"
		mOk "=========================================="
		mOk " ORQUESTADOR DE RESPALDOS (.5bckp)"
		mInf " Ruta activa: $rtaDirTrabajo"
		mOk "=========================================="
		printf "\t1) Modo Hash\n"
		printf "\t2) Modo Par\n"
		printf "\t3) Modo Full\n"
		printf "\tD) Cambiar Directorio\n"
		printf "\tS) Salir\n"
		printf "\tOpcion: "
		read -r opcionPrincipal
		case "$opcionPrincipal" in
			1) submenuHash ;;
			2) submenuPar ;;
			3) submenuFull ;;
			[dD])
				printf "\tNueva ruta (actual: %s): " "$rtaDirTrabajo"
				read -r rtaNuevaEntrada
				rtaNuevaAbsoluta=$(obtenerRutaAbsoluta "$rtaNuevaEntrada")
				if [ -n "$rtaNuevaAbsoluta" ] && [ -d "$rtaNuevaAbsoluta" ]; then
					rtaDirTrabajo="$rtaNuevaAbsoluta"
					mOk "Ruta cambiada a: $rtaDirTrabajo"
				else
					mErr "Ruta invalida"
				fi
				;;
			[sS]) mInf "Saliendo..." ; exit 0 ;;
			*) mErr "Opcion no reconocida"
				stop ;;
		esac
	done
}
stop(){
	aux=""
	impINF "ENTER para continuar"
	read -r "$aux"
	clear
}
menuPrincipal5bckp
sync
exit 0



