#!/bin/sh
# Orquestador Master 2 (.51ns.sh) - 100% POSIX /bin/sh & camelCase
. ./.5lib_clr.sh
. ./.5lib_tmp.sh
. ./.5lib_imp.sh
. ./.5lib_sys.sh
. ./.51ns_pqt.sh
. ./.51ns_pkg.sh
. ./.51ns_rgt.sh
. ./.51ns_cfg.sh
main51ns() {
	detectarSO
	definirPaquetes
	clear
	mOk "=== MENU DE SELECCION OPERATIVA (.51ns) ==="
	printf "\t1) Perfil CLI (Solo Consola)\n"
	printf "\t2) Perfil GUI (Solo Entorno Grafico)\n"
	printf "\t3) Perfil Completo (CLI + GUI)\n"
	printf "\t4) Ingresar paquete manualmente\n"
	printf "\tSeleccione una categoria (1-4): "
	read -r categoriaSeleccionada
	listaPaquetes=""
	activarRed=0
	activarOpenbox=0
	case "$categoriaSeleccionada" in
		1) listaPaquetes="$paquetesCli" ; activarRed=1 ;;
		2) listaPaquetes="$paquetesGui" ; activarOpenbox=1 ;;
		3) listaPaquetes="$paquetesCli $paquetesGui" ; activarRed=1 ; activarOpenbox=1 ;;
		4) printf "\tIngrese el nombre del paquete: " ; read -r paqueteManual ; listaPaquetes="$paqueteManual" ;;
		*) mErr "Categoria invalida" ; exit 1 ;;
	esac
	printf "\n\t=== SELECCION DE MODALIDAD DE DESPLIEGUE ===\n"
	printf "\t1) Modo Full (Instalacion desatendida continua)\n"
	printf "\t2) Modo Paso a Paso (Preguntar por cada paquete)\n"
	printf "\tSeleccione modalidad (1-2): "
	read -r modalidadSeleccionada
	if [ "$modalidadSeleccionada" != "1" ] && [ "$modalidadSeleccionada" != "2" ]; then
		mErr "Modalidad invalida"
		exit 1
	fi
	iniciarCronometro
	inicializarLogs
	actualizarRepositorios
	totalPaquetes=0
	for nbrPaquete in $listaPaquetes; do
		totalPaquetes=$((totalPaquetes + 1))
	done
	paqueteActual=0
	for nbrPaquete in $listaPaquetes; do
		clear
		sync
		paqueteActual=$((paqueteActual + 1))
		if [ "$modalidadSeleccionada" = "2" ]; then
			printf "\n\t¿Desea procesar el paquete [%s]? (s/n): " "$nbrPaquete"
			read -r respuestaUsuario
			case "$respuestaUsuario" in
				[sS]*) ;;
				*) mAdb "Saltando paquete: $nbrPaquete" ; continue ;;
			esac
		fi
		rtaArchLogTemp="/tmp/pkg_proc_$$.log"
		rm -f "$rtaArchLogTemp" 2>/dev/null
		estadoInstalado=$(pqtInstalado "$nbrPaquete")
		estadoRepo=$(pqtEnRepo "$nbrPaquete")
		if [ "$estadoInstalado" = "1" ]; then
			mostrarProgreso "$paqueteActual" "$totalPaquetes" "EXISTE" "$nbrPaquete"
			printf "Ya se encontraba en el sistema local\n" > "$rtaArchLogTemp"
			registrarInstalado "$nbrPaquete" "$soObjetivo" "EXISTE" "$rtaArchLogTemp"
		elif [ "$estadoRepo" = "-1" ]; then
			mostrarProgreso "$paqueteActual" "$totalPaquetes" "NO REPO" "$nbrPaquete"
			registrarNoRepo "$nbrPaquete"
			printf "No indexado en repositorios remotos\n" > "$rtaArchLogTemp"
			registrarInstalado "$nbrPaquete" "$soObjetivo" "NO REPO" "$rtaArchLogTemp"
		else
			mostrarProgreso "$paqueteActual" "$totalPaquetes" "INSTALANDO" "$nbrPaquete"
			printf "\n"
			if administrarPaquete "instalar" "$nbrPaquete" "$rtaArchLogTemp"; then
				registrarInstalado "$nbrPaquete" "$soObjetivo" "OK" "$rtaArchLogTemp"
			else
				registrarInstalado "$nbrPaquete" "$soObjetivo" "ERROR" "$rtaArchLogTemp"
			fi
			sync 2>/dev/null || true
		fi
		rm -f "$rtaArchLogTemp" 2>/dev/null
	done
	printf "\n"
	if [ "$activarRed" = "1" ]; then
		configurarNtp
		configurarFakeClock
		configurarIptables
	fi
	if [ "$activarOpenbox" = "1" ]; then
		configurarOpenbox
	fi
	if [ "$categoriaSeleccionada" != "4" ]; then
		configurarTeclado
	fi
	if [ "$soObjetivo" = "void" ]; then
		crearServiciosRunit
	fi
	if [ "$activarOpenbox" = "1" ]; then
		configurarX11
		configurarPolkit
		configurarXterm
	fi
	limpiarCacheSO
	tiempoFinal=$(finalizarCronometro)
	mOk "=== PROCESO TERMINADO ==="
	mInf "Tiempo total invertido: ${tiempoFinal} segundos."
	mInf "Directorios con reportes aislados: $rtaLogs"
}
main51ns
exit 0



