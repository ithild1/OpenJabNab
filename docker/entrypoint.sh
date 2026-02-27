#!/bin/bash
set -e

OJN_DOMAIN=${OJN_DOMAIN:-localhost}
OJN_TTS=${OJN_TTS:-google}
OJN_LOG_LEVEL=${OJN_LOG_LEVEL:-Warning}

echo "[entrypoint] Generating openjabnab.ini for domain: ${OJN_DOMAIN}"

cat > /opt/openjabnab/bin/openjabnab.ini << EOF
[Config]
httpListener = true
httpApi = true
httpVioletApi = true
xmppListener = true
RealHttpRoot = /var/www/html/ojn_local/
HttpRoot = ojn_local
HttpPluginsFolder = plugins
StandAloneAuthBypass = false
AllowAnonymousRegistration = false
AllowUserManageBunny = false
AllowUserManageZtamp = false
SessionTimeout = 300
TTS = ${OJN_TTS}
MaxNumberOfBunnies = 64
MaxBurstNumberOfBunnies = 72

[OpenJabNabServers]
PingServer = ${OJN_DOMAIN}
BroadServer = ${OJN_DOMAIN}
XmppServer = ${OJN_DOMAIN}
ListeningHttpPort = 8080
ListeningXmppPort = 5222

[Log]
LogFile = openjabnab.log
LogFileLevel = Debug
LogScreenLevel = ${OJN_LOG_LEVEL}
DisplayCronLog = false
EOF

# Required by php-fpm to create its socket
mkdir -p /run/php

# Generate ojn_admin/include/common.php from template (replaces <HOSTNAME> and <EMAIL>)
sed "s/<HOSTNAME>/${OJN_DOMAIN}/g; s/<EMAIL>/admin@${OJN_DOMAIN}/g" \
    /var/www/html/ojn_admin/include/common-def.php \
    > /var/www/html/ojn_admin/include/common.php

# Ensure the ojn_local data directory exists and is writable by the web server
mkdir -p /var/www/html/ojn_local/bootcode
mkdir -p /var/www/html/ojn_local/plugins
mkdir -p /var/www/html/ojn_local/tts
chown -R www-data:www-data /var/www/html/ojn_local

exec "$@"
