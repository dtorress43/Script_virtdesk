#!/bin/bash

greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Actualizar la lista de paquetes y actualizar el sistema

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Actualizando la lista de paquetes y actualizando el sistema . . .${endColour}\n"
sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

# Instalar nginx

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Instalando nginx . . .${endColour}\n"
sudo apt install nginx -y > /dev/null 2>&1

# Habilitar nginx para el arranque automático

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Habilitando nginx para el arranque automático . . .${endColour}\n"
sudo systemctl enable nginx > /dev/null 2>&1

# Instalar gnupg y curl

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Instalando gnupg y curl . . .${endColour}\n"
sudo apt-get install gnupg curl -y > /dev/null 2>&1

# Añadir la clave GPG de MongoDB

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Añadiendo la clave GPG de MongoDB . . .${endColour}\n"
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

# Añadir el repositorio de MongoDB 8.0

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Añadiendo el repositorio de MongoDB 8.0 . . .${endColour}\n"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list > /dev/null 2>&1

# Actualizar la lista de paquetes

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Actualizando la lista de paquetes . . .${endColour}\n"
sudo apt-get update > /dev/null 2>&1

# Instalar MongoDB

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Instalando MongoDB . . .${endColour}\n"
sudo apt-get install -y mongodb-org > /dev/null 2>&1

# Habilitar MongoDB para el arranque automático

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Habilitando MongoDB para el arranque automático . . .${endColour}\n"
sudo systemctl enable mongod > /dev/null 2>&1

sudo apt update > /dev/null 2>&1
sudo apt upgrade -y > /dev/null 2>&1

cd /var/www/html

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Instalando Composer . . .${endColour}\n"
sudo apt install composer -y > /dev/null 2>&1

sudo apt update > /dev/null 2>&1

echo -e "${purpleColour}[+]${endColour} ${yellowColour}Instalamos php8.3 con mongodb${endColour}\n"
sudo apt install php8.3-mongodb -y > /dev/null 2>&1

sudo apt install php8.3-fpm > /dev/null 2>&1

sudo apt install php-mongodb -y > /dev/null 2>&1

sudo systemctl start mongod > /dev/null 2>&1

COMPOSER_ALLOW_SUPERUSER=1 composer init --no-interaction --require="paquete/ejemplo:^1.0" > /dev/null 2>&1


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

git clone https://github.com/dtorress43/frontend_virtdesk

mv /var/www/html/frontend_virtdesk/* /var/www/html

rm -r /var/www/html/frontend_virtdesk

sudo systemctl restart nginx


echo "[+] Todos los comandos se han ejecutado correctamente."
