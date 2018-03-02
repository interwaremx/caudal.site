title: Instalar Leiningen
---

## Linux RHEL 7 & CentOS 7
### Descargar Leiningen

Creamos un directorio y descargamos desde el sitio de [Leiningen](https://leiningen.org)
```#bash
$ mkdir -p /opt/lein/bin
$ cd /opt/lein/bin
$ wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
```

Agregar permisos de ejecución
```#bash
$ chmod +x lein
```

Ejecuta `lein`, descargará algunas dependencias, podría tomar algunos minutos:
```#bash
$ ./lein run
```
### Configurar Variables de Ambiente
Para ejecutar lein desde cualquier sitio se usan las variables de ambiente para trabajar. CentOS y RHEL proveen del directorio `/etc/profile.d/` para personalizar las variables de ambiente por aplicación:
```#bash
# echo "export LEIN_HOME=/opt/lein/" >> /etc/profile.d/lein.sh
# echo "export LEIN=$LEIN_HOME/bin" >> /etc/profile.d/lein.sh
# echo "export PATH=\$PATH:\$LEIN" >> /etc/profile.d/lein.sh
# source /etc/profile.d/lein.sh
```

### Ejecución de lein
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
