title: Configuration
---

## Configuration File

Caudal uses one or many configuration files with the following structure:
```clojure config/caudal-config.clj
;; Requires
(ns caudal.config.basic
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server
                   :parameters {:port 9900
                   :idle-period 60}}])

;; Streamers
(defsink example 1 ;; backpressure
  (counter [:state-counter :event-counter]
           (->INFO [:all])))

;; Wire
(wire [tcp] [example])

```

* **Requires** section loads libs. These libs contains Clojure functions to be used. See [API section](../api) for more information.
* **Listeners** section define mechanisms to retrieve events.
* **Streamers** section define streamer functions to be applied to each event into data stream.
* **Wire** section routes listener acquired event to a streamers.

## Creating a Simple Configuration

Using your favorite editor create a file called **classifier.clj** into **config/** directory: 
```#bash
$ cd caudal-0.7.14
$ emacs config/classifier.clj
```

Put the following content in your **classifier.clj**:
```clojure config/classifier.clj
;; Requires
(ns caudal.config.basic
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server
                   :parameters {:port 9900
                   :idle-period 60}}])

;; Simple classifier
(defn classifier [event]
  (let [counter (:event-counter event)]
    (assoc event :class (if (odd? counter) "odd" "even"))))

;; Streamers
(defsink my-sink 1 ;; backpressure            ;; (0) incoming event
  (counter [:s-counter :event-counter]        ;; (1) count each event
           (smap [classifier]                 ;; (2) smap modify each event using classifier function
                 (by [:class]                 ;; (2) by each event's class
                     (counter [:c-counter :n] ;; (3) counts by its class
                              (->INFO [:all]))))))

;; Wire
(wire [tcp] [my-sink])
```
![Caudal Streamers Diagram](./diagram-streamers.svg)

Save your **classifier.clj** file and run it using Caudal, passing your file with **-c** option:
```
$ bin/caudal -c config/classifier.clj start
```

Now, in other terminal, send events in EDN format using telnet:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
{:foo :bar}
```

In your Caudal terminal, you could see the following output:
```
2018-01-01 22:43:23.227 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo :foo, :caudal/latency 1459909, :event-counter 1, :class "odd", :n 1}
2018-01-01 22:43:33.827 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :foo, :caudal/latency 590683, :event-counter 2, :class "event", :n 1}
2018-01-01 22:43:36.426 INFO  [clojure-agent-send-pool-4] streams.stateless - {:foo :foo, :caudal/latency 675070, :event-counter 3, :class "odd", :n 2}
2018-01-01 22:43:38.513 INFO  [clojure-agent-send-pool-5] streams.stateless - {:foo :foo, :caudal/latency 455418, :event-counter 4, :class "event", :n 2}
2018-01-01 22:43:40.698 INFO  [clojure-agent-send-pool-0] streams.stateless - {:foo :foo, :caudal/latency 438063, :event-counter 5, :class "odd", :n 3}
2018-01-01 22:43:41.967 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo :foo, :caudal/latency 353969, :event-counter 6, :class "event", :n 3}
2018-01-01 22:43:43.152 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo :foo, :caudal/latency 259806, :event-counter 7, :class "odd", :n 4}
2018-01-01 22:43:44.084 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :foo, :caudal/latency 277867, :event-counter 8, :class "event", :n 4}
2018-01-01 22:43:44.894 INFO  [clojure-agent-send-pool-4] streams.stateless - {:foo :foo, :caudal/latency 285944, :event-counter 9, :class "odd", :n 5}
2018-01-01 22:43:45.712 INFO  [clojure-agent-send-pool-5] streams.stateless - {:foo :foo, :caudal/latency 449371, :event-counter 10, :class "event", :n 5}
2018-01-01 22:43:46.454 INFO  [clojure-agent-send-pool-0] streams.stateless - {:foo :foo, :caudal/latency 273238, :event-counter 11, :class "odd", :n 6}
2018-01-01 22:44:25.710 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo :foo, :caudal/latency 381772, :event-counter 12, :class "event", :n 6}
2018-01-01 22:44:26.733 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo :foo, :caudal/latency 290489, :event-counter 13, :class "odd", :n 7}
2018-01-01 22:44:27.464 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :foo, :caudal/latency 360034, :event-counter 14, :class "event", :n 7}
2018-01-01 22:44:28.203 INFO  [clojure-agent-send-pool-4] streams.stateless - {:foo :foo, :caudal/latency 337799, :event-counter 15, :class "odd", :n 8}
2018-01-01 22:44:29.005 INFO  [clojure-agent-send-pool-5] streams.stateless - {:foo :foo, :caudal/latency 335995, :event-counter 16, :class "event", :n 8}
2018-01-01 22:44:29.632 INFO  [clojure-agent-send-pool-0] streams.stateless - {:foo :foo, :caudal/latency 327458, :event-counter 17, :class "odd", :n 9}
2018-01-01 22:44:30.234 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo :foo, :caudal/latency 276567, :event-counter 18, :class "event", :n 9}
2018-01-01 22:44:47.155 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo :foo, :caudal/latency 298137, :event-counter 19, :class "odd", :n 10}
```

You can see how your event has been enriched with some parameters. 

Originally, `caudal-config.clj` counts each event and places in ` event-counter` its number. 

In `classifier.clj` decides if the incoming event is even or odd and puts a new attribute `:class` using `smap`, then using `by` divides the event stream by `:class` and finally with `counter` counts each event again, but using its `:class`.
