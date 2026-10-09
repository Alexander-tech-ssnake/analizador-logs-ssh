# analizador-logs-ssh

Es una herramienta que examina de forma automática o semiautomática los archivos de registro que se generaron por el servicio SSH en un servidor

## Objetivo
* Aprender a utilizar **Windows Subsystem for Linux (WSL)** para desenvolverse en un entorno de línea de comandos Linux de forma nativa desde Windows.
* Demostrar el dominio de **Bash Scripting** aplicado a la administración de sistemas y automatización en ciberseguridad.
* Crear una herramienta práctica de análisis de logs SSH para auditar la seguridad de un servidor.

## Requisitos
* Sistema Operativo: Linux(Ubuntu o Debian de preferencia) o Windows con WSL instalado.
* Interprete: Bash de linux
* Herramientas de sistema: grep, rsyslog, ssh, sort, uniq
* Permisos: Permisos de superusuario "sudo" par acceder a los archivos de registro del sistema.

## Instalación
```bash
git clone git@github.com:Alexander-tech-ssnake/analizador-logs-ssh.git
cd analizador-logs-ssh
chmod +x analizar_ssh.sh
```

## Uso
```bash
./analizar_ssh.sh                      # analiza /var/log/auth.log
./analizar_ssh.sh ruta/a/otro.log      # analiza otro archivo de log
```

## Ejemplo de salida
<img width="506" height="76" alt="{EFD6B107-E556-4AA3-881B-8C416B54D1B5}" src="https://github.com/user-attachments/assets/83d73b8e-50d3-4960-946c-b7ebc3fad5a8" />

## Cómo funciona
El script utiliza erramientas nativas de Linux para extraer y formatear la información relevante con estos 4 pasos importnates:
* Localización de Log: La detección automáticamente si el sistema utiliza /var/log/auth.log
* Filtrado de Eventos: Se utiliza grep para buscar patrones clave como Failed password
* Extracción y conteo: Se hace una combinación de sort y uniq -c para ordenar y contabilizar las frecuencias de cada evento.
* Detección de Umbrales: Compara la cantidad de fallos por IP contra un umbral definido para emitir aletas de posibles ataques de fuerza bruta.

## Limitaciones y mejoras futuras
Limitaciones actuales
Solo reconoce direcciones IPv4; una conexión por IPv6 (por ejemplo ::1) no se contabiliza.
Analiza un único archivo local a la vez y no ofrece lectura en tiempo real.
No distingue entre intentos contra usuarios reales e inexistentes.
No emite alertas: muestra el conteo, pero no indica qué IPs superan un umbral sospechoso.
Requiere ejecución manual.
Mejoras futuras
Umbral configurable que marque como sospechosas las IPs con demasiados intentos fallidos.
Soporte para direcciones IPv6.
Monitoreo en tiempo real (modo tail -f).
Geolocalización de las IPs mediante la API de ipinfo.io.
Exportación de resultados a JSON o CSV.
Bloqueo opcional de IPs sospechosas con reglas de ufw o iptables.
Ejecución automática mediante una tarea de cron.
Entorno de prueba

Los datos se generaron en un laboratorio propio dentro de WSL (Ubuntu), simulando un ataque de fuerza bruta contra la misma máquina:

bash
sudo apt update
sudo apt install openssh-server rsyslog
sudo service rsyslog start
sudo service ssh start

Luego se hicieron varios intentos de conexión con contraseñas incorrectas, tanto con usuarios inexistentes (usuariofalso, admin) como con un usuario real, y desde dos orígenes distintos:

bash
ssh usuariofalso@localhost           # origen 127.0.0.1
ssh usuariofalso@$(hostname -I)      # origen: IP de red de WSL

Cada intento fallido quedó registrado por rsyslog en /var/log/auth.log.

Hallazgos durante las pruebas:

Ubuntu reciente registra las fechas en formato ISO 8601 (2026-10-09T14:41:13.621162-05:00), no en el formato clásico Oct  9 14:41:13; scripts antiguos que dependan de la fecha pueden fallar.
El log pertenece al grupo adm. En Ubuntu, el primer usuario creado pertenece a ese grupo, por lo que puede leer los logs de autenticación sin sudo, un punto a revisar al endurecer un servidor.

## Aviso
Esta herramienta fue desarrollada con fines educativos y de auditoría interna de seguridad. El análisis de registros de sistemas ajenos sin el consentimiento explícito del propietario puede constituir una violación legal.
