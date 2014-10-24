#!/bin/sh

# This file is used to override any default CATALINA_OPTS or JAVA_OPTS settings.
# Generally you should only use CATALINA_OPTS.
# Append settings in this file to the end of the CATALINA_OPTS variable, eg:
#
#   export CATALINA_OPTS="$CATALINA_OPTS -Dmynewsetting=1"
#
# This will ensure they override any existing settings.

#export CATALINA_OPTS="$CATALINA_OPTS -Xmx4096m -Xms4096m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:+CMSPermGenSweepingEnabled -XX:+CMSClassUnloadingEnabled"
export CATALINA_OPTS="$CATALINA_OPTS -Doracle.jdbc.maxCachedBufferSize=20 -Djavax.net.debug=all"

