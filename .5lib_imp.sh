#!/bin/sh
. ./.5lib_clr.sh
. ./.5lib_tmp.sh
imprimirMensaje() {
	printf "\t%b%s%b\n" "$1" "$2" "$RES"
}
imprimirError() {
	printf "\t%bError: %s%b\n" "$ROJ" "$1" "$RES" >&2
}
imp(){ 
	C1="$1"; C2="$3"; 
	M1="$2"; M2="$4"; 
	printf "\t[%b%-15s%b][%b%60s%b]\n" "$C1" "$M1" "$RES" "$C2" "$M2" "$RES"; }
impERR(){	imp "$ROJ" "ERR" "$AMA" "$1" ; }
impOK(){	imp "$VER" " OK" "$CIA" "$1" ; }
impADV(){	imp "$AMA" "ADV" "$NAR" "$1" ; }
impINF(){	imp "$MAG" "INF" "$VER" "$1" ; }
mOk()  { imprimirMensaje "$VER" "$1"; }
mAdb() { imprimirMensaje "$AMA" "$1"; }
mInf() { imprimirMensaje "$CIA" "$1"; }
mErr() { imprimirError "$1"; }
mostrarProgreso() {
	itemActual="$1"
	totalItems="$2"
	estadoTexto="$3"
	nbrItem="$4"
	[ "$totalItems" -le 0 ] && totalItems=1
	porcentaje=$(( (itemActual * 100) / totalItems ))
	cantHashes=$(( porcentaje / 5 ))
	cantGuiones=$(( 20 - cantHashes ))
	barraHashes=""
	indice=0
	while [ "$indice" -lt "$cantHashes" ]; do
		barraHashes="${barraHashes}#"
		indice=$((indice + 1))
	done
	barraGuiones=""
	indice=0
	while [ "$indice" -lt "$cantGuiones" ]; do
		barraGuiones="${barraGuiones}-"
		indice=$((indice + 1))
	done
	tiempoTranscurrido=$(cronometroTranscurrido)
	printf "\r\t[%b%s%b%s%b][%b%3d%%%b][%b%5d%b/%b%-5d%b][%b%-11s%b]%b%21s%b [%bs%b]\n\t[%b%-15s%b][%b%60s%b]\n" \
		"$AMA" "$barraHashes" "$CIA" "$barraGuiones" "$RES" "$AMA" "$porcentaje" "$RES" "$AMA" "$itemActual" "$RES" "$CIA" "$totalItems" "$RES" "$MAG" "$estadoTexto" "$RES" "$ROJ" "$tiempoTranscurrido" "$RES" "$ROJ" "$RES" "$MAG" "$textoAccion" "$RES" "$MAG" "$nbrItem" "$RES"
# Ejemplo Visual
#	[#############-------][ 66%][    2/3    ][PAR2       ]                    5 [s]
#	[Sobrescribiendo][                                                    notB.txt]
#	[####################][100%][    3/3    ][PAR2       ]                    7 [s]
#	[Creando        ][                                                    notC.txt]
}



