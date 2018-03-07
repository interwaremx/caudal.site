title: Installing Leiningen
---

## Linux RHEL 7 & CentOS 7
### Downloading Leiningen

Create a directory and download [Leiningen](https://leiningen.org):
```
$ mkdir -p /opt/lein/bin
$ cd /opt/lein/bin
$ wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
```

Add execute permissions to downloaded file:
```
$ chmod +x lein
```

Run `lein`, will download some dependencies, maybe take a few minutes:
```#bash
$ ./lein run
```

### Configuring Environment Variables
In order to run `lein` in our bash, CentOS and RHEL provides of `/etc/profile.d/` directory for customizing environment variables per application:
```#bash
# echo "export LEIN_HOME=/opt/lein/" >> /etc/profile.d/lein.sh
# echo "export LEIN=$LEIN_HOME/bin" >> /etc/profile.d/lein.sh
# echo "export PATH=\$PATH:\$LEIN" >> /etc/profile.d/lein.sh
# source /etc/profile.d/lein.sh
```

### Running lein
To probe `lein`, run in a new terminal:
```#bash
$ lein relp  
nREPL server started on port 35001 on host 127.0.0.1 - nrepl://127.0.0.1:35001
REPL-y 0.3.7, nREPL 0.2.12
Clojure 1.8.0
Java HotSpot(TM) 64-Bit Server VM 1.8.0_144-b01
    Docs: (doc function-name-here)
          (find-doc "part-of-name-here")
  Source: (source function-name-here)
 Javadoc: (javadoc java-object-or-class-here)
    Exit: Control+D or (exit) or (quit)
 Results: Stored in vars *1, *2, *3, an exception in *e

user=>
```
