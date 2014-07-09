#!/bin/bash
clear
echo "   _______           _______  _______ _________ _______             _______  _    _________ _______"
echo "  (  ___  )|\     /|(  ____ \(  ____ \\\__   __/(  ___  )  |\     /|(  ___  )( \   \__   __/(  ___  )"
echo "  | (   ) || )   ( || (    \/| (    \/   ) (   | (   ) |  | )   ( || (   ) || (      ) (   | (   ) |"
echo "  | |   | || |   | || (__    | (_____    | |   | (___) |  | |   | || |   | || |      | |   | (___) |"
echo "  | |   | || |   | ||  __)   (_____  )   | |   |  ___  |  ( (   ) )| |   | || |      | |   |  ___  |"
echo "  | | /\| || |   | || (            ) |   | |   | (   ) |   \ \_/ / | |   | || |      | |   | (   ) |"
echo "  | (_\ \ || (___) || (____/\/\____) |   | |   | )   ( |    \   /  | (___) || (____/\| |   | )   ( |"
echo "  (____\/_)(_______)(_______/\_______)   )_(   |/     \|     \_/   (_______)(_______/)_(   |/     \|"
echo "   _____           _    ____   _____                    __          _    _____                 "
echo "  / ____|         | |  / __ \ / ____|                  / _|        | |  / ____|                "
echo " | |     ___ _ __ | |_| |  | | (___    _ __   ___ _ __| |_ ___  ___| |_| (___   ___ _ ____   __"
echo " | |    / _ \ '_ \| __| |  | |\___ \  | '_ \ / _ \ '__|  _/ _ \/ __| __|\___ \ / _ \ '__\ \ / /"
echo " | |___|  __/ | | | |_| |__| |____) | | |_) |  __/ |  | ||  __/ (__| |_ ____) |  __/ |   \ V / "
echo "  \_____\___|_| |_|\__|\____/|_____/  | .__/ \___|_|  |_| \___|\___|\__|_____/ \___|_|    \_/  "
echo "                                      | |  v0.1beta"
echo "                                      |_|  for auto hosting simply & easily"
echo ""
echo "\"tail -f log_script.log\" for an install log."
echo ""
# echo "Enter the IP Address of the Server:"
# read ipaddress	
# echo "Enter the Hostname of the Server:"
# read hostname
# rm /etc/hosts
#  cat <<EOF >> /etc/hosts
# 127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
# $ipaddress   $hostname.idthq.com     $hostname
# ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# EOF

echo -e "\033[31mThis script will set up a Questa Volta Optimized Web Server. Are you sure you want to continue?\033[0m"
read areyousure
if [ $areyousure != "YES" ]
then exit 1
else echo -e "\033[31mStarting installation...\033[0m"
fi



LOG=/root/log_script.log
echo "NOZEROCONF=yes" >> /etc/sysconfig/network

# Configuration of repository for CentOS

configure_repo() {
  yum -y install wget >> $LOG 2>&1

  echo -e "[\033[33m*\033[0m] Installing & configuring epel, rpmforge repos..."
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error importing key /etc/pki/rpm-gpg/RPM-GPG-KEY*"
  rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error importing key RPM-GPG-KEY.dag"
  cd /tmp
  wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error downloading RPMForge rpm"
  rpm -ivh rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error installing rpmforge rpm"

  rpm --import https://fedoraproject.org/static/0608B895.txt >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] Error importing epel key"
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] Error downloading epel repo rpm"
  rpm -ivh epel-release-6-8.noarch.rpm >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] Error installing epel repo rpm"

  #rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] Error import key remi"
  #rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] Error installing rpm remi"

  yum install yum-priorities -y >> $LOG 2>&1 echo -e "[\033[31mX\033[0m] Error installing yum-priorites"
  awk 'NR== 2 { print "priority=10" } { print }' /etc/yum.repos.d/epel.repo > /tmp/epel.repo
  rm /etc/yum.repos.d/epel.repo -f
  mv /tmp/epel.repo /etc/yum.repos.d

  #sed -i -e "0,/5/s/enabled=0/enabled=1/" /etc/yum.repos.d/remi.repo
}

update_system() {
  echo -e "[\033[33m*\033[0m] Updating full system (This could take a while...)"
  yum update -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error in yum update"
}

install_required_packages() {
  echo -e "[\033[33m*\033[0m] Installing required packages"
  yum install -y vim htop iftop nmap screen git expect >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error installing base packages"
  echo -e "[\033[33m*\033[0m] Installing Development Tools"
  yum groupinstall -y 'Development Tools'  >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error installing Dev Tools metapackage"
}

install_quota(){
echo -e "[\033[33m*\033[0m] Installing and configuring Quota"
yum install quota -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing Quota"
sed '0,/ext4/s/ext4/ext4    defaults,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0/' /etc/fstab >> $LOG 2>&1 # is this correct?
echo -e "[\033[33m*\033[0m] Remounting..."
mount -o remount / >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error remounting"
echo -e "[\033[33m*\033[0m] Enabling Quota"
quotacheck -avugm >> $LOG 2>&1 
quotaon -avug >> $LOG 2>&1 
}

install_ntpd() {
  echo -e "[\033[33m*\033[0m] Installing and configuring NTPD"
  yum install -y ntp  >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  chkconfig ntpd on >> $LOG 2>&1
}

install_apache_phpMyAdmin(){
echo -e "[\033[33m*\033[0m] Installing Apache, MySQL and phpMyAdmin..."
yum install ntp httpd mod_ssl php php-mysql php-mbstring phpmyadmin -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
}

disable_fw() {
  echo -e "[\033[33m*\033[0m] Disabling Firewall (for installation time)"
  service iptables save >> $LOG 2>&1
  service iptables stop >> $LOG 2>&1
  chkconfig iptables off >> $LOG 2>&1
}

disable_selinux() {
  echo -e "[\033[33m*\033[0m] Disabling SELinux"
  sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error disabling SELinux"
  setenforce 0 >> $LOG 2>&1
}

install_atop_htop(){
  echo -e "[\033[33m*\033[0m] Installing atop"
  yum install atop -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing atop"
  echo -e "[\033[33m*\033[0m] Installing htop"
  yum install htop -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing htop"
}
install_mysql() {
  echo -e "[\033[33m*\033[0m] Installing MYSQL Server"
  yum install mysql mysql-server -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  chkconfig --levels 235 mysqld on >> $LOG 2>&1
  /etc/init.d/mysqld start >> $LOG 2>&1

  echo "Type the MySQL root password you want to set: "
  read mysqlrootpw
  
#   Set pw asside for use later in ISP Config setup
  cat - > /tmp/mysqlpw.conf <<EOF
$mysqlrootpw
EOF
  
  SECURE_MYSQL=$(expect -c "
  
  set timeout 10
  spawn mysql_secure_installation
  
  expect \"Enter current password for root (enter for none):\"
  send \"\r\"
  
  expect \"Set root password?\"
  send \"y\r\"

  expect \"New password:\"
  send \"$mysqlrootpw\r\"

  expect \"Re-enter new password:\"
  send \"$mysqlrootpw\r\"
  
  expect \"Remove anonymous users?\"
  send \"y\r\"
  
  expect \"Disallow root login remotely?\"
  send \"y\r\"
  
  expect \"Remove test database and access to it?\"
  send \"y\r\"
  
  expect \"Reload privilege tables now?\"
  send \"y\r\"
  
  expect eof
  " >> $LOG)

  echo "$SECURE_MYSQL" >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error configuring MySQL"
}
  
install_dovecot() {
  echo -e "[\033[33m*\033[0m] Installing DOVECOT Server"
  yum install dovecot dovecot-mysql -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  chkconfig --levels 235 dovecot on >> $LOG 2>&1
  /etc/init.d/dovecot start >> $LOG 2>&1
}
  
install_postfix() {  
  echo -e "[\033[33m*\033[0m] Installing Postfix Server"
  yum install postfix -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  chkconfig --levels 235 postfix on >> $LOG 2>&1
  /etc/init.d/mysqld start >> $LOG 2>&1
  chkconfig --levels 235 postfix on >> $LOG 2>&1
  /etc/init.d/postfix restart >> $LOG 2>&1
}
  
install_getmail() {
  echo -e "[\033[33m*\033[0m] Installing getmail"
  yum install getmail -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
}


install_modphp(){
  echo -e "[\033[33m*\033[0m] Installing Apache2 With mod_php, mod_fcgi/PHP5, And suPHP"
  yum install php php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/' /etc/php.ini >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing php.ini"
  sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/' /etc/php.ini >> $LOG 2>&1 
  sed -i 's/error_reporting = E_ALL \&\ ~E_DEPRECATED/error_reporting = E_ALL \&\ ~E_NOTICE/' /etc/php.ini >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing php.ini"
  cd /tmp >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Getting suPHP"
  wget http://suphp.org/download/suphp-0.7.1.tar.gz >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Unzipping"
  tar xvfz suphp-0.7.1.tar.gz >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Installing suPHP"
  cd suphp-0.7.1/ >> $LOG 2>&1
  ./configure --prefix=/usr --sysconfdir=/etc --with-apr=/usr/bin/apr-1-config --with-apxs=/usr/sbin/apxs --with-apache-user=apache --with-setid-mode=owner --with-php=/usr/bin/php-cgi --with-logfile=/var/log/httpd/suphp_log --enable-SUPHP_USE_USERGROUP=yes >> $LOG 2>&1
  make >> $LOG 2>&1
  make install >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Adding suPHP to Apache Configuration"
  echo "LoadModule suphp_module modules/mod_suphp.so" > /etc/httpd/conf.d/suphp.conf
  cat <<EOF >> /etc/suphp.conf
	[global]
	;Path to logfile
	logfile=/var/log/httpd/suphp.log
	;Loglevel
	loglevel=info
	;User Apache is running as
	webserver_user=apache
	;Path all scripts have to be in
	docroot=/
	;Path to chroot() to before executing script
	;chroot=/mychroot
	; Security options
	allow_file_group_writeable=true
	allow_file_others_writeable=false
	allow_directory_group_writeable=true
	allow_directory_others_writeable=false
	;Check wheter script is within DOCUMENT_ROOT
	check_vhost_docroot=true
	;Send minor error messages to browser
	errors_to_browser=false
	;PATH environment variable
	env_path=/bin:/usr/bin
	;Umask to set, specify in octal notation
	umask=0077
	; Minimum UID
	min_uid=100
	; Minimum GID
	min_gid=100
	
	[handlers]
	;Handler for php-scripts
	x-httpd-suphp="php:/usr/bin/php-cgi"
	;Handler for CGI-scripts
	x-suphp-cgi="execute:!self"" > /etc/httpd/conf.d/suphp.confetc/suphp.conf
EOF

  echo -e "[\033[33m*\033[0m] Restarting Apache"
  /etc/init.d/httpd restart >> $LOG 2>&1

}


install_pma() {
  echo -e "[\033[33m*\033[0m] Configuring PHPmyAdmin"
  yum install phpmyadmin -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing phpmyadmin"
  mv /usr/share/phpmyadmin/config.inc.php /usr/share/phpmyadmin/config.inc.php.bak >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Created config.inc.php backup at /usr/share/phpmyadmin/config.inc.php.bak"
  cat <<'EOF' > /usr/share/phpmyadmin/config.inc.php
<?php
/* vim: set expandtab sw=4 ts=4 sts=4: */
/**
 * phpMyAdmin sample configuration, you can use it as base for
 * manual configuration. For easier setup you can use scripts/setup.php
 *
 * All directives are explained in Documentation.html and on phpMyAdmin
 * wiki <http://wiki.phpmyadmin.net>.
 *
 * @version $Id$
 */

/*
 * This is needed for cookie based authentication to encrypt password in
 * cookie
 */
$cfg['blowfish_secret'] = ''; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */

/*
 * Servers configuration
 */
$i = 0;

/*
 * First server
 */
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'http';
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
/* Select mysqli if your server has it */
$cfg['Servers'][$i]['extension'] = 'mysql';
/* User for advanced features */
// $cfg['Servers'][$i]['controluser'] = 'pma';
// $cfg['Servers'][$i]['controlpass'] = 'pmapass';
/* Advanced phpMyAdmin features */
// $cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
// $cfg['Servers'][$i]['bookmarktable'] = 'pma_bookmark';
// $cfg['Servers'][$i]['relation'] = 'pma_relation';
// $cfg['Servers'][$i]['table_info'] = 'pma_table_info';
// $cfg['Servers'][$i]['table_coords'] = 'pma_table_coords';
// $cfg['Servers'][$i]['pdf_pages'] = 'pma_pdf_pages';
// $cfg['Servers'][$i]['column_info'] = 'pma_column_info';
// $cfg['Servers'][$i]['history'] = 'pma_history';
// $cfg['Servers'][$i]['designer_coords'] = 'pma_designer_coords';

/*
 * End of servers configuration
 */

/*
 * Directories for saving/loading files from server
 */
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';

?>

EOF

  echo -e "[\033[33m*\033[0m] Enabling connections from remote hosts"  
  sed -e '/<Directory/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing phpmyadmin.conf"
  sed -e '/Order Deny,Allow/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing phpmyadmin.conf"
  sed -e '/Deny from all/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing phpmyadmin.conf"
  sed -e '/Allow from 127.0.0.1/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing phpmyadmin.conf"
  sed -e '/Directory/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error editing phpmyadmin.conf"
  echo -e "[\033[33m*\033[0m] Starting Apache..."
  chkconfig --levels 235 httpd on >> $LOG 2>&1
  /etc/init.d/httpd start >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] Error starting Apache"
  }

install_ftpd() {
  echo -e "[\033[33m*\033[0m] Installing PureFTPD"
  yum install pure-ftpd -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  chkconfig --levels 235 pure-ftpd on >> $LOG 2>&1
  /etc/init.d/pure-ftpd start >> $LOG 2>&1
  yum install openssl -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  sed -i 's/# TLS                      1/TLS    1/' /etc/pure-ftpd/pure-ftpd.conf >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Generating SSL Certificate"
  mkdir -p /etc/ssl/private/ >> $LOG 2>&1
  openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
  echo -e "[\033[33m*\033[0m] Changing SSL Certificate Permissions"
  chmod 600 /etc/ssl/private/pure-ftpd.pem >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Restarting PureFTPD"
  /etc/init.d/pure-ftpd restart >> $LOG 2>&1
}

install_bind() {
  echo -e "[\033[33m*\033[0m] Installing BIND"
  yum install bind bind-utils -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  sed -re 'ROOTDIR=/var/named/chroot s/^#//' /etc/sysconfig/named >> $LOG 2>&1 # is this right??
  cp /etc/named.conf /etc/named.conf_bak >> $LOG 2>&1
  cat <<EOF > /etc/named.conf
  //
  // named.conf
  //
  // Provided by Red Hat bind package to configure the ISC BIND named(8) DNS
  // server as a caching only nameserver (as a localhost DNS resolver only).
  //
  // See /usr/share/doc/bind*/sample/ for example named configuration files.
  //
  options {
	  listen-on port 53 { any; };
	  listen-on-v6 port 53 { any; };
	  directory       "/var/named";
	  dump-file       "/var/named/data/cache_dump.db";
	  statistics-file "/var/named/data/named_stats.txt";
	  memstatistics-file "/var/named/data/named_mem_stats.txt";
	  allow-query     { any; };
	  recursion no; 
	  };
  logging {
	  channel default_debug {
		  file "data/named.run";
		  severity dynamic;
	};
  };

  zone "." IN {
	  type hint;
	  file "named.ca";
  };

  include "/etc/named.conf.local";

EOF

  touch /etc/named.conf.local >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Generating key..."
#   chkconfig --levels 235 named on >> $LOG 2>&1
#   /etc/init.d/named start >> $LOG 2>&1
}

install_python(){
  echo -e "[\033[33m*\033[0m] Installing Python..."
  yum install mod_python -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  echo -e "[\033[33m*\033[0m] Restarting Apache"
  /etc/init.d/httpd restart >> $LOG 2>&1
}



install_awstat() {
  echo -e "[\033[33m*\033[0m] Setting up Webalizer and AWStats"
  yum install webalizer awstats perl-DateTime-Format-HTTP perl-DateTime-Format-Builder -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
}

install_jailkit() {
  echo -e "[\033[33m*\033[0m] Installing Jailkit"
  cd /tmp >> $LOG 2>&1
  wget http://olivier.sessink.nl/jailkit/jailkit-2.16.tar.gz >> $LOG 2>&1
  tar xvfz jailkit-2.16.tar.gz >> $LOG 2>&1
  cd jailkit-2.16 >> $LOG 2>&1
  ./configure >> $LOG 2>&1
  make >> $LOG 2>&1
  make install >> $LOG 2>&1
  cd ..  >> $LOG 2>&1
  rm -rf jailkit-2.16* >> $LOG 2>&1
}

install_fail2ban() {
  echo -e "[\033[33m*\033[0m] Installing fail2ban & RootkitHunter"
  yum install fail2ban -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  sed -i 's,logtarget = SYSLOG,logtarget = /var/log/fail2ban.log,' /etc/fail2ban/fail2ban.conf  >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/fail2ban/fail2ban.conf"
  chkconfig --levels 235 fail2ban on >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Starting fail2ban"
  /etc/init.d/fail2ban start >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Installing rkhunter"
  yum install rkhunter -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
}

install_squirrelmail(){
  echo -e "[\033[33m*\033[0m] Installing SquirrelMail"
  yum install squirrelmail -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing"
  echo -e "[\033[33m*\033[0m] Restarting Apache"
  /etc/init.d/httpd restart >> $LOG 2>&1
  sed -i '/$default_folder_prefix/d' /etc/squirrelmail/config_local.php
  
####################################
#   Automatic squirrelmail config  #
####################################

  cat <<EOF > /etc/squirrelmail/config.php
	<?php

	/**
	 * SquirrelMail Configuration File
	 * Created using the configure script, conf.pl
	 */

	global $version;
	$config_version = '1.4.0';
	$config_use_color = 1;

	$org_name      = "SquirrelMail";
	$org_logo      = SM_PATH . 'images/sm_logo.png';
	$org_logo_width  = '308';
	$org_logo_height = '111';
	$org_title     = "SquirrelMail $version";
	$signout_page  = '';
	$frame_top     = '_top';

	$provider_uri     = 'http://squirrelmail.org/';

	$provider_name     = 'SquirrelMail';

	$motd = "";

	$squirrelmail_default_language = 'en_US';
	$default_charset       = 'iso-8859-1';
	$lossy_encoding        = false;

	$domain                 = 'localhost';
	$imapServerAddress      = 'localhost';
	$imapPort               = 143;
	$useSendmail            = true;
	$smtpServerAddress      = 'localhost';
	$smtpPort               = 25;
	$sendmail_path          = '/usr/sbin/sendmail';
	$sendmail_args          = '-i -t';
	$pop_before_smtp        = false;
	$pop_before_smtp_host   = '';
	$imap_server_type       = 'dovecot';
	$invert_time            = false;
	$optional_delimiter     = 'detect';
	$encode_header_key      = '';

	$default_folder_prefix          = '';
	$trash_folder                   = 'Trash';
	$sent_folder                    = 'Sent';
	$draft_folder                   = 'Drafts';
	$default_move_to_trash          = true;
	$default_move_to_sent           = true;
	$default_save_as_draft          = true;
	$show_prefix_option             = false;
	$list_special_folders_first     = true;
	$use_special_folder_color       = true;
	$auto_expunge                   = true;
	$default_sub_of_inbox           = false;
	$show_contain_subfolders_option = false;
	$default_unseen_notify          = 2;
	$default_unseen_type            = 1;
	$auto_create_special            = true;
	$delete_folder                  = false;
	$noselect_fix_enable            = false;

	$data_dir                 = '/var/lib/squirrelmail/prefs/';
	$attachment_dir           = '/var/spool/squirrelmail/attach/';
	$dir_hash_level           = 0;
	$default_left_size        = '150';
	$force_username_lowercase = true;
	$default_use_priority     = true;
	$hide_sm_attributions     = false;
	$default_use_mdn          = true;
	$edit_identity            = true;
	$edit_name                = true;
	$hide_auth_header         = false;
	$allow_thread_sort        = true;
	$allow_server_sort        = true;
	$allow_charset_search     = true;
	$uid_support              = true;

	$plugins[0] = 'delete_move_next';
	$plugins[1] = 'squirrelspell';
	$plugins[2] = 'newmail';

	$theme_css = '';
	$theme_default = 0;
	$theme[0]['PATH'] = SM_PATH . 'themes/default_theme.php';
	$theme[0]['NAME'] = 'Default';
	$theme[1]['PATH'] = SM_PATH . 'themes/plain_blue_theme.php';
	$theme[1]['NAME'] = 'Plain Blue';
	$theme[2]['PATH'] = SM_PATH . 'themes/sandstorm_theme.php';
	$theme[2]['NAME'] = 'Sand Storm';
	$theme[3]['PATH'] = SM_PATH . 'themes/deepocean_theme.php';
	$theme[3]['NAME'] = 'Deep Ocean';
	$theme[4]['PATH'] = SM_PATH . 'themes/slashdot_theme.php';
	$theme[4]['NAME'] = 'Slashdot';
	$theme[5]['PATH'] = SM_PATH . 'themes/purple_theme.php';
	$theme[5]['NAME'] = 'Purple';
	$theme[6]['PATH'] = SM_PATH . 'themes/forest_theme.php';
	$theme[6]['NAME'] = 'Forest';
	$theme[7]['PATH'] = SM_PATH . 'themes/ice_theme.php';
	$theme[7]['NAME'] = 'Ice';
	$theme[8]['PATH'] = SM_PATH . 'themes/seaspray_theme.php';
	$theme[8]['NAME'] = 'Sea Spray';
	$theme[9]['PATH'] = SM_PATH . 'themes/bluesteel_theme.php';
	$theme[9]['NAME'] = 'Blue Steel';
	$theme[10]['PATH'] = SM_PATH . 'themes/dark_grey_theme.php';
	$theme[10]['NAME'] = 'Dark Grey';
	$theme[11]['PATH'] = SM_PATH . 'themes/high_contrast_theme.php';
	$theme[11]['NAME'] = 'High Contrast';
	$theme[12]['PATH'] = SM_PATH . 'themes/black_bean_burrito_theme.php';
	$theme[12]['NAME'] = 'Black Bean Burrito';
	$theme[13]['PATH'] = SM_PATH . 'themes/servery_theme.php';
	$theme[13]['NAME'] = 'Servery';
	$theme[14]['PATH'] = SM_PATH . 'themes/maize_theme.php';
	$theme[14]['NAME'] = 'Maize';
	$theme[15]['PATH'] = SM_PATH . 'themes/bluesnews_theme.php';
	$theme[15]['NAME'] = 'BluesNews';
	$theme[16]['PATH'] = SM_PATH . 'themes/deepocean2_theme.php';
	$theme[16]['NAME'] = 'Deep Ocean 2';
	$theme[17]['PATH'] = SM_PATH . 'themes/blue_grey_theme.php';
	$theme[17]['NAME'] = 'Blue Grey';
	$theme[18]['PATH'] = SM_PATH . 'themes/dompie_theme.php';
	$theme[18]['NAME'] = 'Dompie';
	$theme[19]['PATH'] = SM_PATH . 'themes/methodical_theme.php';
	$theme[19]['NAME'] = 'Methodical';
	$theme[20]['PATH'] = SM_PATH . 'themes/greenhouse_effect.php';
	$theme[20]['NAME'] = 'Greenhouse Effect (Changes)';
	$theme[21]['PATH'] = SM_PATH . 'themes/in_the_pink.php';
	$theme[21]['NAME'] = 'In The Pink (Changes)';
	$theme[22]['PATH'] = SM_PATH . 'themes/kind_of_blue.php';
	$theme[22]['NAME'] = 'Kind of Blue (Changes)';
	$theme[23]['PATH'] = SM_PATH . 'themes/monostochastic.php';
	$theme[23]['NAME'] = 'Monostochastic (Changes)';
	$theme[24]['PATH'] = SM_PATH . 'themes/shades_of_grey.php';
	$theme[24]['NAME'] = 'Shades of Grey (Changes)';
	$theme[25]['PATH'] = SM_PATH . 'themes/spice_of_life.php';
	$theme[25]['NAME'] = 'Spice of Life (Changes)';
	$theme[26]['PATH'] = SM_PATH . 'themes/spice_of_life_lite.php';
	$theme[26]['NAME'] = 'Spice of Life - Lite (Changes)';
	$theme[27]['PATH'] = SM_PATH . 'themes/spice_of_life_dark.php';
	$theme[27]['NAME'] = 'Spice of Life - Dark (Changes)';
	$theme[28]['PATH'] = SM_PATH . 'themes/christmas.php';
	$theme[28]['NAME'] = 'Holiday - Christmas';
	$theme[29]['PATH'] = SM_PATH . 'themes/darkness.php';
	$theme[29]['NAME'] = 'Darkness (Changes)';
	$theme[30]['PATH'] = SM_PATH . 'themes/random.php';
	$theme[30]['NAME'] = 'Random (Changes every login)';
	$theme[31]['PATH'] = SM_PATH . 'themes/midnight.php';
	$theme[31]['NAME'] = 'Midnight';
	$theme[32]['PATH'] = SM_PATH . 'themes/alien_glow.php';
	$theme[32]['NAME'] = 'Alien Glow';
	$theme[33]['PATH'] = SM_PATH . 'themes/dark_green.php';
	$theme[33]['NAME'] = 'Dark Green';
	$theme[34]['PATH'] = SM_PATH . 'themes/penguin.php';
	$theme[34]['NAME'] = 'Penguin';

	$default_use_javascript_addr_book = false;
	$abook_global_file = '';
	$abook_global_file_writeable = false;
	$abook_global_file_listing = true;
	$abook_file_line_length = 2048;

	$addrbook_dsn = '';
	$addrbook_table = 'address';

	$prefs_dsn = '';
	$prefs_table = 'userprefs';
	$prefs_user_field = 'user';
	$prefs_key_field = 'prefkey';
	$prefs_val_field = 'prefval';
	$addrbook_global_dsn = '';
	$addrbook_global_table = 'global_abook';
	$addrbook_global_writeable = false;
	$addrbook_global_listing = false;

	$no_list_for_subscribe = false;
	$smtp_auth_mech = 'none';
	$imap_auth_mech = 'login';
	$smtp_sitewide_user = '';
	$smtp_sitewide_pass = '';
	$use_imap_tls = false;
	$use_smtp_tls = false;
	$session_name = 'SQMSESSID';
	$only_secure_cookies     = true;
	$disable_security_tokens = false;
	$check_referrer          = '';

	$config_location_base    = '';

	@include SM_PATH . 'config/config_local.php';
EOF
#####################
# Old manual config #
#####################

#   echo "Please configure SquirrelMail! Commands are as follows:"
#   echo "Command >> D"
#   echo "Command >> dovecot"
#   echo "Press enter..."
#   echo "Command >> S"
#   echo "Command >> Q"
#   echo "Ready to go?"
#   echo "Enter to continue..."
#   read ready
#   echo "Starting SquirrelMail Config:"
#   /usr/share/squirrelmail/config/conf.pl
}

install_cyrus(){
  echo -e "[\033[33m*\033[0m] Installing Cyrus"
  yum install cyrus-sasl* -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing Cyrus"
  yum install perl-DateTime-Format* -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing Cyrus"
}
install_ruby(){
  echo -e "[\033[33m*\033[0m] Installing Ruby"
  yum install httpd-devel ruby ruby-devel -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing Ruby"
  cd /tmp $LOG 2>&1
  wget http://fossies.org/unix/www/apache_httpd_modules/mod_ruby-1.3.0.tar.gz >> $LOG 2>&1
  tar zxvf mod_ruby-1.3.0.tar.gz >> $LOG 2>&1
  cd mod_ruby-1.3.0/ >> $LOG 2>&1
  ./configure.rb --with-apr-includes=/usr/include/apr-1 >> $LOG 2>&1
  make >> $LOG 2>&1
  make install >> $LOG 2>&1
  
cat <<EOF > /etc/httpd/conf.d/ruby.conf
  LoadModule ruby_module modules/mod_ruby.so
  RubyAddPath /1.8

EOF
  echo -e "[\033[33m*\033[0m] Restarting Apache"
  /etc/init.d/httpd restart >> $LOG 2>&1
}

configure_webdav(){
  sed -i -e "s,#\(#LoadModule auth_digest_module modules/mod_auth_digest.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/httpd/conf/httpd.conf"
  sed -i -e "s,#\(#LoadModule dav_module modules/mod_dav.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/httpd/conf/httpd.conf"
  sed -i -e "s,#\(#LoadModule dav_fs_module modules/mod_dav_fs.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/httpd/conf/httpd.conf"
  
  }

install_unzip(){
  echo -e "[\033[33m*\033[0m] Installing unzip, bzip2, unrar, perl DBD"
  yum install unzip bzip2 unrar perl-DBD-mysql -y >> $LOG 2>&1
}

install_locate(){
  echo -e "[\033[33m*\033[0m] Installing locate"
  yum install mlocate -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error installing locate"
  echo -e "[\033[33m*\033[0m] Updating db"
  updatedb ||  echo -e "[\033[31mX\033[0m] Error updating db"
}

script_update_1(){
  sed -i 's/Timeout 60/Timeout 2/g' /etc/httpd/conf/httpd.conf >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/httpd/conf/httpd.conf"
  sed -i 's/MaxRequestsPerChild  4000/MaxRequestsPerChild  1000/g' /etc/httpd/conf/httpd.conf >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/httpd/conf/httpd.conf"
  service httpd restart >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error restarting httpd"
  sed -i 's/apc.shm_size=64M/apc.shm_size=128M/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.num_files_hint=1024/apc.num_files_hint=10024/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.user_entries_hint=4096/apc.user_entries_hint=40096/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.enable_cli=0/apc.enable_cli=1/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.enable_cli=0/apc.enable_cli=1/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.max_file_size=1M/apc.max_file_size=8M/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  sed -i 's/apc.stat=1/apc.stat=0/g' /etc/php.d/apc.ini >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error editing /etc/php.d/apc.ini"
  service httpd restart >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] Error restarting httpd"
  sed -i '/symbolic-links=0/a\
    query_cache_size = 128M\
    join_buffer_size = 4M\
    thread_cache_size = 8\
    table_cache = 256\
    tmp_table_size = 64M\
    max_heap_table_size = 64M\
    innodb_buffer_pool_size = 512M
  ' /etc/my.cnf
  echo -e "[\033[33m*\033[0m] Restarting mysql"
  service mysqld restart 
}

disable_fw
disable_selinux
configure_repo
update_system
install_required_packages
install_quota
install_dovecot
install_mysql
install_apache_phpMyAdmin
install_postfix
install_atop_htop
install_pma
install_getmail
install_unzip
install_modphp
install_ruby
install_python
install_ftpd
install_awstat
install_jailkit
install_fail2ban
install_cyrus
install_bind
configure_webdav
install_squirrelmail
install_locate
script_update_1


echo -e "[\033[33m*\033[0m] Setting up ISPConfig !"
#ISPConfig
cd /tmp
wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz >> $LOG 2>&1
tar xfz ISPConfig-3-stable.tar.gz >> $LOG 2>&1
cd ispconfig3_install/install/

mv /tmp/ispconfig3_install/install/install.php /tmp/ispconfig3_install/install/install.php.bak

 cat <<EOF > /tmp/ispconfig3_install/install/install.php
<?php

error_reporting(E_ALL|E_STRICT);

define('INSTALLER_RUN', true);

//** The banner on the command line
echo "\n\n".str_repeat('-', 80)."\n";
echo "                                                   
   (                  )                (    )      
 ( )\    (    (    ( /(   )   (   (    )\( /(   )  
 )((_)  ))\  ))\(  )\()| /(   )\  )\( ((_)\()| /(  
((_)_  /((_)/((_)\(_))/)(_)) ((_)((_)\ _(_))/)(_)) 
 / _ \(_))((_))((_) |_((_)_  \ \ / ((_) | |_((_)_  
| (_) | || / -_|_-<  _/ _` |  \ V / _ \ |  _/ _` | 
 \__\_\\_,_\___/__/\__\__,_|   \_/\___/_|\__\__,_| 
                                                   ";
echo "\n".str_repeat('-', 80)."\n";
echo "\n\n>> Initial configuration  \n\n";

//** Include the library with the basic installer functions
require_once 'lib/install.lib.php';

//** Include the base class of the installer class
require_once 'lib/installer_base.lib.php';

//** Ensure that current working directory is install directory
$cur_dir = getcwd();
if(realpath(dirname(__FILE__)) != $cur_dir) {
	chdir( realpath(dirname(__FILE__)) );
}

//** Install logfile
define('ISPC_LOG_FILE', '/var/log/ispconfig_install.log');
define('ISPC_INSTALL_ROOT', realpath(dirname(__FILE__).'/../'));

//** Include the templating lib
require_once 'lib/classes/tpl.inc.php';

//** Check for existing installation
/*if(is_dir("/usr/local/ispconfig")) {
    die('We will stop here. There is already a ISPConfig installation, use the update script to update this installation.');
}*/

//** Get distribution identifier
$dist = get_distname();

if($dist['id'] == '') die('Linux distribution or version not recognized.');

//** Include the distribution-specific installer class library and configuration
if(is_file('dist/lib/'.$dist['baseid'].'.lib.php')) include_once 'dist/lib/'.$dist['baseid'].'.lib.php';
include_once 'dist/lib/'.$dist['id'].'.lib.php';
include_once 'dist/conf/'.$dist['id'].'.conf.php';

//****************************************************************************************************
//** Installer Interface
//****************************************************************************************************
$inst = new installer();

swriteln($inst->lng('    Following will be a few questions for primary configuration so be careful.'));
swriteln($inst->lng('    Default values are in [brackets] and can be accepted with <ENTER>.'));
swriteln($inst->lng('    Tap in "quit" (without the quotes) to stop the installer.'."\n\n"));

//** Check log file is writable (probably not root or sudo)
if(!is_writable(dirname(ISPC_LOG_FILE))){
	die("ERROR: Cannot write to the ".dirname(ISPC_LOG_FILE)." directory. Are you root or sudo ?\n\n");
}

if(is_dir('/root/ispconfig') || is_dir('/home/admispconfig')) {
	die('This software cannot be installed on a server wich runs ISPConfig 2.x.');
}

if(is_dir('/usr/local/ispconfig')) {
	die('ISPConfig 3 installation found. Please use update.php instead if install.php to update the installation.');
}

//** Detect the installed applications
$inst->find_installed_apps();

//** Select the language and set default timezone

// $conf['language'] = $inst->simple_query('Select language', array('en', 'de'), 'en');

// Set language auto
$conf['language'] = en;

$conf['timezone'] = get_system_timezone();

//* Set default theme
$conf['theme'] = 'default';
$conf['language_file_import_enabled'] = true;

//** Select installation mode

// $install_mode = $inst->simple_query('Installation mode', array('standard', 'expert'), 'standard');

// Set install mode automatically
$install_mode = 'standard';


//** Get the hostname
$tmp_out = array();

exec('hostname -f', $tmp_out);
// $conf['hostname'] = $inst->free_query('Full qualified hostname (FQDN) of the server, eg server1.domain.tld ', @$tmp_out[0]);

// Set hostname automatically

$conf['hostname'] = @$tmp_out[0];

// Set variable to use later

$hostname = @$tmp_out[0];

unset($tmp_out);

// Get mysql pw from earlier perfect server setup

exec('cat /tmp/mysqlpw.conf', $output);

$tmp_mysql_server_admin_password=$output[0];

print_r("MySQL PW: ");
print_r($tmp_mysql_server_admin_password);


// Check if the mysql functions are loaded in PHP
if(!function_exists('mysql_connect')) die('No PHP MySQL functions available. Please ensure that the PHP MySQL module is loaded.');

//** Get MySQL root credentials
$finished = false;
do {
//  Original script setup
//  $tmp_mysql_server_host = $inst->free_query('MySQL server hostname', $conf['mysql']['host']);
// 	$tmp_mysql_server_admin_user = $inst->free_query('MySQL root username', $conf['mysql']['admin_user']);
// 	$tmp_mysql_server_admin_password = $inst->free_query('MySQL root password', $conf['mysql']['admin_password']);
// 	$tmp_mysql_server_database = $inst->free_query('MySQL database to create', $conf['mysql']['database']);
// 	$tmp_mysql_server_charset = $inst->free_query('MySQL charset', $conf['mysql']['charset']);

//  Automatic variable assignment. These variables never change. The MySQL admin pw has already been set in the preceding function which is why it's removed here. 
	$tmp_mysql_server_host = $conf['mysql']['host'];
	$tmp_mysql_server_admin_user = $conf['mysql']['admin_user'];
	$tmp_mysql_server_database = $conf['mysql']['database'];
	$tmp_mysql_server_charset = $conf['mysql']['charset'];
	
// 	if($install_mode == 'expert') {
// 		swriteln("The next two questions are about the internal ISPConfig database user and password.\nIt is recommended to accept the defaults which are 'ispconfig' as username and a random password.\nIf you use a different password, use only numbers and chars for the password.\n");
// 		$conf['mysql']['ispconfig_user'] = $inst->free_query('ISPConfig mysql database username', $conf['mysql']['ispconfig_user']);
// 		$conf['mysql']['ispconfig_password'] = $inst->free_query('ISPConfig mysql database password', $conf['mysql']['ispconfig_password']);
// 	}

	//* Initialize the MySQL server connection
	if(@mysql_connect($tmp_mysql_server_host, $tmp_mysql_server_admin_user, $tmp_mysql_server_admin_password)) {
		$conf['mysql']['host'] = $tmp_mysql_server_host;
		$conf['mysql']['admin_user'] = $tmp_mysql_server_admin_user;
		$conf['mysql']['admin_password'] = $tmp_mysql_server_admin_password;
		$conf['mysql']['database'] = $tmp_mysql_server_database;
		$conf['mysql']['charset'] = $tmp_mysql_server_charset;
		$finished = true;
	} else {
		swriteln($inst->lng('Unable to connect to the specified MySQL server').' '.mysql_error());
	}
} while ($finished == false);
unset($finished);

// Resolve the IP address of the MySQL hostname.
$tmp = explode(':', $conf['mysql']['host']);
if(!$conf['mysql']['ip'] = gethostbyname($tmp[0])) die('Unable to resolve hostname'.$tmp[0]);
unset($tmp);


//** Initializing database connection
include_once 'lib/mysql.lib.php';
$inst->db = new db();

//** Begin with standard or expert installation
if($install_mode == 'standard') {

	//* Create the MySQL database
	$inst->configure_database();

	//* Configure Webserver - Apache or nginx
	if($conf['apache']['installed'] == true && $conf['nginx']['installed'] == true) {
		$http_server_to_use = $inst->simple_query('Apache and nginx detected. Select server to use for ISPConfig:', array('apache', 'nginx'), 'apache');
		if($http_server_to_use == 'apache'){
			$conf['nginx']['installed'] = false;
		} else {
			$conf['apache']['installed'] = false;
		}
	}

	//* Insert the Server record into the database
	$inst->add_database_server_record();

	//* Configure Postfix
	$inst->configure_postfix();

	//* Configure Mailman
	$inst->configure_mailman('install');

	//* Configure jailkit
	swriteln('Configuring Jailkit');
	$inst->configure_jailkit();

	if($conf['dovecot']['installed'] == true) {
		//* Configure Dovecot
		swriteln('Configuring Dovecot');
		$inst->configure_dovecot();
	} else {
		//* Configure saslauthd
		swriteln('Configuring SASL');
		$inst->configure_saslauthd();

		//* Configure PAM
		swriteln('Configuring PAM');
		$inst->configure_pam();

		//* Configure Courier
		swriteln('Configuring Courier');
		$inst->configure_courier();
	}

	//* Configure Spamasassin
	swriteln('Configuring Spamassassin');
	$inst->configure_spamassassin();

	//* Configure Amavis
	swriteln('Configuring Amavisd');
	$inst->configure_amavis();

	//* Configure Getmail
	swriteln('Configuring Getmail');
	$inst->configure_getmail();

	//* Configure Pureftpd
	swriteln('Configuring Pureftpd');
	$inst->configure_pureftpd();

	//* Configure DNS
	if($conf['powerdns']['installed'] == true) {
		swriteln('Configuring PowerDNS');
		$inst->configure_powerdns();
	} elseif($conf['bind']['installed'] == true) {
		swriteln('Configuring BIND');
		$inst->configure_bind();
	} else {
		swriteln('Configuring MyDNS');
		$inst->configure_mydns();
	}

	//* Configure Apache
	if($conf['apache']['installed'] == true){
		swriteln('Configuring Apache');
		$inst->configure_apache();
	}

	//* Configure nginx
	if($conf['nginx']['installed'] == true){
		swriteln('Configuring nginx');
		$inst->configure_nginx();
	}

	//** Configure Vlogger
	swriteln('Configuring Vlogger');
	$inst->configure_vlogger();

	//** Configure apps vhost
	swriteln('Configuring Apps vhost');
	$inst->configure_apps_vhost();

	//* Configure Firewall
	//* Configure Bastille Firewall
	$conf['services']['firewall'] = true;
	swriteln('Configuring Bastille Firewall');
	$inst->configure_firewall();

	//* Configure Fail2ban
	if($conf['fail2ban']['installed'] == true) {
		swriteln('Configuring Fail2ban');
		$inst->configure_fail2ban();
	}

	/*
	if($conf['squid']['installed'] == true) {
		$conf['services']['proxy'] = true;
		swriteln('Configuring Squid');
		$inst->configure_squid();
	} else if($conf['nginx']['installed'] == true) {
		$conf['services']['proxy'] = true;
		swriteln('Configuring Nginx');
		$inst->configure_nginx();
	}
	*/

	//* Configure ISPConfig
	swriteln('Installing ISPConfig');

	//** Customize the port ISPConfig runs on
    // 	$ispconfig_vhost_port = $inst->free_query('ISPConfig Port', '8080');
    // Auto set ispconfig port
	$ispconfig_vhost_port = '8080';
	if($conf['apache']['installed'] == true) $conf['apache']['vhost_port']  = $ispconfig_vhost_port;
	if($conf['nginx']['installed'] == true) $conf['nginx']['vhost_port']  = $ispconfig_vhost_port;
	unset($ispconfig_vhost_port);

// 	if(strtolower($inst->simple_query('Do you want a secure (SSL) connection to the ISPConfig web interface', array('y', 'n'), 'y')) == 'y') {
// 		$inst->make_ispconfig_ssl_cert();

// We always use an ssl connection
		$inst->make_ispconfig_ssl_cert();
	}

	$inst->install_ispconfig();

	//* Configure DBServer
	swriteln('Configuring DBServer');
	$inst->configure_dbserver();

	//* Configure ISPConfig
	swriteln('Installing ISPConfig crontab');
	$inst->install_crontab();

	swriteln('Restarting services ...');
	if($conf['mysql']['installed'] == true && $conf['mysql']['init_script'] != '') system($inst->getinitcommand($conf['mysql']['init_script'], 'restart'));
	if($conf['postfix']['installed'] == true && $conf['postfix']['init_script'] != '') system($inst->getinitcommand($conf['postfix']['init_script'], 'restart'));
	if($conf['saslauthd']['installed'] == true && $conf['saslauthd']['init_script'] != '') system($inst->getinitcommand($conf['saslauthd']['init_script'], 'restart'));
	if($conf['amavis']['installed'] == true && $conf['amavis']['init_script'] != '') system($inst->getinitcommand($conf['amavis']['init_script'], 'restart'));
	if($conf['clamav']['installed'] == true && $conf['clamav']['init_script'] != '') system($inst->getinitcommand($conf['clamav']['init_script'], 'restart'));
	if($conf['courier']['installed'] == true){
		if($conf['courier']['courier-authdaemon'] != '') system($inst->getinitcommand($conf['courier']['courier-authdaemon'], 'restart'));
		if($conf['courier']['courier-imap'] != '') system($inst->getinitcommand($conf['courier']['courier-imap'], 'restart'));
		if($conf['courier']['courier-imap-ssl'] != '') system($inst->getinitcommand($conf['courier']['courier-imap-ssl'], 'restart'));
		if($conf['courier']['courier-pop'] != '') system($inst->getinitcommand($conf['courier']['courier-pop'], 'restart'));
		if($conf['courier']['courier-pop-ssl'] != '') system($inst->getinitcommand($conf['courier']['courier-pop-ssl'], 'restart'));
	}
	if($conf['dovecot']['installed'] == true && $conf['dovecot']['init_script'] != '') system($inst->getinitcommand($conf['dovecot']['init_script'], 'restart'));
	if($conf['mailman']['installed'] == true && $conf['mailman']['init_script'] != '') system('nohup '.$inst->getinitcommand($conf['mailman']['init_script'], 'restart').' >/dev/null 2>&1 &');
	if($conf['apache']['installed'] == true && $conf['apache']['init_script'] != '') system($inst->getinitcommand($conf['apache']['init_script'], 'restart'));
	//* Reload is enough for nginx
	if($conf['nginx']['installed'] == true){
		if($conf['nginx']['php_fpm_init_script'] != '') system($inst->getinitcommand($conf['nginx']['php_fpm_init_script'], 'reload'));
		if($conf['nginx']['init_script'] != '') system($inst->getinitcommand($conf['nginx']['init_script'], 'reload'));
	}
	if($conf['pureftpd']['installed'] == true && $conf['pureftpd']['init_script'] != '') system($inst->getinitcommand($conf['pureftpd']['init_script'], 'restart'));
	if($conf['mydns']['installed'] == true && $conf['mydns']['init_script'] != '') system($inst->getinitcommand($conf['mydns']['init_script'], 'restart').' &> /dev/null');
	if($conf['powerdns']['installed'] == true && $conf['powerdns']['init_script'] != '') system($inst->getinitcommand($conf['powerdns']['init_script'], 'restart').' &> /dev/null');
	if($conf['bind']['installed'] == true && $conf['bind']['init_script'] != '') system($inst->getinitcommand($conf['bind']['init_script'], 'restart').' &> /dev/null');
	//if($conf['squid']['installed'] == true && $conf['squid']['init_script'] != '' && is_file($conf['init_scripts'].'/'.$conf['squid']['init_script']))     system($conf['init_scripts'].'/'.$conf['squid']['init_script'].' restart &> /dev/null');
	if($conf['nginx']['installed'] == true && $conf['nginx']['init_script'] != '') system($inst->getinitcommand($conf['nginx']['init_script'], 'restart').' &> /dev/null');
	//if($conf['ufw']['installed'] == true && $conf['ufw']['init_script'] != '' && is_file($conf['init_scripts'].'/'.$conf['ufw']['init_script']))     system($conf['init_scripts'].'/'.$conf['ufw']['init_script'].' restart &> /dev/null');
} else {

	//* In expert mode, we select the services in the following steps, only db is always available
	$conf['services']['mail'] = false;
	$conf['services']['web'] = false;
	$conf['services']['dns'] = false;
	$conf['services']['db'] = true;
	$conf['services']['firewall'] = false;
	$conf['services']['proxy'] = false;


	//** Get Server ID
	// $conf['server_id'] = $inst->free_query('Unique Numeric ID of the server','1');
	// Server ID is an autoInc value of the mysql database now

	if(strtolower($inst->simple_query('Shall this server join an existing ISPConfig multiserver setup', array('y', 'n'), 'n')) == 'y') {
		$conf['mysql']['master_slave_setup'] = 'y';

		//** Get MySQL root credentials
		$finished = false;
		do {
			$tmp_mysql_server_host = $inst->free_query('MySQL master server hostname', $conf['mysql']['master_host']);
			$tmp_mysql_server_admin_user = $inst->free_query('MySQL master server root username', $conf['mysql']['master_admin_user']);
			$tmp_mysql_server_admin_password = $inst->free_query('MySQL master server root password', $conf['mysql']['master_admin_password']);
			$tmp_mysql_server_database = $inst->free_query('MySQL master server database name', $conf['mysql']['master_database']);

			//* Initialize the MySQL server connection
			if(@mysql_connect($tmp_mysql_server_host, $tmp_mysql_server_admin_user, $tmp_mysql_server_admin_password)) {
				$conf['mysql']['master_host'] = $tmp_mysql_server_host;
				$conf['mysql']['master_admin_user'] = $tmp_mysql_server_admin_user;
				$conf['mysql']['master_admin_password'] = $tmp_mysql_server_admin_password;
				$conf['mysql']['master_database'] = $tmp_mysql_server_database;
				$finished = true;
			} else {
				swriteln($inst->lng('Unable to connect to mysql server').' '.mysql_error());
			}
		} while ($finished == false);
		unset($finished);

		// initialize the connection to the master database
		$inst->dbmaster = new db();
		if($inst->dbmaster->linkId) $inst->dbmaster->closeConn();
		$inst->dbmaster->dbHost = $conf['mysql']["master_host"];
		$inst->dbmaster->dbName = $conf['mysql']["master_database"];
		$inst->dbmaster->dbUser = $conf['mysql']["master_admin_user"];
		$inst->dbmaster->dbPass = $conf['mysql']["master_admin_password"];

	} else {
		// the master DB is the same then the slave DB
		$inst->dbmaster = $inst->db;
	}

	//* Create the mysql database
	$inst->configure_database();

	//* Configure Webserver - Apache or nginx
	if($conf['apache']['installed'] == true && $conf['nginx']['installed'] == true) {
		$http_server_to_use = $inst->simple_query('Apache and nginx detected. Select server to use for ISPConfig:', array('apache', 'nginx'), 'apache');
		if($http_server_to_use == 'apache'){
			$conf['nginx']['installed'] = false;
		} else {
			$conf['apache']['installed'] = false;
		}
	}

	//* Insert the Server record into the database
	swriteln('Adding ISPConfig server record to database.');
	swriteln('');
	$inst->add_database_server_record();


	if(strtolower($inst->simple_query('Configure Mail', array('y', 'n') , 'y') ) == 'y') {

		$conf['services']['mail'] = true;

		//* Configure Postfix
		swriteln('Configuring Postfix');
		$inst->configure_postfix();

		//* Configure Mailman
		swriteln('Configuring Mailman');
		$inst->configure_mailman();

		if($conf['dovecot']['installed'] == true) {
			//* Configure dovecot
			swriteln('Configuring Dovecot');
			$inst->configure_dovecot();
		} else {

			//* Configure saslauthd
			swriteln('Configuring SASL');
			$inst->configure_saslauthd();

			//* Configure PAM
			swriteln('Configuring PAM');
			$inst->configure_pam();

			//* Configure courier
			swriteln('Configuring Courier');
			$inst->configure_courier();
		}

		//* Configure Spamasassin
		swriteln('Configuring Spamassassin');
		$inst->configure_spamassassin();

		//* Configure Amavis
		swriteln('Configuring Amavisd');
		$inst->configure_amavis();

		//* Configure Getmail
		swriteln('Configuring Getmail');
		$inst->configure_getmail();

		if($conf['postfix']['installed'] == true && $conf['postfix']['init_script'] != '') system($inst->getinitcommand($conf['postfix']['init_script'], 'restart'));
		if($conf['saslauthd']['installed'] == true && $conf['saslauthd']['init_script'] != '') system($inst->getinitcommand($conf['saslauthd']['init_script'], 'restart'));
		if($conf['amavis']['installed'] == true && $conf['amavis']['init_script'] != '') system($inst->getinitcommand($conf['amavis']['init_script'], 'restart'));
		if($conf['clamav']['installed'] == true && $conf['clamav']['init_script'] != '') system($inst->getinitcommand($conf['clamav']['init_script'], 'restart'));
		if($conf['courier']['installed'] == true){
			if($conf['courier']['courier-authdaemon'] != '') system($inst->getinitcommand($conf['courier']['courier-authdaemon'], 'restart'));
			if($conf['courier']['courier-imap'] != '') system($inst->getinitcommand($conf['courier']['courier-imap'], 'restart'));
			if($conf['courier']['courier-imap-ssl'] != '') system($inst->getinitcommand($conf['courier']['courier-imap-ssl'], 'restart'));
			if($conf['courier']['courier-pop'] != '') system($inst->getinitcommand($conf['courier']['courier-pop'], 'restart'));
			if($conf['courier']['courier-pop-ssl'] != '') system($inst->getinitcommand($conf['courier']['courier-pop-ssl'], 'restart'));
		}
		if($conf['dovecot']['installed'] == true && $conf['dovecot']['init_script'] != '') system($inst->getinitcommand($conf['dovecot']['init_script'], 'restart'));
		if($conf['mailman']['installed'] == true && $conf['mailman']['init_script'] != '') system('nohup '.$inst->getinitcommand($conf['mailman']['init_script'], 'restart').' >/dev/null 2>&1 &');
	}

	//** Configure Jailkit
	if(strtolower($inst->simple_query('Configure Jailkit', array('y', 'n'), 'y') ) == 'y') {
		swriteln('Configuring Jailkit');
		$inst->configure_jailkit();
	}

	//** Configure Pureftpd
	if(strtolower($inst->simple_query('Configure FTP Server', array('y', 'n'), 'y') ) == 'y') {
		swriteln('Configuring Pureftpd');
		$inst->configure_pureftpd();
		if($conf['pureftpd']['installed'] == true && $conf['pureftpd']['init_script'] != '') system($inst->getinitcommand($conf['pureftpd']['init_script'], 'restart'));
	}

	//** Configure DNS
	if(strtolower($inst->simple_query('Configure DNS Server', array('y', 'n'), 'y')) == 'y') {
		$conf['services']['dns'] = true;
		//* Configure DNS
		if($conf['powerdns']['installed'] == true) {
			swriteln('Configuring PowerDNS');
			$inst->configure_powerdns();
			if($conf['powerdns']['init_script'] != '') system($inst->getinitcommand($conf['powerdns']['init_script'], 'restart').' &> /dev/null');
		} elseif($conf['bind']['installed'] == true) {
			swriteln('Configuring BIND');
			$inst->configure_bind();
			if($conf['bind']['init_script'] != '') system($inst->getinitcommand($conf['bind']['init_script'], 'restart').' &> /dev/null');
		} else {
			swriteln('Configuring MyDNS');
			$inst->configure_mydns();
			if($conf['mydns']['init_script'] != '') system($inst->getinitcommand($conf['mydns']['init_script'], 'restart').' &> /dev/null');
		}

	}

	/*
	//** Configure Squid
	if(strtolower($inst->simple_query('Configure Proxy Server', array('y','n'),'y') ) == 'y') {
		if($conf['squid']['installed'] == true) {
			$conf['services']['proxy'] = true;
			swriteln('Configuring Squid');
			$inst->configure_squid();
			if($conf['squid']['init_script'] != '' && is_executable($conf['init_scripts'].'/'.$conf['squid']['init_script']))system($conf['init_scripts'].'/'.$conf['squid']['init_script'].' restart &> /dev/null');
		} else if($conf['nginx']['installed'] == true) {
			$conf['services']['proxy'] = true;
			swriteln('Configuring Nginx');
			$inst->configure_nginx();
			if($conf['nginx']['init_script'] != '' && is_executable($conf['init_scripts'].'/'.$conf['nginx']['init_script']))system($conf['init_scripts'].'/'.$conf['nginx']['init_script'].' restart &> /dev/null');
		}
	}
	*/

	//** Configure Apache
	if($conf['apache']['installed'] == true){
		swriteln("\nHint: If this server shall run the ISPConfig interface, select 'y' in the 'Configure Apache Server' option.\n");
		if(strtolower($inst->simple_query('Configure Apache Server', array('y', 'n'), 'y')) == 'y') {
			$conf['services']['web'] = true;
			swriteln('Configuring Apache');
			$inst->configure_apache();

			//** Configure Vlogger
			swriteln('Configuring Vlogger');
			$inst->configure_vlogger();

			//** Configure apps vhost
			swriteln('Configuring Apps vhost');
			$inst->configure_apps_vhost();
		}
	}

	//** Configure nginx
	if($conf['nginx']['installed'] == true){
		swriteln("\nHint: If this server shall run the ISPConfig interface, select 'y' in the 'Configure nginx Server' option.\n");
		if(strtolower($inst->simple_query('Configure nginx Server', array('y', 'n'), 'y')) == 'y') {
			$conf['services']['web'] = true;
			swriteln('Configuring nginx');
			$inst->configure_nginx();

			//** Configure Vlogger
			//swriteln('Configuring Vlogger');
			//$inst->configure_vlogger();

			//** Configure apps vhost
			swriteln('Configuring Apps vhost');
			$inst->configure_apps_vhost();
		}
	}

	//** Configure Firewall
	if(strtolower($inst->simple_query('Configure Firewall Server', array('y', 'n'), 'y')) == 'y') {
		//if($conf['bastille']['installed'] == true) {
		//* Configure Bastille Firewall
		$conf['services']['firewall'] = true;
		swriteln('Configuring Bastille Firewall');
		$inst->configure_firewall();
		/*} elseif($conf['ufw']['installed'] == true) {
			//* Configure Ubuntu Firewall
			$conf['services']['firewall'] = true;
			swriteln('Configuring Ubuntu Firewall');
			$inst->configure_ufw_firewall();
		}
		*/
	}

	//** Configure Firewall
	/*if(strtolower($inst->simple_query('Configure Firewall Server',array('y','n'),'y')) == 'y') {
		swriteln('Configuring Firewall');
		$inst->configure_firewall();
	}*/

	//** Configure ISPConfig :-)
	$install_ispconfig_interface_default = ($conf['mysql']['master_slave_setup'] == 'y')?'n':'y';
	if(strtolower($inst->simple_query('Install ISPConfig Web Interface', array('y', 'n'), $install_ispconfig_interface_default)) == 'y') {
		swriteln('Installing ISPConfig');

		//** We want to check if the server is a module or cgi based php enabled server
		//** TODO: Don't always ask for this somehow ?
		/*
		$fast_cgi = $inst->simple_query('CGI PHP Enabled Server?', array('yes','no'),'no');

		if($fast_cgi == 'yes') {
	 		$alias = $inst->free_query('Script Alias', '/php/');
	 		$path = $inst->free_query('Script Alias Path', '/path/to/cgi/bin');
	 		$conf['apache']['vhost_cgi_alias'] = sprintf('ScriptAlias %s %s', $alias, $path);
		} else {
	 		$conf['apache']['vhost_cgi_alias'] = "";
		}
		*/

		//** Customise the port ISPConfig runs on
		$ispconfig_vhost_port = $inst->free_query('ISPConfig Port', '8080');
		if($conf['apache']['installed'] == true) $conf['apache']['vhost_port']  = $ispconfig_vhost_port;
		if($conf['nginx']['installed'] == true) $conf['nginx']['vhost_port']  = $ispconfig_vhost_port;
		unset($ispconfig_vhost_port);

		if(strtolower($inst->simple_query('Enable SSL for the ISPConfig web interface', array('y', 'n'), 'y')) == 'y') {
			$inst->make_ispconfig_ssl_cert();
		}

		$inst->install_ispconfig_interface = true;

	} else {
		$inst->install_ispconfig_interface = false;
	}

	$inst->install_ispconfig();

	//* Configure DBServer
	swriteln('Configuring DBServer');
	$inst->configure_dbserver();

	//* Configure ISPConfig
	swriteln('Installing ISPConfig crontab');
	$inst->install_crontab();
	if($conf['apache']['installed'] == true && $conf['apache']['init_script'] != '') system($inst->getinitcommand($conf['apache']['init_script'], 'restart'));
	//* Reload is enough for nginx
	if($conf['nginx']['installed'] == true){
		if($conf['nginx']['php_fpm_init_script'] != '') system($inst->getinitcommand($conf['nginx']['php_fpm_init_script'], 'reload'));
		if($conf['nginx']['init_script'] != '') system($inst->getinitcommand($conf['nginx']['init_script'], 'reload'));
	}



} //* << $install_mode / 'Standard' or Genius


echo "Installation completed.\n";


?>
EOF

php install.php
