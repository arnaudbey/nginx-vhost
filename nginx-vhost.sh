#!/bin/bash
addToConf() {
	FILE="/etc/nginx/sites-available/$VHOST.conf"
	for i in `seq 1 $1`;
    do
        echo -n '	' >> $FILE
    done  
	echo $2 >> $FILE
}  

echo "VHOST NAME:"
read -rp "> " VHOST

if [ -f "/etc/nginx/sites-available/$VHOST.conf" ]
then
	echo "déjà un avec ce nom"
	exit
fi

touch /etc/nginx/sites-available/$VHOST.conf
addToConf 0 "server {"
addToConf 1 "server_name $VHOST;"

echo "VHOST ROOT:"
read -rp "> " ROOT
addToConf 1 "root $ROOT;"

echo "IS THIS A SYMFONY2 RELATED VHOST ?  [y/n]:"
read -rp "> " SF2
if [ $SF2 = y ]; then
	addToConf 1 "location / {"
	addToConf 2 "try_files \$uri @rewriteapp;"
	addToConf 1 "}"
	addToConf 1 "location @rewriteapp {"
	addToConf 2 "rewrite ^(.*)$ /app.php/\$1 last;"
	addToConf 1 "}"
	addToConf 1 "location ~ ^/(app|app_dev|config)\.php(/|$) {"
	addToConf 2 "fastcgi_pass unix:/var/run/php5-fpm.sock;"
	addToConf 2 "fastcgi_split_path_info ^(.+\.php)(/.*)$;"
	addToConf 2 "include fastcgi_params;"
	addToConf 2 "fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;"
	addToConf 2 "fastcgi_param HTTPS off;"
	addToConf 1 "}"
fi

addToConf 0 "}"

echo "ENABLE IT ? [y/n]:"
read -rp "> " ACTIVATE
if [ $ACTIVATE = y ]; then
	echo "Création du lien symbolique..."
	ln -s /etc/nginx/sites-available/$VHOST.conf /etc/nginx/sites-enabled/$VHOST.conf
fi

echo "RELOAD NGINX ? [y/n]:"
read -rp "> " RELOAD
if [ $RELOAD = y ]; then
	echo "Reload Nginx"
	service nginx reload
fi

echo "ADD AN ENTRY IN /etc/hosts ? [y/n]:"
read -rp "> " HOSTS
if [ $HOSTS = y ]; then
	echo "add entry hosts file"
	echo "$VHOST $VHOST" >> /etc/hosts
fi