#!/bin/sh
# Metodos de medicion cronometrica bajo estandard POSIX sh
getTimestamp() {
	date +%Y%m%d%H%M%S 2>/dev/null || printf "99991231235959"
}
getFechaLegible() {
	date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || printf "0000-00-00 00:00:00"
}
cronometroIniciar() {
	tiempoInicio=$(date +%s 2>/dev/null)
	[ -z "$tiempoInicio" ] && tiempoInicio=0
}
cronometroTranscurrido() {
	tiempoActual=$(date +%s 2>/dev/null)
	[ -z "$tiempoActual" ] && tiempoActual=0
	[ -z "$tiempoInicio" ] && tiempoInicio=0
	printf "%s" "$((tiempoActual - tiempoInicio))"
}
cronometroFinalizar() {
	tiempoFin=$(date +%s 2>/dev/null)
	[ -z "$tiempoFin" ] && tiempoFin=0
	[ -z "$tiempoInicio" ] && tiempoInicio=0
	printf "%s" "$((tiempoFin - tiempoInicio))"
}
