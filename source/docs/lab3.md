title: Lab 3 - Streamers
---
A lab exercise that shows examples for main streamers existing in Caudal 


## Requirements
 * Have successfully completed **Lab 2**: [Listeners and Parsing](lab2.html)


## Setting up an event enricher streamer

1. Change current directory to the **caudal-labs** project

```
$ cd caudal-labs/
```

2. Edit **config/caudal-config.clj** file to configure a **dafault** streamer that adds attibutes to received event message.
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

## Testing event enricher streamer

1. Restart Caudal for applying changes in configuration.

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
```

2. Open another terminal and send through the **tcp channel** the events shown below.
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "login" :user "ClojurianX"}
{:tx "set-status" :value "waiting"}
...
```

3. Verify the generated log for the received events
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

As you can see, the **default** streamer is adding **reception-time** attribute to every received event


## Setting up a counter streamer

1. Edit **config/caudal-config.clj** file to configure a **counter** streamer that count every received event message having :tx attribute. File content must be the following:
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


## Testing the counter streamer

1. Restart Caudal for applying changes in configuration

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:53:39.442 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
16:53:40.639 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Open another terminal and send some event message through the Caudal **tcp** channel running on port **9900**

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

3. Verify the generated log for the received events

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

Note that for every received event the attribute 'count' was added containing the current count


## Setting up a transformer streamer

1. Edit **config/caudal-config.clj** file to configure a **smap** streamer that transform every received event message applying a transformation function to them
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


## Testing the transformer streamer

1. Restart Caudal for applying changes in configuration

```
mactirio:caudal-labs axis$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:57:49.825 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
16:57:51.001 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...

```

2. Open another terminal and send some event message through the Caudal **tcp** channel running on port **9900**

```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "sale" :product "CDTO-12" :price 12.50}
{:tx "sale" :product "JTAP-01" :price 23.30}
```

3. Verify the generated log for the received events

```
17:02:48.033 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=46 cap=4096: 7B 3A 74 78 20 22 73 61 6C 65 22 20 3A 70 72 6F...]
17:02:48.035 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Transformed event : {:tx "sale", :product "CDTO-12", :price 12.5, :caudal/latency 676227, :iva 2.0, :total 14.5}
17:02:54.446 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=46 cap=4096: 7B 3A 74 78 20 22 73 61 6C 65 22 20 3A 70 72 6F...]
17:02:54.446 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Transformed event : {:tx "sale", :product "JTAP-01", :price 23.3, :caudal/latency 433533, :iva 3.728, :total 27.028000000000002}
```


## Setting up an event filter streamer

1. Modify **config/caudal-config.clj** configuration file so that streamer sink **streamer-1** is set as shown. Only events having **tweet-id** attribute should be counted.
```
...
(defsink streamer-1 10000
  (where [:tweet-id]
         (counter [:tweet-counter :count]
                  (printe ["Received tweet : "]))))
...
```


## Testing event filter streamer

1. Restart Caudal for applying changes in configuration

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
17:05:31.472 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
17:05:32.648 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Open another terminal and send the events shown below through the **tcp channel**
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

3. Verify the generated log for the received events
```
...
Received tweet : {:tweet-id "114729583239036718", :user "ClojurianX", :text "How to use a charting library in Reagent http://buff.ly/2i0q23R  #clojure #chart #reagent", :retweeted false, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:07:23 +0000 2017", :caudal/latency 614706, :count 1}
Received tweet : {:tweet-id "114729583239036819", :user "ClojurianX", :text "Why #Clojure is better than C, Python,Ruby and Java and why should you care", :retweeted true, :coordinates [19.3660316 -99.1843784], :created_at "Wed Jan 11 10:17:28 +0000 2017", :caudal/latency 19507629, :count 2}
Received tweet : {:tweet-id "114729583239050123", :user "ClojurianY", :text "Official #Neo4j Driver for Python 1.1.0 beta 4 has just been released", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:21:11 +0000 2017", :caudal/latency 20246520, :count 3}
Received tweet : {:tweet-id "114729583239050542", :user "ClojurianY", :text "Learn live! \"getless - better every day\" https://www.livecoding. #software #agile #Clojure", :retweeted false, :coordinates [27.2550316 -80.1666784], :created_at "Wed Jan 11 12:30:25 +0000 2017", :caudal/latency 20207344, :count 4}
...
```

As you can see, this time the counter came only up to 4


## Setting up an event classifier streamer

1. Modify **config/caudal-config.clj** configuration file so that streamer sink **streamer-1** is set as shown. Events having **tweet-id** attribute should be classified by **:user** attribute and then counted.
```
...
(defsink streamer-1 10000
  (where [:tweet-id]
         (by [:user]
             (counter [:tweet-counter :count]
                      (printe ["Received tweet : "])))))
...
```


## Testing event calssifier streamer

1. Restart Caudal for applying changes in configuration

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
17:10:43.179 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
17:10:44.588 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```

2. Open another terminal and send through the **tcp channel** the events shown below
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

3. Verify the generated log for the received events
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

As you can see, this time the counter came up to 2 for both kind of events, those having user 'ClojurianX' and 'ClojurianY'

