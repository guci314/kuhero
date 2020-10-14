#!/bin/sh

# configs
mkdir -p /etc/caddy/ /usr/share/caddy && wget $CADDYIndexPage -O /usr/share/caddy/index.html 
unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
[[ "$ROBOTS" == "true" ]] && wget -qO- $ROBOTSCONFIG >/usr/share/caddy/robots.txt
wget -qO- $CADDYCONFIG | sed -e "1c :$PORT" -e "s/\$SSPATH$/\\$SSPATH/" -e "s/\$GOSTPATH$/\\$GOSTPATH/" -e "s/\$BROOKPATH$/\\$BROOKPATH/" -e "s/\$VMESSPATH$/\\$VMESSPATH/" -e "s/\$VLESSPATH$/\\$VLESSPATH/" >/etc/caddy/Caddyfile
wget -qO- $V2RAYCONFIG | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$VMESSPATH/\\$VMESSPATH/" -e "s/\$VLESSPATH/\\$VLESSPATH/" >/v2ray.json

# start
[[ "$TOREnable"      ==    "true" ]]    &&    tor &

[[ "$V2RAYEnable"    ==    "true" ]]    &&    /v2ray -config /v2ray.json &

[[ "$BROOKEnable"    ==    "true" ]]    &&    brook wsserver -l 127.0.0.1:3234 --path $BROOKPATH -p $APASSWORD &

[[ "$GOSTEnable"     ==    "true" ]]    &&    eval gost $GOSTMETHOD &

[[ "$SSEnable"       ==    "true" ]]    &&    ss-server -s 127.0.0.1 -p 1234 -k $APASSWORD -m $SSENCYPT --plugin /usr/bin/v2ray-plugin_linux_amd64 --plugin-opts "server;path=$SSPATH" &

cd /gsnova &
tar -xjvf gsnova.tar.bz2 &
chmod +x gsnova & 
./gsnova -cmd -server -listen tcp://:48100 -listen wss://:48100 -listen quic://:48100 -listen tls://:48101 -listen kcp://:48101 -listen http://:48102 -listen http2://:48103 -key 809240d3a021449f6e67aa73221d42df942a308a -window 521k -window_refresh 32k -user "*" -log gsnova.log &
cd ..  &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
