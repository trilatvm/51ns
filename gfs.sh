#!/bin/sh
# Barra de progreso identada en magenta para estados dinamicos
. ./tmp.sh
. ./clr.sh
mostrarProgreso() {
	_act="$1" ; _tot="$2" ; _est="$3" ; _item="$4"
	[ "$_tot" -le 0 ] && _tot=1
	_porc=$(( (_act * 100) / _tot ))
	_h=$(( _porc / 5 )) ; _d=$(( 20 - _h ))
	
	_hashes=$(printf "%0${_h}s" 2>/dev/null | tr ' ' '#')
	_dashes=$(printf "%0${_d}s" 2>/dev/null | tr ' ' '-')
	_tTranscurrido=$(cronometroTranscurrido)
	
	printf "\r\t%b[%s%s] %3d%% (%d/%d) %b[%-11s]%b -> %s (%ss)" \
		"$CIA" "$_hashes" "$_dashes" "$_porc" "$_act" "$_tot" "$MAG" "$_est" "$CIA" "$_item" "$_tTranscurrido"
}
