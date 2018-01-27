title: Configuration
---

## Configuration File

Caudal uses one or many configuration files with the following structure:

```
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

* **Requires** section loads libs. These libs contains Clojure functions to be used. See [API section](/api) for more information.
* **Sinks** section define streamers functions to be applied to each event into data stream.
* **Listeners** section define mechanisms to retrieve events.
* **Wire** section routes listener acquired event to a streamers.

## Creating a Simple Configuration

Using your favorite editor create a file called **simple.clj** into **config/** directory: 
```#bash
$ cd caudal-0.7.4
$ emacs config/simple.clj
```

Put the following content in your **simple.clj**:
```
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

Save your **simple.clj** file and run it using Caudal, passing your file with **-c** option:
```#bash
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

Now, in other terminal, send events in EDN format using telnet:
```#bash
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

In your Caudal terminal, you could see the following output:
```#bash
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

