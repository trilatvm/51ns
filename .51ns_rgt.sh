#!/bin/sh
. ./.5lib_tmp.sh
. ./.5lib_sys.sh
inicializarLogs() {
	marcaTiempo=$(obtenerTimestamp)
	rtaBase=$(obtenerRutaAbsoluta ".")
	rtaLogs="${rtaBase}/logs_51ns_${marcaTiempo}"
	mkdir -p "$rtaLogs" 2>/dev/null || {
		rtaLogs="/tmp/logs_51ns_${marcaTiempo}"
		mkdir -p "$rtaLogs"
	}
	rtaArchInstalados="${rtaLogs}/instalados.log"
	rtaArchNoRepo="${rtaLogs}/no_repo.log"
	rtaArchDetalle="${rtaLogs}/detalle.log"
	: > "$rtaArchInstalados"
	: > "$rtaArchNoRepo"
	: > "$rtaArchDetalle"
}
registrarNoRepo() {
	fechaActual=$(obtenerFechaLegible)
	printf "[%s] %s\n" "$fechaActual" "$1" >> "$rtaArchNoRepo"
}
registrarInstalado() {
	nbrPaquete="$1"
	soActual="$2"
	estadoPaquete="$3"
	rtaArchLogTemp="$4"
	fechaActual=$(obtenerFechaLegible)
	printf "[%s] [%s] %-10s -> %s\n" "$fechaActual" "$soActual" "$estadoPaquete" "$nbrPaquete" >> "$rtaArchInstalados"
	if [ -f "$rtaArchLogTemp" ]; then
		{
			printf "=== [%s] %s (%s) ===\n" "$fechaActual" "$nbrPaquete" "$estadoPaquete"
			cat "$rtaArchLogTemp"
			printf "\n"
		} >> "$rtaArchDetalle"
	fi
}



