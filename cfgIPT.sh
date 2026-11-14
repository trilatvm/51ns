#!/bin/sh
# Despliegue de seguridad perimetral iptables / ip6tables
. ./imp.sh
aplicarReglas() {
	_fw="$1"
	impMsg "$AMA" "Escribiendo tablas en $_fw..."
	execSudo "$_fw" -F 2>/dev/null ; execSudo "$_fw" -X 2>/dev/null
	execSudo "$_fw" -t nat -F 2>/dev/null || true
	execSudo "$_fw" -P INPUT DROP 2>/dev/null
	execSudo "$_fw" -P FORWARD DROP 2>/dev/null
	execSudo "$_fw" -P OUTPUT ACCEPT 2>/dev/null
	execSudo "$_fw" -A INPUT -i lo -j ACCEPT 2>/dev/null
	execSudo "$_fw" -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null
	execSudo "$_fw" -A INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null
	execSudo "$_fw" -A INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null
	execSudo "$_fw" -A INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null
	
	if [ "$_fw" = "iptables" ]; then
		execSudo "$_fw" -A INPUT -p icmp --icmp-type echo-request -j ACCEPT 2>/dev/null
	else
		execSudo "$_fw" -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT 2>/dev/null
	fi
	execSudo "$_fw" -A INPUT -j REJECT 2>/dev/null ; execSudo "$_fw" -A FORWARD -j REJECT 2>/dev/null
	
	if [ "$soTarget" = "debian" ] && [ -d /etc/iptables ]; then
		[ "$_fw" = "iptables" ] && _fExt="v4" || _fExt="v6"
		execSudo sh -c "$_fw-save > /etc/iptables/rules.$_fExt" 2>/dev/null || true
	elif [ "$soTarget" = "void" ]; then
		execSudo mkdir -p "/etc/$_fw" 2>/dev/null
		[ "$_fw" = "iptables" ] && _fExt="v4" || _fExt="v6"
		execSudo sh -c "$_fw-save > /etc/$_fw/rules.$_fExt" 2>/dev/null || true
	fi
}
configurarIptables() {
	case "$soTarget" in
		debian|void)
			if [ "$soTarget" = "debian" ]; then
				admPkg "instalar" "iptables-persistent" "/tmp/ipt_dep.log" >/dev/null 2>&1
			fi
			hasCmd iptables && aplicarReglas "iptables"
			hasCmd ip6tables && aplicarReglas "ip6tables" ;;
		freebsd)
			impMsg "$AMA" "Aviso: FreeBSD omite IPTables (usa PF nativo)." ;;
	esac
}
