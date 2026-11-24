#!/bin/sh
obtenerTimestamp() { date +%Y%m%d%H%M%S 2>/dev/null || printf "19791215232745"; }
obtenerFechaLegible() { date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || printf "1979-12-15 23:27:45"; }
iniciarCronometro() {
	tiempoInicio=$(date +%s 2>/dev/null)
	[ -z "$tiempoInicio" ] && tiempoInicio=0; }
cronometroTranscurrido() {
	tiempoActual=$(date +%s 2>/dev/null)
	[ -z "$tiempoActual" ] && tiempoActual=0
	[ -z "$tiempoInicio" ] && tiempoInicio=0
	printf "%s" "$((tiempoActual - tiempoInicio))"; }
finalizarCronometro() { cronometroTranscurrido; }




