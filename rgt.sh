#!/bin/sh
# Subsistema de persistencia de logs aislados por aplicacion
. ./tmp.sh
inicializarLogs() {
	logDir="./$(getTimestamp)"
	mkdir -p "$logDir" 2>/dev/null
	if [ ! -d "$logDir" ] || [ ! -w "$logDir" ]; then
		logDir="/tmp/logs_fallback_$(getTimestamp)"
		mkdir -p "$logDir"
	fi
	logBuscados="$logDir/buscados_no_repo.log"
	printf "No encontrados - %s\n" "$(getFechaLegible)" > "$logBuscados"
}
registrarNoRepo() {
	printf "NO REPO: %s [%s]\n" "$1" "$(getFechaLegible)" >> "$logBuscados" 2>/dev/null
}
registrarInstalado() {
	_pkgName="$1" ; _soActual="$2" ; _estadoFinal="$3" ; _logOrigen="$4"
	_metaLog="$logDir/${_pkgName}.log"
	{
		printf "PAQUETE: %s\nSO: %s\nFECHA: %s\nESTADO: %s\nSALIDA GESTOR:\n" "$_pkgName" "$_soActual" "$(getFechaLegible)" "$_estadoFinal"
		if [ -f "$_logOrigen" ]; then
			cat "$_logOrigen"
		else
			printf "Sin salida registrada.\n"
		fi
	} > "$_metaLog" 2>/dev/null
	rm -f "$_logOrigen" 2>/dev/null
}
