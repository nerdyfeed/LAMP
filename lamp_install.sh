# /bin/sh
clear
	echo "
	Добро пожаловать в автоматический установщик LAMP-сервера
	Далее будет произведена установка сервера
	"
read -p "Введите имя сайта: " siteName
sleep 1
sudo apt-get -y update
#sudo apt-get -y upgrade
echo "Установка компонентов LAMP-сервера"
sleep 1
sudo apt-get install -y mc htop apache2 libapache2-mod-fastcgi php7.0 php7.0-fpm phpmyadmin mysql-client mysql-server && echo "Выполнено"
echo "Настройка Apache2"
sleep 1
a2dismod mpm_event
a2enmod mpm_worker
a2enmod proxy_fcgi
service apache2 restart && echo "Выполнено"
cd /etc/apache2/sites-available/
cp 000-default.conf $siteName.conf
echo "<VirtualHost *:80> \n ServerName $siteName \n ServerAlias www.$siteName \n ServerAdmin webmaster@$siteName \n DocumentRoot /var/www/$siteName/public_html \n ErrorLog ${APACHE_LOG_DIR}/error-$siteName.log \n CustomLog ${APACHE_LOG_DIR}/access-$siteName.log combined \n ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php/php7.0-fpm.sock|fcgi://localhost/var/www/$siteName/public_html \n <IfModule mod_header.c> \n Header always append X-Frame-Options SAMEORIGIN \n Header set X-Content-Type-Options nosniff \n Header set X-XSS-Protection "1; mode-block" \n </iFmodule> \n <Directory /var/www/$siteName/public_html> \n AllowOverride none \n Options +Indexes +ExecCGI \n Order deny,allow \n Allow from all \n </Directory> \n </VirtualHost>" > /etc/apache2/$siteName
mkdir /var/www/$siteName
mkdir /var/www/$siteName/public_html
touch /var/www/$siteName/public_html/index.html
a2ensite $siteName.conf
service apache2 restart
ln -s /usr/share/phpmyadmin /var/www/$siteName/public_html/phpmyadmin
a2dissite 000-default.conf
service apache2 restart && echo "Выполнено"
echo "Установка пройдена успешно!
--------------------------------------------------
Ссылка на сайт: http://$siteName
Ссылка на phpmyadmin: http://$siteName/phpmyadmin
Директория: /var/www/$siteName/public_html/
--------------------------------------------------"