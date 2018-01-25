title: Lab 2 - Listeners and Parsing
---
A lab exercise intended to show the configuration and the use of listeners and parsers inside the Caudal Platform


## Requirements
 * Have successfully completed **Lab 1**: [Getting Started and Setup](lab1.html)


## Creating a TCP listener

1. Change current directory to the **caudal-labs** project

```
$ cd caudal-labs/
```

2. Edit **config/caudal-config.clj** file to configure a **tcp** listener running on port **9900**. File content must be the following:
```
(ns caudal-labs)

(require '[mx.interware.caudal.streams.common :refer :all])
(require '[mx.interware.caudal.streams.stateful :refer :all])
(require '[mx.interware.caudal.streams.stateless :refer :all])

(defsink streamer-1 10000
  (printe ["Received event : "]))

(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server
                            :parameters {:port 9900
                                         :idle-period 60}}])

(wire [tcp-listener] [streamer-1])
```


## Running Caudal

1. Start Caudal using the configuration from the modified file **config/caudal-config.clj**

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
/usr/bin/java
JAVA executable found in PATH
JAVA Version : 1.8.0_91
BIN path /projects/caudal-labs/bin
Starting Caudal from /projects/caudal-labs
                        __      __
  _________ ___  ______/ /___ _/ /
 / ___/ __ `/ / / / __  / __ `/ /
/ /__/ /_/ / /_/ / /_/ / /_/ / /
\___/\__,_/\__,_/\__,_/\__,_/_/

Caudal 0.7.4-SNAPSHOT
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/projects/caudal-labs/lib/logback-classic-1.1.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/projects/caudal-labs/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
16:27:37.788 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
16:27:39.162 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
```


## Testing the TCP listener

1. Open another terminal and send an event message through the Caudal **tcp** channel running on port **9900**

```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "getOperation" :customer "Nile" :id 96 :ammount 57.1428}
EOT
Connection closed by foreign host.
$
```

2. Verify the generated log for the received event
```
16:29:17.801 [NioProcessor-3] INFO  o.a.m.filter.logging.LoggingFilter - CREATED
16:29:17.801 [NioProcessor-3] INFO  o.a.m.filter.logging.LoggingFilter - OPENED
16:29:24.669 [NioProcessor-3] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=63 cap=4096: 7B 3A 74 78 20 22 67 65 74 4F 70 65 72 61 74 69...]
16:29:24.670 [NioProcessor-3] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 2
Received event : {:tx "getOperation", :customer "Nile", :id 96, :ammount 57.1428, :caudal/latency 509612}
16:29:28.091 [NioProcessor-3] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=5 cap=4096: 45 4F 54 0D 0A]
16:29:28.091 [NioProcessor-3] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 2
16:29:28.091 [NioProcessor-3] INFO  o.a.m.filter.logging.LoggingFilter - CLOSED
```

### Creating a tailer listener

1. Modify **config/caudal-config.clj** configuration file to use tailer listener that reads events from **data/input.txt** file. Add the listener configuration to the end of the file as shown below:
```
...

(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server
                            :parameters {:port 9900
                                         :idle-period 60}}])


(deflistener tailer [{:type 'mx.interware.caudal.io.tailer-server
                      :parameters {:parser      'mx.interware.caudal.test.simple-parser/parse-log-line
                                   :inputs      {:directory  "./data"
                                                 :wildcard   "*txt"
                                                 :expiration 5}
                                   :delta       1000
                                   :from-end    true
                                   :reopen      true
                                   :buffer-size 16384}}])

(wire [tcp-listener tailer] [streamer-1])
```
*Note :* Now Caudal is ready for receiving event messages from two sources, a tcp channel and tailing txt files in data directory

2. Restart Caudal for applying changes in configuration. Caudal can be stopped pressing **ctrl+c** key combination

```
mactirio:caudal-labs axis$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:35:29.705 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
16:35:29.759 [main] INFO  mx.interware.caudal.io.tailer-server - Tailing files :  (/projects/caudal-labs/./data/input.txt)  ...
16:35:29.769 [main] INFO  mx.interware.caudal.io.tailer-server - Channel created for file  input.txt  - > channel :  #object[clojure.core.async.impl.channels.ManyToManyChannel 0x49cf9028 clojure.core.async.impl.channels.ManyToManyChannel@49cf9028]
16:35:29.846 [main] INFO  mx.interware.caudal.io.tailer-server - register-channels for tailer
```


### Testing tailer listener

1. Open another terminal and send a test event using the Caudal **tailer**, appending the message to **data/input.txt** file
```
$ echo "{:tx \"findSales\" :customer \"Congo\" :id 88 :key \"XSA-89\"}" > data/input.txt
```

2. Verify the generated log for the tailed event
```
line :  {:tx "findSales" :customer "Congo" :id 88 :key "XSA-89"}
Received event : {:tx "findSales", :customer "Congo", :id 88, :key "XSA-89", :caudal/latency 608933}
```


### Creating custom parser

1. Create a clojure namespace file on **src/caudal_labs/parser.clj** and set the following code to it:

```
(ns caudal-labs.parser
  (:require [clojure.string :refer [split]]))

(defn parse-piped-line [line]
  (let [_        (println "piped line : " line)
        elements (split line #"\|")
        event    {:operation (nth elements 0)
                  :product   (nth elements 1)
                  :volume    (Integer/parseInt (nth elements 2))
                  :price     (Double/parseDouble (nth elements 3))}]
    event))
```

2. Modify tailer listener definition in **config/caudal-config** for using **parse-piped-line** function as the parser

```
...
(deflistener tailer [{:type 'mx.interware.caudal.io.tailer-server
                      :parameters {:parser      'caudal-labs.parser/parse-piped-line
                                   :inputs      {:directory  "./data"
                                                 :wildcard   "*txt"
                                                 :expiration 5}
                                   :delta       1000
                                   :from-end    true
                                   :reopen      true
                                   :buffer-size 16384}}])
...
```

3. Build project to use the namespace recently created

```
$ lein jar
Warning: specified :main without including it in :aot.
Implicit AOT of :main will be removed in Leiningen 3.0.0.
If you only need AOT for your uberjar, consider adding :aot :all into your
:uberjar profile instead.
Compiling caudal-labs.custom
Warning: The Main-Class specified does not exist within the jar. It may not be executable as expected. A gen-class directive may be missing in the namespace which contains the main method.
Created /projects/caudal-labs/target/caudal-labs-0.1.2-SNAPSHOT.jar

$ cp target/caudal-labs-0.1.2-SNAPSHOT.jar lib
```

4. Restart Caudal for applying changes in configuration

```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
...
16:43:43.791 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
16:43:43.850 [main] INFO  mx.interware.caudal.io.tailer-server - Tailing files :  (/projects/caudal-labs/./data/input.txt)  ...
16:43:43.857 [main] INFO  mx.interware.caudal.io.tailer-server - Channel created for file  input.txt  - > channel :  #object[clojure.core.async.impl.channels.ManyToManyChannel 0x1ad8df52 clojure.core.async.impl.channels.ManyToManyChannel@1ad8df52]
16:43:43.876 [main] INFO  mx.interware.caudal.io.tailer-server - register-channels for tailer
```

### Testing custom parser

1. Open another terminal and send a test event using the Caudal **tailer**, appending the message to **data/input.txt** file
```
$ echo "sale|flash memory|2|5.0" > data/input.txt
```

2. Verify the generated log for the tailed event
```
piped line :  sale|flash memory|2|5.0
Received event : {:operation "sale", :product "flash memory", :volume 2, :price 5.0, :caudal/latency 4205855}
```
