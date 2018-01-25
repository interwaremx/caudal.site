title: Lab 3 - Streamers
---
Una guia que muestra ejemplos para los principales streamers existentes en Caudal

## Requerimientos
 * Haber completado exitosamente el **Lab 2**: [Escuchas y Parsing](lab2.html)

## Estableciendo un streamer enriquecedor de eventos
1. Cambia el actual directorio al proyecto **caudal-labs**.
```
$ cd caudal-labs/
```

2. Edita el archivo **config/caudal-config.clj** para configurar un streamer que agregue atributos a los eventos recibidos.
```
(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink streamer-1 10000
  (default [:reception-time (new java.util.Date)]
           (printe ["Received event : "])))

(deflistener [{:type 'mx.interware.caudal.io.tcp-server
               :parameters {:port 9900
                            :idle-period 60}}]
  streamer-1)
```

## Verifica el streamer enriquecedor de eventos

1. Reinicia Caudal para aplicar los cambios en la configuración.
```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
```

2. Abre otra terminal y envía a través del canal **tcp** los eventos como se muestra a continuación.
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "login" :user "ClojurianX"}
{:tx "set-status" :value "waiting"}
...
```

3. Verifica la bitácora generada por los eventos recibidos.
```
...
18:45:47.636 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=34 cap=4096: 7B 3A 74 78 20 22 6C 6F 67 69 6E 22 20 3A 75 73...]
18:45:47.641 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Received event : {:tx "login", :user "ClojurianX", :caudal/latency 744956, :reception-time #inst "2017-01-13T00:45:10.850-00:00"}
18:46:47.853 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - IDLE
IDLE  1
18:47:16.997 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=37 cap=4096: 7B 3A 74 78 20 22 73 65 74 2D 73 74 61 74 75 73...]
18:47:16.998 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Received event : {:tx "set-status", :value "waiting", :caudal/latency 397546, :reception-time #inst "2017-01-13T00:45:10.850-00:00"}
...
```

Como puedes observar, el streamer **default** esta agregando el atributo **reception-time** a cada evento recibido.

## Estableciendo un streamer contador

1. Edita el archivo **config/caudal-config.clj** para configurar un streamer **counter** que cuente cada evento recibido. El archivo debe contener lo siguiente:
```
(ns caudal-labs)

(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink streamer-1 10000
  (counter [:event-counter :count]
           (printe ["Received event : "])))

(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server
                            :parameters {:port 9900
                                         :idle-period 60}}])

(wire [tcp-listener] [streamer-1])
```

## Probando el streamer counter

1. Restaura Caudal para aplicar los cambios en la configuración:
```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:53:39.442 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
16:53:40.639 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Abre otra terminal y envia algunos eventos a través del canal **tcp** de Caudal que corre en el puerto **9900**
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "login" :time #inst"2017-01-11T17:29:34.712-00:00" :user "schatsi" :host "tirio"}
{:tx "login" :time #inst"2017-01-11T17:29:35.145-00:00" :user "imushroom" :host "andromeda"}
{:tweet-id "114729583239036718" :user "ClojurianX" :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent" :retweeted false :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:07:23 +0000 2017"}
{:tweet-id "114729583239036819" :user "ClojurianX" :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care" :retweeted true :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:17:28 +0000 2017"}
{:tweet-id "114729583239050123" :user "ClojurianY" :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:21:11 +0000 2017"}
{:tweet-id "114729583239050542" :user "ClojurianY" :text "Learn live! \"getless - better every day\" https://www.livecoding.oftware #agile #Clojure" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:30:25 +0000 2017"}
EOT
Connection closed by foreign host.
$
```

3. Verifica la bitácora generada por los eventos recibidos:
```
16:54:42.081 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - CREATED
16:54:42.083 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - OPENED
16:54:52.796 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=900 cap=4096: 7B 3A 74 78 20 22 6C 6F 67 69 6E 22 20 3A 74 69...]
16:54:52.801 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
16:54:52.816 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=254 cap=4096: 7B 3A 74 77 65 65 74 2D 69 64 20 22 31 31 34 37...]
16:54:52.816 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Received event : {:tx "login", :time #inst "2017-01-11T17:29:34.712-00:00", :user "schatsi", :host "tirio", :caudal/latency 2098653, :count 1}
Received event : {:tx "login", :time #inst "2017-01-11T17:29:35.145-00:00", :user "imushroom", :host "andromeda", :caudal/latency 12395903, :count 2}
Received event : {:tweet-id "114729583239036718", :user "ClojurianX", :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent", :retweeted false, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:07:23 +0000 2017", :caudal/latency 11766637, :count 3}
Received event : {:tweet-id "114729583239036819", :user "ClojurianX", :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care", :retweeted true, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:17:28 +0000 2017", :caudal/latency 24829791, :count 4}
Received event : {:tweet-id "114729583239050123", :user "ClojurianY", :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:21:11 +0000 2017", :caudal/latency 25634089, :count 5}
Received event : {:tweet-id "114729583239050542", :user "ClojurianY", :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:30:25 +0000 2017", :caudal/latency 25721860, :count 6}
16:55:08.029 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=5 cap=2048: 45 4F 54 0D 0A]
16:55:08.029 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
16:55:08.032 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - CLOSED
```

Nota que por cada evento recibido el atributo **:count** fue agregando el contenido de la cuenta actual.

## Estableciendo un streamer transformador

1. Edita el archivo **config/caudal-config.clj** para configurar un streamer **smap** que transforma cada evento recibido aplicandole una función de transformación.
```
(ns caudal-labs)

(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defn calculate-iva [event]
  (let [ammount (:ammount event)
        iva     (* 0.16 ammount)
        total   (+ ammount iva)]
    (assoc event {:iva iva :total total})))

(defsink streamer-1 10000
  (smap [calculate-iva]
        (printe ["Transformed event : "])))

(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server
                            :parameters {:port 9900
                                         :idle-period 60}}])

(wire [tcp-listener] [streamer-1])
```

## Probando el streamer de transformación
1. Restaura Caudal para aplicar los cambios en la configuración:
```
mactirio:caudal-labs axis$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:57:49.825 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
16:57:51.001 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...

```

2. Abre otra terminal y envía algunos mensages a través del canal **tcp** de Caudal que corre en el puerto **9900**.
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "sale" :product "CDTO-12" :price 12.50}
{:tx "sale" :product "JTAP-01" :price 23.30}
```

3. Verifica la bitácora generada por los eventos recibidos:
```
17:02:48.033 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=46 cap=4096: 7B 3A 74 78 20 22 73 61 6C 65 22 20 3A 70 72 6F...]
17:02:48.035 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Transformed event : {:tx "sale", :product "CDTO-12", :price 12.5, :caudal/latency 676227, :iva 2.0, :total 14.5}
17:02:54.446 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=46 cap=4096: 7B 3A 74 78 20 22 73 61 6C 65 22 20 3A 70 72 6F...]
17:02:54.446 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Transformed event : {:tx "sale", :product "JTAP-01", :price 23.3, :caudal/latency 433533, :iva 3.728, :total 27.028000000000002}
```

## Estableciendo un streamer filtro de eventos

1. Modifica en el archivo de configuración **config/caudal-config.clj** el **streamer-1** como se muestra a continuación. Solo los eventos que tengan el atributo **tweet-id** deberían ser contados:
```
...
(defsink streamer-1 10000
  (where [:tweet-id]
         (counter [:tweet-counter :count]
                  (printe ["Received tweet : "]))))
...
```

## Probando el stremer filtro de eventos

1. Reinicia Caudal para aplicar los cambios en la configuración:
```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
17:05:31.472 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
17:05:32.648 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Abre otra terminal y envía algunos eventos a través del canal **tcp** como se muestra a continuación:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "login" :time #inst"2017-01-11T17:29:34.712-00:00" :user "schatsi" :host "tirio"}
{:tx "login" :time #inst"2017-01-11T17:29:35.145-00:00" :user "imushroom" :host "andromeda"}
{:tweet-id "114729583239036718" :user "ClojurianX" :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent" :retweeted false :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:07:23 +0000 2017"}
{:tweet-id "114729583239036819" :user "ClojurianX" :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care" :retweeted true :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:17:28 +0000 2017"}
{:tweet-id "114729583239050123" :user "ClojurianY" :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:21:11 +0000 2017"}
{:tweet-id "114729583239050542" :user "ClojurianY" :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:30:25 +0000 2017"}
...
```

3. Verifica la bitácora generada por los eventos recibidos.
```
...
Received tweet : {:tweet-id "114729583239036718", :user "ClojurianX", :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent", :retweeted false, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:07:23 +0000 2017", :caudal/latency 614706, :count 1}
Received tweet : {:tweet-id "114729583239036819", :user "ClojurianX", :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care", :retweeted true, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:17:28 +0000 2017", :caudal/latency 19507629, :count 2}
Received tweet : {:tweet-id "114729583239050123", :user "ClojurianY", :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:21:11 +0000 2017", :caudal/latency 20246520, :count 3}
Received tweet : {:tweet-id "114729583239050542", :user "ClojurianY", :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:30:25 +0000 2017", :caudal/latency 20207344, :count 4}
...
```

Como puedes observar, en este momento el contador solo ha llegado a 4.

## Estableciendo un streamer clasificador de eventos

1. Modifica en el archivo de configuración **config/caudal-config.clj** el **streamer-1** como se muestra a continuación. Los eventos con el atributo **tweet-id** deben ser clasificados por su atributo **:user** y entonces contados.
```
...
(defsink streamer-1 10000
  (where [:tweet-id]
         (by [:user]
             (counter [:tweet-counter :count]
                      (printe ["Received tweet : "])))))
...
```

## Verificando el streamer clasificador de eventos
1. Reinicia Caudal para aplicar los cambios en la configuración:
```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
17:10:43.179 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
17:10:44.588 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Abre otra terminal y envia a través de canal **tcp** los eventos como se muestra a continuación:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "login" :time #inst"2017-01-11T17:29:34.712-00:00" :user "schatsi" :host "tirio"}
{:tx "login" :time #inst"2017-01-11T17:29:35.145-00:00" :user "imushroom" :host "andromeda"}
{:tweet-id "114729583239036718" :user "ClojurianX" :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent" :retweeted false :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:07:23 +0000 2017"}
{:tweet-id "114729583239036819" :user "ClojurianX" :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care" :retweeted true :coordinates [19.3660316 -99.1843784] :created_at "Wed Jan 11 10:17:28 +0000 2017"}
{:tweet-id "114729583239050123" :user "ClojurianY" :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:21:11 +0000 2017"}
{:tweet-id "114729583239050542" :user "ClojurianY" :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure" :retweeted false :coordinates [27.2550316 -80.1666784] :created_at "Wed Jan 11 12:30:25 +0000 2017"}
...
```

3. Verifica la bitácora generada por los eventos recibidos:
```
...
17:11:26.443 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=900 cap=4096: 7B 3A 74 78 20 22 6C 6F 67 69 6E 22 20 3A 74 69...]
17:11:26.447 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
17:11:26.456 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=254 cap=4096: 7B 3A 74 77 65 65 74 2D 69 64 20 22 31 31 34 37...]
17:11:26.456 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Received tweet : {:tweet-id "114729583239036718", :user "ClojurianX", :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent", :retweeted false, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:07:23 +0000 2017", :caudal/latency 392488, :count 1}
Received tweet : {:tweet-id "114729583239036819", :user "ClojurianX", :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care", :retweeted true, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:17:28 +0000 2017", :caudal/latency 20958119, :count 2}
Received tweet : {:tweet-id "114729583239050123", :user "ClojurianY", :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:21:11 +0000 2017", :caudal/latency 19182546, :count 1}
Received tweet : {:tweet-id "114729583239050542", :user "ClojurianY", :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:30:25 +0000 2017", :caudal/latency 19235139, :count 2}
...
```
Como puedes observar, en este momento el contador llega hasta 2 para ambos tipos evento, los que contienen como usuario 'ClojurianX' y 'ClojurianY'
