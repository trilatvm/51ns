#!/bin/sh
ROJO='\033[0;31m'; VERDE='\033[0;32m'; AMARILLO='\033[1;33m'
AZUL='\033[0;34m'; CIAN='\033[0;36m'; NEGRITA='\033[1m'; RESET='\033[0m'
# Validar comandos requeridos
verificar_dependencias() {
    for cmd in convert identify awk sed grep; do
        command -v "$cmd" >/dev/null 2>&1 || { printf "${ROJO}Error: Comando ausente: %s.${RESET}\n" "$cmd"; exit 1; }
    done
}
# Verificar y habilitar politica PDF
verificar_politica_pdf() {
    policy_file=""
    for ruta in /etc/ImageMagick-6/policy.xml /usr/local/etc/ImageMagick-6/policy.xml; do
        [ -f "$ruta" ] && policy_file="$ruta" && break
    done
    [ -z "$policy_file" ] && return 0
    if grep -q 'rights="none" pattern="PDF"' "$policy_file"; then
        printf "\n${AMARILLO}[AVISO] Exportacion PDF bloqueada en: %s${RESET}\n" "$policy_file"
        printf "Habilitar politica ahora? (s/N): "
        read -r resp
        case "$resp" in
            s|S|si|SI|Si)
                [ "$(id -u)" -ne 0 ] && { printf "${ROJO}Error: Ejecutar como root.${RESET}\n"; exit 1; }
                sed -i.bak 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' "$policy_file" && rm -f "${policy_file}.bak"
                printf "${VERDE}[OK] Politica activada:${RESET}\n${CIAN}"; grep 'pattern="PDF"' "$policy_file"; printf "${RESET}\n" ;;
            *) printf "${ROJO}Operacion cancelada.${RESET}\n"; exit 1 ;;
        esac
    fi
}
# Configurar hoja, orientacion y DPI
configurar_parametros() {
    printf "${NEGRITA}Seleccionar tamano${RESET} [1 = A4 (defecto), 2 = Oficio]: "
    read -r opt_tam
    case "$opt_tam" in
        2|oficio|OFICIO|Oficio) base_w="8.50"; base_h="13.00"; nom_tam="Oficio" ;;
        *) base_w="8.27"; base_h="11.69"; nom_tam="A4" ;;
    esac
    printf "${NEGRITA}Seleccionar orientacion${RESET} [1 = Vertical (defecto), 2 = Horizontal]: "
    read -r opt_ori
    case "$opt_ori" in
        2|h|H|horizontal|HORIZONTAL) hoja_w="$base_h"; hoja_h="$base_w"; nom_ori="Horizontal" ;;
        *) hoja_w="$base_w"; hoja_h="$base_h"; nom_ori="Vertical" ;;
    esac
    while true; do
        printf "${NEGRITA}Ingresar DPI${RESET} [Enter = original de cada imagen]: "
        read -r dpi_usuario
        [ -z "$dpi_usuario" ] && break
        case "$dpi_usuario" in
            *[!0-9]*|0) printf "${ROJO}Error: Ingresar numero entero positivo.${RESET}\n" ;;
            *) break ;;
        esac
    done
    etiqueta="${nom_tam} ${nom_ori}"
}
# Convertir imagen individual
procesar_imagen() {
    img="$1"; dest_dir="$2"; in_w="$3"; in_h="$4"; etiq="$5"; dpi_forzado="$6"
    base=$(basename "$img")
    salida="${dest_dir}/${base%.*}.pdf"
    if [ -n "$dpi_forzado" ]; then
        dpi="$dpi_forzado"
    else
        dpi=$(identify -units PixelsPerInch -format "%x" "$img" 2>/dev/null | awk '{print int($1)}')
        [ -z "$dpi" ] || [ "$dpi" -le 0 ] && dpi=72
    fi
    w_hoja=$(awk "BEGIN {printf \"%d\", $dpi * $in_w}")
    h_hoja=$(awk "BEGIN {printf \"%d\", $dpi * $in_h}")
    w_max=$(awk "BEGIN {printf \"%d\", $dpi * ($in_w - 0.40)}")
    h_max=$(awk "BEGIN {printf \"%d\", $dpi * ($in_h - 0.40)}")
    printf "${AZUL}Procesar:${RESET} %s ${CIAN}(%s DPI | %s)${RESET} -> %s\n" "$base" "$dpi" "$etiq" "$salida"
    convert "$img" -resize "${w_max}x${h_max}" -gravity center -background white \
        -extent "${w_hoja}x${h_hoja}" -units PixelsPerInch -density "$dpi" "$salida"
    if [ $? -eq 0 ] && [ -s "$salida" ]; then
        printf "  ${VERDE}[OK] Archivo generado.${RESET}\n"
    else
        printf "  ${ROJO}[ERROR] Fallo al convertir: %s.${RESET}\n" "$base"
    fi
}
# Procesar archivo unico o directorio
ejecutar_lote() {
    entrada="$1"; destino="$2"; w="$3"; h="$4"; etiq="$5"; dpi_cfg="$6"; contador=0
    if [ -f "$entrada" ]; then
        procesar_imagen "$entrada" "$destino" "$w" "$h" "$etiq" "$dpi_cfg"; contador=1
    elif [ -d "$entrada" ]; then
        for archivo in "$entrada"/*; do
            [ -f "$archivo" ] || continue
            ext=$(printf "%s" "${archivo##*.}" | tr '[:upper:]' '[:lower:]')
            case "$ext" in
                jpg|jpeg|png|tif|tiff|bmp|webp|gif)
                    procesar_imagen "$archivo" "$destino" "$w" "$h" "$etiq" "$dpi_cfg"
                    contador=$((contador + 1)) ;;
            esac
        done
    fi
    if [ "$contador" -eq 0 ]; then
        printf "${AMARILLO}Sin imagenes validas en: %s.${RESET}\n" "$entrada"
    else
        printf "\n${VERDE}${NEGRITA}Finalizar lote. Total procesados: %d (%s).${RESET}\n" "$contador" "$etiq"
    fi
}
# Punto de entrada principal
main() {
    verificar_dependencias
    verificar_politica_pdf
    while true; do
        printf "\n${NEGRITA}${CIAN}==================================================${RESET}\n"
        printf "${NEGRITA}Ingresar archivo o directorio origen${RESET} [Enter = actual]: "
        read -r entrada
        [ -z "$entrada" ] && entrada="."
        entrada="${entrada%/}"; [ -z "$entrada" ] && entrada="/"
        [ ! -e "$entrada" ] && { printf "${ROJO}Error: Ruta inexistente: %s.${RESET}\n" "$entrada"; continue; }
        [ -d "$entrada" ] && dir_origen="$entrada" || dir_origen=$(dirname "$entrada")
        printf "${NEGRITA}Ingresar directorio destino${RESET} [Enter = %s/convertidos]: " "$dir_origen"
        read -r destino
        [ -z "$destino" ] && destino="${dir_origen}/convertidos"
        destino="${destino%/}"
        configurar_parametros
        if [ ! -d "$destino" ]; then
            mkdir -p "$destino" || { printf "${ROJO}Error: Imposible crear directorio: %s.${RESET}\n" "$destino"; continue; }
            printf "${VERDE}Crear directorio:${RESET} %s\n" "$destino"
        fi
        ejecutar_lote "$entrada" "$destino" "$hoja_w" "$hoja_h" "$etiqueta" "$dpi_usuario"
        printf "\nConvertir mas archivos? (s/N): "
        read -r repetir
        case "$repetir" in
            s|S|si|SI|Si) ;;
            *) printf "${CIAN}Finalizar ejecucion.${RESET}\n"; break ;;
        esac
    done
}
main "$@"
sync
exit 0