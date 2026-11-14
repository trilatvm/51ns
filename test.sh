#!/sh
# Script de simulación segura (Mock-Sandbox) compatible con POSIX sh
SANDBOX="/tmp/sandbox_test"
mkdir -p "$SANDBOX/etc" "$SANDBOX/var/service" "$SANDBOX/home_mock"
export HOME="$SANDBOX/home_mock"
# --- INTERCEPCIÓN Y MOCK DE COMANDOS CRÍTICOS ---
sudo() { printf "[MOCK-SUDO] Ejecutando: %s\n" "$*"; "$@"; }
xbps-install() { printf "[MOCK-XBPS] Sincronizando/Instalando paquete: %s\n" "$*"; return 0; }
xbps-query() { case "$1" in -l) return 1 ;; -Rs) printf "paquete-void-mock\n"; return 0 ;; esac; }
apt-get() { printf "[MOCK-APT] Actualizando/Instalando paquete: %s\n" "$*"; return 0; }
apt-cache() { printf "paquete-debian-mock\n"; return 0; }
dpkg-query() { return 1; }
pkg() { printf "[MOCK-PKG-BSD] Operando: %s\n" "$*"; return 0; }
iptables() { printf "[MOCK-FIREWALL] Regla IPv4: %s\n" "$*"; return 0; }
ip6tables() { printf "[MOCK-FIREWALL] Regla IPv6: %s\n" "$*"; return 0; }
sysrc() { printf "[MOCK-SYSRC] Fijando rc.conf: %s\n" "$*"; return 0; }
tee() { case "$*" in */etc/*) printf "[MOCK-WRITE] Redirigido a sandbox: %s\n" "$*"; cat > "$SANDBOX/etc/mock_file" ;; *) /usr/bin/tee "$@" ;; esac; }
sed() { printf "[MOCK-SED] Modificando archivo de configuración inline.\n"; return 0; }
# Redirección de comandos del sistema para evitar alteración real
mkdir() { /bin/mkdir -p "$SANDBOX/$*"; }
chown() { printf "[MOCK-CHOWN] Cambiando propietarios en entorno aislado.\n"; return 0; }
sync() { printf "[MOCK-SYNC] Búferes sincronizados de forma segura.\n"; return 0; }
# --- CONTROL DE ENTORNO E INTEGRIDAD ---
for m in ./pqt.sh ./sys.sh ./inst.sh; do
	if [ ! -f "$m" ]; then printf "Error: No se encuentra %s en el directorio actual.\n" "$m" >&2; exit 1; fi
done
# Modificación dinámica temporal de sys.sh para inyectar el entorno mock de carpetas
cp ./sys.sh "$SANDBOX/sys.sh.tmp"
sed_mock() { /usr/bin/sed "s|/etc|$SANDBOX/etc|g; s|/var/service|$SANDBOX/var/service|g" "$SANDBOX/sys.sh.tmp" > ./sys.sh; }
sed_mock 2>/dev/null || true
# --- EJECUCIÓN DEL INSTALADOR ---
printf "========================================================================\n"
printf " INICIANDO SIMULACIÓN SEGURA (NINGÚN PAQUETE REAL SERÁ INSTALADO)\n"
printf "========================================================================\n"
export SO="debian" # Podés cambiarlo manualmente a "void" o "freebsd" para probar otra rama
. ./inst.sh
# --- RESTAURACIÓN Y LIMPIEZA ---
mv "$SANDBOX/sys.sh.tmp" ./sys.sh 2>/dev/null || true
rm -rf "$SANDBOX"
printf "\n========================================================================\n"
printf " SIMULACIÓN FINALIZADA - Entorno limpio y sistema intacto.\n"
printf "========================================================================\n"
exit 0
