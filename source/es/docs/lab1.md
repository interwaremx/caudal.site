title: Lab 1 - Listeners (Escuchas)
---

Los Listeners toman una fuente de datos y alimentan nuestro Caudal.

## Requerimientos
 * [Instalación](setup.html)
 * [Configuración](configuration.html)

## Configuration
Caudal define una macro llamada `deflistener` para declarar un nuevo listener, recibe como parametro un vector con un mapa que contiene `:type` y `:parameters`

```clojure
;; macro     ;; var-name  ;; listener-type
(deflistener foo-listener [{:type 'mx.interware.caudal.io.listener 
                            :parameters {:param1 "a"       ;; Ad-hoc params
                                         :param2 "b" ...}}])
```

| Elemento      | Descripción   |
| ------------- | ------------- |
| foo-listener  | Nombre del listener. Un archivo de configuración puede tener un o mas listeners. 1
| :type         | Simbolo que apunta a una implementacion de listener valida. Véase `mx.interware.caudal.io` en la sección [API](.../api). |
| :parameters   | Mapa con los parametros acorde con el uso del listener. |


### TCP
En [Configuración](configuration.html) usamos la macro `deflistener` para definir un canal TCP en el puerto 9900:

```clojure
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server
                   :parameters {:port        9900 
                                :idle-period 60}}])
```

| Parametro     | Descripción   |
| ------------- | ------------- |
| :port         | Numero de puerto (1-65535) para escuchar eventos. Los eventos entrantes son recibidos en formato [EDN] (https://learnxinyminutes.com/docs/edn/) .|
| :idle-period  | Idle period for socket. |

### Configuración

Escribe la siguiente configuración en el directorio `config/`:

```clojure config/example-tcp.clj
;; Requires
(ns caudal.example.tcp
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tcp [{:type 'mx.interware.caudal.io.tcp-server
                   :parameters {:port 9900
                                :idle-period 60}}])
;; Sinks
(defsink example 1 ;; backpressure
  (->INFO [:all]))

;; Wire
(wire [tcp] [example])
```

Inicia Caudal pasando el archivo creado como config:
```
$ bin/caudal  -c config/example-tcp.clj start
```

Abre un telenet to `localhost` al puerto `9900`:
```
$ telnet localhost 9900
```

y escribe un mapa EDN como se muestra:
```
$ telnet localhost 9900
Trying ::1...
Connected to localhost.
Escape character is '^]'.
{:foo 1}
```

Verifica el log generado para el nuevo evento entrante:
```
2018-01-02 22:55:15.295 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 2546987}
```

### Tailer

Lee una linea entrante desde un archivo, similar al comando `tail`.
```clojure
(deflistener tailer [{:type 'mx.interware.caudal.io.tailer-server
                      :parameters {:parser       read-string 
                                   :inputs       {:directory "." 
                                                  :wildcard "*.log"}
                                   :delta        200
                                   :from-end     true
                                   :reopen       true
                                   :buffer-size  1024}}])
```

| Parameter     | Description   |
| ------------- | ------------- |
| :parser       | Función que recibe una nueva linea y regresa un EDN. `read-string` es util si tu log esta escrito en EDN. |
| :inputs       | Mapa con `:directory` ruta de los archivos y `:wildcard` archivos a filtrar desde la cola .|
| :delta        | Tiempo de actualización de archivo en milisegundos. |
| :from-end     | Boolean, si es true ignora las entradas previas y solo lee las nuevas modificaciones, false para leer el archivo completo. |
| :reopen       | Boolean, si es true abre los archivos si no existen, false se pierde el archivo. |
| :buffer-size  | Número indicando los bytes a leer cada delta tiempo. |

### Configuración

Escribe la siguiente configuracion en el directorio `config/`:
```clojure config/example-tailer.clj
;; Requires
(ns caudal.example.tcp
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener tailer [{:type 'mx.interware.caudal.io.tailer-server
                      :parameters {:parser read-string
                                   :inputs  {:directory "."
                                             :wildcard  "my-edn.log"}
                                   :delta        200
                                   :from-end     true
                                   :reopen       true
                                   :buffer-size  1024}}])
;; Sinks
(defsink example 1 ;; backpressure
  (->INFO [:all]))

;; Wire
(wire [tailer] [example])
```

Inicia Caudal pasando el archivo creado como config:
```
$ bin/caudal -c config/example-tailer.clj start
```

En el directorio de Caudal, escribe un nuevo archivo `me-edn.log` con un simple EDN usando el siguiente comando:
```
$ bin/caudal -c config/example-tailer.clj start
```

Verifica el log generado para el nuevo evento:
```
2018-01-02 23:38:11.091 INFO  [main] io.tailer-server - {:tailing-files ()}
2018-01-02 23:38:11.093 WARN  [main] io.tailer-server - {:files-not-found {:directory ".", :wildcard "my-edn.log"}}
2018-01-02 23:38:21.199 INFO  [async-dispatch-2] io.tailer-server - {:added-files-to-tailer ("/opt/caudal-0.7.14/./my-edn.log")}
2018-01-02 23:38:21.205 INFO  [clojure-agent-send-pool-1] streams.stateless - {:foo 1, :caudal/latency 1741426}
```

### Syslog
Captura el log de salida usando el protocolo Syslog.
```clojure
(deflistener syslog [{:type 'mx.interware.caudal.io.syslog-server
                      :parameters {:port 1111
                                   :parser message-parser-fn}}])
```
| Paramereo     | Descripcion   |
| ------------- | ------------- |
| :port         | Numero del puerto (1-65535) para escuchar los eventos. Los eventos de entrada son recibidos con el protocolo Syslog |
| :parser       | Función que recibe el mensaje del evento de Syslog y returna un EDN |

### Log4j
Captura el log de slida usando el framework Log4j.
```clojure
(deflistener log4j [{:type 'mx.interware.caudal.io.log4j-server
                     :parameters {:port   2222
                                  :parser message-parser-fn}}])

```
| Parametro     | Descripción   |
| ------------- | ------------- |
| :port         | Número del puerto (1-65535) para escuchar eventos. Eventos de entrada son recibidos en el protocolo Log4j |
| :parser       | Funcion que recibe el mensaje del evento de Log4j y returna un EDN. |

### Telegram
Captura mensajes desde Telegram.

```clojure
(deflistener telegram [{:type 'mx.interware.caudal.io.telegram
                        :parameters {:token "BOT-TOKEN"
                                     :parser text-parser-fn}}])

```
| Parameter     | Description   |
| ------------- | ------------- |
| :token        | Cadena Bot Token despachada mediante el @BotFather de Telegram.|
| :parser       | Función opcional que recibe el texto escrito en el chat y devuelve un EDN. |

### Twitter
Lee tweets desde la Twitter API.
```clojure
(deflistener twitter [{:type       'mx.interware.caudal.io.twitter
                       :parameters {:name            "Caudal"
                                    :consumer-key    "key----------------------"
                                    :consumer-secret "consumer-secret-----------------------------------"
                                    :token           "token---------------------------------------------"
                                    :token-secret    "token-secret---------------------------------"
                                    :terms           ["challenge"]}}])
```
| Parametro        | Descripción   |
| ---------------- | ------------- |
| :name            | String, representa el nombre de nuestra aplicación. Esta aplicación debe estar registrada en Twitter |
| :consumer-key    | String, proporcionado por Twitter |
| :consumer-secret | String, proporcionado por Twitter |
| :token           | String, proporcionado por Twitter |
| :token-secret    | String, proporcionado por Twitter |
| :terms           | Vector, palabra clave para buscar un tweet |

### Configuración

Para obtener los keys y secrets de la API de Twitter, es necesario iniciar sesión con tu cuenta de Twitter.

Ve a la pagina [Application Manager](https://apps.twitter.com/) y da click en el botón `Create New App`.

![Create New APP](twitter-01.jpg)

Llena los datos requeridos nombre, descripción y website. Callback URL no es necesario. Recuerda de leer y aceptar los terminos y condiciones de Twitter antes de dar click en el botón `Create your Twitter application`.

![Create your Twitter application](twitter-02.jpg)

Si tu aplicación es creada correctamente, veras la siguiente pantalla:

![MyCaudalExample APP](twitter-03.jpg)

Ve a la sección `Keys and Access Token` para obtener tu `Consumer Key` y `Consumer Secret`. Da click en el botón `Create my acces token` para obtener tu `Token` y `Token Secret Pair`.

![Keys and Secrets](twitter-04.jpg)

Escribe la siguiente configuración en el directorio `config/`

```clojure config/example-twitter.clj
;; Requires
(ns caudal.example.tcp
  (:require
   [mx.interware.caudal.io.rest-server :refer :all]
   [mx.interware.caudal.streams.common :refer :all]
   [mx.interware.caudal.streams.stateful :refer :all]
   [mx.interware.caudal.streams.stateless :refer :all]))

;; Listeners
(deflistener twitter [{:type       'mx.interware.caudal.io.twitter
                       :parameters {:name            "MyCaudalExample"
                                    :consumer-key    "CoNsuMerKey"
                                    :consumer-secret "CoNsUmErSeCrEt"
                                    :token           "00000000-AcCeSsToKeN"
                                    :token-secret    "AcCeSsToKeNsEcReT"
                                    :terms           ["WorldCup"]}}])

;; Sinks
(defsink example 1 ;; backpressure
  (->INFO [:all]))

;; Wire
(wire [twitter] [example])
```

Inicia Caudal pasando el archivo creado como config:

```
$ bin/caudal -c config/example-twitter.clj start
```

Verifica el log generado para los eventos entrantes.
```
2018-03-03 01:23:15.241 INFO  [main] httpclient.BasicClient - New connection executed: MyCaudalExample, endpoint: /1.1/statuses/filter.json?delimited=length&stall_warnings=true
2018-03-03 01:23:15.396 INFO  [hosebird-client-io-thread-0] httpclient.ClientBase - MyCaudalExample Establishing a connection
log4j:WARN No appenders could be found for logger (org.apache.http.impl.conn.PoolingClientConnectionManager).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
2018-03-03 01:23:48.358 INFO  [hosebird-client-io-thread-0] httpclient.ClientBase - MyCaudalExample Processing connection data
2018-03-03 01:24:36.655 INFO  [clojure-agent-send-pool-1] streams.stateless - {:quote_count 0, :in_reply_to_screen_name nil, :is_quote_status false, :coordinates nil, :filter_level "low", :in_reply_to_status_id_str nil, :place nil, :timestamp_ms "1520061876356", :geo nil, :in_reply_to_status_id nil, :entities {:hashtags [{:text "WorldCup", :indices [18 27]}], :urls [], :user_mentions [{:screen_name "History_Newz", :name "History Newz", :id 881454090244501504, :id_str "881454090244501504", :indices [3 16]}], :symbols []}, :retweeted_status {:quote_count 0, :in_reply_to_screen_name nil, :is_quote_status false, :coordinates nil, :filter_level "low", :in_reply_to_status_id_str nil, :place nil, :possibly_sensitive false, :geo nil, :in_reply_to_status_id nil, :extended_tweet {:full_text "#WorldCup Countdown: 16 Weeks to Go - The Magical Magyars, the Best Team Never to Win the World Cup? https://t.co/gJQLuKnOZD https://t.co/UmBXRCQbjd", :display_text_range [0 124], :entities {:hashtags [{:text "WorldCup", :indices [0 9]}], :urls [{:url "https://t.co/gJQLuKnOZD", :expanded_url "https://goo.gl/3iahJG", :display_url "goo.gl/3iahJG", :indices [101 124]}], :user_mentions [], :symbols [], :media [{:sizes {:large {:w 660, :h 345, :resize "fit"}, :thumb {:w 150, :h 150, :resize "crop"}, :medium {:w 660, :h 345, :resize "fit"}, :small {:w 660, :h 345, :resize "fit"}}, :media_url_https "https://pbs.twimg.com/media/DXUkikZWsAA9q7w.jpg", :type "photo", :media_url "http://pbs.twimg.com/media/DXUkikZWsAA9q7w.jpg", :id 969721471072382976, :expanded_url "https://twitter.com/History_Newz/status/969721473437970433/photo/1", :url "https://t.co/UmBXRCQbjd", :display_url "pic.twitter.com/UmBXRCQbjd", :indices [125 148], :id_str "969721471072382976"}]}, :extended_entities {:media [{:sizes {:large {:w 660, :h 345, :resize "fit"}, :thumb {:w 150, :h 150, :resize "crop"}, :medium {:w 660, :h 345, :resize "fit"}, :small {:w 660, :h 345, :resize "fit"}}, :media_url_https "https://pbs.twimg.com/media/DXUkikZWsAA9q7w.jpg", :type "photo", :media_url "http://pbs.twimg.com/media/DXUkikZWsAA9q7w.jpg", :id 969721471072382976, :expanded_url "https://twitter.com/History_Newz/status/969721473437970433/photo/1", :url "https://t.co/UmBXRCQbjd", :display_url "pic.twitter.com/UmBXRCQbjd", :indices [125 148], :id_str "969721471072382976"}]}}, :entities {:hashtags [{:text "WorldCup", :indices [0 9]}], :urls [{:url "https://t.co/PX1cYSCN8h", :expanded_url "https://twitter.com/i/web/status/969721473437970433", :display_url "twitter.com/i/web/status/9…", :indices [102 125]}], :user_mentions [], :symbols []}, :source "<a href=\"http://twittamp.dev2.hu/\" rel=\"nofollow\">TwittAMP</a>", :lang "en", :in_reply_to_user_id_str nil, :id 969721473437970433, :contributors nil, :display_text_range [0 140], :truncated true, :retweeted false, :in_reply_to_user_id nil, :id_str "969721473437970433", :favorited false, :user {:description "The latest news of interest about #history #ancient in one place!", :profile_link_color "ABB8C2", :profile_sidebar_border_color "000000", :profile_image_url "http://pbs.twimg.com/profile_images/881525990123610112/3oJls2gK_normal.jpg", :profile_use_background_image false, :default_profile false, :profile_background_image_url "http://abs.twimg.com/images/themes/theme1/bg.png", :is_translator false, :profile_text_color "000000", :profile_banner_url "https://pbs.twimg.com/profile_banners/881454090244501504/1498999477", :name "History Newz", :profile_background_image_url_https "https://abs.twimg.com/images/themes/theme1/bg.png", :favourites_count 32, :screen_name "History_Newz", :listed_count 171, :profile_image_url_https "https://pbs.twimg.com/profile_images/881525990123610112/3oJls2gK_normal.jpg", :statuses_count 2225, :contributors_enabled false, :following nil, :lang "en", :utc_offset nil, :notifications nil, :default_profile_image false, :profile_background_color "000000", :id 881454090244501504, :follow_request_sent nil, :url nil, :translator_type "none", :time_zone nil, :profile_sidebar_fill_color "000000", :protected false, :profile_background_tile false, :id_str "881454090244501504", :geo_enabled false, :location "Global", :followers_count 36162, :friends_count 1999, :verified false, :created_at "Sun Jul 02 10:06:46 +0000 2017"}, :reply_count 0, :retweet_count 1, :favorite_count 0, :created_at "Fri Mar 02 23:49:50 +0000 2018", :text "#WorldCup Countdown: 16 Weeks to Go - The Magical Magyars, the Best Team Never to Win the World Cup?… https://t.co/PX1cYSCN8h"}, :source "<a href=\"http://twitter.com/download/android\" rel=\"nofollow\">Twitter for Android</a>", :lang "en", :in_reply_to_user_id_str nil, :id 969835918705045504, :contributors nil, :truncated false, :retweeted false, :in_reply_to_user_id nil, :id_str "969835918705045504", :favorited false, :user {:description "✍🎨💕", :profile_link_color "1DA1F2", :profile_sidebar_border_color "C0DEED", :profile_image_url "http://pbs.twimg.com/profile_images/894032388166098945/f-_miJBo_normal.jpg", :profile_use_background_image true, :default_profile true, :profile_background_image_url "", :is_translator false, :profile_text_color "333333", :profile_banner_url "https://pbs.twimg.com/profile_banners/874473957285650432/1507700544", :name "AYAN 🖤NEOGI🖤🖤", :profile_background_image_url_https "", :favourites_count 6906, :screen_name "AyanNeog001", :listed_count 1, :profile_image_url_https "https://pbs.twimg.com/profile_images/894032388166098945/f-_miJBo_normal.jpg", :statuses_count 11182, :contributors_enabled false, :following nil, :lang "en", :utc_offset nil, :notifications nil, :default_profile_image false, :profile_background_color "F5F8FA", :id 874473957285650432, :follow_request_sent nil, :url nil, :translator_type "none", :time_zone nil, :profile_sidebar_fill_color "DDEEF6", :protected false, :profile_background_tile false, :id_str "874473957285650432", :geo_enabled true, :location "🌐", :followers_count 332, :friends_count 1020, :verified false, :created_at "Tue Jun 13 03:50:13 +0000 2017"}, :reply_count 0, :caudal/latency 1941968, :retweet_count 0, :favorite_count 0, :created_at "Sat Mar 03 07:24:36 +0000 2018", :text "RT @History_Newz: #WorldCup Countdown: 16 Weeks to Go - The Magical Magyars, the Best Team Never to Win the World Cup? https://t.co/gJQLuKn…"}
```

Caudal recibe todos los tweets con la palabra clave `WorldCup` in EDN format, para información especifica acerca de los campos y la información recibida, echa un vistazo a [Twitter API documentation] (https://developer.twitter.com/en/docs/tweets/filter-realtime/overview).
