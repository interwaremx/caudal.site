title: Lab 4 - Estadísticas
---
Una guía para recuperar y producir estadísticas.

## Requerimientos
 * Completar [Listeners](lab1.html)
 * Completar [Streamers](lab3.html)

## Cuenta
### Contando eventos
Esta sección explica como contar cada evento recibido.

Crea una nueva configuración en `config/` con el siguiente contenido:
```config/stats.clj
;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])

(defsink stats-streamer 1
  ;; Counts received events
  ;; stores account into State with keyword :my-counter
  ;; decorates received event with account with keyword :n
  (counter [:my-counter :n]
    (->INFO [:all])))

;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```

Arranca tu configuración usando:
```#bash
$ bin/caudal -c config/stats.clj start
```

Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```
Verifica la salida de Caudal. Observa que cada entrada de evento ha sido decorada con un atributo adicional **:n** con el actual conteo de eventos:
```#bash
2018-03-07 09:12:25.853 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 1291159, :n 1}
2018-03-07 09:12:58.312 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 1345733, :n 2}
```
Detén Caudal usando **Ctrl-c**

### Guardar cuenta
Guarda la cuenta de tus eventos usando **dump-every**.

Actualiza tu configuración:
```config/stats.clj

;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])

(defsink stats-streamer 1
  ;; Counts received events
  ;; stores account into State with keyword :my-counter
  ;; decorates received event with account with keyword :n
  (counter [:my-counter :n]
    (->INFO [:all]
      (dump-every [:my-counter "my-counter" "YYYYMMdd" 1000 "data/stats/"]))))

;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```
Arranca tu configuración usando:
```#bash
$ bin/caudal -c config/stats.clj start
```

Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

Verifica la salida de Caudal:
```#bash
2018-03-07 09:47:10.567 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 2045889, :n 1}
2018-03-07 09:47:22.083 INFO  [clojure-agent-send-pool-3] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 578514, :n 2}
```

Y trata de leer el contenido del archivo **data/stats/YYYMMdd-my-counter.edn**:
```#bash
$ cat data/stats/$( date +"%Y%m%d" )-my-counter.edn
{:n 2,
 :caudal/type "dump_every",
 :caudal/created 1520437630559,
 :caudal/touched 1520437642084}
```

Detén Caudal usando **Ctrl-c**.

### Recuperando cuenta
Para leer tu EDN con el estado de la cuenta es obligatorio cargar el archivo usando **scheduler**.

Actualiza tu configuración y usa el streamer **deflistener** como sigue:

```config/stats.clj
;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])
(deflistener my-scheduler [{:type 'mx.interware.caudal.core.scheduler-server
                            :jobs [{:runit? true
                                    :schedule-def {:in [0 :seconds]}       ;; Run immediately
                                    :event-factory 'mx.interware.caudal.core.scheduler-server/state-admin-event-factory
                                    :parameters {:cmd :load-history        ;; Caudal command to populate State
                                                 :path "data/stats"        ;; Directory of your dump file
                                                 :go-back-millis 0         ;; Milliseconds back to now
                                                 :date-fmt "yyyyMMdd"      ;; Date format
                                                 :key-name "my-counter"}}] ;; Key name to retrieve your file and put in State
                         }])

(defsink stats-streamer 1
  ;; Counts received events
  ;; stores account into State with keyword :my-counter
  ;; decorates received event with account with keyword :n
  (counter [:my-counter :n]
    (->INFO [:all]
      (dump-every [:my-counter "my-counter" "YYYYMMdd" 1000 "data/stats/"]))))

;; Connect listeners and streamers
(wire [my-listener my-scheduler] [stats-streamer])
```

Arranca tu configuración:
```#bash
$ bin/start-caudal.sh -c ./config/stats.clj
```

Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

Verifica la salida de Caudal, el contador de tu evento inicia su valor usando el archivo guardado:
```#bash
2018-03-07 10:15:56.653 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 3657243, :n 3}
2018-03-07 10:16:07.405 INFO  [clojure-agent-send-pool-4] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 942940, :n 4}
```
Detén Caudal usando **Ctrl-c**.

## Desviación Estándar
### Estadísticas de eventos
Esta sección explica como obtener media, varianza y desviación estándar desde los eventos.

 Crea un nuevo archivo de configuración `config/` con el contenido que sigue:
```config/stdev.clj

;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])

(defsink stats-streamer 1
  ;; Welford received events
  ;; stores stats of events into State with keyword :my-stdev
  ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
  (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
    (->INFO [:all])))

;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```

Arranca tu configuración usando:
```#bash
$ bin/caudal -c config/stdev.clj start
```
Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :metric 13}
{:tx "bar" :metric 23}
{:tx "baz" :metric 12}
{:tx "qux" :metric 44}
{:tx "foo" :metric 55}
```

Verifica la salida de Caudal. Observa que cada entrada de evento ha sido decorada con algunos atributos adicionales:
```#bash
2018-03-07 10:32:02.620 INFO  [clojure-agent-send-pool-1] streams.stateless - {:caudal/created 1520440322614, :mean 13, :caudal/touched 1520440322614, :n 1, :variance 0.0, :stdev 0.0, :tx "foo", :caudal/type "welford", :sqrs 0.0, :caudal/latency 3081567, :metric 13}
2018-03-07 10:32:13.503 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520440322614, :mean 18.0, :caudal/touched 1520440333502, :n 2, :variance 25.0, :stdev 5.0, :tx "bar", :caudal/type "welford", :sqrs 50.0, :caudal/latency 1206392, :metric 23}
2018-03-07 10:32:29.653 INFO  [clojure-agent-send-pool-3] streams.stateless - {:caudal/created 1520440322614, :mean 16.0, :caudal/touched 1520440349652, :n 3, :variance 24.666666666666668, :stdev 4.96655480858378, :tx "baz", :caudal/type "welford", :sqrs 74.0, :caudal/latency 1280853, :metric 12}
2018-03-07 10:32:37.842 INFO  [clojure-agent-send-pool-4] streams.stateless - {:caudal/created 1520440322614, :mean 23.0, :caudal/touched 1520440357841, :n 4, :variance 165.5, :stdev 12.864680330268607, :tx "qux", :caudal/type "welford", :sqrs 662.0, :caudal/latency 1278748, :metric 44}
2018-03-07 10:32:38.733 INFO  [clojure-agent-send-pool-5] streams.stateless - {:caudal/created 1520440322614, :mean 29.4, :caudal/touched 1520440358732, :n 5, :variance 296.24, :stdev 17.21162397916013, :tx "foo", :caudal/type "welford", :sqrs 1481.2, :caudal/latency 1266055, :metric 55}
```

Detén Caudal usando **Ctrl-c**.

### Guardar estadísticas
Guarda las estadísticas de tus eventos usando **dump-every**.

Actualiza tu configuración:
```config/stdev.clj

;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])

(defsink stats-streamer 1
  ;; Welford received events
  ;; stores stats of events into State with keyword :my-stdev
  ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
  (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
    (->INFO [:all]
       (dump-every [:my-stdev "my-stdev" "YYYYMMdd" 1000 "data/stats/"]))))

;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```
Arranca tu configuración usando:
```#bash
$ bin/caudal -c config/stdev.clj start
```

Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :metric 13}
{:tx "bar" :metric 23}
{:tx "baz" :metric 12}
{:tx "qux" :metric 44}
{:tx "foo" :metric 55}
```

Verifica la salida de Caudal:
```#bash
2018-03-07 10:37:05.194 INFO  [clojure-agent-send-pool-1] streams.stateless - {:caudal/created 1520440625185, :mean 13, :caudal/touched 1520440625185, :n 1, :variance 0.0, :stdev 0.0, :tx "foo", :caudal/type "welford", :sqrs 0.0, :caudal/latency 1637940, :metric 13}
2018-03-07 10:37:05.197 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520440625185, :mean 18.0, :caudal/touched 1520440625196, :n 2, :variance 25.0, :stdev 5.0, :tx "bar", :caudal/type "welford", :sqrs 50.0, :caudal/latency 12266143, :metric 23}
2018-03-07 10:37:05.198 INFO  [clojure-agent-send-pool-3] streams.stateless - {:caudal/created 1520440625185, :mean 16.0, :caudal/touched 1520440625198, :n 3, :variance 24.666666666666668, :stdev 4.96655480858378, :tx "baz", :caudal/type "welford", :sqrs 74.0, :caudal/latency 1499147, :metric 12}
2018-03-07 10:37:05.201 INFO  [clojure-agent-send-pool-4] streams.stateless - {:caudal/created 1520440625185, :mean 23.0, :caudal/touched 1520440625200, :n 4, :variance 165.5, :stdev 12.864680330268607, :tx "qux", :caudal/type "welford", :sqrs 662.0, :caudal/latency 2467279, :metric 44}
2018-03-07 10:37:06.021 INFO  [clojure-agent-send-pool-5] streams.stateless - {:caudal/created 1520440625185, :mean 29.4, :caudal/touched 1520440626020, :n 5, :variance 296.24, :stdev 17.21162397916013, :tx "foo", :caudal/type "welford", :sqrs 1481.2, :caudal/latency 1632950, :metric 55}
```

Y trata de leer el contenido del archivo **/data/stats/YYYMMdd-my-stdev.edn**:
```#bash
$ cat data/stats/$( date +"%Y%m%d" )-my-stdev.edn
{:caudal/created 1520440625185,
 :mean 29.4,
 :caudal/touched 1520440626021,
 :n 5,
 :variance 296.24,
 :stdev 17.21162397916013,
 :caudal/type "dump_every",
 :sqrs 1481.2}
```
Detén Caudal usando **Ctrl-c**.

### Recuperando estadísticas

Para leer tu EDN con el estado de las estadísticas es obligatorio cargar el archivo usando **scheduler**.

Actualice tu archivo de configuración y usa el streamer **deflistener** como sigue:
```config/stats.clj

;; Requires
(ns caudal.example.stats
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port        9900
                                        :idle-period 60}}])
(deflistener my-scheduler [{:type 'mx.interware.caudal.core.scheduler-server
                            :jobs [{:runit? true
                                    :schedule-def {:in [0 :seconds]}       ;; Run immediately
                                    :event-factory 'mx.interware.caudal.core.scheduler-server/state-admin-event-factory
                                    :parameters {:cmd :load-history        ;; Caudal command to populate State
                                                 :path "data/stats"        ;; Directory of your dump file
                                                 :go-back-millis 0         ;; Milliseconds back to now
                                                 :date-fmt "yyyyMMdd"      ;; Date format
                                                 :key-name "my-stdev"}}]   ;; Key name to retrieve your file and put in State
                         }])

(defsink stats-streamer 1
  ;; Welford received events
  ;; stores stats of events into State with keyword :my-stdev
  ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
  (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
    (->INFO [:all]
       (dump-every [:my-stdev "my-stdev" "YYYYMMdd" 1000 "data/stats/"]))))

;; Connect listeners and streamers
(wire [my-listener my-scheduler] [stats-streamer])
```

Arranca tu configuración usando:
```#bash
$ bin/caudal -c config/stdev.clj start
```

Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :metric 11}    
{:tx "foo" :metric 15}
```

Verifica la salida de Caudal, las estadísticas de tu evento inicia su valor usando el archivo guardado:
```#bash
2018-03-07 10:46:17.190 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520440625185, :mean 26.333333333333332, :caudal/touched 1520441177184, :n 6, :variance 293.88888888888886, :stdev 17.143187827498387, :tx "foo", :caudal/type "welford", :sqrs 1763.3333333333333, :caudal/latency 2455726, :metric 11}
2018-03-07 10:46:18.382 INFO  [clojure-agent-send-pool-4] streams.stateless - {:caudal/created 1520440625185, :mean 24.71428571428571, :caudal/touched 1520441178381, :n 7, :variance 267.63265306122446, :stdev 16.35948205357445, :tx "foo", :caudal/type "welford", :sqrs 1873.4285714285713, :caudal/latency 944378, :metric 15}
```
