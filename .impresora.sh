#!/bin/sh
set -e
for f in ./*.pdf; do echo ">>> Procesando: $f"; lp -d PDF "$f"; while [ -n "$(lpstat -o)" ]; do sleep 2; done; echo ">>> Terminado: $f"; done
sync
exit 0
