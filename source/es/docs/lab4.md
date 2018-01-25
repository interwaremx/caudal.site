title: Lab 4 - Estadísticas
---
Una guía para recuperar y producir estadísticas.

## Requerimientos
 * Completar el [Lab 3 - Streamers](lab03.html)

## Cuenta
### Contando eventos
Esta sección explica como contar cada evento recibido.

1. Cambia el directorio actual al del proyecto caudal-labs
```#bash
$ cd caudal-labs/
```

2. Crea una nueva configuración en el archivo **config/stats.clj** con el siguiente contenido:
```clojure config/stats.clj
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Counts received events
  ;; stores account into State with keyword :my-counter
  ;; decorates received event with account with keyword :n
  (counter [:my-counter :n]
    (printe ["Received event: "])))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port 9900
                                        :idle-period 60}}])
;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```

3. Arranca tu configuración usando:
```#bash
$ bin/start-caudal.sh -c ./config/stats.clj
```

4. Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```
5. Verifica la salida de Caudal. Observa que cada entrada de evento ha sido decorada con un atributo adicional **:n** con el actual conteo de eventos:
```#bash
Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-30 18:22:55.998 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-30 18:22:56.009 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stats.clj}}
2017-01-30 18:22:58.085 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
Received event: {:tx "foo", :user "bar", :caudal/latency 686527, :n 1}
Received event: {:tx "baz", :user "qux", :caudal/latency 1132024, :n 2}
```
6. Detén Caudal usando **Ctrl-c**

### Guardar cuenta
Guarda la cuenta de tus eventos usando **dump-every**.

1. Modifica tu **config/stats.clj**  y usa el streamer **dump-every** como sigue:
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Counts received events
  ;; stores account into State with keyword :my-counter
  ;; decorates received event with account with keyword :n
  (counter [:my-counter :n]
    (printe ["Received event: "]
      ;; Dumps state :my-counter in ./data/stats/YYYMMdd-my-counter.edn
      ;; updates the file each 1000 milliseconds
      (dump-every [:my-counter "my-counter" "YYYYMMdd" 1000 "data/stats/"]))))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port 9900
                                        :idle-period 60}}])
;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```
2. Arranca tu configuración usando:
```#bash
$ bin/start-caudal.sh -c ./config/stats.clj
```

3. Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

4. Verifica la salida de Caudal:
```#bash
Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-30 18:37:55.608 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-30 18:37:55.612 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stats.clj}}
2017-01-30 18:37:57.428 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
Received event: {:tx "foo", :user "bar", :caudal/latency 1052168, :n 1}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "baz", :user "qux", :caudal/latency 902071, :n 2}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
```

5. Y trata de leer el contenido del archivo **data/stats/YYYMMdd-my-counter.edn**:
```#bash
$ cat data/stats/$( date +"%Y%m%d" )-my-counter.edn
{:n 3}
```

6. Detén Caudal usando **Ctrl-c**.

### Recuperando cuenta
Para leer tu EDN con el estado de la cuenta es obligatorio cargar el archivo usando **scheduler**.

1. Modifica tu **config/stats.clj** y usa el streamer **deflistener** como sigue:
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Decorates each event using key/value
  ;; stored in State with keyword :my-counter
  (decorate [:my-counter]
    ;; Counts received events
    ;; stores account into State with keyword :my-counter
    ;; decorates received event with account with keyword :n
    (counter [:my-counter :n]
      (printe ["Received event: "]
        ;; Dumps state :my-counter in ./data/stats/yyyyMMdd-my-counter.edn
        ;; updates the file each 1000 milliseconds
        (dump-every [:my-counter "my-counter" "yyyyMMdd" 1000 "data/stats"])))))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                               :parameters {:port 9900
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

;; Connect listeners and streamers
(wire [my-listener my-scheduler] [stats-streamer])
```

2. Arranca tu configuración:
```#bash
$ bin/start-caudal.sh -c ./config/stats.clj
```

3. Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

4. Verifica la salida de Caudal, el contador de tu evento inicia su valor usando el archivo guardado:
```#bash
Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-30 18:37:55.608 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-30 18:37:55.612 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stats.clj}}
2017-01-30 18:37:57.428 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
loading history: 20170130-my-counter
loading history file-re: #"(20170130-my-counter)\-(.*)[\.]edn|(20170130-my-counter)\.edn"
se añade al state: [:my-counter] {:n 3}
Received event: {:tx "foo", :user "bar", :caudal/latency 621616, :n 4}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "baz", :user "qux", :caudal/latency 633123, :n 5}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
```

5. Detén Caudal usando **Ctrl-c**.

## Desviación Estándar
### Estadísticas de eventos
Esta sección explica como obtener media, varianza y desviación estándar desde los eventos.

1. Cambia el directorio actual al del proyecto caudal-labs
```#bash
$ cd caudal-labs/
```

2. Crea un nuevo archivo de configuración **config/stdev.clj** con el contenido que sigue:
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Welford received events
  ;; stores stats of events into State with keyword :my-stdev
  ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
  (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
    (printe ["Received event: "])))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port 9900
                                        :idle-period 60}}])
;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```

3. Arranca tu configuración usando:
```#bash
$ bin/start-caudal.sh -c ./config/stdev.clj
```
4. Prueba tu configuración enviando algunos eventos con telnet:
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

5. Verifica la salida de Caudal. Observa que cada entrada de evento ha sido decorada con algunos atributos adicionales:
```#bash
Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-31 09:24:04.427 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-31 09:24:04.432 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stdev.clj}}
2017-01-31 09:24:06.589 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
Received event: {:tx "foo", :metric 13, :caudal/latency 606551, :mean 13, :sqrs 0.0, :variance 0.0, :stdev 0.0, :n 1}
Received event: {:tx "bar", :metric 23, :caudal/latency 632011, :mean 18.0, :sqrs 50.0, :variance 25.0, :stdev 5.0, :n 2}
Received event: {:tx "baz", :metric 12, :caudal/latency 1141706, :mean 16.0, :sqrs 74.0, :variance 24.666666666666668, :stdev 4.96655480858378, :n 3}
Received event: {:tx "qux", :metric 44, :caudal/latency 662683, :mean 23.0, :sqrs 662.0, :variance 165.5, :stdev 12.864680330268607, :n 4}
Received event: {:tx "foo", :metric 55, :caudal/latency 628280, :mean 29.4, :sqrs 1481.2, :variance 296.24, :stdev 17.21162397916013, :n 5}
```

6. Detén Caudal usando **Ctrl-c**.

### Guardar estadísticas
Guarda las estadísticas de tus eventos usando **dump-every**.

1. Modifica tu **config/stdev.clj** y usa el streamer **dump-every** como sigue:
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Welford received events
  ;; stores stats of events into State with keyword :my-stdev
  ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
  (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
    (printe ["Received event: "]
      ;; Dumps state :my-stdev in ./data/stats/YYYMMdd-my-stdev.edn
      ;; updates the file each 1000 milliseconds
      (dump-every [:my-stdev "my-stdev" "YYYYMMdd" 1000 "data/stats/"]))))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port 9900
                                        :idle-period 60}}])
;; Connect listeners and streamers
(wire [my-listener] [stats-streamer])
```
2. Arranca tu configuración usando:
```#bash
$ bin/start-caudal.sh -c ./config/stdev.clj
```

3. Prueba tu configuración enviando algunos eventos con telnet:
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

4. Verifica la salida de Caudal:
```#bash
Caudal 0.7.4-SNAPSHOT
2017-01-31 09:37:13.367 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-31 09:37:13.376 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stdev.clj}}
2017-01-31 09:37:15.141 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
Received event: {:tx "foo", :metric 13, :caudal/latency 711846, :mean 13, :sqrs 0.0, :variance 0.0, :stdev 0.0, :n 1}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "bar", :metric 23, :caudal/latency 665459, :mean 18.0, :sqrs 50.0, :variance 25.0, :stdev 5.0, :n 2}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "baz", :metric 12, :caudal/latency 703682, :mean 16.0, :sqrs 74.0, :variance 24.666666666666668, :stdev 4.96655480858378, :n 3}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "qux", :metric 44, :caudal/latency 181307, :mean 23.0, :sqrs 662.0, :variance 165.5, :stdev 12.864680330268607, :n 4}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "foo", :metric 55, :caudal/latency 204247, :mean 29.4, :sqrs 1481.2, :variance 296.24, :stdev 17.21162397916013, :n 5}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
```

5. Y trata de leer el contenido del archivo **/data/stats/YYYMMdd-my-stdev.edn**:
```#bash
$ cat data/stats/$( date +"%Y%m%d" )-my-stdev.edn
{:mean 29.4,
 :sqrs 1481.2,
 :variance 296.24,
 :stdev 17.21162397916013,
 :n 5}
```
6. Detén Caudal usando **Ctrl-c**.

### Recuperando estadísticas

Para leer tu EDN con el estado de las estadísticas es obligatorio cargar el archivo usando **scheduler**.

1. Modifica tu **onfig/stats.clj** y usa el streamer deflistener como sigue:
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink stats-streamer 10000
  ;; Decorates each event using key/value
  ;; stored in State with keyword :my-stdev
  (decorate [:my-stdev]
    ;; Welford received events
    ;; stores stats of events into State with keyword :my-stdev
    ;; decorates received event with its :mean :variance :stdev :sqrs(sum of squares) and :n (count)
    (welford [:my-stdev :metric :mean :variance :stdev :sqrs :n]
      (printe ["Received event: "]
        ;; Dumps state :my-stdev in ./data/stats/YYYMMdd-my-stdev.edn
        ;; updates the file each 1000 milliseconds
        (dump-every [:my-stdev "my-stdev" "YYYYMMdd" 1000 "data/stats/"])))))

;; Listeners
(deflistener my-listener [{:type 'mx.interware.caudal.io.tcp-server
                           :parameters {:port 9900
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

;; Connect listeners and streamers
(wire [my-listener my-scheduler] [stats-streamer])
```

2. Arranca tu configuración usando:
```#bash
$ bin/start-caudal.sh -c ./config/stdev.clj
```

3. Prueba tu configuración enviando algunos eventos con telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :metric 11}    
{:tx "foo" :metric 15}
```

4. Verifica la salida de Caudal, las estadísticas de tu evento inicia su valor usando el archivo guardado:
```#bash
Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-31 09:45:16.710 [main] INFO  starter-dsl:1 - {:caudal start}
2017-01-31 09:45:16.713 [main] INFO  starter-dsl:1 - {:loading-dsl {:file config/stdev.clj}}
2017-01-31 09:45:18.388 [main] INFO  tcp-server:1 - Starting server on port :  9900  ...
loading history: 20170131-my-stdev
loading history file-re: #"(20170131-my-stdev)\-(.*)[\.]edn|(20170131-my-stdev)\.edn"
se añade al state: [:my-stdev] {:mean 29.4, :sqrs 1481.2, :variance 296.24, :stdev 17.21162397916013, :n 5}
Received event: {:tx "foo", :metric 11, :caudal/latency 552805, :mean 26.333333333333332, :sqrs 1763.3333333333333, :variance 293.88888888888886, :stdev 17.143187827498387, :n 6}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
Received event: {:tx "foo", :metric 15, :caudal/latency 571749, :mean 24.71428571428571, :sqrs 1873.4285714285713, :variance 267.63265306122446, :stdev 16.35948205357445, :n 7}
repeat-every from: :mx.interware.caudal.streams.stateful/dump-every  delta= 1000  count= 1
executing from:  :mx.interware.caudal.streams.stateful/dump-every
```
