# /bin/sh
function MenuResume() {
	clear
	echo "Добро пожаловать в установщик LAMP"
	echo "Репозиторий скрипта доступен здесь: https://github.com/nerdyfeed/LAMP"
	echo ""
	echo "Похоже, у вас уже установлен LAMP"
	echo ""
	echo "Что хотите сделать?"
	echo "   1) Установка"
	echo "   2) Добавить сайт"
	echo "   3) Удалить сайт"
	echo "   4) Выход"

until [[ "$MENU_OPTION" =~ ^[1-4]$ ]]; do
	read -rp "Выбор [1-4]: " MENU_OPTION
done

case $MENU_OPTION in
	1)
		FirstSetup
	;;
	2)
		addSite
	;;
	3)
		removeSite
	;;
	4)
		exit 0
	;;
esac

}

function FirstSetup() {

clear
VERSION=`lsb_release -r -s`
INSTALLPACK="mc htop apache2 libapache2-mod-fastcgi php7.0 php7.0-fpm phpmyadmin mysql-client mysql-server"
if [[ $VERSION == "16.04" ]];
then
	echo "
	Добро пожаловать в автоматический установщик LAMP-сервера
	Далее будет произведена установка сервера
	"
read -p "Введите имя сайта: " siteName
sudo apt-get -y update
#sudo apt-get -y upgrade
echo "Установка компонентов LAMP-сервера"
dpkg --add-architecture i386
export DEBIAN_FRONTEND=noninteractive;apt-get --allow-unauthenticated -y -q install $INSTALLPACK && echo "Выполнено"
dlinapass=10
rootmysqlpass=`base64 -w 10 /dev/urandom | head -n 1`
adminmysqlpass=`base64 -w 10 /dev/urandom | head -n 1`
echo "Настройка MYSQL"
# Adding new user to mysql
mysqladmin -uroot password $rootmysqlpass
echo "CREATE USER 'admin'@'%' IDENTIFIED BY '$adminmysqlpass';" | mysql -uroot -p$rootmysqlpass
echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;" | mysql -uroot -p$rootmysqlpass
echo "FLUSH PRIVILEGES;" | mysql -uroot -p$rootmysqlpass
# Activating remote access
sed -i 's/#bind-address/bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "Настройка Apache2"
a2enmod rewrite
a2dismod mpm_event
a2enmod mpm_worker
a2enmod proxy_fcgi
service apache2 restart && echo "Выполнено"
cd /etc/apache2/sites-available/
cp 000-default.conf $siteName.conf
echo -e "<VirtualHost *:80> \n ServerName $siteName \n ServerAlias www.$siteName \n ServerAdmin admin@$siteName \n DocumentRoot /var/www/$siteName/public_html \n ErrorLog ${APACHE_LOG_DIR}/error-$siteName.log \n CustomLog ${APACHE_LOG_DIR}/access-$siteName.log combined \n ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php/php7.0-fpm.sock|fcgi://localhost/var/www/$siteName/public_html \n <IfModule mod_header.c> \n Header always append X-Frame-Options SAMEORIGIN \n Header set X-Content-Type-Options nosniff \n Header set X-XSS-Protection ""1; mode-block"" \n </iFmodule> \n <Directory /var/www/$siteName/public_html> \n AllowOverride none \n Options +Indexes +ExecCGI \n Order deny,allow \n Allow from all \n </Directory> \n</VirtualHost>" > /etc/apache2/sites-available/$siteName.conf
mkdir /var/www/$siteName
mkdir /var/www/$siteName/public_html
touch /var/www/$siteName/public_html/index.html
ln -s /usr/share/phpmyadmin /var/www/$siteName/public_html/phpmyadmin
a2ensite $siteName.conf
service apache2 restart
# Disabling default config
a2dissite 000-default.conf
service apache2 restart && echo "Выполнено"
echo "
Установка пройдена успешно!
--------------------------------------------------
Ссылка на сайт: http://$siteName
Ссылка на phpmyadmin: http://$siteName/phpmyadmin
Логин phpmyadmin: root
Пароль phpmyadmin (root): $rootmysqlpass
-
Логин phpmyadmin: admin
Пароль phpmyadmin (admin): $adminmysqlpass
Директория: /var/www/$siteName/public_html/
--------------------------------------------------
"
else
	echo "
	Данный скрипт может быть установлен только на Ubuntu 16.04 , версия этого сервера: $VERSION
	"
fi

}

function addSite() {
read -p "Введите имя сайта: " siteName
cd /etc/apache2/sites-available/
cp 000-default.conf $siteName.conf
echo -e "<VirtualHost *:80> \n ServerName $siteName \n ServerAlias www.$siteName \n ServerAdmin admin@$siteName \n DocumentRoot /var/www/$siteName/public_html \n ErrorLog ${APACHE_LOG_DIR}/error-$siteName.log \n CustomLog ${APACHE_LOG_DIR}/access-$siteName.log combined \n ProxyPassMatch ^/(.*\.php(/.*)?)$ unix:/run/php/php7.0-fpm.sock|fcgi://localhost/var/www/$siteName/public_html \n <IfModule mod_header.c> \n Header always append X-Frame-Options SAMEORIGIN \n Header set X-Content-Type-Options nosniff \n Header set X-XSS-Protection ""1; mode-block"" \n </iFmodule> \n <Directory /var/www/$siteName/public_html> \n AllowOverride none \n Options +Indexes +ExecCGI \n Order deny,allow \n Allow from all \n </Directory> \n</VirtualHost>" > /etc/apache2/sites-available/$siteName.conf
mkdir /var/www/$siteName
mkdir /var/www/$siteName/public_html
touch /var/www/$siteName/public_html/index.html
echo -e "<!DOCTYPE html>\n <html> \n <head> \n <title>LAMP Server Installed!</title> \n <link rel=\"shortcut icon\" href=\"http://apache.org/favicons/favicon.ico\"> \n </head> \n <body> \n <h1>LAMP Installed!</h1> \n <p>Enjoy!</p> \n </body> \n </html>" > /var/www/$siteName/public_html/index.html
ln -s /usr/share/phpmyadmin /var/www/$siteName/public_html/phpmyadmin
a2ensite $siteName.conf
service apache2 restart
clear
echo "
Выполнено! Сайт $siteName добавлен.
--------------------------------------------------
Ссылка на сайт: http://$siteName
Ссылка на phpmyadmin: http://$siteName/phpmyadmin
--------------------------------------------------
"
}

function removeSite() {
ACTIVED=`a2query -s`
echo -e "Активные сайты: \n$ACTIVED"
read -p "Введите имя сайта: " delsite
a2dissite $delsite
service apache2 restart
rm -rf /var/www/$delsite
rm /etc/apache2/sites-available/$delsite.conf
service apache2 restart
clear
echo "
Выполнено! Сайт $delsite удалён.
"
}
if [[ -f /etc/apache2/apache2.conf ]]; then
	MenuResume
else
	FirstSetup
fi