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
*sudo apt update
*sudo apt install openssh-server rsyslog
*sudo service rsyslog start
*sudo service ssh start
*ls -l

## Uso
Se hace uso del comando sudo 
<img width="608" height="28" alt="{E45D25AF-39C8-481E-8113-BBB403B62EAB}" src="https://github.com/user-attachments/assets/92f62206-2127-47ea-93cb-ba5cae095bca" />

## Ejemplo de salida
<img width="506" height="76" alt="{EFD6B107-E556-4AA3-881B-8C416B54D1B5}" src="https://github.com/user-attachments/assets/83d73b8e-50d3-4960-946c-b7ebc3fad5a8" />

## Cómo funciona
El script utiliza erramientas nativas de Linux para extraer y formatear la información relevante con estos 4 pasos importnates:
* Localización de Log: La detección automáticamente si el sistema utiliza /var/log/auth.log
* Filtrado de Eventos: Se utiliza grep para buscar patrones clave como Failed password
* Extracción y conteo: Se hace una combinación de sort y uniq -c para ordenar y contabilizar las frecuencias de cada evento.
* Detección de Umbrales: Compara la cantidad de fallos por IP contra un umbral definido para emitir aletas de posibles ataques de fuerza bruta.

## Limitaciones y mejoras futuras
##Limitaciones actuales 
Solo analiza un archivo de log local a la vez; no soporta lectura en tiempo real mediante streaming. 
No distingue entre usuarios reales e inexistentes en el sistema durante el conteo de fallos. 
Requiere ejecutarse manualmente por el usuario. 
##Mejoras futuras 
*Agregar opción de monitoreo en tiempo real (modo watch/tail). 
*Integración con la API de ipinfo.io para geolocalizar las direcciones IP atacantes.
*Exportación de resultados a formatos estructurados (JSON o CSV). 
*Opción para bloquear automáticamente las IP sospechosas generando reglas en iptables o ufw. 
*Configuración de ejecución automática mediante una tarea programada (cron job).

## Aviso
Esta herramienta fue desarrollada con fines educativos y de auditoría interna de seguridad. El análisis de registros de sistemas ajenos sin el consentimiento explícito del propietario puede constituir una violación legal.
