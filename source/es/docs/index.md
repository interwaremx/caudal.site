title: Documentación
---
Bienvenido a la documentación de Caudal. Si encuentras algún problema usando Caudal, hecha un vistazo a la [sección de Solución de Problemas](troubleshooting.html) o crea una incidencia en [GitHub](https://github.com/interwaremx/caudal/issues).

## ¿Qué es Caudal?
Caudal es una plataforma que analiza bitácoras de aplicación usando modelos predictivos en tiempo real con el fin de enriquecer la información para un monitoreo confiable.

![Caudal Basic Diagram](../../docs/diagram-basic.svg)

## ¿Que es un Evento?
Un evento es cualquier estructura de datos y es pasada como un Mapa Inmutable de Clojure. Los eventos son registrados en un Estado y son provistos por Listeners.

## ¿Qué es un _Listener_ ?
Un _Listener_ es un mecanismo para poner información dentro de Caudal. Cualquier cosa puede ser una fuente de eventos: bitácoras de aplicaciones, un chat o Twitter. Caudal viene con varios _Listeners_ listos para usar.

## ¿Qué es son los _Streamers_ ?
Los _Streamers_ son funciones que serán aplicadas a cada evento dentro del flujo de datos y pueden ser compuestas y combinadas para enriquecer el flujo de datos.

## ¿Qué es el Estado?
Caudal usa un Estado de aplicación para guardar los datos necesarios para métricas y estadísticas. El Estado es global para todos los streamers y para la aplicación. Internamente, el Estado es un Agente Clojure, así que es concurrente. El Estado esta guardado en memoria, y es limpiado cada vez que el proceso de Caudal finaliza.

## Requerimientos
 * [Java 1.8 (OpenJDK or OracleJDK)](java.html)

## Instalando
Obtén los últimos archivos binarios de la distribución de Caudal en la [sección de Descargas](downloads.html)
```
$ wget https://interwaremx.github.io/caudal.docs/downloads/caudal-0.7.14.tar.gz
$ tar xzvf caudal-0.7.14.tar.gz
```

## Arrancando
Inicia el servidor de Caudal
```
cd caudal-0.7.14/
$ bin/caudal -c config/caudal-config.clj start

```
