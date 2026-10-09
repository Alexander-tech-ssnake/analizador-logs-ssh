# analizador-logs-ssh

Script en Bash que cuenta los intentos fallidos de inicio de sesión SSH por dirección IP, a partir de los registros del sistema, para detectar posibles ataques de fuerza bruta.

## Objetivo

- Aprender a utilizar **Windows Subsystem for Linux (WSL)** para trabajar en un entorno de línea de comandos Linux desde Windows.
- Demostrar el dominio de **Bash scripting** aplicado a la administración de sistemas y a la ciberseguridad defensiva.
- Crear una herramienta práctica de análisis de logs SSH para auditar la seguridad de un servidor.

## Requisitos

- **Sistema operativo:** Linux (de preferencia Ubuntu o Debian) o Windows con WSL.
- **Intérprete:** Bash.
- **Herramientas del sistema:** `grep` (con soporte para `-P`), `sort` y `uniq`.
- **Permisos:** lectura sobre el archivo de log, ya sea con `sudo` o perteneciendo al grupo `adm`.

`openssh-server` y `rsyslog` solo son necesarios si quieres generar tus propios logs (ver [Entorno de prueba](#entorno-de-prueba)).

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

Si tu usuario no tiene permisos de lectura sobre el log, ejecútalo con `sudo`.

## Ejemplo de salida

<img width="506" height="76" alt="Ejemplo de salida del analizador" src="https://github.com/user-attachments/assets/83d73b8e-50d3-4960-946c-b7ebc3fad5a8" />

La primera columna es el número de intentos fallidos y la segunda la IP de origen, ordenadas de mayor a menor.

## Cómo funciona

El script usa herramientas nativas de Linux encadenadas con tuberías (`|`) en cuatro pasos:

1. **Selección y validación del log:** usa el archivo que se le pase como argumento o, si no recibe ninguno, `/var/log/auth.log`. Antes de analizarlo comprueba que el archivo exista y se pueda leer; si no, muestra un mensaje de error y termina, en lugar de fallar en silencio.
2. **Filtrado de eventos:** `grep "Failed password"` conserva solo las líneas de intentos de autenticación fallidos.
3. **Extracción de la IP:** `grep -oP 'from \K[0-9.]+'` toma únicamente la dirección que aparece después de la palabra `from`.
   No se usa `awk` por columnas porque la posición de la IP cambia: cuando el usuario no existe, el log agrega las palabras `invalid user`, lo que desplaza los campos.

   ```
   Failed password for invalid user admin from 127.0.0.1 port 49054 ssh2   ← IP en el campo 11
   Failed password for alex from 127.0.0.1 port 35846 ssh2                 ← IP en el campo 9
   ```

4. **Conteo y orden:** `sort` agrupa las IPs iguales (requisito de `uniq`, que solo une líneas consecutivas), `uniq -c` cuenta cuántas veces aparece cada una y `sort -nr` las ordena numéricamente de mayor a menor.

## Entorno de prueba

Los datos se generaron en un laboratorio propio dentro de WSL (Ubuntu), simulando un ataque de fuerza bruta contra la misma máquina:

```bash
sudo apt update
sudo apt install openssh-server rsyslog
sudo service rsyslog start
sudo service ssh start
```

Luego se hicieron varios intentos de conexión con contraseñas incorrectas, tanto con usuarios inexistentes (`usuariofalso`, `admin`) como con un usuario real, y desde dos orígenes distintos:

```bash
ssh usuariofalso@localhost           # origen 127.0.0.1
ssh usuariofalso@$(hostname -I)      # origen: IP de red de WSL
```

Cada intento fallido quedó registrado por `rsyslog` en `/var/log/auth.log`.

**Hallazgos durante las pruebas:**

- Ubuntu reciente registra las fechas en formato ISO 8601 (`2026-10-09T14:41:13.621162-05:00`), no en el formato clásico `Oct  9 14:41:13`; scripts antiguos que dependan de la fecha pueden fallar.
- El log pertenece al grupo `adm`. En Ubuntu, el primer usuario creado pertenece a ese grupo, por lo que puede leer los logs de autenticación sin `sudo`, un punto a revisar al endurecer un servidor.

## Limitaciones y mejoras futuras

### Limitaciones actuales

- Solo reconoce direcciones IPv4; una conexión por IPv6 (por ejemplo `::1`) no se contabiliza.
- Analiza un único archivo local a la vez y no ofrece lectura en tiempo real.
- No distingue entre intentos contra usuarios reales e inexistentes.
- No emite alertas: muestra el conteo, pero no indica qué IPs superan un umbral sospechoso.
- Requiere ejecución manual.

### Mejoras futuras

- Umbral configurable que marque como sospechosas las IPs con demasiados intentos fallidos.
- Soporte para direcciones IPv6.
- Monitoreo en tiempo real (modo `tail -f`).
- Geolocalización de las IPs mediante la API de ipinfo.io.
- Exportación de resultados a JSON o CSV.
- Bloqueo opcional de IPs sospechosas con reglas de `ufw` o `iptables`.
- Ejecución automática mediante una tarea de `cron`.

## Aviso

Esta herramienta fue desarrollada con fines educativos y de auditoría interna de seguridad. Úsala solo en sistemas propios o con autorización explícita del propietario: analizar registros de sistemas ajenos sin consentimiento puede constituir una infracción legal.
