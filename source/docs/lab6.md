title: Lab 6 - Clustering
---
## Requirements
 * [Listeners](lab1.html)
 * [Streamers](lab3.html)

A lab exercises intended to show how to use Caudal in a distributed environment as shown in image below.

![caudal cluster](lab6-01.svg)

## Creating multiple caudal nodes

Change current directory to the **caudal-labs** project parent and make two copies of the caudal-labs directory.

```
$ mkdir cluster
$ wget https://interwaremx.github.io/caudal.docs/downloads/caudal-0.7.14.tar.gz
$ mkdir caudal-balancer && tar xzvf caudal-0.7.14.tar.gz -C caudal-balancer --strip-components 1
$ mkdir caudal-1 && tar xzvf caudal-0.7.14.tar.gz -C caudal-1 --strip-components 1
$ mkdir caudal-2 && tar xzvf caudal-0.7.14.tar.gz -C caudal-2 --strip-components 1
$ mkdir caudal-3 && tar xzvf caudal-0.7.14.tar.gz -C caudal-3 --strip-components 1
```

Edit configuration files for every Caudal instance in the cluster as follow:
```clojure caudal-balancer/config/caudal-balancer.clj
;; Requires
(ns caudal.example.cluster
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server 
                            :parameters {:port 9900
                                         :idle-period 60}}])

;; Sinks
(defsink streamer-1 1
        (printe ["Received event : "]
                (split [(fn [e] (= "CX" (:state e)))]
                       (printe ["Forwarding event to node 1 : "] (forward ["localhost" 9901]))
                       
                       [(fn [e] (= "HG" (:state e)))]
                       (printe ["Forwarding event to node 2 : "] (forward ["localhost" 9902]))

                       [(fn [e] (= "MN" (:state e)))]
                       (printe ["Forwarding event to node 3 : "] (forward ["localhost" 9903]))
                        
                       (printe ["Skipping event : "] ))))

;; Wire
(wire [tcp-listener] [streamer-1])
```


```clojure caudal-1/config/caudal-node1.clj
;; Requires
(ns caudal.example.cluster
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server 
                            :parameters {:port 9901
                                         :idle-period 60}}])

(defn calculate-tax [event]
  (let [price     (:price event)
        ammount   (:ammount event)
        sub-total (* ammount price)
        tax       (* 0.15 sub-total)
        total     (+ sub-total tax)]
    (assoc event :sub-total sub-total :tax tax :total total)))

;; Sinks
(defsink streamer-1 1
  (smap [calculate-tax]
        (printe ["TAX 15% applied : "])))

;; Wire
(wire [tcp-listener] [streamer-1])

```

```clojure caudal-2/config/caudal-node2.clj
;; Requires
(ns caudal.example.cluster
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server 
                            :parameters {:port 9902
                                         :idle-period 60}}])

(defn calculate-tax [event]
  (let [price     (:price event)
        ammount   (:ammount event)
        sub-total (* ammount price)
        tax       (* 0.16 sub-total)
        total     (+ sub-total tax)]
    (assoc event :sub-total sub-total :tax tax :total total)))

;; Sinks
(defsink streamer-1 1
  (smap [calculate-tax]
        (printe ["TAX 16% applied : "])))

;; Wire
(wire [tcp-listener] [streamer-1])
```

```clojure caudal-3/config/caudal-node3.clj
;; Requires
(ns caudal.example.cluster
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp-listener [{:type 'mx.interware.caudal.io.tcp-server 
                            :parameters {:port 9903
                                         :idle-period 60}}])

(defn calculate-tax [event]
  (let [price     (:price event)
        ammount   (:ammount event)
        sub-total (* ammount price)
        tax       (* 0.10 sub-total)
        total     (+ sub-total tax)]
    (assoc event :sub-total sub-total :tax tax :total total)))

;; Sinks
(defsink streamer-1 1
  (smap [calculate-tax]
        (printe ["TAX 10% applied : "])))

;; Wire
(wire [tcp-listener] [streamer-1])
```

## Start Caudal instances

Open a terminal for each caudal instance and start them as shown:

```plain Balancer
$ cd caudal-balancer/
$ bin/caudal -c config/caudal-balancer.clj start
```

```plain node 1
$ cd caudal-1
$ bin/caudal -c config/caudal-node1.clj start
```

```plain node 2
$ cd caudal-2
$ bin/caudal -c config/caudal-node2.clj start
```

```plain node 3
$ cd caudal-3
$ bin/caudal -c config/caudal-node3     .clj start
```


## Feeding event streamer

Open another terminal and send some events to te balancer through the **tcp channel** like this.
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:tx "sale" :state "MN" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:50.522-00:00" :ammount 1}
{:tx "sale" :state "HG" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:50.596-00:00" :ammount 2}
{:tx "sale" :state "CX" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:50.622-00:00" :ammount 4}
{:tx "sale" :state "HG" :product "mango" :price 23.0 :time #inst"2017-01-16T19:14:50.659-00:00" :ammount 5}
{:tx "sale" :state "CX" :product "avocado" :price 52.1 :time #inst"2017-01-16T19:14:50.739-00:00" :ammount 2}
{:tx "sale" :state "MN" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:50.824-00:00" :ammount 7}
{:tx "sale" :state "HG" :product "avocado" :price 52.1 :time #inst"2017-01-16T19:14:50.864-00:00" :ammount 4}
{:tx "sale" :state "CX" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:50.901-00:00" :ammount 4}
{:tx "sale" :state "HG" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:50.935-00:00" :ammount 9}
{:tx "sale" :state "MN" :product "blueberry" :price 65.2 :time #inst"2017-01-16T19:14:51.030-00:00" :ammount 1}
{:tx "sale" :state "CX" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:51.074-00:00" :ammount 2}
{:tx "sale" :state "SL" :product "blueberry" :price 65.2 :time #inst"2017-01-16T19:14:51.103-00:00" :ammount 3}
{:tx "sale" :state "MN" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:51.148-00:00" :ammount 6}
{:tx "sale" :state "MN" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:51.245-00:00" :ammount 5}
{:tx "sale" :state "CX" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:51.341-00:00" :ammount 5}
{:tx "sale" :state "CX" :product "blueberry" :price 65.2 :time #inst"2017-01-16T19:14:51.399-00:00" :ammount 9}
{:tx "sale" :state "MN" :product "avocado" :price 52.1 :time #inst"2017-01-16T19:14:51.456-00:00" :ammount 10}
{:tx "sale" :state "CX" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:51.491-00:00" :ammount 4}
{:tx "sale" :state "HG" :product "avocado" :price 52.1 :time #inst"2017-01-16T19:14:51.583-00:00" :ammount 9}
{:tx "sale" :state "HG" :product "blueberry" :price 65.2 :time #inst"2017-01-16T19:14:51.665-00:00" :ammount 8}
{:tx "sale" :state "MN" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:51.676-00:00" :ammount 4}
{:tx "sale" :state "MN" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:51.699-00:00" :ammount 7}
{:tx "sale" :state "MN" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:51.799-00:00" :ammount 6}
{:tx "sale" :state "BC" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:51.802-00:00" :ammount 2}
{:tx "sale" :state "CX" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:51.805-00:00" :ammount 7}
{:tx "sale" :state "CX" :product "blueberry" :price 65.2 :time #inst"2017-01-16T19:14:51.832-00:00" :ammount 3}
{:tx "sale" :state "HG" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:51.934-00:00" :ammount 6}
{:tx "sale" :state "HG" :product "pear" :price 37.3 :time #inst"2017-01-16T19:14:51.983-00:00" :ammount 7}
{:tx "sale" :state "CX" :product "mango" :price 23.0 :time #inst"2017-01-16T19:14:51.995-00:00" :ammount 3}
{:tx "sale" :state "CX" :product "avocado" :price 52.1 :time #inst"2017-01-16T19:14:52.095-00:00" :ammount 7}
{:tx "sale" :state "HG" :product "apple" :price 42.5 :time #inst"2017-01-16T19:14:52.186-00:00" :ammount 3}
{:tx "sale" :state "MN" :product "papaya" :price 20.5 :time #inst"2017-01-16T19:14:52.229-00:00" :ammount 9}
```


## Verifying logs

Verify log outputs for every Caudal instance, contents should be similar to the ones shown below.

```plain Balancer
2018-03-06 20:21:10.379 INFO  [main] io.tcp-server - Starting server on port :  9900  ...
Received event : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.522-00:00", :ammount 1, :caudal/latency 2235302}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.522-00:00", :ammount 1, :caudal/latency 2235302}
Received event : {:tx "sale", :state "HG", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.596-00:00", :ammount 2, :caudal/latency 14620839}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.596-00:00", :ammount 2, :caudal/latency 14620839}
Received event : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:50.622-00:00", :ammount 4, :caudal/latency 5694661}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:50.622-00:00", :ammount 4, :caudal/latency 5694661}
Received event : {:tx "sale", :state "HG", :product "mango", :price 23.0, :time #inst "2017-01-16T19:14:50.659-00:00", :ammount 5, :caudal/latency 3102839}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "mango", :price 23.0, :time #inst "2017-01-16T19:14:50.659-00:00", :ammount 5, :caudal/latency 3102839}
Received event : {:tx "sale", :state "CX", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:50.739-00:00", :ammount 2, :caudal/latency 1783828}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:50.739-00:00", :ammount 2, :caudal/latency 1783828}
Received event : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.824-00:00", :ammount 7, :caudal/latency 1789110}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:50.824-00:00", :ammount 7, :caudal/latency 1789110}
Received event : {:tx "sale", :state "HG", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:50.864-00:00", :ammount 4, :caudal/latency 2273229}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:50.864-00:00", :ammount 4, :caudal/latency 2273229}
Received event : {:tx "sale", :state "CX", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:50.901-00:00", :ammount 4, :caudal/latency 1445252}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:50.901-00:00", :ammount 4, :caudal/latency 1445252}
Received event : {:tx "sale", :state "HG", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:50.935-00:00", :ammount 9, :caudal/latency 4387371}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:50.935-00:00", :ammount 9, :caudal/latency 4387371}
Received event : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.074-00:00", :ammount 2, :caudal/latency 4468205}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.074-00:00", :ammount 2, :caudal/latency 4468205}
Received event : {:tx "sale", :state "SL", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.103-00:00", :ammount 3, :caudal/latency 2472304}
Skipping event : {:tx "sale", :state "SL", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.103-00:00", :ammount 3, :caudal/latency 2472304}
Received event : {:tx "sale", :state "MN", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.148-00:00", :ammount 6, :caudal/latency 8134483}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.148-00:00", :ammount 6, :caudal/latency 8134483}
Received event : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.245-00:00", :ammount 5, :caudal/latency 6383133}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.245-00:00", :ammount 5, :caudal/latency 6383133}
Received event : {:tx "sale", :state "CX", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.341-00:00", :ammount 5, :caudal/latency 13905716}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.341-00:00", :ammount 5, :caudal/latency 13905716}
Received event : {:tx "sale", :state "CX", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.399-00:00", :ammount 9, :caudal/latency 9565542}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.399-00:00", :ammount 9, :caudal/latency 9565542}
Received event : {:tx "sale", :state "MN", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:51.456-00:00", :ammount 10, :caudal/latency 6471559}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:51.456-00:00", :ammount 10, :caudal/latency 6471559}
Received event : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.491-00:00", :ammount 4, :caudal/latency 7859170}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.491-00:00", :ammount 4, :caudal/latency 7859170}
Received event : {:tx "sale", :state "HG", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:51.583-00:00", :ammount 9, :caudal/latency 3560219}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:51.583-00:00", :ammount 9, :caudal/latency 3560219}
Received event : {:tx "sale", :state "HG", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.665-00:00", :ammount 8, :caudal/latency 4008278}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.665-00:00", :ammount 8, :caudal/latency 4008278}
Received event : {:tx "sale", :state "MN", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.676-00:00", :ammount 4, :caudal/latency 9026685}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.676-00:00", :ammount 4, :caudal/latency 9026685}
Received event : {:tx "sale", :state "MN", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.699-00:00", :ammount 7, :caudal/latency 6402041}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.699-00:00", :ammount 7, :caudal/latency 6402041}
Received event : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.799-00:00", :ammount 6, :caudal/latency 2112642}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.799-00:00", :ammount 6, :caudal/latency 2112642}
Received event : {:tx "sale", :state "BC", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.802-00:00", :ammount 2, :caudal/latency 10368327}
Skipping event : {:tx "sale", :state "BC", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:51.802-00:00", :ammount 2, :caudal/latency 10368327}
Received event : {:tx "sale", :state "CX", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.805-00:00", :ammount 7, :caudal/latency 2993864}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.805-00:00", :ammount 7, :caudal/latency 2993864}
Received event : {:tx "sale", :state "CX", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.832-00:00", :ammount 3, :caudal/latency 863598}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "blueberry", :price 65.2, :time #inst "2017-01-16T19:14:51.832-00:00", :ammount 3, :caudal/latency 863598}
Received event : {:tx "sale", :state "HG", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.934-00:00", :ammount 6, :caudal/latency 898653}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:51.934-00:00", :ammount 6, :caudal/latency 898653}
Received event : {:tx "sale", :state "HG", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.983-00:00", :ammount 7, :caudal/latency 59845760}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "pear", :price 37.3, :time #inst "2017-01-16T19:14:51.983-00:00", :ammount 7, :caudal/latency 59845760}
Received event : {:tx "sale", :state "CX", :product "mango", :price 23.0, :time #inst "2017-01-16T19:14:51.995-00:00", :ammount 3, :caudal/latency 5950219}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "mango", :price 23.0, :time #inst "2017-01-16T19:14:51.995-00:00", :ammount 3, :caudal/latency 5950219}
Received event : {:tx "sale", :state "CX", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:52.095-00:00", :ammount 7, :caudal/latency 19483436}
Forwarding event to node 1 : {:tx "sale", :state "CX", :product "avocado", :price 52.1, :time #inst "2017-01-16T19:14:52.095-00:00", :ammount 7, :caudal/latency 19483436}
Received event : {:tx "sale", :state "HG", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:52.186-00:00", :ammount 3, :caudal/latency 8162344}
Forwarding event to node 2 : {:tx "sale", :state "HG", :product "apple", :price 42.5, :time #inst "2017-01-16T19:14:52.186-00:00", :ammount 3, :caudal/latency 8162344}
Received event : {:tx "sale", :state "MN", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:52.229-00:00", :ammount 9, :caudal/latency 260805}
Forwarding event to node 3 : {:tx "sale", :state "MN", :product "papaya", :price 20.5, :time #inst "2017-01-16T19:14:52.229-00:00", :ammount 9, :caudal/latency 260805}
```

```plain node 1
2018-03-06 20:08:53.450 INFO  [main] io.tcp-server - Starting server on port :  9901  ...
TAX 15% applied : {:ammount 4, :sub-total 82.0, :time #inst "2017-01-16T19:14:50.622-00:00", :state "CX", :tax 12.299999999999999, :product "papaya", :total 94.3, :tx "sale", :price 20.5, :caudal/latency 798004}
TAX 15% applied : {:ammount 2, :sub-total 104.2, :time #inst "2017-01-16T19:14:50.739-00:00", :state "CX", :tax 15.629999999999999, :product "avocado", :total 119.83, :tx "sale", :price 52.1, :caudal/latency 330996}
TAX 15% applied : {:ammount 4, :sub-total 170.0, :time #inst "2017-01-16T19:14:50.901-00:00", :state "CX", :tax 25.5, :product "apple", :total 195.5, :tx "sale", :price 42.5, :caudal/latency 586374}
TAX 15% applied : {:ammount 2, :sub-total 41.0, :time #inst "2017-01-16T19:14:51.074-00:00", :state "CX", :tax 6.1499999999999995, :product "papaya", :total 47.15, :tx "sale", :price 20.5, :caudal/latency 639997}
TAX 15% applied : {:ammount 5, :sub-total 212.5, :time #inst "2017-01-16T19:14:51.341-00:00", :state "CX", :tax 31.875, :product "apple", :total 244.375, :tx "sale", :price 42.5, :caudal/latency 1216909}
TAX 15% applied : {:ammount 9, :sub-total 586.8000000000001, :time #inst "2017-01-16T19:14:51.399-00:00", :state "CX", :tax 88.02000000000001, :product "blueberry", :total 674.82, :tx "sale", :price 65.2, :caudal/latency 2977407}
TAX 15% applied : {:ammount 4, :sub-total 82.0, :time #inst "2017-01-16T19:14:51.491-00:00", :state "CX", :tax 12.299999999999999, :product "papaya", :total 94.3, :tx "sale", :price 20.5, :caudal/latency 5280419}
TAX 15% applied : {:ammount 7, :sub-total 261.09999999999997, :time #inst "2017-01-16T19:14:51.805-00:00", :state "CX", :tax 39.16499999999999, :product "pear", :total 300.265, :tx "sale", :price 37.3, :caudal/latency 260094}
TAX 15% applied : {:ammount 3, :sub-total 195.60000000000002, :time #inst "2017-01-16T19:14:51.832-00:00", :state "CX", :tax 29.340000000000003, :product "blueberry", :total 224.94000000000003, :tx "sale", :price 65.2, :caudal/latency 279546}
TAX 15% applied : {:ammount 3, :sub-total 69.0, :time #inst "2017-01-16T19:14:51.995-00:00", :state "CX", :tax 10.35, :product "mango", :total 79.35, :tx "sale", :price 23.0, :caudal/latency 465704}
TAX 15% applied : {:ammount 7, :sub-total 364.7, :time #inst "2017-01-16T19:14:52.095-00:00", :state "CX", :tax 54.705, :product "avocado", :total 419.405, :tx "sale", :price 52.1, :caudal/latency 221464}
```

```plain node 2
2018-03-06 20:08:59.623 INFO  [main] io.tcp-server - Starting server on port :  9902  ...
TAX 16% applied : {:ammount 2, :sub-total 74.6, :time #inst "2017-01-16T19:14:50.596-00:00", :state "HG", :tax 11.936, :product "pear", :total 86.536, :tx "sale", :price 37.3, :caudal/latency 808651}
TAX 16% applied : {:ammount 5, :sub-total 115.0, :time #inst "2017-01-16T19:14:50.659-00:00", :state "HG", :tax 18.400000000000002, :product "mango", :total 133.4, :tx "sale", :price 23.0, :caudal/latency 695902}
TAX 16% applied : {:ammount 4, :sub-total 208.4, :time #inst "2017-01-16T19:14:50.864-00:00", :state "HG", :tax 33.344, :product "avocado", :total 241.744, :tx "sale", :price 52.1, :caudal/latency 1429757}
TAX 16% applied : {:ammount 9, :sub-total 382.5, :time #inst "2017-01-16T19:14:50.935-00:00", :state "HG", :tax 61.2, :product "apple", :total 443.7, :tx "sale", :price 42.5, :caudal/latency 589796}
TAX 16% applied : {:ammount 9, :sub-total 468.90000000000003, :time #inst "2017-01-16T19:14:51.583-00:00", :state "HG", :tax 75.024, :product "avocado", :total 543.924, :tx "sale", :price 52.1, :caudal/latency 543612}
TAX 16% applied : {:ammount 8, :sub-total 521.6, :time #inst "2017-01-16T19:14:51.665-00:00", :state "HG", :tax 83.456, :product "blueberry", :total 605.056, :tx "sale", :price 65.2, :caudal/latency 2104298}
TAX 16% applied : {:ammount 6, :sub-total 123.0, :time #inst "2017-01-16T19:14:51.934-00:00", :state "HG", :tax 19.68, :product "papaya", :total 142.68, :tx "sale", :price 20.5, :caudal/latency 341763}
TAX 16% applied : {:ammount 7, :sub-total 261.09999999999997, :time #inst "2017-01-16T19:14:51.983-00:00", :state "HG", :tax 41.775999999999996, :product "pear", :total 302.876, :tx "sale", :price 37.3, :caudal/latency 540235}
TAX 16% applied : {:ammount 3, :sub-total 127.5, :time #inst "2017-01-16T19:14:52.186-00:00", :state "HG", :tax 20.400000000000002, :product "apple", :total 147.9, :tx "sale", :price 42.5, :caudal/latency 316746}
```

```plain node 3
2018-03-06 20:09:16.948 INFO  [main] io.tcp-server - Starting server on port :  9903  ...
TAX 10% applied : {:ammount 1, :sub-total 37.3, :time #inst "2017-01-16T19:14:50.522-00:00", :state "MN", :tax 3.73, :product "pear", :total 41.029999999999994, :tx "sale", :price 37.3, :caudal/latency 865691}
TAX 10% applied : {:ammount 7, :sub-total 261.09999999999997, :time #inst "2017-01-16T19:14:50.824-00:00", :state "MN", :tax 26.11, :product "pear", :total 287.21, :tx "sale", :price 37.3, :caudal/latency 3902999}
TAX 10% applied : {:ammount 6, :sub-total 255.0, :time #inst "2017-01-16T19:14:51.148-00:00", :state "MN", :tax 25.5, :product "apple", :total 280.5, :tx "sale", :price 42.5, :caudal/latency 793210}
TAX 10% applied : {:ammount 5, :sub-total 186.5, :time #inst "2017-01-16T19:14:51.245-00:00", :state "MN", :tax 18.650000000000002, :product "pear", :total 205.15, :tx "sale", :price 37.3, :caudal/latency 488819}
TAX 10% applied : {:ammount 10, :sub-total 521.0, :time #inst "2017-01-16T19:14:51.456-00:00", :state "MN", :tax 52.1, :product "avocado", :total 573.1, :tx "sale", :price 52.1, :caudal/latency 518560}
TAX 10% applied : {:ammount 4, :sub-total 170.0, :time #inst "2017-01-16T19:14:51.676-00:00", :state "MN", :tax 17.0, :product "apple", :total 187.0, :tx "sale", :price 42.5, :caudal/latency 654091}
TAX 10% applied : {:ammount 7, :sub-total 143.5, :time #inst "2017-01-16T19:14:51.699-00:00", :state "MN", :tax 14.350000000000001, :product "papaya", :total 157.85, :tx "sale", :price 20.5, :caudal/latency 5066034}
TAX 10% applied : {:ammount 6, :sub-total 223.79999999999998, :time #inst "2017-01-16T19:14:51.799-00:00", :state "MN", :tax 22.38, :product "pear", :total 246.17999999999998, :tx "sale", :price 37.3, :caudal/latency 243846}
TAX 10% applied : {:ammount 9, :sub-total 184.5, :time #inst "2017-01-16T19:14:52.229-00:00", :state "MN", :tax 18.45, :product "papaya", :total 202.95, :tx "sale", :price 20.5, :caudal/latency 323802}
```
