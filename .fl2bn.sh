Llevar el control de la seguridad en una placa de desarrollo (como tu TV Box con chip Rockchip RK3229/RK3228 y kernel actual 6.18) es una excelente decisión para protegerla de ataques de fuerza bruta, especialmente si está expuesta a la red hogareña o a internet.
Al tratarse de una arquitectura armv7l (procesador de 32 bits de bajo consumo), la configuración de fail2ban debe ser eficiente para no consumir memoria RAM innecesaria ni sobrecargar el almacenamiento (tarjeta SD o memoria eMMC integrada) con escrituras constantes en los logs.
------------------------------
## 📦 1. Instalación limpia
Primero, asegurate de tener los paquetes actualizados e instalados en tu sistema:
sudo apt update
sudo apt install fail2ban -y
------------------------------
## ⚙️ 2. Configuración de la persistencia (Crucial para TV Boxes)
Por defecto, fail2ban escribe una base de datos en /var/lib/fail2ban/fail2ban.sqlite3. En dispositivos embebidos basados en Rockchip, las escrituras constantes en la SD pueden acortar su vida útil o ralentizar el sistema.
Vamos a configurar fail2ban para que use la memoria RAM para su base de datos o deshabilitarla si no te interesa guardar el historial tras un reinicio.
1. Creá o editá el archivo de configuración global:

sudo nano /etc/fail2ban/fail2ban.local

2. Agregá el siguiente contenido para desactivar la base de datos persistente (altamente recomendado para tu hardware):

[Definition]
dbfile = :memory:


------------------------------
## 🛡️ 3. Configuración de las Reglas (Jails) para SSH
Nunca modifiques el archivo /etc/fail2ban/jail.conf directamente, ya que las actualizaciones lo van a sobrescribir. Siempre debés usar un archivo terminado en .local.
1. Creá el archivo de reglas locales:

sudo nano /etc/fail2ban/jail.local

2. Pegá la siguiente configuración optimizada para tu entorno:
[DEFAULT]
# IPs a las que NUNCA se va a bloquear (tu red local)
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24
# Tiempo de baneo por defecto: 10 minutos (600 segundos)
bantime  = 600
# Ventana de tiempo para contar los intentos: 10 minutos
findtime = 600
# Cantidad de intentos fallidos antes de bloquear
maxretry = 3
# Usar systemd para leer los logs (más eficiente que buscar archivos de texto)
backend = systemd
[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
backend = systemd
Nota: Si cambiaste el puerto de SSH por defecto (22), modificá la línea port = ssh por tu número de puerto (ejemplo: port = 2222).
------------------------------
## 🚀 4. Habilitación y Verificación del Servicio
Una vez que guardaste los cambios en ambos archivos .local, reiniciá y habilitá el servicio para que arranque automáticamente con el sistema:
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
## Comandos útiles de control técnico:
* Ver el estado general de las jaulas:
sudo fail2ban-client status
* Ver el estado específico del filtro SSH (ver cuántos atacantes bloqueó):
sudo fail2ban-client status sshd
* Desbloquear una IP manualmente (si te bloqueaste por error):
sudo fail2ban-client set sshd unbanip TU_DIRECCION_IP
------------------------------
¿Tenés algún servidor web (como Nginx o Apache) o un panel de control corriendo en la TV Box para el cual necesites agregar reglas de bloqueo adicionales?
##################################################
Este error técnico significa que el comando cliente de fail2ban no puede comunicarse con el motor del servicio porque el proceso principal del servidor no está en ejecución, o el archivo de socket de Unix no pudo crearse en la RAM.
Al configurar previamente dbfile = :memory: en un kernel 6.18 sobre hardware Rockchip, es muy común que el directorio temporal /var/run/fail2ban/ pierda los permisos adecuados o que un error de sintaxis en los archivos .local impida el arranque del servicio.
------------------------------
## 🛠️ Pasos de diagnóstico y resolución
Siga este orden estricto de comandos para identificar y solucionar el fallo:
## 1. Verificar el error real del servicio
El comando fail2ban-client solo reporta la ausencia del socket. Para ver exactamente por qué se detuvo el motor, ejecute:
sudo systemctl status fail2ban.service
O revise las últimas líneas del registro del sistema:
sudo journalctl -u fail2ban -n 20 --no-pager
## 2. Corregir permisos del directorio del socket
En distribuciones optimizadas para placas de desarrollo (como Armbian), el directorio /var/run/ reside en la memoria RAM (tmpfs). Si el servicio se detiene abruptamente, la estructura de carpetas puede bloquearse. Fuerce la creación y asigne los permisos correctos:
sudo mkdir -p /var/run/fail2ban
sudo chmod 0755 /var/run/fail2ban
## 3. Verificar errores de sintaxis en la configuración
Si hay un espacio de más o un carácter inválido en jail.local o fail2ban.local, el daemon abortará el inicio. Valide la configuración con:
sudo fail2ban-server -t
Si este comando devuelve algún error con la palabra ConfigParserError o similar, le indicará la línea exacta que debe corregir con nano.
## 4. Forzar el reinicio limpio
Una vez hechas las comprobaciones, proceda a reiniciar el servicio de forma limpia:
sudo systemctl stop fail2ban
sudo systemctl start fail2ban
------------------------------
¿Qué salida le devolvió el comando sudo systemctl status fail2ban.service para poder identificar la línea exacta que está bloqueando el arranque?
#########################################
El error técnico crítico con el código status=255/EXCEPTION inmediatamente después de indicar Server ready confirma que el motor de fail2ban arrancó correctamente, pero abortó de forma abrupta al intentar inicializar la jaula (jail) de SSH mediante el backend de systemd.
Este comportamiento es un error conocido (bug) en la integración de fail2ban con las versiones modernas de systemd y python en arquitecturas de 32 bits (como tu procesador ARMv7). El módulo de lectura de logs por sistema de archivos virtual falla al procesar los punteros de los diarios.
------------------------------
## 🛠️ Solución técnica definitiva
Para resolver la excepción, debemos cambiar el método de lectura de registros de systemd al método clásico de archivos de texto (polling a través de /var/log/auth.log).
## 1. Modificar el archivo jail.local
Abra el archivo de configuración de las jaulas:
sudo nano /etc/fail2ban/jail.local
## 2. Reemplazar la configuración del backend
Busque las líneas que configuramos antes y cambie el backend = systemd por backend = polling. Su archivo debe quedar estructurado exactamente de la siguiente manera:
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 192.168.1.0/24
bantime  = 600
findtime = 600
maxretry = 3
# Cambiado de systemd a polling para estabilidad en ARMv7
backend = polling
[sshd]
enabled = true
port = ssh
# Ruta absoluta del registro de autenticación tradicional
logpath = /var/log/auth.log
backend = polling
Guarde los cambios presionando Ctrl+O, confirme con Enter y salga con Ctrl+X.
## 3. Forzar el inicio y verificar
Aplique un reinicio limpio del servicio del sistema para que tome la nueva directiva de lectura de archivos:
sudo systemctl daemon-reload
sudo systemctl restart fail2ban
Verifique nuevamente el estado del servicio:
sudo systemctl status fail2ban.service
------------------------------
Si el servicio ahora muestra el estado en verde como active (running), el problema quedó resuelto. ¿Podría ejecutar ahora el comando sudo fail2ban-client status sshd para confirmar que la jaula está monitoreando activamente el archivo de log?



