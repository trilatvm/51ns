#!/bin/sh
definirPaquetes() {
	cliSistema="tmux htop nano vim curl wget git tar unzip zip p7zip rsync mc"
	cliDesarrollo="gcc make cmake python3 nodejs"
	cliHerramientas="ripgrep fd fzf bat eza jq tree ncdu"
	cliMultimedia="ffmpeg yt-dlp"
	guiOpenbox="openbox obconf tint2 nitrogen rofi dunst picom lxappearance"
	guiEntorno="xorg xinit xterm thunar gvfs file-roller scrot"
	guiMultimedia="mpv feh"
	guiOficina="zathura zathura-pdf-mupdf galculator"
	paquetesCli="$cliSistema $cliDesarrollo $cliHerramientas $cliMultimedia"
	paquetesGui="$guiOpenbox $guiEntorno $guiMultimedia $guiOficina"
}




