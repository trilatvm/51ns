#!/bin/sh
# Modulo core de identificacion de distribucion base
. ./imp.sh
detectarSO() {
	soTarget=""
	if [ -f /etc/os-release ]; then
		# Se ejecuta en una subcapa para no contaminar el entorno global
		soTarget=$( (
			. /etc/os-release
			if [ "$ID" = "void" ]; then
				printf "void"
			elif [ "$ID" = "debian" ] || [ "$ID_LIKE" = "debian" ] || [ "${ID_LIKE#*debian*}" != "$ID_LIKE" ]; then
				printf "debian"
			fi
		) )
	fi
	
	if [ -z "$soTarget" ] && [ "$(uname 2>/dev/null)" = "FreeBSD" ]; then
		soTarget="freebsd"
	fi
	
	if [ -z "$soTarget" ]; then
		impErr "SO no soportado"
		exit 1
	fi
	
	impMsg "$CIA" "SO Detectado: $soTarget"
}
