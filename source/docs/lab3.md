title: Lab 3 - Streamers
---

Streamers are special functions that manipulates and enrich events.

## Requirements
 * [Setup](setup.html)
 * [Configuration](configuration.html)

![Caudal Streamers Diagram](./diagram-streamers.svg)

Caudal provides `defsink` macro to ingest events and streamers to manipulate it. Exists 2 types of streamers:

| | |
| - | - |
| Stateless | smap, by, ->INFO take an event and can modified it (or not), however, not performs any modification in State |
| Stateful | counter needs to remember how many events has been labeled, therefore, uses the State to make it |


Below are some streamers:

## default
Take each event and puts a new and key value. Is a stateless streamer function.

### Configuration
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (default [:my-new-random (Math/random)]))
```
Receives a vector with 2 elements, a new key and value to enrich current event.

### Example
Write following configuration in `config/` directory:
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/streamer-default.clj start

```

Open a telnet to `localhost` port `9900`:
```
$ telnet localhost 9900
```

And write an EDN map as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo 1}
```

Verify generated log for new incoming event:
```
2018-03-05 18:21:50.419 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 2118820, :reception-time #inst "2018-03-06T00:21:42.360-00:00"}
```

As you can see, `default` streamer is adding `:reception-time` attribute to every received event.


## counter
Take each event and put a field with its number of incoming. Is a stateful streamer function.

### Configuration
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (counter [:state-counter :event-counter]))
```
Receives a vector with 2 elements, a key to store current count in State and a key to propagate current count in event. 

### Example
Write following configuration in `config/` directory:
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/streamer-counter.clj start
```

Open a telnet to `localhost` port `9900`:
```
$ telnet localhost 9900
```

And write some EDN maps as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo 1}
{:foo 1}
{:foo 1}
```

Verify generated log for new incoming events:
```
2018-03-05 18:51:03.484 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 747057, :event-count 1}
2018-03-05 18:51:04.465 INFO  [clojure-agent-send-pool-2] streams.stateless - {:foo 1, :caudal/latency 790930, :event-count 2}
2018-03-05 18:51:05.053 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo 1, :caudal/latency 705925, :event-count 3}
```

Note that for every received event the attribute ':event-count' was added containing the current count.

## smap

Takes each event and transform it. Is a stateless streamer function.

### Configuration
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (smap [(fn [event] (assoc event :key "value"))]))
```
Receives a vector with an arity 1 function, such that, propagates as new event the result of apply function to event.

### Example

Write following configuration in `config/` directory:
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/streamer-smap.clj start
```

Open a telnet to `localhost` port `9900`:
```
$ telnet localhost 9900
```

And write an EDN map as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:product "kiwi" :ammount 10}
```

Verify generated log for new incoming event:

```
2018-03-05 18:30:55.618 INFO  [clojure-agent-send-pool-1] streams.stateless - {:product "kiwi", :ammount 10, :caudal/latency 1815598, :tax 1.6, :total 11.6}
```

As you can see, `smap` streamer transform every event adding two new fields `:tax` and `:total`.


## where
Filter events using a conditional predicate. Is a stateless streamer function.

### Configuration
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
         (where [(countains? % :foo)]
              (->INFO[:all])))
```
Receives a vector with a conditional, if true execute the nested code.

### Example

Write following configuration in `config/` directory:
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/streamer-where.clj start
```

Open a telnet to `localhost` port `9900`:
```
$ telnet localhost 9900
```

And write some EDN maps as follow:
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

Verify generated log for new incoming events:
```
2018-03-05 19:13:28.642 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 652919, :count 1}
2018-03-05 19:13:52.874 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tweet-id 2, :text "World", :caudal/latency 802505, :count 2}
2018-03-05 19:15:01.228 INFO  [clojure-agent-send-pool-0] streams.stateless - {:tweet-id "ok", :text "!!", :caudal/latency 436745, :count 3}
```

As you can see, this time the counter came only up to 3


## by
Streamer function that groups events by values of sent keys.  Is a stateless streamer function.

### Configuration
```clojure
;; macro ;; var-name  ;; backpressure
(defsink my-sink     1 
      (by [:id]
           (counter [:s-count :e-count])))
```
Receives a vector with keys to classfify the nested code, such that, nested code runs independently to each classification.

### Example

Write following configuration in `config/` directory:
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

Run Caudal passing this file as config:
```
bin/caudal -c config/streamer-by.clj start
```

Open a telnet to `localhost` port `9900`:
```
$ telnet localhost 9900
```

And write some EDN maps as follow:
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

Verify generated log for new incoming events:
```
2018-03-05 19:45:22.258 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 2896923, :count 1}
2018-03-05 19:45:39.660 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tweet-id 2, :text "Hello", :caudal/latency 804470, :count 1}
2018-03-05 19:46:03.188 INFO  [clojure-agent-send-pool-3] streams.stateless - {:tweet-id 3, :text "Hello", :caudal/latency 877918, :count 1}
2018-03-05 19:46:29.936 INFO  [clojure-agent-send-pool-4] streams.stateless - {:tweet-id 2, :text "World", :caudal/latency 697957, :count 2}
2018-03-05 19:46:46.604 INFO  [clojure-agent-send-pool-5] streams.stateless - {:tweet-id 1, :text "World", :caudal/latency 523277, :count 2}
2018-03-05 19:46:49.927 INFO  [clojure-agent-send-pool-0] streams.stateless - {:tweet-id 1, :text "Hello", :caudal/latency 659900, :count 3}
```

As you can see, this time the `counter` value is independent for each `:tweet-id`.

