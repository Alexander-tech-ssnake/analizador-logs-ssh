#!/bin/bash
#Analizador de intentos fallidos de SSH
#Uso: sudo ./analizar_ssh.sh [archivo_de_log]

LOG="${1:-/var/log/auth.log}"

if [ ! -r "$LOG" ]; then
	echo "Error: no se pude leer $LOG (¿olvidaste usar sudo?)"
	exit 1
fi

echo "Intentos fallidos de SSH por IP en: $LOG"
echo "----------------------------------------"
grep "Failed password" "$LOG" | grep -oP 'from \K[0-9.]+' | sort | uniq -c | sort -nr
