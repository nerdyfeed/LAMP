# /bin/sh
function FirstStart {
	echo "
	Добро пожаловать в автоматический установщик LAMP-сервера
	Далее будет произведена установка сервера
	"
sleep 1
sudo apt-get -y update
#sudo apt-get -y upgrade
echo "Установка компонентов LAMP-сервера"
sleep 1
sudo apt-get install mc htop apache2 libapache2-mod-fastcgi php7.0 php7.0-fpm phpmyadmin mysql-client-5.7 mysql-server && echo "Выполнено"
echo "Настройка Apache2"
sleep 1
a2dismod npm_event
a2enmod mpm_worker
a2enmod proxy_fcgi
service apache2 restart && echo "Выполнено"
rm /var/www/html/index.html
}

function Setup {
	if [ -f /apache2/]
}
echo Начинаю установку LAMP-сервера.
sleep 1
echo Подготовка системы к установке.
sleep 1