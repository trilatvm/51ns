#!/bin/sh
# Orquestador Maestro - Ejecución Modular Limpia POSIX sh
. ./os.sh
. ./rgt.sh
. ./pqt.sh
. ./pkg.sh
. ./gfs.sh
. ./cfgNTP.sh
. ./cfgIPT.sh
. ./cfgSV.sh
. ./cfgX11.sh
. ./cfgOBX.sh
. ./cfgPLKT.sh
main() {
	detectarSO
	definirPaquetes
	clear
	impMsg "$VER" "=== MENU DE SELECCION OPERATIVA ==="
	printf "\t1) Perfil CLI (Solo Consola)\n"
	printf "\t2) Perfil GUI (Solo Entorno Grafico)\n"
	printf "\t3) Perfil Completo (CLI + GUI)\n"
	printf "\t4) Ingresar paquete manualmente\n"
	printf "\tSeleccione una categoria (1-4): " ; read -r catSel
	pkgs="" ; cnfNet=0 ; cnfOb=0
	case "$catSel" in
		1) pkgs="$cliSistema $cliDesarrollo $cliHerramientas $cliMultimedia" ; cnfNet=1 ;;
		2) pkgs="$guiOpenbox $guiEntorno $guiMultimedia $guiOficina" ; cnfOb=1 ;;
		3) pkgs="$CLI $GUI" ; cnfNet=1 ; cnfOb=1 ;;
		4) printf "\tIngrese el nombre del paquete: " ; read -r pkgManual ; pkgs="$pkgManual" ;;
		*) impErr "Categoria invalida" ; exit 1 ;;
	esac
	printf "\n\t=== SELECCION DE MODALIDAD DE DESPLIEGUE ===\n"
	printf "\t1) Modo Full (Instalacion desatendida continua)\n"
	printf "\t2) Modo Paso a Paso (Preguntar por cada paquete)\n"
	printf "\tSeleccione modalidad (1-2): " ; read -r modSel
	[ "$modSel" != "1" ] && [ "$modSel" != "2" ] && { impErr "Modalidad invalida"; exit 1; }
	cronometroIniciar
	inicializarLogs
	updateRepo
	tot=0; for p in $pkgs; do tot=$((tot + 1)); done
	act=0
	for p in $pkgs; do
		clear && sync
		act=$((act + 1))
		if [ "$modSel" = "2" ]; then
			printf "\n\t¿Desea procesar el paquete [%s]? (s/n): " "$p" ; read -r rAns
			case "$rAns" in
				[sS]*) ;;
				*) impMsg "$AMA" "Saltando paquete: $p" ; continue ;;
			esac
		fi
		tLog="/tmp/pkg_proc.log" ; rm -f "$tLog"
		if admPkg "buscar_inst" "$p"; then
			mostrarProgreso "$act" "$tot" "EXISTE" "$p"
			printf "Ya se encontraba en el sistema local\n" > "$tLog"
			registrarInstalado "$p" "$soTarget" "EXISTE" "$tLog"
		elif ! admPkg "buscar_repo" "$p"; then
			mostrarProgreso "$act" "$tot" "NO REPO" "$p"
			registrarNoRepo "$p"
			printf "No indexado en repositorios remotos\n" > "$tLog"
			registrarInstalado "$p" "$soTarget" "NO REPO" "$tLog"
		else
			mostrarProgreso "$act" "$tot" "INSTALANDO" "$p"
			printf "\n"
			if admPkg "instalar" "$p" "$tLog"; then
				registrarInstalado "$p" "$soTarget" "OK" "$tLog"
			else
				registrarInstalado "$p" "$soTarget" "ERROR" "$tLog"
			fi
			sync 2>/dev/null || true
		fi
	done
	printf "\n"
	[ "$cnfNet" = "1" ] && { configurarNtp ; configurarIptables; }
	[ "$cnfOb" = "1" ] && configurarOpenbox
	[ "$catSel" != "4" ] && configurarTeclado

	crearSvAll
	configurarx11
	configurarPolkit
	
	[ -f /proc/sys/vm/drop_caches ] && { sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null || true; }
	tiempoFinal=$(cronometroFinalizar)
	impMsg "$VER" "=== PROCESO TERMINADO ==="
	impMsg "$CIA" "Tiempo total invertido: ${tiempoFinal} segundos."
	impMsg "$CIA" "Directorios con reportes aislados: $logDir"
}
main
exit 0
