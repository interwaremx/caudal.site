title: Documentation
---
Welcome to Caudal documentation. If you encounter any problems when using Caudal, have a look at the [troubleshooting guide](troubleshooting.html), raise an issue on [GitHub](https://github.com/interwaremx/caudal/issues) or start a topic on the [Google Group](https://groups.google.com/group/caudal).

## What is Caudal?
Caudal is a platform that analyzes application logs using predictive models in real-time in order to get rich information for reliability monitoring and recomendation systems.

## What is an Event?
Event are any data struct and is passed as a Clojure Inmutable Map.

## What is the State?
Caudal uses an application State in order to store data needed for metrics and statistics. State is global for all streamers and application. Internally, State is a Clojure Agent, so it is concurrent. State are allocated in memory, it is cleaned each time Caudal process is finished.

## What is a Listener?
A Listener is a mechanism to put Events. Caudal comes with some Listeners out of the box.

## What is a Streamer?
Streamers define a function to be applied to each event into data stream and can be composed and combinated to enrich the data stream.

## Requirements
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)

## Installing
Get the binary file for the lastest Caudal distribution at [downloads section](/downloads)

```#bash
$ wget http://caudal.io/downloads/caudal-0.7.4.tgz
$ tar xvfz caudal-0.7.4.tgz
```

### Running
Start Caudal server

```#bash
cd caudal-0.7.4
$ bin/start-caudal.sh -c config/caudal-config.clj
```