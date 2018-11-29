# /bin/sh
	echo "
	Добро пожаловать в автоматический установщик LAMP-сервера
	Далее будет произведена установка сервера
	"
sleep 1
sudo apt-get -y update
#sudo apt-get -y upgrade
echo "Установка компонентов LAMP-сервера"
sleep 1
sudo apt-get install -y mc htop apache2 php7.0 php7.0-fpm phpmyadmin mysql-client-5.7 mysql-server && echo "Выполнено"
echo "Настройка Apache2"
sleep 1
a2dismod npm_event
a2enmod mpm_worker
a2enmod proxy_fcgi
service apache2 restart && echo "Выполнено"
rm /var/www/html/index.html