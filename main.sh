#!/bin/bash

# Actualizar la lista de paquetes y actualizar el sistema
echo "Actualizando la lista de paquetes y actualizando el sistema..."
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
# Instalar nginx
echo "Instalando nginx..."
sudo apt install nginx -y > /dev/null 2>&1
# Habilitar nginx para el arranque automático
echo "Habilitando nginx para el arranque automático..."
sudo systemctl enable nginx > /dev/null 2>&1
# Instalar gnupg y curl
echo "Instalando gnupg y curl..."
sudo apt-get install gnupg curl -y > /dev/null 2>&1
# Añadir la clave GPG de MongoDB
echo "Añadiendo la clave GPG de MongoDB..."
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
# Añadir el repositorio de MongoDB 8.0
echo "Añadiendo el repositorio de MongoDB 8.0..."
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list > /dev/null 2>&1
# Actualizar la lista de paquetes
echo "Actualizando la lista de paquetes..."
sudo apt-get update > /dev/null 2>&1
# Instalar MongoDB
echo "Instalando MongoDB... "
sudo apt-get install -y mongodb-org > /dev/null 2>&1
# Habilitar MongoDB para el arranque automático
echo "Habilitando MongoDB para el arranque automático..."
sudo systemctl enable mongod > /dev/null 2>&1
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1
cd /var/www/html
echo "Instalando Composer..."
sudo apt install composer -y > /dev/null 2>&1
sudo apt update > /dev/null 2>&1
echo "Instalamos php8.3 con mongodb"
sudo apt install php8.3-mongodb -y > /dev/null 2>&1
sudo apt install php8.3-fpm > /dev/null 2>&1
sudo apt install php-mongodb -y > /dev/null 2>&1
sudo systemctl start mongod > /dev/null 2>&1
COMPOSER_ALLOW_SUPERUSER=1 composer init --no-interaction --require="paquete/ejemplo:^1.0"
# Define la nueva configuración para Nginx
CONFIG="server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name _;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }
    location ~ /\\.ht {
        deny all;
    }
}"
# Modifica el archivo de configuración de Nginx
echo "$CONFIG" > /etc/nginx/sites-available/default
# Reinicia Nginx para aplicar los cambios
systemctl restart nginx
echo "La configuración de Nginx ha sido actualizada."
cd /var/www/html
COMPOSER_ALLOW_SUPERUSER=1 composer require mongodb/mongodb --no-interaction
git clone https://github.com/dtorress43/frontend_virtdesk > /dev/null 2>&1
mv /var/www/html/frontend_virtdesk/* /var/www/html
rm -r /var/www/html/frontend_virtdesk
sudo systemctl restart nginx
echo "[+] Todos los comandos se han ejecutado correctamente."
