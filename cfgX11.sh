#!/bin/sh
# Estructuracion automatica del entorno visual de usuario
. ./imp.sh
confx11='
Section "Device"
    Identifier  "Rockchip Graphics"
    Driver      "modesetting"
    Option      "kmsdev" "/dev/dri/card0"
    Option      "pageflip" "true"
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Device      "Rockchip Graphics"
EndSection
'
configurarx11() {
	echo "$confx11" | tee -a ~/.config/openbox/autostart
}
