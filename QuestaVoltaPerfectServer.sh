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
cd ispconfig3_install/install/  >> $LOG 2>&1
mv /tmp/ispconfig3_install/install/install.php /tmp/ispconfig3_install/install/install.php.bak  >> $LOG 2>&1
wget https://raw.githubusercontent.com/nicktrela/qv-server-install/master/perfectServer_ISPConfig_install.php  >> $LOG 2>&1
mv perfectServer_ISPConfig_install.php /tmp/ispconfig3_install/install/install.php  >> $LOG 2>&1
php install.php
