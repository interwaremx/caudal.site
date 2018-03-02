title: Setup
---

Installing Caudal is quite easy. However, you do need to have other thing installed first:

## Requirements
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)
 * [Leiningen](leiningen.html)

## Installation from binary distribution

There are several Caudal binary distributions. They are packaged in the form of compressed tar files.

### Obtaining

Get the binary file for the lastest Caudal distribution at [downloads](https://interwaremx.github.io/caudal.docs/downloads) section:
```
$ wget https://interwaremx.github.io/caudal.docs/downloads/caudal-0.7.14.tar.gz
```

### Unpacking

Unpack downloaded file, wich creates the installation directory:
```
$ tar xzvf caudal-0.7.14.tar.gz
```

### Running

1. Go to Caudal directory and start 
```
$ cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start
```

2. Open another terminal and send an event message through **tcp** channel running on port **9900** to make sure it can be accessed, try with this:
```
$ telnet localhost 9900
```

3. Now write `{:message "HelloWorld!"}` as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
```

4. Verify the generated log for the received event:
```
2018-01-01 21:19:52.822 INFO  [clojure-agent-send-pool-2] streams.stateless - {:message "HelloWorld!", :caudal/latency 3364529, :event-counter 1}
```

5. Write `{:foo :bar}` and close connection:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
{:foo :bar}
EOT
Connection closed by foreign host.
$
```

6. Verify the generated log for the received event:
```
2018-01-01 21:21:01.076 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :bar, :caudal/latency 644263, :event-counter 2}
```

7. To stop Caudal press `Ctrl-C`

## Installation from source

You can start a Caudal configuration from the [sources](https://github.com/interwaremx/caudal).

### Downloading

Use **git** to download latest version of Caudal:
```
$ git clone https://github.com/interwaremx/caudal
```

### Building

1. Use `make-distro.sh` script to compile and build project, maybe take a few minutes:
```
$ bin/make-distro.sh
```

2. Finally, script generates a directory `caudal-0.7.14/`
```
$ cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start
```

3. Open another terminal and send an event message through **tcp** channel running on port **9900** to make sure it can be accessed, try with this:
```
$ telnet localhost 9900
```

4. Now write `{:message "HelloWorld!"}` as follow:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
```

5. Verify the generated log for the received event:
```
2018-01-01 21:19:52.822 INFO  [clojure-agent-send-pool-2] streams.stateless - {:message "HelloWorld!", :caudal/latency 3364529, :event-counter 1}
```

6. Write `{:foo :bar}` and close connection:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:message "HelloWorld!"}
{:foo :bar}
EOT
Connection closed by foreign host.
$
```

7. Verify the generated log for the received event:
```
2018-01-01 21:21:01.076 INFO  [clojure-agent-send-pool-3] streams.stateless - {:foo :bar, :caudal/latency 644263, :event-counter 2}
```

8. To stop Caudal press `Ctrl-C`
