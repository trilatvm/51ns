#!/bin/sh
# Estructuracion automatica del entorno visual de usuario
. ./imp.sh
. ./cfgSV.sh
configurarFakeClock() {
	ntpdate -u ntp.metas.ch
	fake-hwclock save
}
