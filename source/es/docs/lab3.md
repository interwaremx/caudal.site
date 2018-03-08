title: Lab 3 - Streamers
---

Streamers son funciones especiales que manipulan y enriquecen** los eventos.

## Requerimientos
 * [Setup](setup.html)
 * [Configuration](configuration.html)

![Caudal Streamers Diagram](../../docs/diagram-streamers.svg)

Caudal proporciona `defsink` que es un macro para consumir** eventos y streamers para manipularlo. Existe 2 tipos de streamers:

| | |
| - | - |
| Stateless | `smap`, `by`, `->INFO` toma un evento y puede modificarlo (o no), sin embargo, no realiza ninguna modificación en el estado|
| Stateful | `counter` necesita recordar cuántos eventos ha sido etiquetados, por lo tanto, usa el estado para hacerlo|


A continuación se muestran algunos streamers:


## default
Toma cada evento y agrega una nueva clave y valor. Es una función streamer stateless.

### Configuración
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (default [:my-new-random (Math/random)]))
```
Recibe un vector con 2 elementos, una nueva clave y valor para enriquecer el evento actual.

### Ejemplo
Escriba la siguiente configuración en el directorio `config/`:
```clojure config/streamer-default.clj
;; Requires
(ns caudal.example.streamers
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server 
                   :parameters {:port        9900
                                :idle-period 60}}])

;; Sinks
(defsink example 1 ;; backpressure
  (default [:reception-time (new java.util.Date)]
           (->INFO [:all])))

;; Wire
(wire [tcp] [example])
```

Ejecute Caudal pasando este archivo en la configuración:
```
$ bin/caudal -c config/streamer-default.clj start

```

Abra una terminal telnet hacia `localhost`puerto `9900`:
```
$ telnet localhost 9900
```

Y escriba un mapa EDN de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo 1}
```

Verifique el registro generado para el nuevo evento entrante:
```
2018-03-05 18:21:50.419 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 2118820, :reception-time #inst "2018-03-06T00:21:42.360-00:00"}
```
Como puede ver, el streamer `default` agrega el atributo `:reception-time` a cada evento recibido.


## counter
Toma cada evento y agrega un campo con su número de entrada. Es una función streamer stateful.

### Configuración
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (counter [:state-counter :event-counter]))
```
Recibe un vector con 2 elementos, una clave para almacenar el conteo actual en el estado y una clave para propagar el conteo actual en el evento.

### Ejemplo
Escriba la siguiente configuración en el directorio `config/`:
```clojure config/streamer-counter.clj
;; Requires
(ns caudal.example.streamers
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server 
                   :parameters {:port        9900
                                :idle-period 60}}])

;; Sinks
(defsink example 1 ;; backpressure
  (counter [:state-count :event-count]
           (->INFO [:all])))

;; Wire
(wire [tcp] [example])
```

Ejecute Caudal pasando este archivo en la configuración:
```
$ bin/caudal -c config/streamer-counter.clj start
```

Abra una terminal telnet hacia `localhost`puerto `9900`:
```
$ telnet localhost 9900
```

Y escriba un mapa EDN de la siguiente manera
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo 1}
{:foo 1}
{:foo 1}
```

Verifique el registro generado para el nuevo evento entrante:
```
2018-03-05 18:51:03.484 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 747057, :event-count 1}
2018-03-05 18:51:04.465 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo 1, :caudal/latency 790930, :event-count 2}
2018-03-05 18:51:05.053 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo 1, :caudal/latency 705925, :event-count 3}
```
Como puede ver, a cada evento recibido se le agregó el atributo `:event-count` que contiene el conteo actual.


## smap
Toma cada evento y lo transforma. Es una función streamer stateless.

### Configuración
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (smap [(fn [event] (assoc event :key "value"))]))
```
Recibe un vector con una función de arity 1, de modo que propaga como un evento nuevo, el resultado de aplicar la función al evento.

### Ejemplo
Escriba la siguiente configuración en el directorio `config/`:
```clojure config/streamer-smap.clj
;; Requires
(ns caudal.example.streamers
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server 
                   :parameters {:port        9900
                                :idle-period 60}}])

(defn calculate-tax [event]
  (let [ammount (:ammount event)
        tax     (* 0.16 ammount)
        total   (+ ammount tax)]
    (assoc event :tax tax :total total)))

;; Sinks
(defsink example 1 ;; backpressure
  (smap [calculate-tax]
           (->INFO [:all])))

;; Wire
(wire [tcp] [example])
```

Ejecute Caudal pasando este archivo en la configuración:
```
$ bin/caudal -c config/streamer-smap.clj start
```

Abra una terminal telnet hacia `localhost`puerto `9900`:
```
$ telnet localhost 9900
```

Y escriba un mapa EDN de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:product "kiwi" :ammount 10}
```

Verifique el registro generado para el nuevo evento entrante:
```
2018-03-05 18:30:55.618 INFO  [clojure-agent-send-pool-1] streams.stateless - {:product "kiwi", :ammount 10, :caudal/latency 1815598, :tax 1.6, :total 11.6}
```
Como puede ver, el streamer `smap` transformo cada evento agregando dos nuevos campos `:tax` y `:total`.


## where
Filtrar eventos usando un predicado condicional. Es una función streamer stateless.

### Configuración
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (where [(countains? % :foo)]
              (->INFO[:all])))
```
Recibe un vector con un condicional, si es verdadero, ejecuta el código anidado.

### Ejemplo
Escriba la siguiente configuración en el directorio `config/`:
```clojure config/streamer-where.clj
;; Requires
(ns caudal.example.streamers
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server 
                   :parameters {:port        9900
                                :idle-period 60}}])

;; Sinks
(defsink example 1 ;; backpressure
  (where [:tweet-id]
         (counter [:tweet-count :count]
                  (->INFO [:all]))))

;; Wire
(wire [tcp] [example])
```

Ejecute Caudal pasando este archivo en la configuración:
```
$ bin/caudal -c config/streamer-where.clj start
```

Abra una terminal telnet hacia `localhost`puerto `9900`:
```
$ telnet localhost 9900
```

Y escriba un mapa EDN de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tweet-id 1 :text "Hello"}
{:tweet-id 2 :text "World"}
{:tweet-id false :text "!!"}
{:tweet-id nil :text "!!"}
{:text "!!"}
{:tweet-id "ok" :text "!!"}
```

Verifique el registro generado para el nuevo evento entrante:
```
2018-03-05 19:13:28.642 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 652919, :count 1}
2018-03-05 19:13:52.874 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tweet-id 2, :text "World", :caudal/latency 802505, :count 2}
2018-03-05 19:15:01.228 INFO  [clojure-agent-send-pool-0] streams.stateless - {:tweet-id "ok", :text "!!", :caudal/latency 436745, :count 3}
```
Como puede ver, esta vez el contador solo llegó a 3


## by
Agrupa eventos por valores de claves enviadas. Es una función streamer stateless.

### Configuración
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
      (by [:id]
           (counter [:s-count :e-count])))
```
Recibe un vector con claves para clasificar el código anidado, de modo que el código anidado se ejecute independientemente para cada clasificación.

### Ejemplo
Escriba la siguiente configuración en el directorio `config/`:
```clojure config/streamer-by.clj
;; Requires
(ns caudal.example.streamers
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server 
                   :parameters {:port        9900
                                :idle-period 60}}])

;; Sinks
(defsink example 1 ;; backpressure
  (by [:tweet-id]
         (counter [:tweet-count :count]
                  (->INFO [:all]))))

;; Wire
(wire [tcp] [example])
```

Ejecute Caudal pasando este archivo en la configuración:
```
bin/caudal -c config/streamer-by.clj start
```

Abra una terminal telnet hacia `localhost`puerto `9900`:
```
$ telnet localhost 9900
```

Y escriba un mapa EDN de la siguiente manera:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tweet-id 1 :text "Hello"}
{:tweet-id 2 :text "Hello"}
{:tweet-id 3 :text "Hello"}
{:tweet-id 2 :text "World"}
{:tweet-id 1 :text "World"}
{:tweet-id 1 :text "Hello"}
```

Verifique el registro generado para el nuevo evento entrante:
```
2018-03-05 19:45:22.258 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 2896923, :count 1}
2018-03-05 19:45:39.660 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tweet-id 2, :text "Hello", :caudal/latency 804470, :count 1}
2018-03-05 19:46:03.188 INFO  [clojure-agent-send-pool-3] streams.stateless - {:tweet-id 3, :text "Hello", :caudal/latency 877918, :count 1}
2018-03-05 19:46:29.936 INFO  [clojure-agent-send-pool-4] streams.stateless - {:tweet-id 2, :text "World", :caudal/latency 697957, :count 2}
2018-03-05 19:46:46.604 INFO  [clojure-agent-send-pool-5] streams.stateless - {:tweet-id 1, :text "World", :caudal/latency 523277, :count 2}
2018-03-05 19:46:49.927 INFO  [clojure-agent-send-pool-0] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 659900, :count 3}
```
Como puede ver, esta vez el valor de `counter` es independiente para cada atributo `:tweet-id`.
