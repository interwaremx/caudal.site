title: Setup
---

Installing Caudal is quite easy. However, you do need to have a couple of other things installed first:

## Requirements
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)
 * [Leiningen 2.6.1](install-leiningen.html)


## Installation from binary distribution

There are several Caudal binary distributions. They are packaged in the form of compressed tar files.

### Obtaining

1. Get the binary file for the lastest Caudal distribution at [downloads](http://caudal.io/downloads) section

```
$ wget http://caudal.io/downloads/caudal-0.7.4-SNAPSHOT.tar.gz
```

### Unpacking

1. Unpack downloaded file, wich creates the installation directory.

```
$ tar xzvf caudal-0.7.4-SNAPSHOT.tar.gz
x caudal/bin/
x caudal/bin/start-caudal-with-els.sh
x caudal/bin/start-caudal.sh
x caudal/config/
x caudal/config/caudal-config.clj
...
x caudal/log4j.properties
x caudal/logs/
x caudal/logs/caudal.log
```

2. Verify directory contents.

```
$ cd caudal
$ ls -l
total 8
drwxr-xr-x    4 axis  staff   136 Jan 27 12:13 bin
drwxr-xr-x    3 axis  staff   102 Jan 27 13:50 config
drwxr-xr-x    3 axis  staff   102 Jan 27 13:53 data
drwxr-xr-x  137 axis  staff  4658 Jan 25 10:48 lib
-rw-r--r--    1 axis  staff   891 Jan 27 14:01 log4j.properties
drwxr-xr-x    3 axis  staff   102 Jan 27 13:46 logs
```


### Running

1. Start Caudal server

```
$ bin/start-caudal.sh -c config/caudal-config.clj
Verifying JAVA instalation ...
/usr/bin/java
JAVA executable found in PATH
JAVA Version : 1.8.0_91
BIN path /projects/caudal/bin
Starting Caudal from /projects/caudal
                        __      __
  _________ ___  ______/ /___ _/ /
 / ___/ __ `/ / / / __  / __ `/ /
/ /__/ /_/ / /_/ / /_/ / /_/ / /
\___/\__,_/\__,_/\__,_/\__,_/_/

Caudal 0.7.4
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/projects/caudal/lib/logback-classic-1.1.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/projects/caudal/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
15:48:12.503 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file config/caudal-config.clj}}
15:48:13.916 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
15:48:13.986 [main] INFO  mx.interware.caudal.io.tailer-server - Tailing files :  (/projects/caudal/./data/input.txt)  ...
15:48:13.998 [main] INFO  mx.interware.caudal.io.tailer-server - Channel created for file  input.txt  - > channel :  #object[clojure.core.async.impl.channels.ManyToManyChannel 0x33b082c5 clojure.core.async.impl.channels.ManyToManyChannel@33b082c5]
15:48:14.086 [main] INFO  mx.interware.caudal.io.tailer-server - register-channels for tailer
```

2. Open another terminal and send an event message through the Caudal **tcp** channel running on port **9900** to make sure it can be accessed

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

3. Verify the generated log for the received event.

```
15:53:03.172 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - CREATED
15:53:03.172 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - OPENED
15:53:06.394 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=63 cap=4096: 7B 3A 74 78 20 22 67 65 74 4F 70 65 72 61 74 69...]
15:53:06.397 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
Received event : {:tx "getOperation", :customer "Nile", :id 96, :ammount 57.1428, :caudal/latency 559586}
15:53:10.903 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - RECEIVED: HeapBuffer[pos=0 lim=5 cap=4096: 45 4F 54 0D 0A]
15:53:10.903 [NioProcessor-2] DEBUG o.a.m.f.codec.ProtocolCodecFilter - Processing a MESSAGE_RECEIVED for session 1
15:53:10.906 [NioProcessor-2] INFO  o.a.m.filter.logging.LoggingFilter - CLOSED
```

## Installation from git repository

You can start a Caudal configuration from the sources. Caudal is an open source project and is distributed for free at [github](https://github.com/interwaremx/caudal).

### Downloading

Use **git** to download latest version of Caudal.

```
$ git clone https://github.com/interwaremx/caudal
```

### Building

1. Build a standalone jar into the cloned project directory and then run **lein uberjar**.
```
$ cd caudal/
$ lein uberjar
Compiling mx.interware.caudal.core.global
Compiling mx.interware.caudal.core.main
Compiling mx.interware.caudal.core.starter
...
Compiling mx.interware.caudal.core.starter-dsl
Warning: The Main-Class specified does not exist within the jar. It may not be executable as expected. A gen-class directive may be missing in the namespace which contains the main method.
Created /projects/caudal/target/caudal-0.7.4.jar
Created /projects/caudal/target/caudal-0.7.4-standalone.jar
```

## Running and Testing

1. Caudal can run interactively via the command line using **java** and a minimal configuration file in clj format already included in **config/** directory.
```
$ java -jar target/caudal-0.7.4-standalone.jar -c config/caudal-config.clj
                        __      __
  _________ ___  ______/ /___ _/ /
 / ___/ __ `/ / / / __  / __ `/ /
/ /__/ /_/ / /_/ / /_/ / /_/ / /
\___/\__,_/\__,_/\__,_/\__,_/_/

Caudal 0.7.4
log4j:WARN [stdout] should be System.out or System.err.
log4j:WARN Using previously set target, System.out by default.
2017-01-27 16:53:24.453 [main] INFO  starter-dsl:0 - {:loading-dsl {:file config/caudal-config.clj}}
2017-01-27 16:53:25.690 [main] INFO  tcp-server:0 - Starting server on port :  9900  ...
2017-01-27 16:53:25.741 [main] INFO  tailer-server:0 - Tailing files :  (/Users/axis/Development/Interware/caudal/projects/caudal/./data/input.txt)  ...
2017-01-27 16:53:25.749 [main] INFO  tailer-server:0 - Channel created for file  input.txt  - > channel :  #object[clojure.core.async.impl.channels.ManyToManyChannel 0x27fde870 clojure.core.async.impl.channels.ManyToManyChannel@27fde870]
2017-01-27 16:53:25.811 [main] INFO  tailer-server:0 - register-channels for tailer
```
As we can see, Caudal server has been started and is running a TCP Server in port 9900.

2. Now, in another terminal, using **telnet** we can sent events to Caudal in EDN format, by instance, when we typing `{:host "example.com" :app "myapp" :metric 2}` as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:host "example.com" :app "myapp" :metric 2}
EOT
```

3. Verify results in Caudal terminal:

```
2017-01-27 16:56:28.494 [NioProcessor-2] INFO  LoggingFilter:186 - CREATED
2017-01-27 16:56:28.495 [NioProcessor-2] INFO  LoggingFilter:186 - OPENED
2017-01-27 16:56:29.852 [NioProcessor-2] INFO  LoggingFilter:157 - RECEIVED: HeapBuffer[pos=0 lim=46 cap=4096: 7B 3A 68 6F 73 74 20 22 65 78 61 6D 70 6C 65 2E...]
Received event : {:host "example.com", :app "myapp", :metric 2, :caudal/latency 655711}
2017-01-27 16:56:33.657 [NioProcessor-2] INFO  LoggingFilter:157 - RECEIVED: HeapBuffer[pos=0 lim=5 cap=4096: 45 4F 54 0D 0A]
2017-01-27 16:56:33.660 [NioProcessor-2] INFO  LoggingFilter:186 - CLOSED
```

To stop Caudal press **Ctrl**-**C**.


## Installation using leinengen template

### Building

1. Create a new project named **caudal-example** from the **caudal-template**
```
$ lein new caudal-template caudal-example
Generating fresh 'lein new' caudal-template project.
```

2. Change current directory to the one recently created
```
$ cd caudal-example/
```

3. Transfer all required dependencies to **lib** directoy
```
$ lein libdir
Copied 143 file(s) to: /projects/caudal-example/lib
```

4. Build the new project **caudal-example**
```
$ lein jar
Warning: specified :main without including it in :aot.
Implicit AOT of :main will be removed in Leiningen 3.0.0.
If you only need AOT for your uberjar, consider adding :aot :all into your
:uberjar profile instead.
Compiling caudal-example.custom
Warning: The Main-Class specified does not exist within the jar. It may not be executable as expected. A gen-class directive may be missing in the namespace which contains the main method.
Created /projects/caudal-example/target/caudal-example-0.1.2-SNAPSHOT.jar
```

5. Copy de project jar into the **lib** directory
```
$ cp target/caudal-example-0.1.2-SNAPSHOT.jar lib/
```

### Running

1. Start Caudal project using the default configuration from the file **./config/caudal-config.clj**
```
$ ./bin/start-caudal.sh -c ./config/caudal-config.clj
Verifying JAVA instalation ...
/usr/bin/java
JAVA executable found in PATH
JAVA Version : 1.8.0_91
BIN path /projects/caudal-example/bin
Starting Caudal from /projects/caudal-example
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
SLF4J: Found binding in [jar:file:/projects/caudal-example/lib/logback-classic-1.1.3.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/projects/caudal-example/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [ch.qos.logback.classic.util.ContextSelectorStaticBinder]
15:15:08.327 [main] INFO  mx.interware.caudal.core.starter-dsl - {:loading-dsl {:file ./config/caudal-config.clj}}
15:15:09.711 [main] INFO  mx.interware.caudal.io.tcp-server - Starting server on port :  9900  ...
15:15:09.767 [main] INFO  mx.interware.caudal.io.tailer-server - Tailing files :  (/projects/caudal-example/./data/input.txt)  ...
15:15:09.775 [main] INFO  mx.interware.caudal.io.tailer-server - Channel created for file  input.txt  - > channel :  #object[clojure.core.async.impl.channels.ManyToManyChannel 0x8d7b252 clojure.core.async.impl.channels.ManyToManyChannel@8d7b252]
15:15:09.855 [main] INFO  mx.interware.caudal.io.tailer-server - register-channels for tailer
15:15:10.064 INFO  [org.quartz.core.QuartzScheduler] (main) Quartz Scheduler v.2.2.1 created.
15:15:10.068 INFO  [org.quartz.core.QuartzScheduler] (main) Scheduler meta-data: Quartz Scheduler (v2.2.1) 'SimpleQuartzScheduler:-1011881444' with instanceId 'SIMPLE_NON_CLUSTERED:-1011881444'
  Scheduler class: 'org.quartz.core.QuartzScheduler' - running locally.
  NOT STARTED.
  Currently in standby mode.
  Number of jobs executed: 0
  Using thread pool 'org.quartz.simpl.SimpleThreadPool' - with 5 threads.
  Using job-store 'org.quartz.simpl.RAMJobStore' - which does not support persistence. and is not clustered.

15:15:10.069 INFO  [org.quartz.core.QuartzScheduler] (main) Scheduler SimpleQuartzScheduler:-1011881444_$_SIMPLE_NON_CLUSTERED:-1011881444 started.
15:15:10.069 INFO  [org.projectodd.wunderboss.scheduling.Scheduling] (main) Quartz started
```


## Testing

1. Open another terminal and send a test event using the Caudal **tailer**, appending the message to **data/input.txt** file
```
$ echo "{:host \"server1\" :service \"http\" :customer \"orinoco\" :id 42 :cost 14.2857}" > data/input.txt
```

2. Verify the generated log for the tailed event
```
line :  {:host "server1" :service "http" :customer "orinoco" :id 42 :cost 14.2857}
{:event-1 {:host server1, :service http, :customer orinoco, :id 42, :cost 14.2857, :caudal/latency 713696}}
```

3. Send another event using the Caudal **tcp** channel running on port **9900**
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:host "server2" :service "ssl" :customer "amazonas" :id 101 :cost 28.5714}
```

4. Verify the generated log for the received event
```
15:19:19.832 INFO  [org.apache.mina.filter.logging.LoggingFilter] (NioProcessor-2) CREATED
15:19:19.832 INFO  [org.apache.mina.filter.logging.LoggingFilter] (NioProcessor-2) OPENED
15:19:21.109 INFO  [org.apache.mina.filter.logging.LoggingFilter] (NioProcessor-2) RECEIVED: HeapBuffer[pos=0 lim=77 cap=4096: 7B 3A 68 6F 73 74 20 22 73 65 72 76 65 72 32 22...]
{:event-1 {:host server2, :service ssl, :customer amazonas, :id 101, :cost 28.5714, :caudal/latency 268423}}
MAIN - Customer    : {:host "server2", :service "ssl", :customer "amazonas", :id 101, :cost 28.5714, :caudal/latency 555964, :path "A good one"}
MAIN - Adjusted *  : {:host "server2", :service "ssl", :customer "amazonas", :id 101, :cost 33.142824, :caudal/latency 555964, :path "A good one", :count 1}
MAIN - Adjusted +  : {:host "server2", :service "ssl", :customer "amazonas", :id 101, :cost 133.142824, :caudal/latency 555964, :path "A good one", :count 1}
MAIN - Timestamped : {:host "server2", :service "ssl", :customer "amazonas", :id 101, :cost 28.5714, :caudal/latency 555964, :path "A good one", :time 1485206361129}
```
