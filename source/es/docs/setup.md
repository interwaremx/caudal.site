title: Instalación
---

Instalar Caudal es bastante sencillo. Siempre, necesitas tener instaladas algunas otras cosas primero:

## Requerimientos
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)
 * [Leiningen](leiningen.html)

## Instalación desde los binarios

Hay varias distribuciones binarias de Caudal. Se encuentran empaquetadas en forma de archivos con compresión tar.

### Descargar

Obtén el archivo binario para la última distribición de Caudal desde la [sección de Descargas](https://interwaremx.github.io/caudal.docs/downloads/)
```txt
$ wget https://interwaremx.github.io/caudal.docs/downloads/caudal-0.7.14.tar.gz
```

### Desempaquetar

Desempaqueta el archivo descargado, el cual crea el directorio de instalación.
```
$ tar xzvf caudal-0.7.14.tar.gz
```

### Iniciar
1. Inicia el servidor Caudal
```
$ cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start
```
2. Abre otra terminal y envia un evento a través del canal **tcp** de Caudal corriendo en el puerto **9900** para estar seguro de que puede ser accedido
```
$ telnet localhost 9900
```
3. Ahora escriba `{:message "HelloWorld!"}` de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
```
4. Verifica la bitácora generada para los eventos recibidos.
```
2018-03-07 11:26:02.397 INFO  [clojure-agent-send-pool-2] streams.stateless - {:message "HelloWorld!", :caudal/latency 2953093, :event-counter 1, :millis 1520443562396, :date #inst "2018-03-07T17:26:02.396-00:00"}
```
5. Escribe `{: foo: bar}` y cierra la conexión:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
{:foo :bar}
EOT
Connection closed by foreign host.
$
```
6. Verifica la bitácora generada para los eventos recibidos.
```
2018-03-07 11:26:36.698 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :bar, :caudal/latency 1114642, :event-counter 2, :millis 1520443596698, :date #inst "2018-03-07T17:26:36.698-00:00"}
```
7. Detén Caudal usando `Ctrl-C`

## Instalación desde las fuentes
Puedes iniciar una configuración de Caudal desde las fuentes, gratuitamente desde [github](https://github.com/interwaremx/caudal).

### Descargar
Usa **git** para descargar la última versión de Caudal.
```
$ git clone https://github.com/interwaremx/caudal
```

### Compilar

1. Utilice el script `make-distro.sh` para compilar y crear un proyectos, tal vez demore algunos minutos:
```
$ bin/make-distro.sh
```
2. Finalmente, el script genera un directorio `caudal-0.7.14/`
```
$ cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start
```
3. Abre otra terminal y envia un evento a través del canal **tcp** de Caudal corriendo en el puerto **9900** para estar seguro de que puede ser accedido
```
$ telnet localhost 9900
```
4. Ahora escriba `{:message "HelloWorld!"}` de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
```
5. Verifica la bitácora generada para los eventos recibidos.
```
2018-03-07 11:26:02.397 INFO  [clojure-agent-send-pool-2] streams.stateless - {:message "HelloWorld!", :caudal/latency 2953093, :event-counter 1, :millis 1520443562396, :date #inst "2018-03-07T17:26:02.396-00:00"}
```
6. Escribe `{: foo: bar}` y cierra la conexión:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
{:foo :bar}
EOT
Connection closed by foreign host.
$
```
7. Verifica la bitácora generada para los eventos recibidos.
```
2018-03-07 11:26:36.698 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :bar, :caudal/latency 1114642, :event-counter 2, :millis 1520443596698, :date #inst "2018-03-07T17:26:36.698-00:00"}
```
8. Detén Caudal usando `Ctrl-C`
