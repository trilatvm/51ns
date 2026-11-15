#!/bin/sh
# Estructuracion automatica del entorno visual de usuario
. ./imp.sh
confAutostart='
! --- Dimencion ---
xterm*geometry: 100x25
! --- Color ---
xterm*background: black
xterm*foreground: green
! --- Fuente y suavizado (Antialiasing) ---
xterm*faceName: Terminus
xterm*faceSize: 8
xterm*renderFont: true
Xft.antialias: true
Xft.hinting: true
Xft.rgba: rgb
Xft.hintstyle: hintslight
! --- Soporte UTF-8 y 256 colores ---
xterm*locale: false
xterm*utf8: 2
xterm*termName: xterm-256color
! --- Copiar y Pegar (Ctrl+Shift+C / Ctrl+Shift+V) ---
xterm*selectToClipboard: true
xterm*VT100.translations: #override \n\
    Ctrl Shift <Key>C: copy-selection(CLIPBOARD) \n\
    Ctrl Shift <Key>V: insert-selection(CLIPBOARD)
'
configurarXter() {
	echo "$confAutostart" | tee -a ~/.Xresources
	xrdb -merge ~/.Xresources
}
