title: Lab 4 - Statistics
---
Retrieve and produce statistics from your configuration.

## Requirements
 * [Listeners](lab1.html)
 * [Streamers](lab3.html)

## Count
### Counting events
This section explains how to count each event received.

Write following configuration in `config/` directory:
```clojure config/stats.clj
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

Run Caudal passing this file as config:
```
bin/caudal -c config/stats.clj start
```

Test your configuration sending some events with telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

Verify generated log. As you can see, each incoming event has been decorated with an additional attribute **:n** with the current count of events:
```
2018-03-05 20:03:27.970 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 310076, :n 1}
2018-03-05 20:03:28.325 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 838793, :n 2}

```

Stop Caudal using `Ctrl-C`.

### Dumping count
Saving your event count using **dump-every**.

Update your configuration:
```clojure config/stats.clj
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/stats.clj start
```

Test your configuration sending some events with telnet:
```#bash
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

Verify Caudal output:
```
2018-03-05 20:07:11.906 INFO  [clojure-agent-send-pool-1] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 1889811, :n 1}
2018-03-05 20:07:13.216 INFO  [clojure-agent-send-pool-3] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 743669, :n 2}
```

And try to read the content in **data/stats/YYYMMdd-my-counter.edn** file:
```
$ cat data/stats/$( date +"%Y%m%d" )-my-counter.edn
{:n 2,
 :caudal/type "dump_every",
 :caudal/created 1520302031899,
 :caudal/touched 1520302033217}
```
Stop Caudal using `Ctrl-C`.

### Retrieving count
To read your EDN with count status is mandatory load file using  **scheduler**.

Update configuration file to use **deflistener** streamer as follows:
```clojure config/stats.clj
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

Run your configuration using:
```#bash
$ bin/start-caudal.sh -c ./config/stats.clj
```

Test your configuration sending some events with telnet:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :user "bar"}
{:tx "baz" :user "qux"}
```

Verify generated log. Your event counter starts its value using dumped file:
```
2018-03-05 20:25:09.225 INFO  [clojure-agent-send-pool-2] streams.stateless - {:tx "foo", :user "bar", :caudal/latency 602855, :n 3}
2018-03-05 20:25:14.293 INFO  [clojure-agent-send-pool-4] streams.stateless - {:tx "baz", :user "qux", :caudal/latency 719210, :n 4}
```

Stop Caudal using `Ctrl-C`.

## Standard Deviation
### Statistics of events
This section explains how to get mean, variance, and standard deviation from events.

Write following configuration in config/ directory:
```clojure config/stdev.clj
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

Run Caudal passing this file as config:
```
$ bin/caudal -c config/stdev.clj start
```

Test your configuration sending some events with telnet:
```
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

Verify generated log. As you can see each event entry has been decorated with some additional attributes:
```
2018-03-05 21:04:37.581 INFO  [clojure-agent-send-pool-1] streams.stateless - {:caudal/created 1520305477571, :mean 13, :caudal/touched 1520305477571, :n 1, :variance 0.0, :stdev 0.0, :tx "foo", :caudal/type "welford", :sqrs 0.0, :caudal/latency 3648365, :metric 13}
2018-03-05 21:04:37.588 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520305477571, :mean 18.0, :caudal/touched 1520305477588, :n 2, :variance 25.0, :stdev 5.0, :tx "bar", :caudal/type "welford", :sqrs 50.0, :caudal/latency 19147934, :metric 23}
2018-03-05 21:04:37.592 INFO  [clojure-agent-send-pool-3] streams.stateless - {:caudal/created 1520305477571, :mean 16.0, :caudal/touched 1520305477591, :n 3, :variance 24.666666666666668, :stdev 4.96655480858378, :tx "baz", :caudal/type "welford", :sqrs 74.0, :caudal/latency 719184, :metric 12}
2018-03-05 21:04:37.593 INFO  [clojure-agent-send-pool-4] streams.stateless - {:caudal/created 1520305477571, :mean 23.0, :caudal/touched 1520305477593, :n 4, :variance 165.5, :stdev 12.864680330268607, :tx "qux", :caudal/type "welford", :sqrs 662.0, :caudal/latency 788691, :metric 44}
2018-03-05 21:04:38.808 INFO  [clojure-agent-send-pool-5] streams.stateless - {:caudal/created 1520305477571, :mean 29.4, :caudal/touched 1520305478808, :n 5, :variance 296.24, :stdev 17.21162397916013, :tx "foo", :caudal/type "welford", :sqrs 1481.2, :caudal/latency 960081, :metric 55}
```

Stop Caudal using `Ctrl-C`.

### Dumping statistics
Saving your event statistics using **dump-every**.

Update your configuration:
```clojure config/stdev.clj
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
Run Caudal passing this file as config:
```
$ bin/caudal -c config/stdev.clj start
```

Test your configuration sending some events with telnet:
```
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

Verify generated log:
```
2018-03-05 21:10:23.066 INFO  [clojure-agent-send-pool-1] streams.stateless - {:caudal/created 1520305823057, :mean 13, :caudal/touched 1520305823057, :n 1, :variance 0.0, :stdev 0.0, :tx "foo", :caudal/type "welford", :sqrs 0.0, :caudal/latency 1743068, :metric 13}
2018-03-05 21:10:23.078 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520305823057, :mean 18.0, :caudal/touched 1520305823078, :n 2, :variance 25.0, :stdev 5.0, :tx "bar", :caudal/type "welford", :sqrs 50.0, :caudal/latency 22624436, :metric 23}
2018-03-05 21:10:23.081 INFO  [clojure-agent-send-pool-3] streams.stateless - {:caudal/created 1520305823057, :mean 16.0, :caudal/touched 1520305823081, :n 3, :variance 24.666666666666668, :stdev 4.96655480858378, :tx "baz", :caudal/type "welford", :sqrs 74.0, :caudal/latency 3166083, :metric 12}
2018-03-05 21:10:23.083 INFO  [clojure-agent-send-pool-4] streams.stateless - {:caudal/created 1520305823057, :mean 23.0, :caudal/touched 1520305823083, :n 4, :variance 165.5, :stdev 12.864680330268607, :tx "qux", :caudal/type "welford", :sqrs 662.0, :caudal/latency 2347646, :metric 44}
2018-03-05 21:10:23.393 INFO  [clojure-agent-send-pool-5] streams.stateless - {:caudal/created 1520305823057, :mean 29.4, :caudal/touched 1520305823392, :n 5, :variance 296.24, :stdev 17.21162397916013, :tx "foo", :caudal/type "welford", :sqrs 1481.2, :caudal/latency 553334, :metric 55}
```

And try to read the content in **/data/stats/YYYMMdd-my-stdev.edn**:
```
$ cat data/stats/$( date +"%Y%m%d" )-my-stdev.edn
{:caudal/created 1520305823057,
 :mean 29.4,
 :caudal/touched 1520305823393,
 :n 5,
 :variance 296.24,
 :stdev 17.21162397916013,
 :caudal/type "dump_every",
 :sqrs 1481.2}
```
Stop Caudal using `Ctrl-C`.

### Retrieving statistics
To read your EDN with statistics status is mandatory load file using a **scheduler**.

Update configuration file to use deflistener streamer as follows:
```clojure config/stdev.clj
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

Run your configuration using:
```
$ bin/caudal -c config/stdev.clj start
```

Test your configuration sending some events with telnet:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "foo" :metric 11}    
{:tx "foo" :metric 15}
```

Verify Caudal output, your event statistics starts its value using dumped file:
```
2018-03-05 21:22:48.365 INFO  [clojure-agent-send-pool-2] streams.stateless - {:caudal/created 1520306522793, :mean 26.333333333333332, :caudal/touched 1520306568357, :n 6, :variance 293.88888888888886, :stdev 17.143187827498387, :tx "foo", :caudal/type "welford", :sqrs 1763.3333333333333, :caudal/latency 2180281, :metric 11}
2018-03-05 21:22:49.281 INFO  [clojure-agent-send-pool-3] streams.stateless - {:caudal/created 1520306522793, :mean 24.71428571428571, :caudal/touched 1520306569280, :n 7, :variance 267.63265306122446, :stdev 16.35948205357445, :tx "foo", :caudal/type "welford", :sqrs 1873.4285714285713, :caudal/latency 817669, :metric 15}
```
