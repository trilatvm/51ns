#!/bin/sh
# Servicios OS
verSv(){ nmb="$1"; rta="/var/service/${nmb}";
	if [ -L ${rta} ]; then
		sv status ${nmb}
	else
		printf "[ERR][SV][VER][${nmb}] no existe\n"
	fi;  }
crearSv(){ nmb="$1"; rta="/etc/sv/${nmb}";
	if [ -d ${rta} ]; then
		ln -sf "${rta}" /var/service/
		verSv "${nmb}"
	else
		printf "[ERR][SV][CREAR][${nmb}] no existe\n"
	fi;  }
iniciarSv(){ nmb="$1"; sv start ${nmb}; verSv "${nmb}"; }
reIniciarSv(){ nmb="$1"; sv restart ${nmb}; verSv "${nmb}"; }
pararSv(){ nmb="$1"; sv stop ${nmb}; verSv "${nmb}"; }
crearSvNTP() { pararSv "chronyd"; crearSv "ntpd"; }
crearSvNET() { crearSv "iptables"; crearSv "fail2ban"; crearSv "NetworkManager"; }
crearSvGUI() { crearSv "dbus"; crearSv "polkitd"; }
crearSvAll() { crearSvNTP; crearSvNET; crearSvGUI; }
#crearSvAll
#exit 0
