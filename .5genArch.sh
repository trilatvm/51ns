#!/bin/sh
# .5genArch.sh: Generador de archivos para pruebas
set -e
# Configuración global de entorno
BASE_BLOQUE=1024
TOTAL_ARCHIVOS=29   # Cantidad exacta de archivos a generar (del 1 al 50)
BASE_ESTETICA=100   # Forzar que el nombre empiece en 100 para mantener 3 dígitos constantes
PREFIJO_SALIDA="./Arch"
# Capa Visual: Mensajes formateados
log_info() { printf "\033[0;36m[INF]\033[0m %s\n" "$1"; }
log_ok() { printf "\033[0;92m[ OK ]\033[0m %s\n" "$1"; }
limpiar_residuos() { rm -f "${PREFIJO_SALIDA}"*.zip; }
# Algoritmo de Fibonacci optimizado con printf nativo
calcular_fibonacci_count() {
	indice_fibo=$1
	fibo_previo=0
	fibo_actual=1
	if [ "$indice_fibo" -eq 1 ]; then
		printf "%s" "$fibo_actual"
		return 0
	fi
	it=2
	while [ "$it" -le "$indice_fibo" ]; do
		fibo_siguiente=$((fibo_previo + fibo_actual))
		fibo_previo=$fibo_actual
		fibo_actual=$fibo_siguiente
		it=$((it + 1))
	done
	printf "%s" "$fibo_actual"
}
# Capa de Escritura Física con formateo de columnas alineadas a la derecha
escribir_contenedor_binario() {
	ruta_archivo=$1
	bloques_count=$2
	# Protección contra desbordamiento numérico / límite seguro para tu disco (ej: 4 Millones de bloques = 4GB)
	if [ "$bloques_count" -gt 4194304 ] || [ "$bloques_count" -le 0 ]; then
		printf "\033[0;33m[WARN]\033[0m Archivo %s omitido: El tamaño excede el límite seguro.\n" "$(basename "$ruta_archivo")"
		return 1 # Retorna fallo para detener el lote si se llega al límite de espacio seguro
	fi
	bytes_totales=$((bloques_count * BASE_BLOQUE))
	# Conversión humana dinámica para evitar deformación visual de números masivos
	if [ "$bytes_totales" -lt 1048576 ]; then
		size_humanos="$((bytes_totales / 1024)) KB"
	elif [ "$bytes_totales" -lt 1073741824 ]; then
		size_humanos="$((bytes_totales / 1048576)) MB"
	else
		size_humanos="$((bytes_totales / 1073741824)) GB"
	fi
	# Printf con padding rígido para alinear columnas a la derecha
	# %-12s -> Nombre de archivo alineado a la izquierda (longitud fija gracias a tu base 100)
	metrics=$(printf "Archivo: %-12s | Count: %15s | %12s | %20s Bytes" \
		"$(basename "$ruta_archivo")" "$bloques_count" "$size_humanos" "$bytes_totales")
	log_info "$metrics"
	# Inyección física real controlada
	dd if=/dev/urandom of="$ruta_archivo" bs=$BASE_BLOQUE count="$bloques_count" status=none conv=fdatasync
	return 0
}
procesar_lote_pruebas() {
	ciclo_actual=1
	while [ "$ciclo_actual" -le "$TOTAL_ARCHIVOS" ]; do
		# SEPARACIÓN LÓGICA: El nombre usa la base 100 (101, 102...), el cálculo usa el índice real (1, 2...)
		id_estetico=$((BASE_ESTETICA + ciclo_actual))
		nombre_salida="${PREFIJO_SALIDA}${id_estetico}.zip"
		multiplicador_dd=$(calcular_fibonacci_count "$ciclo_actual")
		# Detiene el bucle de forma segura si la protección por tamaño se activa
		if ! escribir_contenedor_binario "$nombre_salida" "$multiplicador_dd"; then
			break
		fi
		ciclo_actual=$((ciclo_actual + 1))
	done
}
main() {
	clear
	log_ok "SCRITP INICIO"
	limpiar_residuos
	procesar_lote_pruebas
	log_ok "SCRITP    FIN"
}
main "$@"
exit 0



