#!/bin/sh

# Set up default CATALINA_OPTS and JAVA_OPTS or all instances.
# To override these for a particular instance use setopts.sh in the instance's bin dir.

IP_ADDRESS=`/sbin/ifconfig eth0 | grep "inet addr" | awk '{ print $2 }' | awk 'BEGIN { FS=":" } { print $2 }'`

HOST_NAME=`hostname`

# Memory settings
export CATALINA_OPTS="-Xms4096m -Xmx4096m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:MaxNewSize=1024m -XX:NewSize=1024m -XX:+UseConcMarkSweepGC -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled -XX:CMSInitiatingOccupancyFraction=70 -XX:+UseCMSInitiatingOccupancyOnly -Dnet.sf.ehcache.use.classic.lru=true -XX:ThreadStackSize=512 $CATALINA_OPTS"

# JVM GC logrotate 
export CATALINA_OPTS="$CATALINA_OPTS -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=5M"

# HTTP proxy properties
export CATALINA_OPTS="-Dhttp.nonProxyHosts=*.sabre.com|10.208.*|10.200.*|10.136.132.48|localhost -Dhttp.proxyPort=80 -Dhttps.proxyPort=80 -Dhttp.proxyHost=outbound-proxy.cert.sabre.com -Dhttps.proxyHost=outbound-proxy.cert.sabre.com -Dhttp.proxyUser=sg0920208 -Dhttp.proxyPassword=abcd1234 -Dhttps.proxyUser=sg0920208 -Dhttps.proxyPassword=abcd1234 $CATALINA_OPTS"

# JMX properties
export CATALINA_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=$HOST_NAME $CATALINA_OPTS"

# JMX old port for B2/GF/S7/SN/UN and temporary SE/SSW
[[ $AIRLINE == "B2" || $AIRLINE == "GF" || $AIRLINE == "S7" || $AIRLINE == "SN" || $AIRLINE == "UN" ]] && export CATALINA_OPTS="-Dcom.sun.management.jmxremote.port=900$INST_NUM $CATALINA_OPTS"

# Tomcat properties
export CATALINA_OPTS="-Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true $CATALINA_OPTS"

# Logging properties
export CATALINA_OPTS="-Delogging.log4j=elogging/elogging.log4j.xml -Delogging.addSidToThreadName=true -Delogging.enabled=true -Delogging.port=801$INST_NUM -Dlog.directory.base=/nas/logs/int -Dbox.id=$HOST_NAME -Dlog4jConfigLocation=$CATALINA_BASE/conf/ -Dlog4j.defaultInitOverride=true $CATALINA_OPTS"

export CATALINA_OPTS="-XX:-OmitStackTraceInFastThrow $CATALINA_OPTS"

# Allow restricted HTTP headers to. It fixes hotels issue causing Bad Request error.
export CATALINA_OPTS="-Dsun.net.http.allowRestrictedHeaders=true $CATALINA_OPTS"

#fix for Jasper parse feature
export CATALINA_OPTS="$CATALINA_OPTS -Dorg.apache.el.parser.SKIP_IDENTIFIER_CHECK=true"

# JIRA: https://jira.sabre.com/browse/SSWOPS-2485 - v12: T1 -> F5 -> T2 w PROD : unexpected EOF
export CATALINA_OPTS="$CATALINA_OPTS -Dsun.net.http.retryPost=false"
