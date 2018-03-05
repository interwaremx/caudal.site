title: Lab 2 - Parsing
---

Some Caudal Listeners require a parser function to convert custom data to EDN. 

## Requirements
 * Have successfully completed [Listeners](lab1.html)


[Tailer](lab1.html#Tailer), [Syslog](lab1.html#Syslog) and [Log4j](lab1.html#Log4j) uses a parser function to format our incoming data into EDN for analysis. 

## Parsing an Apache Log

[Apache Common Log Format](https://httpd.apache.org/docs/2.4/logs.html#common) has 7 fields. Into `httpd.conf` looks like this:

```apache /etc/httpd.log
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog logs/access_log common
```

And produces the following output:
```plain /var/log/httpd/access_log
127.0.0.1 - - [05/Mar/2018:06:58:56 +0000] \"GET /docs/lab2.html HTTP/1.1\" 200 41144
```

Tailer can help us to read this file, only we need to write a parser. This is easy thanks to `re-matches` function of Clojure:

```clojure version 1
;; Converts ApacheLog line to EDN
(defn apache-parser [line]
  (let [regex #"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s([0-9a-zA-Z-]+)\s([0-9a-zA-Z-]+)\s\[([0-9]{2}/[a-zA-Z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}\s[\+-]+[0-9]{4})\]\s\"([A-Z]+\s\S+\sHTTP/[0-9]+.[0-9]+)\"\s([0-9]+)\s([0-9]+)" 
        [_ host remote-log-name remote-user time request status size] (re-matches regex line)]
    {:host host
     :remote-log-name remote-log-name
     :remote-user remote-user
     :time time
     :request request
     :status status
     :size size}))
```

Using this new function is simple, only we need passing it in `:parser` parameter of tailer’s deflistener as follows:
```clojure config/example-parser.clj
;; Requires
(ns caudal.example.tcp
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Converts ApacheLog line to EDN
(defn apache-parser [line]
  (let [regex #"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s([0-9a-zA-Z-]+)\s([0-9a-zA-Z-]+)\s\[([0-9]{2}/[a-zA-Z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}\s[\+-]+[0-9]{4})\]\s\"([A-Z]+\s\S+\sHTTP/[0-9]+.[0-9]+)\"\s([0-9]+)\s([0-9]+)" 
        [host remote-log-name remote-user time request status size] (re-matches regex line)]
    {:host host
     :remote-log-name remote-log-name
     :remote-user remote-user
     :time time
     :request request
     :status status
     :size size}))

;; Listeners
(deflistener tailer [{:type 'mx.interware.caudal.io.tailer-server
                      :parameters {:parser apache-parser  ;; Call to our parser
                                   :inputs  {:directory "."
                                             :wildcard  "access_log"}
                                   :delta        200
                                   :from-end     false
                                   :reopen       true
                                   :buffer-size  1024}}])
;; Sinks
(defsink example 1 ;; backpressure
  (->INFO [:all]))

;; Wire
(wire [tailer] [example])
```

Running Caudal, output results as:
```
$ bin/caudal -c config/example-parser.clj start
Verifying JAVA installation ...
/usr/bin/java
Using JVM installed on : java ...
                        __      __
  _________ ___  ______/ /___ _/ /
 / ___/ __ `/ / / / __  / __ `/ /
/ /__/ /_/ / /_/ / /_/ / /_/ / /
\___/\__,_/\__,_/\__,_/\__,_/_/

mx.interware/caudal 0.7.14

:opts {:help false, :config "config/example-parser.clj"}
2018-03-05 02:18:51.099 INFO  [main] core.starter-dsl - {:caudal :start, :version "0.7.14"}
2018-03-05 02:18:51.104 INFO  [main] core.starter-dsl - {:loading-dsl {:file #object[java.io.File 0x183e8023 config/example-parser.clj]}}
2018-03-05 02:18:56.146 INFO  [main] io.rest-server - Register fn for:  "hello"
2018-03-05 02:18:56.288 INFO  [main] streams.common - Attaching send2agent and sink to state
2018-03-05 02:18:57.347 INFO  [main] io.tailer-server - {:tailing-files ("/var/log/httpd/access_log")}
2018-03-05 02:18:57.394 INFO  [clojure-agent-send-pool-1] streams.stateless - {:host "127.0.0.1", :remote-log-name "-", :remote-user "-", :time "05/Mar/2018:06:58:56 +0000", :request "GET /docs/lab2.html HTTP/1.1", :status "200", :size "41144", :caudal/latency 1841978}
```

Parser function `apache-parser` can be improved in many ways, by instance, warranting match or converting data from String to Integer or Date as appropiate:

```clojure version 2
;; Converts ApacheLog line to EDN
(defn apache-parser [line]
  (let [regex #"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s([0-9a-zA-Z-]+)\s([0-9a-zA-Z-]+)\s\[([0-9]{2}/[a-zA-Z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}\s[\+-]+[0-9]{4})\]\s\"([A-Z]+\s\S+\sHTTP/[0-9]+.[0-9]+)\"\s([0-9]+)\s([0-9]+)" 
        [_ host remote-log-name remote-user time request status size] (re-matches regex line)]
    (if (and host remote-log-name remote-user time request status size) ;; all fields exists
      {:host host
       :remote-log-name remote-log-name
       :remote-user remote-user
       :time (-> "dd/MMM/yyyy:hh:mm:ss Z" java.text.SimpleDateFormat. (.parse time)) ;; to Date
       :request request
       :status (Integer/parseInt status) ;; to Integer
       :size (Integer/parseInt size)}))) ;; to Integer
```

Now time, status and size are not Strings:
```
2018-03-05 02:28:23.921 INFO  [clojure-agent-send-pool-1] streams.stateless - {:host "127.0.0.1", :remote-log-name "-", :remote-user "-", :time #inst "2018-03-05T06:58:56.000-00:00", :request "GET /docs/lab2.html HTTP/1.1", :status 200, :size 41144, :caudal/latency 1133576}
```

And with some parenthesis into request regex group:
```clojure version 3
;; Converts ApacheLog line to EDN
(defn apache-parser [line]
  (let [regex #"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s([0-9a-zA-Z-]+)\s([0-9a-zA-Z-]+)\s\[([0-9]{2}/[a-zA-Z]{3}/[0-9]{4}:[0-9]{2}:[0-9]{2}:[0-9]{2}\s[\+-]+[0-9]{4})\]\s\"(([A-Z]+)\s(\S+)\s(HTTP/[0-9]+.[0-9]+))\"\s([0-9]+)\s([0-9]+)" 
        [_ host remote-log-name remote-user time request protocol path version status size] (re-matches regex line)]
    (if (and host remote-log-name remote-user time request protocol path version status size) ;; all fields exists
      {:host host
       :remote-log-name remote-log-name
       :remote-user remote-user
       :time (-> "dd/MMM/yyyy:hh:mm:ss Z" java.text.SimpleDateFormat. (.parse time)) ;; to Date
       :request request
       :protocol protocol
       :path path
       :version version
       :status (Integer/parseInt status) ;; to Integer
       :size (Integer/parseInt size)}))) ;; to Integer
```

Is possible obtain protocol, path and version parts of request:
```
2018-03-05 02:35:04.124 INFO  [clojure-agent-send-pool-1] streams.stateless - {:path "/docs/lab2.html", :request "GET /docs/lab2.html HTTP/1.1", :remote-user "-", :remote-log-name "-", :protocol "GET", :time #inst "2018-03-05T06:58:56.000-00:00", :size 41144, :host "127.0.0.1", :status 200, :version "HTTP/1.1", :caudal/latency 1093145}
```