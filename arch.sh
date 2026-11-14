#!/bin/sh
chequear_entorno() {
	for mod in ./pqt.sh ./clr.sh ./tmp.sh ./gfs.sh ./cfgNTP.sh ./cfgOBX.sh ./cfgITB.sh ./cfgF2B.sh; do
		if [ ! -f "$mod" ]; then printf "Error Crítico de Integridad: Falta módulo obligatorio %s\n" "$mod" >&2; exit 1; fi
	done
	if [ ! -w "." ]; then printf "Error de Permisos: El directorio actual no posee permisos de escritura.\n" >&2; exit 1; fi
}
crear_arbol_sesion() {
	chequear_entorno
	L_D=$(get_ts); D_INS="$L_D/instalados"; D_BUS="$L_D/buscados"; L_ERR="$L_D/errores.log"
	if ! mkdir -p "$D_INS" "$D_BUS" 2>/dev/null; then printf "Error de Sistema: Imposible crear estructura en %s\n" "$L_D" >&2; exit 1; fi
}
registrar_ok() { [ -w "$D_INS" ] && printf "paquete='%s'\nsistema='%s'\nfecha='%s'\nestado='EXITO'\n" "$1" "$SO" "$(get_fmt_date)" > "$D_INS/${1}.log.sh"; }
registrar_err() { [ -w "$(dirname "$L_ERR")" ] && printf "[FALLO] Error al instalar paquete %s\n" "$1" >> "$L_ERR"; }
