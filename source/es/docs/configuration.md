title: Configuración
---

## Archivo de Configuración

Caudal usa uno o varios archivos de configuration con la siguiente estructura:
```clojure config.clj
;; Requires
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

;; Sinks
(defsink my-streamer 10000 ;; backpressure limit
  (printe ["Received event : "]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                               :parameters {:port 9900
                                            :idle-period 60}}])

;; Wire listeners and streamers
(wire [my-listener] [my-streamer])
```

* La sección **Requires** carga bibliotecas. Estas bibliotecas contienen funciones de Clojure a ser usadas. Vea la [sección de API](/api) para más información.
* La sección **Sinks** define las funciones analizadoras a ser aplicadas a cada evento dentro del flujo de datos.
* La sección **Listeners** define mecanismos para capturar eventos.
* La sección **Wire** rutea los eventos adquiridos por un listener a un analizador.

## Creando una Configuración Simple

Usando tu editor favorito crea un archivo llamado **simple.clj** dentro del directorio **config/**:
```txt
$ cd caudal-0.7.4
$ emacs config/simple.clj
```

Pon el siguiente contenido en tu **simple.clj**:
```clojure simple.clj
;; Requires
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

;; Sinks
(defsink my-streamer 10000
  ;; Counts received events
  ;; stores account into State with keyword ::counting
  ;; decorates received event with account with keyword :n
  (counter [::counting :n]
    (printe ["Received event: "])))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                               :parameters {:port 9900
                                            :idle-period 60}}])

;; Wire listeners and streamers
(wire [my-listener] [my-streamer])
```

Guarda tu archivo **simple.clj** y arrancalo usando Caudal, pasando tu archivo con la opción **-c**:
```txt
$ bin/start-caudal.sh -c
                        __      __
  _________ ___  ______/ /___ _/ /
 / ___/ __ `/ / / / __  / __ `/ /
/ /__/ /_/ / /_/ / /_/ / /_/ / /
\___/\__,_/\__,_/\__,_/\__,_/_/

Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-30 15:23:35.797 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-30 15:23:35.801 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/simple.clj}}
2017-01-30 15:23:37.007 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
```
Ahora, en otra terminal, envía eventos en formato EDN usando telnet:
```txt
$ telnet localhost 9900
{:foo "bar"}
{:foo "bar"}
{:foo "bar"}
{:foo "bar"}
{:foo "bar"}
{:baz "qux"}
{:baz "qux"}
{:baz "qux"}
{:baz "qux"}
{:baz "qux"}
```

En la terminal de Caudal, tu podrías ver la siguiente salida:
```txt
Received event: {:foo "bar", :caudal/latency 656848, :n 1}
Received event: {:foo "bar", :caudal/latency 666314, :n 2}
Received event: {:foo "bar", :caudal/latency 694574, :n 3}
Received event: {:foo "bar", :caudal/latency 713406, :n 4}
Received event: {:foo "bar", :caudal/latency 598784, :n 5}
Received event: {:baz "qux", :caudal/latency 331390, :n 6}
Received event: {:baz "qux", :caudal/latency 189937, :n 7}
Received event: {:baz "qux", :caudal/latency 196689, :n 8}
Received event: {:baz "qux", :caudal/latency 189225, :n 9}
Received event: {:baz "qux", :caudal/latency 221523, :n 10}
```
