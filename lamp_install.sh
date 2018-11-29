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
sudo apt-get install -y mc htop apache2 php7.0 php7.0-fpm phpmyadmin mysql-client mysql-server && echo "Выполнено"
echo "Настройка Apache2"
sleep 1
service apache2 restart && echo "Выполнено"