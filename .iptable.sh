#!/bin/sh
set -eu
aplicarReglas(){
	echo "Reglas $1"
	# Script de firewall para IPv4
	# ----------------------
	echo "Reglas $1: Limpiar reglas existentes"
	# ----------------------
	sudo $1 -F
	sudo $1 -X
	sudo $1 -t nat -F
	sudo $1 -t nat -X
	sudo $1 -t mangle -F
	sudo $1 -t mangle -X
	# ----------------------
	echo "Reglas $1: Políticas por defecto"
	# ----------------------
	sudo $1 -P INPUT DROP
	sudo $1 -P FORWARD DROP
	sudo $1 -P OUTPUT ACCEPT
	# ----------------------
	echo "Reglas $1: Permitir loopback"
	# ----------------------
	sudo $1 -A INPUT -i lo -j ACCEPT
	sudo $1 -A OUTPUT -o lo -j ACCEPT
	# ----------------------
	echo "Reglas $1: Permitir conexiones ya establecidas y relacionadas"
	# ----------------------
	sudo $1 -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
	# ----------------------
	echo "Reglas $1: Puertos permitidos"
	# ----------------------
	echo "Reglas $1: SSH"
	sudo $1 -A INPUT -p tcp --dport 22 -j ACCEPT
	echo "Reglas $1: HTTP/HTTPS"
	sudo $1 -A INPUT -p tcp --dport 80 -j ACCEPT
	sudo $1 -A INPUT -p tcp --dport 443 -j ACCEPT
	echo "Reglas $1: Ping (ICMP)"
#	if "$1"=="iptables" >/dev/null 2>&1; then
#	if '$1' eq 'iptables'; then
#	if [[ "$1" == "iptables" ]]; then
#		sudo $1 -A INPUT -p icmp --icmp-type echo-request -j ACCEPT	# Éxito		
#	else
#		sudo ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT	# Fallo
#	fi; }
	# Uso de corchete simple [ ] y un solo '=' para máxima compatibilidad POSIX (/bin/sh)
	if [ "$1" = "iptables" ]; then
		sudo "$1" -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
	else
		sudo "$1" -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT
	fi
	# ----------------------
	echo "Reglas $1: Rechazar todo lo demás explícitamente"
	# ----------------------
	sudo $1 -A INPUT -j REJECT
	sudo $1 -A FORWARD -j REJECT
	# ----------------------
#	echo "Reglas $1: Guardar reglas"
	# ----------------------
	# Void Linux
	#sudo $1-save > /etc/$1/rules.v4
	#sudo ip6tables-save > /etc/$1/rules.v6
	# Debian
	# $1-persistent
	#sudo $1-save > /etc/$1/rules.v4
	#sudo ip6tables-save > /etc/$1/rules.v6
	# ----------------------
	echo "Reglas $1: Guardar reglas para Debian"
	# ----------------------
	if [ -d /etc/iptables ]; then
		if [ "$1" = "iptables" ]; then
			sudo sh -c "$1-save > /etc/iptables/rules.v4"
			echo "Reglas IPv4 guardadas en /etc/iptables/rules.v4"
		else
			sudo sh -c "$1-save > /etc/iptables/rules.v6"
			echo "Reglas IPv6 guardadas en /etc/iptables/rules.v6"
		fi
	fi
	echo "Reglas de $1 aplicadas"
	sudo $1 -L -n -v -x --line-numbers
}
aplicar(){
	if command -v "$1" >/dev/null 2>&1; then
		aplicarReglas "$1"
	else
		echo "$1 no se encuentra en el sistema."
	fi
}
# Función para asegurar que iptables-persistent esté instalado en Debian
preparar_persistencia() {
	if [ -f /etc/debian_version ]; then
		echo "Detectado Debian. Verificando iptables-persistent..."
		if ! dpkg -s iptables-persistent >/dev/null 2>&1; then
			echo "Instalando iptables-persistent..."
			sudo apt-get update
			# DEBIAN_FRONTEND=noninteractive evita que aparezcan pantallas pidiendo confirmación
			sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent
		fi
	fi
}
aplicar "iptables"
aplicar "ip6tables"


