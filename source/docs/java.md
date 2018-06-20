title: Installing Java 8
---

## Linux RHEL 7 & CentOS 7

### Downloading Latest Java

 **Note:** *If your CentOS or RHEL is a fresh minimal installation, maybe you have to install wget utility using yum*

```#bash
# yum -y install wget
```

Download latest Java SE Development Kit 8 release from its official download page or use following commands to download from shell

```#bash
# cd /opt/
# wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz"
# tar xzfv jdk-8u172-linux-x64.tar.gz
```

 **Note:** *For production servers is highly recommended installing Java Server JRE. The Server JRE includes tools for JVM monitoring and tools commonly required for application servers, but does not include browser integration (the Java plug-in)*

```#bash
# cd /opt/
# wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/server-jre-8u172-linux-x64.tar.gz"
# tar xzfv server-jre-8u172-linux-x64.tar.gz
```

### Configuring Environment Variables

Most of Java based application’s uses environment variables to work. CentOS and RHEL provides of `/etc/profile.d/` directory for customizing environment variables per application

```#bash
# echo "export JAVA_HOME=/opt/jdk1.8.0_172/" >> /etc/profile.d/java.sh
# echo "export JRE_HOME=/opt/jdk1.8.0_172/jre/" >> /etc/profile.d/java.sh
# echo "export PATH=\$PATH:\$JAVA_HOME/bin/:\$JRE_HOME/bin/" >> /etc/profile.d/java.sh
# source /etc/profile.d/java.sh
```

### Install Java with Alternatives

After setting Environment Variables use Alternatives to install Java

```#bash
# alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
# alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 1
# alternatives --set java $JAVA_HOME/bin/java
# alternatives --set jar $JAVA_HOME/bin/jar
```

At this point *Java 8* has been successfully installed on your system.

 **Note:** *If you performed this installation in a Development Server, we also recommend to setup javac commands path using alternatives*

```#bash

# alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1
# alternatives --set javac $JAVA_HOME/bin/javac
```

## Linux Debian & Ubuntu
### Downloading Latest Java

 **Note:** *If your Ubuntu or Debian is a fresh minimal installation, maybe you have to install wget utility using apt-get*

```#bash
$ sudo apt-get install wget 
```

Download latest Java SE Development Kit 8 release from its official download page or use following commands to download from shell

```#bash
$ cd /opt/
$ sudo wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/jdk-8u172-linux-x64.tar.gz"
$ sudo tar xzfv jdk-8u172-linux-x64.tar.gz
```

 **Note:** *For production servers is highly recommended installing Java Server JRE. The Server JRE includes tools for JVM monitoring and tools commonly required for server applications, but does not include browser integration (the Java plug-in)*

```#bash
$ cd /opt/
$ sudo wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/server-jre-8u172-linux-x64.tar.gz"
$ sudo tar xzfv server-jre-8u172-linux-x64.tar.gz
```

### Configuring Environment Variables

Most of Java based application’s uses environment variables to work. CentOS provides of `/etc/profile.d/` directory for customizing environment variables per application

```#bash
$ sudo echo "export JAVA_HOME=/opt/jdk1.8.0_172/" >> /etc/profile.d/java.sh
$ sudo echo "export JRE_HOME=/opt/jdk1.8.0_172/jre/" >> /etc/profile.d/java.sh
$ sudo echo "export PATH=\$PATH:\$JAVA_HOME/bin/:\$JRE_HOME/bin/" >> /etc/profile.d/java.sh
$ source /etc/profile.d/java.sh
```

### Install Java with Alternatives

After setting Environment Variables use Alternatives to install Java

```#bash
$ sudo update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1
$ sudo update-alternatives --install /usr/bin/jar jar $JAVA_HOME/bin/jar 1
$ sudo update-alternatives --set java $JAVA_HOME/bin/java
$ sudo update-alternatives --set jar $JAVA_HOME/bin/jar
```

At this point *Java 8* has been successfully installed on your system.

 **Note:** *If you performed this installation in a Development Server,  we also recommend to setup javac and jar commands path using alternatives*

```#bash
$ sudo update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1
$ sudo update-alternatives --set javac $JAVA_HOME/bin/javac
```

## MacOS X

### Downloading Latest Java

 **Note:** *If your MacOS is a fresh installation, maybe you have to install wget utility*

Firstly, launch Terminal (found in Application/Utilities). Download latest Java SE Development Kit 8 release from its official download page or use following commands to download:


```#bash
$ cd ~/Downloads/
$ wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-macosx-x64.dmg"
```

Open downloaded file with:
```#bash
$ open jdk-8u161-macosx-x64.dmg
```

This command launch a window that contains a **pkg** file. Make double click and follow instructions

![](java-01.png)
