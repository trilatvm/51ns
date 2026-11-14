#!/bin/sh
# Metodos de impresion por consola homologados con identacion logica
. ./clr.sh
impMsg() {
	printf "\t%b%s%b\n" "$1" "$2" "$RES"
}
impErr() {
	printf "\t%bError: %s%b\n" "$ROJ" "$1" "$RES" >&2
}
