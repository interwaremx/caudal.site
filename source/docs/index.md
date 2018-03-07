title: Documentation
---
Welcome to Caudal documentation. If you encounter any problems when using Caudal, have a look at the [troubleshooting guide](troubleshooting.html) or raise an issue on [GitHub](https://github.com/interwaremx/caudal/issues).

## What is Caudal?
Caudal is a platform that analyzes application events using predictive models in realtime in order to get rich information for reliability monitoring.

![Caudal Basic Diagram](./diagram-basic.svg)

## What is an Event?
Event are any data struct and is passed as a Clojure Inmutable Map. Events are registered in a State and are provided by Listeners.

## What is a Listener?
A Listener is a mechanism to put information into Caudal. Anything can be a source of events: application logs, a chat, or Twitter. Caudal comes with some Listeners out of the box.

## What are Streamers?
Streamers are functions to be applied to each event into data stream and can be composed and combinated to enrich the data stream.

## What is the State?
Caudal uses an application State in order to store data needed for metrics and statistics. State is global for all streamers and application. Internally, State is a Clojure Agent, so it is concurrent. State are allocated in memory, it is cleaned each time Caudal process is finished.

## Requirements
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)

## Installing
Get the binary file for the lastest Caudal distribution at [downloads section](/downloads)

```#bash
$ wget https://interwaremx.github.io/caudal.docs/downloads/caudal-0.7.14.tar.gz
$ tar xvfz caudal-0.7.14.tar.gz
```

### Running
Start Caudal server

```#bash
cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start
```
