title: Documentación
---
Bienvenido a la documentación de Caudal. Si encuentras algún problema usando Caudal, hecha un vistazo a la [sección de Solución de Problemas](troubleshooting.html) o crea una incidencia en [GitHub](https://github.com/interwaremx/caudal/issues).

## ¿Qué es Caudal?
Caudal es una plataforma que analiza bitácoras de aplicación usando modelos predictivos en tiempo real con el fin de enriquecer la información para un monitoreo confiable y para sistemas de recomendaciones.

## ¿Que es un Evento?
Un evento es cualquier estructura de datos y es pasada como un Mapa Inmutable de Clojure.

## ¿Qué es el Estado?
Caudal usa un Estado de aplicación para guardar los datos necesarios para métricas y estadísticas. El Estado es global para todos los streamers y para la aplicación. Internamente, el Estado es un Agente Clojure, así que es concurrente. El Estado esta guardado en memoria, y es limpiado cada vez que el proceso de Caudal finaliza.

## ¿Qué es un Escucha?
Un escucha es un mecanismo para obtener eventos. Caudal viene con algunos Escuchas listos para usar.

## ¿Qué es un Streamer?
Los *Streamers* definen funciones que serán aplicadas a cada evento dentro del flujo de datos y pueden ser compuestas y combinadas para enriquecer el flujo de datos.

## Requerimientos
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)

## Instalando
Obtén los últimos archivos binarios de la distribución de Caudal en la [sección de Descargas](/downloads)
```txt
$ wget http://caudal.io/downloads/caudal-0.7.4-SNAPSHOT.tar.gz
$ tar xzvf caudal-0.7.4-SNAPSHOT.tar.gz
```

## Arrancando
Inicia el servidor de Caudal
```txt
cd caudal-0.7.4
$ bin/start-caudal.sh -c config/caudal-config.clj
```
