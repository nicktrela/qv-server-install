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

echo -e "\033[31mThis script will set up a Questa Volta Optimized Web Server.\033[0m"
# read areyousure
# if [ $areyousure != "YES" ]
# then exit 1
# else echo -e "\033[31mStarting installation...\033[0m"
# fi

test "$(whoami)" != 'root' && (echo -e "\033[31mYou are using a non-privileged account. Please log in as root.\033[0m"; exit 1)

LOG=/root/log_script.log

# Create hostname & servername variables
hostname="$(hostname)"
servername=$(echo "$(hostname)" | sed 's/.idthq.com//g')
  
echo "NOZEROCONF=yes" >> /etc/sysconfig/network

# Configuration of repository for CentOS
configure_repo() {
  yum -y install wget >> $LOG 2>&1
  
  echo -e "[\033[33m*\033[0m] Installing & configuring epel, rpmforge repos..." && echo -e "[\033[33m*\033[0m] Installing & configuring epel, rpmforge repos..." >> /tmp/server_log.txt
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* >> $LOG 2>&1
  rpm --import http://dag.wieers.com/rpm/packages/RPM-GPG-KEY.dag.txt >> $LOG 2>&1
  cd /tmp
  wget http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm >> $LOG 2>&1
  rpm -ivh rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm >> $LOG 2>&1
  
  rpm --import https://fedoraproject.org/static/0608B895.txt >> $LOG 2>&1
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >> $LOG 2>&1
  rpm -ivh epel-release-6-8.noarch.rpm >> $LOG 2>&1
  
  #rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] ($LINENO) Error import key remi"
  #rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm >> $LOG 2>&1  || echo -e "[\033[31mX\033[0m] ($LINENO) Error installing rpm remi"

  yum install yum-priorities -y >> $LOG 2>&1
  awk 'NR== 2 { print "priority=10" } { print }' /etc/yum.repos.d/epel.repo > /tmp/epel.repo
  rm /etc/yum.repos.d/epel.repo -f >> $LOG 2>&1
  mv /tmp/epel.repo /etc/yum.repos.d >> $LOG 2>&1
  
  #sed -i -e "0,/5/s/enabled=0/enabled=1/" /etc/yum.repos.d/remi.repo
}

pword() {
  # Password generator
  date +%s | sha256sum | base64 | head -c 24 ; echo
}

update_system() {
  echo -e "[\033[33m*\033[0m] Updating full system (This could take a while...)" && echo -e "[\033[33m*\033[0m] Updating full system" >> /tmp/server_log.txt
  yum update -y >> $LOG 2>&1
}

install_required_packages() {
  echo -e "[\033[33m*\033[0m] Installing required packages" && echo -e "[\033[33m*\033[0m] Installing required packages" >> /tmp/server_log.txt
  yum install -y vim htop iftop nmap screen git expect >> $LOG 2>&1 || echo -e "[\033[31mX\033[0m] ($LINENO) Error installing base packages" >> /tmp/server_log.txt
  echo -e "[\033[33m*\033[0m] Installing Development Tools" && echo -e "[\033[33m*\033[0m] Installing Development Tools" >> /tmp/server_log.txt 
  yum groupinstall -y 'Development Tools'  >> $LOG 2>&1
}

install_quota(){
  echo -e "[\033[33m*\033[0m] Installing and configuring Quota" && echo -e "[\033[33m*\033[0m] Installing and configuring Quota" >> /tmp/server_log.txt
  yum install quota -y >> $LOG 2>&1
  sed -i "s#/dev/mapper/VolGroup-lv_root /                       ext4    defaults#/dev/mapper/VolGroup-lv_root /                       ext4    defaults,noatime,usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0#" /etc/fstab >> $LOG 2>&1
  touch /quota.user /quota.group
  chmod 600 /quota.*
  echo -e "[\033[33m*\033[0m] Remounting..." && echo -e "[\033[33m*\033[0m] Remounting..." >> /tmp/server_log.txt
  mount -o remount / >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error remounting" >> /tmp/server_log.txt
  echo -e "[\033[33m*\033[0m] Enabling Quota" && echo -e "[\033[33m*\033[0m] Enabling Quota" >> /tmp/server_log.txt
  quotacheck -avugm >> $LOG 2>&1 
  quotaon -avug >> $LOG 2>&1 
}

install_ntpd() {
  echo -e "[\033[33m*\033[0m] Installing and configuring NTPD" && echo -e "[\033[33m*\033[0m] Installing and configuring NTPD" >> /tmp/server_log.txt
  yum install -y ntp  >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing" >> /tmp/server_log.txt
  chkconfig ntpd on >> $LOG 2>&1
}

install_apache_phpMyAdmin(){
  echo -e "[\033[33m*\033[0m] Installing Apache, MySQL and phpMyAdmin..." && echo -e "[\033[33m*\033[0m] Installing Apache, MySQL and phpMyAdmin..." >> /tmp/server_log.txt
  yum install ntp httpd mod_ssl php php-mysql php-mbstring phpmyadmin -y >> $LOG 2>&1
}

disable_fw() {
  echo -e "[\033[33m*\033[0m] Disabling Firewall (for installation time)" && echo -e "[\033[33m*\033[0m] Disabling Firewall (for installation time)" >> /tmp/server_log.txt
  service iptables save >> $LOG 2>&1
  service iptables stop >> $LOG 2>&1
  chkconfig iptables off >> $LOG 2>&1
}

disable_selinux() {
  echo -e "[\033[33m*\033[0m] Disabling SELinux" && echo -e "[\033[33m*\033[0m] Disabling SELinux" >> /tmp/server_log.txt
  sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
  setenforce 0 >> $LOG 2>&1
}

install_atop_htop(){
  echo -e "[\033[33m*\033[0m] Installing atop" && echo -e "[\033[33m*\033[0m] Installing atop" >> /tmp/server_log.txt
  yum install atop -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing atop" >> /tmp/server_log.txt
  echo -e "[\033[33m*\033[0m] Installing htop" && echo -e "[\033[33m*\033[0m] Installing htop" >> /tmp/server_log.txt
  yum install htop -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing htop" >> /tmp/server_log.txt
}
install_mysql() {
  echo -e "[\033[33m*\033[0m] Installing MYSQL Server" && echo -e "[\033[33m*\033[0m] Installing MYSQL Server" >> /tmp/server_log.txt
  yum install mysql mysql-server -y >> $LOG 2>&1
  chkconfig --levels 235 mysqld on >> $LOG 2>&1
  /etc/init.d/mysqld start >> $LOG 2>&1
    
  echo "Generating MySQL Root PW: "
  mysqlrootpw=$(pword)
  echo $mysqlrootpw
  
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

  echo "$SECURE_MYSQL" >> $LOG 2>&1
}

MySQLCreateDB(){
  BTICK='`'
  EXPECTED_ARGS=3
  E_BADARGS=65
  MYSQL=`which mysql`
 
  Q1="CREATE DATABASE IF NOT EXISTS $1;"
  Q2="GRANT ALL ON ${BTICK}$1${BTICK}.* TO '$2'@'localhost' IDENTIFIED BY '$3';"
  Q3="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}"
 
  if [ $# -ne $EXPECTED_ARGS ]
  then
    echo "Usage: $0 dbname dbuser dbpass"
    exit $E_BADARGS
  fi
 
  $MYSQL -uroot -p$(cat /tmp/mysqlpw.conf) -e "$SQL"
}

MySQLCreateFirewall(){
  BTICK='`'
  EXPECTED_ARGS=0
  E_BADARGS=65
  MYSQL=`which mysql`

  Q1="INSERT INTO ${BTICK}dbispconfig${BTICK}.${BTICK}firewall${BTICK} (${BTICK}firewall_id${BTICK}, ${BTICK}sys_userid${BTICK}, ${BTICK}sys_groupid${BTICK}, ${BTICK}sys_perm_user${BTICK}, ${BTICK}sys_perm_group${BTICK}, ${BTICK}sys_perm_other${BTICK}, ${BTICK}server_id${BTICK}, ${BTICK}tcp_port${BTICK}, ${BTICK}udp_port${BTICK}, ${BTICK}active${BTICK}) VALUES ('2', '1', '1', 'riud', 'riud', '', '1', '20,21,22,25,53,80,110,143,443,587,993,995,3306,8080,8081,10000', '53,3306', 'y');"
  SQL="${Q1}"
   
  $MYSQL -uroot -p$(cat /tmp/mysqlpw.conf) -e "$SQL"
}

MySQLCreateRemoteISPConfigUser(){
  BTICK='`'
  EXPECTED_ARGS=2
  E_BADARGS=65
  MYSQL=`which mysql`
  
  Q1="INSERT INTO ${BTICK}dbispconfig${BTICK}.${BTICK}remote_user${BTICK} (${BTICK}remote_userid${BTICK}, ${BTICK}sys_userid${BTICK}, ${BTICK}sys_groupid${BTICK}, ${BTICK}sys_perm_user${BTICK}, ${BTICK}sys_perm_group${BTICK}, ${BTICK}sys_perm_other${BTICK}, ${BTICK}remote_username${BTICK}, ${BTICK}remote_password${BTICK}, ${BTICK}remote_functions${BTICK}) VALUES ('1', '1', '1', 'riud', 'riud', NULL, '$1', MD5('$2'), 'server_get,get_function_list,client_templates_get_all,server_get_serverid_by_ip,server_ip_get,server_ip_add,server_ip_update,server_ip_delete;admin_record_permissions;vm_openvz;mail_domain_get,mail_domain_add,mail_domain_update,mail_domain_delete,mail_domain_set_status,mail_domain_get_by_domain;mail_aliasdomain_get,mail_aliasdomain_add,mail_aliasdomain_update,mail_aliasdomain_delete;mail_mailinglist_get,mail_mailinglist_add,mail_mailinglist_update,mail_mailinglist_delete;mail_user_get,mail_user_add,mail_user_update,mail_user_delete;mail_alias_get,mail_alias_add,mail_alias_update,mail_alias_delete;mail_forward_get,mail_forward_add,mail_forward_update,mail_forward_delete;mail_catchall_get,mail_catchall_add,mail_catchall_update,mail_catchall_delete;mail_transport_get,mail_transport_add,mail_transport_update,mail_transport_delete;mail_relay_get,mail_relay_add,mail_relay_update,mail_relay_delete;mail_whitelist_get,mail_whitelist_add,mail_whitelist_update,mail_whitelist_delete;mail_blacklist_get,mail_blacklist_add,mail_blacklist_update,mail_blacklist_delete;mail_spamfilter_user_get,mail_spamfilter_user_add,mail_spamfilter_user_update,mail_spamfilter_user_delete;mail_policy_get,mail_policy_add,mail_policy_update,mail_policy_delete;mail_fetchmail_get,mail_fetchmail_add,mail_fetchmail_update,mail_fetchmail_delete;mail_spamfilter_whitelist_get,mail_spamfilter_whitelist_add,mail_spamfilter_whitelist_update,mail_spamfilter_whitelist_delete;mail_spamfilter_blacklist_get,mail_spamfilter_blacklist_add,mail_spamfilter_blacklist_update,mail_spamfilter_blacklist_delete;mail_user_filter_get,mail_user_filter_add,mail_user_filter_update,mail_user_filter_delete;mail_filter_get,mail_filter_add,mail_filter_update,mail_filter_delete;sites_cron_get,sites_cron_add,sites_cron_update,sites_cron_delete;sites_database_get,sites_database_add,sites_database_update,sites_database_delete, sites_database_get_all_by_user,sites_database_user_get,sites_database_user_add,sites_database_user_update,sites_database_user_delete, sites_database_user_get_all_by_user;sites_web_folder_get,sites_web_folder_add,sites_web_folder_update,sites_web_folder_delete,sites_web_folder_user_get,sites_web_folder_user_add,sites_web_folder_user_update,sites_web_folder_user_delete;sites_ftp_user_get,sites_ftp_user_server_get,sites_ftp_user_add,sites_ftp_user_update,sites_ftp_user_delete;sites_shell_user_get,sites_shell_user_add,sites_shell_user_update,sites_shell_user_delete;sites_web_domain_get,sites_web_domain_add,sites_web_domain_update,sites_web_domain_delete,sites_web_domain_set_status;sites_web_aliasdomain_get,sites_web_aliasdomain_add,sites_web_aliasdomain_update,sites_web_aliasdomain_delete;sites_web_subdomain_get,sites_web_subdomain_add,sites_web_subdomain_update,sites_web_subdomain_delete;dns_zone_get,dns_zone_get_id,dns_zone_add,dns_zone_update,dns_zone_delete,dns_zone_set_status,dns_templatezone_add;dns_a_get,dns_a_add,dns_a_update,dns_a_delete;dns_aaaa_get,dns_aaaa_add,dns_aaaa_update,dns_aaaa_delete;dns_alias_get,dns_alias_add,dns_alias_update,dns_alias_delete;dns_cname_get,dns_cname_add,dns_cname_update,dns_cname_delete;dns_hinfo_get,dns_hinfo_add,dns_hinfo_update,dns_hinfo_delete;dns_mx_get,dns_mx_add,dns_mx_update,dns_mx_delete;dns_ns_get,dns_ns_add,dns_ns_update,dns_ns_delete;dns_ptr_get,dns_ptr_add,dns_ptr_update,dns_ptr_delete;dns_rp_get,dns_rp_add,dns_rp_update,dns_rp_delete;dns_srv_get,dns_srv_add,dns_srv_update,dns_srv_delete;dns_txt_get,dns_txt_add,dns_txt_update,dns_txt_delete;client_get_all,client_get,client_add,client_update,client_delete,client_get_sites_by_user,client_get_by_username,client_change_password,client_get_id,client_delete_everything;domains_domain_get,domains_domain_add,domains_domain_delete,domains_get_all_by_user')"
  SQL="${Q1}"
 
  if [ $# -ne $EXPECTED_ARGS ]
  then
    echo "Usage: $0 Args: username password"
    exit $E_BADARGS
  fi
 
  $MYSQL -uroot -p$(cat /tmp/mysqlpw.conf) -e "$SQL"
}

MySQLChangeCPAdminPass(){
  BTICK='`'
  EXPECTED_ARGS=1
  E_BADARGS=65
  MYSQL=`which mysql`
  
  Q1="UPDATE  ${BTICK}dbispconfig${BTICK}.${BTICK}sys_user${BTICK} SET  ${BTICK}passwort${BTICK} = MD5('$1') WHERE  ${BTICK}sys_user${BTICK}.${BTICK}userid${BTICK} =1 LIMIT 1 ;"
  SQL="${Q1}"
 
  if [ $# -ne $EXPECTED_ARGS ]
  then
    echo "Usage: $0 Args: newAdminPass"
    exit $E_BADARGS
  fi
 
  $MYSQL -uroot -p$(cat /tmp/mysqlpw.conf) -e "$SQL" >> $LOG 2>&1
}
MySQLAddIP(){
  BTICK='`'
  EXPECTED_ARGS=1
  E_BADARGS=65
  MYSQL=`which mysql`

  Q1="INSERT INTO  ${BTICK}dbispconfig${BTICK}.${BTICK}server_ip${BTICK} (${BTICK}server_ip_id${BTICK} ,${BTICK}sys_userid${BTICK} ,${BTICK}sys_groupid${BTICK} ,${BTICK}sys_perm_user${BTICK} ,${BTICK}sys_perm_group${BTICK} ,${BTICK}sys_perm_other${BTICK} ,${BTICK}server_id${BTICK} ,${BTICK}client_id${BTICK} ,${BTICK}ip_type${BTICK} ,${BTICK}ip_address${BTICK} ,${BTICK}virtualhost${BTICK} ,${BTICK}virtualhost_port${BTICK})VALUES ('1',  '1',  '1',  'riud',  'riud',  '',  '1',  '1',  'IPv4',  '$1',  'y',  '80,443')"
  SQL="${Q1}"
  
  if [ $# -ne $EXPECTED_ARGS ]
  then
    echo "Usage: $0 Args: ipAddress"
    exit $E_BADARGS
  fi
  
  $MYSQL -uroot -p$(cat /tmp/mysqlpw.conf) -e "$SQL" >> $LOG 2>&1
}
install_dovecot() {
  echo -e "[\033[33m*\033[0m] Installing DOVECOT Server" && echo -e "[\033[33m*\033[0m] Installing DOVECOT Server" >> /tmp/server_log.txt
  yum install dovecot dovecot-mysql -y >> $LOG 2>&1
  chkconfig --levels 235 dovecot on >> $LOG 2>&1
  /etc/init.d/dovecot start >> $LOG 2>&1
}
  
install_postfix() {  
  echo -e "[\033[33m*\033[0m] Installing Postfix Server" && echo -e "[\033[33m*\033[0m] Installing Postfix Server" >> /tmp/server_log.txt
  yum install postfix -y >> $LOG 2>&1
  chkconfig --levels 235 postfix on >> $LOG 2>&1
  /etc/init.d/mysqld start >> $LOG 2>&1
  chkconfig --levels 235 postfix on >> $LOG 2>&1
  /etc/init.d/postfix restart >> $LOG 2>&1
}
  
install_getmail() {
  echo -e "[\033[33m*\033[0m] Installing getmail" >> /tmp/server_log.txt
  yum install getmail -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing" >> /tmp/server_log.txt
}


install_modphp(){
  echo -e "[\033[33m*\033[0m] Installing Apache2 With mod_php, mod_fcgi/PHP5, And suPHP" && echo -e "[\033[33m*\033[0m] Installing Apache2 With mod_php, mod_fcgi/PHP5, And suPHP" >> /tmp/server_log.txt
  yum install php php-devel php-gd php-imap php-ldap php-mysql php-odbc php-pear php-xml php-xmlrpc php-pecl-apc php-mbstring php-mcrypt php-mssql php-snmp php-soap php-tidy curl curl-devel perl-libwww-perl ImageMagick libxml2 libxml2-devel mod_fcgid php-cli httpd-devel -y >> $LOG 2>&1
  sed -i 's/; cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/' /etc/php.ini >> $LOG 2>&1
  sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/' /etc/php.ini >> $LOG 2>&1 
  sed -i 's/error_reporting = E_ALL \&\ ~E_DEPRECATED/error_reporting = E_ALL \&\ ~E_NOTICE/' /etc/php.ini >> $LOG 2>&1
  cd /tmp >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Getting suPHP" && echo -e "[\033[33m*\033[0m] Getting suPHP" >> /tmp/server_log.txt
  wget http://suphp.org/download/suphp-0.7.1.tar.gz >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Unzipping" && echo -e "[\033[33m*\033[0m] Unzipping" >> /tmp/server_log.txt
  tar xvfz suphp-0.7.1.tar.gz >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Installing suPHP" && echo -e "[\033[33m*\033[0m] Installing suPHP" >> /tmp/server_log.txt
  cd suphp-0.7.1/ >> $LOG 2>&1
  ./configure --prefix=/usr --sysconfdir=/etc --with-apr=/usr/bin/apr-1-config --with-apxs=/usr/sbin/apxs --with-apache-user=apache --with-setid-mode=owner --with-php=/usr/bin/php-cgi --with-logfile=/var/log/httpd/suphp_log --enable-SUPHP_USE_USERGROUP=yes >> $LOG 2>&1
  make >> $LOG 2>&1
  make install >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Adding suPHP to Apache Configuration" && echo -e "[\033[33m*\033[0m] Adding suPHP to Apache Configuration" >> /tmp/server_log.txt
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

  echo -e "[\033[33m*\033[0m] Restarting Apache" && echo -e "[\033[33m*\033[0m] Restarting Apache" >> /tmp/server_log.txt
  /etc/init.d/httpd restart >> $LOG 2>&1

}


install_pma() {
  echo -e "[\033[33m*\033[0m] Configuring PHPmyAdmin" && echo -e "[\033[33m*\033[0m] Configuring PHPmyAdmin" >> /tmp/server_log.txt
  yum install phpmyadmin -y >> $LOG 2>&1
  mv /usr/share/phpmyadmin/config.inc.php /usr/share/phpmyadmin/config.inc.php.bak >> $LOG 2>&1
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
  sed -e '/<Directory/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1
  sed -e '/Order Deny,Allow/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1
  sed -e '/Deny from all/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1
  sed -e '/Allow from 127.0.0.1/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1
  sed -e '/Directory/ s/^#*/#/' -i /etc/httpd/conf.d/phpmyadmin.conf >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Starting Apache..." && echo -e "[\033[33m*\033[0m] Starting Apache..." >> /tmp/server_log.txt
  chkconfig --levels 235 httpd on >> $LOG 2>&1
  /etc/init.d/httpd start >> $LOG 2>&1
}

install_ftpd() {
  echo -e "[\033[33m*\033[0m] Installing PureFTPD" && echo -e "[\033[33m*\033[0m] Installing PureFTPD" >> /tmp/server_log.txt
  yum install pure-ftpd -y >> $LOG 2>&1
  chkconfig --levels 235 pure-ftpd on >> $LOG 2>&1
  /etc/init.d/pure-ftpd start >> $LOG 2>&1
  yum install openssl -y >> $LOG 2>&1
  sed -i 's/# TLS                      1/TLS    1/' /etc/pure-ftpd/pure-ftpd.conf >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Generating PureFTP SSL Certificate" && echo -e "[\033[33m*\033[0m] Generating PureFTP SSL Certificate" >> /tmp/server_log.txt
  mkdir -p /etc/ssl/private/ >> $LOG 2>&1
  openssl req -new -newkey rsa:2048 -days 7300 -nodes -x509 -subj "/C=US/ST=California/L=Los Angeles/O=Questa Volta/CN=\'$hostname\'" -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Changing SSL Certificate Permissions" && echo -e "[\033[33m*\033[0m] Changing SSL Certificate Permissions" >> /tmp/server_log.txt
  chmod 600 /etc/ssl/private/pure-ftpd.pem >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Restarting PureFTPD" && echo -e "[\033[33m*\033[0m] Restarting PureFTPD" >> /tmp/server_log.txt
  /etc/init.d/pure-ftpd restart >> $LOG 2>&1

}

install_bind() {
  echo -e "[\033[33m*\033[0m] Installing BIND" && echo -e "[\033[33m*\033[0m] Installing BIND" >> /tmp/server_log.txt
  yum install bind bind-utils -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing" >> /tmp/server_log.txt
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
  echo -e "[\033[33m*\033[0m] Installing Python..." && echo -e "[\033[33m*\033[0m] Installing Python..." >> /tmp/server_log.txt
  yum install mod_python -y >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Restarting Apache" && echo -e "[\033[33m*\033[0m] Restarting Apache" >> /tmp/server_log.txt
  /etc/init.d/httpd restart >> $LOG 2>&1
}



install_awstat() {
  echo -e "[\033[33m*\033[0m] Setting up Webalizer and AWStats" && echo -e "[\033[33m*\033[0m] Setting up Webalizer and AWStats" >> /tmp/server_log.txt
  yum install webalizer awstats perl-DateTime-Format-HTTP perl-DateTime-Format-Builder -y >> $LOG 2>&1
}

install_jailkit() {
  echo -e "[\033[33m*\033[0m] Installing Jailkit" && echo -e "[\033[33m*\033[0m] Installing Jailkit" >> /tmp/server_log.txt
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
  echo -e "[\033[33m*\033[0m] Installing fail2ban & RootkitHunter" && echo -e "[\033[33m*\033[0m] Installing fail2ban & RootkitHunter" >> /tmp/server_log.txt
  yum install fail2ban -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing" >> /tmp/server_log.txt
  sed -i 's,logtarget = SYSLOG,logtarget = /var/log/fail2ban.log,' /etc/fail2ban/fail2ban.conf  >> $LOG 2>&1
  chkconfig --levels 235 fail2ban on >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Starting fail2ban" && echo -e "[\033[33m*\033[0m] Starting fail2ban" >> /tmp/server_log.txt
  /etc/init.d/fail2ban start >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Installing rkhunter" && echo -e "[\033[33m*\033[0m] Installing rkhunter" >> /tmp/server_log.txt
  yum install rkhunter -y >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error installing" >> /tmp/server_log.txt
}

install_roundcube(){
  echo -e "[\033[33m*\033[0m] Installing Roundcube" && echo -e "[\033[33m*\033[0m] Installing Roundcube" >> /tmp/server_log.txt
  mkdir /usr/share/webmail >> $LOG 2>&1
  cd /usr/share/webmail >> $LOG 2>&1
  wget http://jaist.dl.sourceforge.net/project/roundcubemail/roundcubemail/1.0.0/roundcubemail-1.0.0.tar.gz >> $LOG 2>&1
  tar -zxvf roundcubemail-1.0.0.tar.gz >> $LOG 2>&1
  rm -rf roundcubemail-1.0.0.tar.gz >> $LOG 2>&1
  shopt -s dotglob >> $LOG 2>&1
  mv -f roundcubemail-1.0.0/* . >> $LOG 2>&1
  rmdir roundcubemail-1.0.0 >> $LOG 2>&1

  wget http://jaist.dl.sourceforge.net/project/roundcubemail/roundcubemail/1.0.0/roundcube-framework-1.0.0.tar.gz >> $LOG 2>&1
  tar -zxvf roundcube-framework-1.0.0.tar.gz >> $LOG 2>&1

  mkdir /usr/share/webmail/installer/Roundcube >> $LOG 2>&1
  cp /usr/share/webmail/roundcube-framework-1.0.0/bootstrap.php /usr/share/webmail/installer/Roundcube >> $LOG 2>&1

  chown root:root -R /usr/share/webmail  >> $LOG 2>&1
  chmod 777 -R /usr/share/webmail/temp/ >> $LOG 2>&1
  chmod 777 -R /usr/share/webmail/logs/ >> $LOG 2>&1

  cp /etc/httpd/conf/sites-enabled/000-ispconfig.conf /etc/httpd/conf/sites-enabled/000-ispconfig.conf.bak >> $LOG 2>&1

  cat <<EOF >> /etc/httpd/conf/sites-enabled/000-ispconfig.conf
  <Directory /usr/share/webmail>
    Order allow,deny
    Allow from all
  </Directory>
EOF

  cat <<EOF > /etc/httpd/conf.d/roundcube.conf
#
# Roundcube is a webmail package written in PHP.
#

Alias /webmail /usr/share/webmail

<Directory /usr/share/webmail/config>
  Order Deny,Allow
  Deny from All
</Directory>

<Directory /usr/share/webmail/temp>
  Order Deny,Allow
  Deny from All
</Directory>
 
<Directory /usr/share/webmail/logs>
  Order Deny,Allow
  Deny from All
</Directory>

# this section makes Roundcube use https connections only, for this you
# need to have mod_ssl installed. If you want to use unsecure http 
# connections, just remove this section:
<Directory /usr/share/webmail>
  RewriteEngine  on
  RewriteCond    %{HTTPS} !=on
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
</Directory>
EOF

  echo -e "[\033[33m*\033[0m] Restarting Apache" && echo -e "[\033[33m*\033[0m] restarting Apache" >> /tmp/server_log.txt
  service httpd restart >> $LOG 2>&1
  
  yum -y install libicu-devel >> $LOG 2>&1
  yum -y install php-intl >> $LOG 2>&1
  
  cp /etc/php.ini /etc/php.ini.bak >> $LOG 2>&1
  
  sed -i 's#\;date\.timezone =#date.timezone = America/Los_Angeles#' /etc/php.ini >> $LOG 2>&1
  sed -i 's#bc#/usr/share/webmail/program/include/bc#' /usr/share/webmail/installer/index.php >> $LOG 2>&1

  echo -e "[\033[33m*\033[0m] Restarting Apache" && echo -e "[\033[33m*\033[0m] restarting Apache" >> /tmp/server_log.txt
  service httpd restart >> $LOG 2>&1
    
  dbUser=roundcube_u1
  dbPass=$(pword)
  dbName=roundcubedb
  
#   create Roundcube DB
  MySQLCreateDB $dbName $dbUser $dbPass >> $LOG 2>&1
  
#   Initialize Roundcube DB
  mysql -u $dbUser -p$dbPass -h localhost $dbName < /usr/share/webmail/SQL/mysql.initial.sql >> $LOG 2>&1
    
  smtpPass=$(pword)

  config='$config'
  
  cat <<EOF > /usr/share/webmail/config/config.inc.php
<?php

/* Local configuration for Roundcube Webmail */

// ----------------------------------
// SQL DATABASE
// ----------------------------------
// Database connection string (DSN) for read+write operations
// Format (compatible with PEAR MDB2): db_provider://user:password@host/database
// Currently supported db_providers: mysql, pgsql, sqlite, mssql or sqlsrv
// For examples see http://pear.php.net/manual/en/package.database.mdb2.intro-dsn.php
// NOTE: for SQLite use absolute path: 'sqlite:////full/path/to/sqlite.db?mode=0646'
$config['db_dsnw'] = 'mysql://$dbUser:$dbPass@localhost/$dbName';

// ----------------------------------
// IMAP
// ----------------------------------
// The mail host chosen to perform the log-in.
// Leave blank to show a textbox at login, give a list of hosts
// to display a pulldown menu or set one host as string.
// To use SSL/TLS connection, enter hostname with prefix ssl:// or tls://
// Supported replacement variables:
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %s - domain name after the '@' from e-mail address provided at login screen
// For example %n = mail.domain.tld, %t = domain.tld
// WARNING: After hostname change update of mail_host column in users table is
//          required to match old user data records with the new host.
$config['default_host'] = 'localhost';

// provide an URL where a user can get support for this Roundcube installation
// PLEASE DO NOT LINK TO THE ROUNDCUBE.NET WEBSITE HERE!
$config['support_url'] = 'http://support.questavolta.com';

// replace Roundcube logo with this image
// specify an URL relative to the document root of this Roundcube installation
// an array can be used to specify different logos for specific template files, '*' for default logo
// for example array("*" => "/images/roundcube_logo.png", "messageprint" => "/images/roundcube_logo_print.png")
$config['skin_logo'] = '/images/roundcube_logo.png';

// this key is used to encrypt the users imap password which is stored
// in the session record (and the client cookie if remember password is enabled).
// please provide a string of exactly 24 chars.
$config['des_key'] = '$smtpPass';

// ----------------------------------
// PLUGINS
// ----------------------------------
// List of active plugins (in plugins/ directory)
$config['plugins'] = array();
EOF

}

initialize_ISPConfig(){
  echo -e "[\033[33m*\033[0m] Initializing ISP Config" && echo -e "[\033[33m*\033[0m] Initializing ISP Config" >> /tmp/server_log.txt

# 	move to ISP Config remote API directory
  cd /tmp/ispconfig3_install/remoting_client/examples
  
  ipAddress="$(curl ifconfig.me)" #   resolve ip address
  
#   Create remote user
  RM_PASS=$(pword)
  RM_USER='admin'
  MySQLCreateRemoteISPConfigUser $RM_USER $RM_PASS
  
  MySQLCreateFirewall
  
  MySQLAddIP $ipAddress
  
#   Modify remoting config
  sed -i "s/192.168.0.105/localhost/g" soap_config.php >> $LOG 2>&1
  sed -i "s/password = 'admin/password = '$RM_PASS/g" soap_config.php >> $LOG 2>&1
  sed -i "s#http://#https://#g" soap_config.php >> $LOG 2>&1
  
#   change cp password
#   adminPass=$(pword)
  adminPass='perf0011'
  MySQLChangeCPAdminPass $adminPass

#   add client
  clientPW=$(pword)
  clientUN=$servername
  sed -i "s/company_name' => 'awesomecompany/company_name' => '$servername/g" client_add.php >> $LOG 2>&1
  sed -i "s/contact_name' => 'name/contact_name' => '$hostname/g" client_add.php >> $LOG 2>&1
  sed -i "s/fleetstreet//g" client_add.php >> $LOG 2>&1
  sed -i "s/21337//g" client_add.php >> $LOG 2>&1
  sed -i "s/london//g" client_add.php >> $LOG 2>&1
  sed -i "s/bavaria//g" client_add.php >> $LOG 2>&1
  sed -i "s/GB/US/g" client_add.php >> $LOG 2>&1
  sed -i "s/123456789//g" client_add.php >> $LOG 2>&1
  sed -i "s/987654321//g" client_add.php >> $LOG 2>&1
  sed -i "s/546718293//g" client_add.php >> $LOG 2>&1
  sed -i "s/e@mail\.int/support@webstudioswest\.com/g" client_add.php >> $LOG 2>&1
  sed -i "s/111111111//g" client_add.php >> $LOG 2>&1
  sed -i "s/awesome//g" client_add.php >> $LOG 2>&1
  sed -i "s/guy3/$clientUN/g" client_add.php >> $LOG 2>&1
  sed -i "s/brush/$clientPW/g" client_add.php >> $LOG 2>&1
  
  php client_add.php >> $LOG 2>&1
    
#   add site

  cat - > sites_web_domain_add_new.php <<'EOF'
<?php

require 'soap_config.php';


$client = new SoapClient(null, array('location' => $soap_location,
		'uri'      => $soap_uri,
		'trace' => 1,
		'exceptions' => 1));


try {
	if($session_id = $client->login($username, $password)) {
		echo 'Logged successful. Session ID:'.$session_id.'<br />';
	}

	//* Set the function parameters.
	$client_id = 1;
	$params_website = array('server_id' => 1,  
                            'ip_address' => '*',  
                            'domain' => 'hostname',  
                            'type' => 'vhost',  
                            'parent_domain_id' => '',  
                            'vhost_type' => 'name',  
                            'hd_quota' => -1,  
                            'traffic_quota' => '-1',  
                            'cgi' =>'n',  
                            'ssi' =>'n',  
                            'suexec' =>'y',  
                            'errordocs' =>'1',  
                            'subdomain' =>'none',  
                            'ssl' =>'y',  
                            'php' =>"mod",  
                            'ruby' =>'n',  
                            'active' =>'y',  
                            'redirect_type' =>'no',  
                            'redirect_path' =>'',  
                            'ssl_state' =>'California',  
                            'ssl_organisation' =>'Questa Volta',  
                            'ssl_organisation_unit' =>'Web',  
                            'ssl_country' =>'United States',  
                            'ssl_domain' => 'hostname',  
                            'ssl_request' =>'',  
                            'ssl_cert' =>'',  
                            'ssl_bundle' =>'',  
                            'ssl_action' =>'create',    
                            'stats_password' =>'',  
                            'stats_type' =>'webalizer',  
                            'backup_interval' =>'daily',  
                            'backup_copies' =>'7',  
                            'document_root' => '/var/www/clients/client'.$client_id.'/web'.$domain_id,
                            'system_user' =>'web1',  
                            'system_group' =>'client2',  
                            'allow_override' =>'All',  
			    			'pm' => 'dynamic',
			    			'pm.min_spare_servers' => 1,
		            		'pm.max_spare_servers' => 5,
			    			'pm_process_idle_timeout' => 10,
		 	    			'pm_max_requests' => 0,
			    		    'pm.start_servers' => 2,
                            'php_open_basedir' => '/var/www/clients/client'.$client_id.'/web'.$domain_id.'/web:/var/www/clients/client'.$client_id.'/web'.$domain_id.'/private:/var/www/clients/client'.$client_id.'/web'.$domain_id.'/tmp:/var/www/hostname/web:/srv/www/hostname/web:/usr/share/php5:/usr/share/php:/tmp:/usr/share/phpmyadmin:/etc/phpmyadmin:/var/lib/phpmyadmin',
                            'custom_php_ini' =>'',   
                            'apache_directives' => '<Directory /> 
                                        Options FollowSymLinks 
                                        AllowOverride All 
                                        Order allow,deny 
                                        Allow from all 
                                        </Directory>',  
                            'client_group_id' =>$client_id +1 
                            );  
     
    $website_id = $client->sites_web_domain_add($session_id, $client_id, $params_website);  
	echo "Web Domain ID: ".$website_id."<br>";


	if($client->logout($session_id)) {
		echo 'Logged out.<br />';
	}


} catch (SoapFault $e) {
	echo $client->__getLastResponse();
	die('SOAP Error: '.$e->getMessage());
}

?>
EOF
  
  sed -i "s/hostname/$hostname/" sites_web_domain_add_new.php
  
  php sites_web_domain_add_new.php >> $LOG 2>&1
    
#   add db
  sed -i "s/db_name2/site_db/g" sites_database_add.php >> $LOG 2>&1
  
  siteDBuser='site_DB_u1'
  dbUserPW=$(pword)
  sed -i "s/database_user' => 'db_name2/database_user' => '$siteDBuser/g" sites_database_user_add.php >> $LOG 2>&1
  sed -i "s/database_password' => 'db_name2/database_password' => '$dbUserPW/g" sites_database_user_add.php >> $LOG 2>&1
  
  php sites_database_user_add.php >> $LOG 2>&1
  
  DBuserID=1
  dbName='site_db'
  sed -i "s/db_name2/$dbName/g" sites_database_add.php >> $LOG 2>&1
  sed -i "s/database_user_id' => '1/database_user_id' => '$DBuserID/g" sites_database_add.php >> $LOG 2>&1
  
  php sites_database_add.php >> $LOG 2>&1

#   add ftp usr
  ftpShellUsr=${servername}_com 	 
  ftpShellPass=$(pword)
  
  sed -i "s/threep/$ftpShellUsr/g" sites_ftp_user_add.php >> $LOG 2>&1
  sed -i "s/wood/$ftpShellPass/g" sites_ftp_user_add.php >> $LOG 2>&1
  sed -i "s#maybe#/var/www/clients/client1/web1#g" sites_ftp_user_add.php >> $LOG 2>&1
  sed -i "s/uid' => '5000/uid' => 'web1/g" sites_ftp_user_add.php >> $LOG 2>&1
  sed -i "s/gid' => '5000/gid' => 'client1/g" sites_ftp_user_add.php >> $LOG 2>&1
  sed -i "s/10000/-1/g" sites_ftp_user_add.php >> $LOG 2>&1
  
  php sites_ftp_user_add.php >> $LOG 2>&1

#   add shell usr
  sed -i "s/threep2/$ftpShellUsr/g" sites_shell_user_add.php >> $LOG 2>&1
  sed -i "s/wood/$ftpShellPass/g" sites_shell_user_add.php >> $LOG 2>&1
  sed -i "s#maybe#/var/www/clients/client1/web1#g" sites_shell_user_add.php >> $LOG 2>&1
  sed -i "s/chroot' => '/chroot' => 'no/g" sites_shell_user_add.php >> $LOG 2>&1
  sed -i "s/10000/-1/g" sites_shell_user_add.php >> $LOG 2>&1
  
  php sites_shell_user_add.php >> $LOG 2>&1
  
#   add mail domain
  sed -i "s/test.int/$hostname/g" mail_domain_add.php >> $LOG 2>&1
  
#   php mail_domain_add.php >> $LOG 2>&1
  
#   add email usr
  mailPW=$(pword)
  emailUsr='info'
  
  emailAddr=$emailUsr@$hostname
  
  sed -i "s/joe@test.int/$emailUsr\@$hostname/g" mail_user_add.php >> $LOG 2>&1
  sed -i "s/howtoforge/$mailPW/g" mail_user_add.php >> $LOG 2>&1
  sed -i "s/name' => 'joe/name' => '$servername/g" mail_user_add.php >> $LOG 2>&1
  sed -i "s#maildir' => '/var/vmail/test.int/joe#maildir' => '/var/vmail/$hostname/$servername#g" mail_user_add.php >> $LOG 2>&1
  
#   php mail_user_add.php >> $LOG 2>&1
  
  cat - > /tmp/credentials.conf <<EOF
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#999;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#999;color:#444;background-color:#F7FDFA;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#999;color:#fff;background-color:#26ADE4;}
.tg .tg-vn4c{background-color:#D2E4FC}
</style>
<table class="tg" style="undefined;table-layout: fixed; width: 90%; margin-left: auto; margin-right: auto;">
<colgroup>
<col style="width: 255px">
<col style="width: 302px">
</colgroup>
  <tr>
    <td class="tg-z2zr">Control Panel Username:</td>
    <td class="tg-z2zr">$servername</td>
  </tr>
  <tr>
    <td class="tg-z2zr">Control Panel Password:</td>
    <td class="tg-z2zr">$clientPW</td>
  </tr>
  <tr>
    <td class="tg-z2zr">Control Panel:</td>
    <td class="tg-z2zr"><a href="https://$hostname:8080">https://$hostname:8080</a></td>
  </tr>
  <tr>
    <td class="tg-vn4c">Database Name:</td>
    <td class="tg-vn4c">$dbName</td>
  </tr>
  <tr>
    <td class="tg-vn4c">Database Username:</td>
    <td class="tg-vn4c">$siteDBuser</td>
  </tr>
  <tr>
    <td class="tg-vn4c">Database Password:</td>
    <td class="tg-vn4c">$dbUserPW</td>
  </tr>
  <tr>
    <td class="tg-z2zr">FTP Username:</td>
    <td class="tg-z2zr">$ftpShellUsr</td>
  </tr>
  <tr>
    <td class="tg-z2zr">FTP Password:</td>
    <td class="tg-z2zr">$ftpShellPass</td>
  </tr>
</table>
EOF
}

install_cyrus(){
  echo -e "[\033[33m*\033[0m] Installing Cyrus" && echo -e "[\033[33m*\033[0m] Installing Cyrus" >> /tmp/server_log.txt
  yum install cyrus-sasl* -y >> $LOG 2>&1
  yum install perl-DateTime-Format* -y >> $LOG 2>&1
}
install_ruby(){
  echo -e "[\033[33m*\033[0m] Installing Ruby" && echo -e "[\033[33m*\033[0m] Installing Ruby" >> /tmp/server_log.txt
  yum install httpd-devel ruby ruby-devel -y >> $LOG 2>&1
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
  echo -e "[\033[33m*\033[0m] Restarting Apache" && echo -e "[\033[33m*\033[0m] Restarting Apache" >> /tmp/server_log.txt
  /etc/init.d/httpd restart >> $LOG 2>&1
}

configure_webdav(){
  sed -i -e "s,#\(#LoadModule auth_digest_module modules/mod_auth_digest.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1
  sed -i -e "s,#\(#LoadModule dav_module modules/mod_dav.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1
  sed -i -e "s,#\(#LoadModule dav_fs_module modules/mod_dav_fs.so\),\1,g" /etc/httpd/conf/httpd.conf >> $LOG 2>&1
  }

install_unzip(){
  echo -e "[\033[33m*\033[0m] Installing unzip, bzip2, unrar, perl DBD" && echo -e "[\033[33m*\033[0m] Installing unzip, bzip2, unrar, perl DBD" >> /tmp/server_log.txt
  yum install unzip bzip2 unrar perl-DBD-mysql -y >> $LOG 2>&1
}

send_install_report(){
  wget -O /tmp/email-template.html https://raw.githubusercontent.com/nicktrela/qv-server-install/master/QV%20Email%20Template.html >> $LOG 2>&1 ||  echo -e "[\033[31mX\033[0m] ($LINENO) Error downloading email template"
  hostname="$(hostname)"
  cd /tmp
  sed -i "s/{{hostname}}/$hostname/" /tmp/email-template.html >> $LOG 2>&1
  perl -pe 's/install_credentials/`cat credentials.conf`/ge' -i /tmp/email-template.html
  mail -s "$(echo -e "Welcome to Questa Volta. Your server was successfully setup. \nFrom: Questa Volta Support <support@questavolta.com> \nContent-Type: text/html")" nick@questavolta.com < /tmp/email-template.html
  rm -rf /tmp/email-template.html
  echo -e "[\033[33m*\033[0m] Installation confirmation email has been sent" && echo -e "[\033[33m*\033[0m] Installation confirmation email has been sent" >> /tmp/server_log.txt
}

install_locate_nano(){
  echo -e "[\033[33m*\033[0m] Installing locate and nano" && echo -e "[\033[33m*\033[0m] Installing locate and nano" >> /tmp/server_log.txt
  yum install mlocate -y >> $LOG 2>&1
  yum -y install nano >> $LOG 2>&1
  echo -e "[\033[33m*\033[0m] Updating db" >> /tmp/server_log.txt
  updatedb >> $LOG 2>&1
}

script_update_1(){
  sed -i 's/Timeout 60/Timeout 2/g' /etc/httpd/conf/httpd.conf >> $LOG 2>&1
  sed -i 's/MaxRequestsPerChild  4000/MaxRequestsPerChild  1000/g' /etc/httpd/conf/httpd.conf >> $LOG 2>&1
  service httpd restart >> $LOG 2>&1
  sed -i 's/apc.shm_size=64M/apc.shm_size=128M/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.num_files_hint=1024/apc.num_files_hint=10024/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.user_entries_hint=4096/apc.user_entries_hint=40096/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.enable_cli=0/apc.enable_cli=1/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.enable_cli=0/apc.enable_cli=1/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.max_file_size=1M/apc.max_file_size=8M/g' /etc/php.d/apc.ini >> $LOG 2>&1
  sed -i 's/apc.stat=1/apc.stat=0/g' /etc/php.d/apc.ini >> $LOG 2>&1
  service httpd restart >> $LOG 2>&1
  
  sed -i '/symbolic-links=0/a\
    query_cache_size = 128M\
    join_buffer_size = 4M\
    thread_cache_size = 8\
    table_cache = 256\
    tmp_table_size = 64M\
    max_heap_table_size = 64M\
    innodb_buffer_pool_size = 512M
  ' /etc/my.cnf
  echo -e "[\033[33m*\033[0m] Restarting mysql" && echo -e "[\033[33m*\033[0m] Restarting mysql" >> /tmp/server_log.txt
  service mysqld restart >> $LOG 2>&1
}

script_update_2(){
  sed -i 's/hash:\/etc\/mailman\/virtual-mailman, //g' /etc/postfix/main.cf >> $LOG 2>&1
  sed -i 's/content_filter = amavis/#content_filter = amavis/g' /etc/postfix/main.cf >> $LOG 2>&1
  sed -i 's/receive_override_options = no_address_mappings/#receive_override_options = no_address_mappings/g' /etc/postfix/main.cf >> $LOG 2>&1
  sed -i 's/transport_maps = hash/#transport_maps = hash/g' /etc/postfix/main.cf >> $LOG 2>&1
  cat <<EOF >> /etc/postfix/main.cf
relayhost = 
mailbox_size_limit = 0
message_size_limit = 0
EOF

  echo -e "[\033[33m*\033[0m] Disable clamav / amavis" >> /tmp/server_log.txt
  sed -i 's/amavis unix - - - - 2 smtp/#amavis unix - - - - 2 smtp/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtp_data_done_timeout=1200/#-o smtp_data_done_timeout=1200/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtp_send_xforward_command=yes/#-o smtp_send_xforward_command=yes/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/127.0.0.1:10025 inet n - - - - smtpd/#127.0.0.1:10025 inet n - - - - smtpd/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o content_filter=/#-o content_filter=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o local_recipient_maps=/#-o local_recipient_maps=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o relay_recipient_maps=/#-o relay_recipient_maps=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtpd_restriction_classes=/#-o smtpd_restriction_classes=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtpd_client_restrictions=/#-o smtpd_client_restrictions=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtpd_helo_restrictions=/#-o smtpd_helo_restrictions=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtpd_sender_restrictions=/#-o smtpd_sender_restrictions=/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o smtpd_recipient_restrictions=permit_mynetworks,reject/#-o smtpd_recipient_restrictions=permit_mynetworks,reject/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o mynetworks=127.0.0.0/#-o mynetworks=127.0.0.0/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o strict_rfc821_envelopes=yes/#-o strict_rfc821_envelopes=yes/g' /etc/postfix/master.cf >> $LOG 2>&1
  sed -i 's/-o receive_override_options=no_unknown_recipient_checks,no_header_body_checks/#-o receive_override_options=no_unknown_recipient_checks,no_header_body_checks/g' /etc/postfix/master.cf >> $LOG 2>&1
  
  
  
  echo -e "[\033[33m*\033[0m] Stop amavis / clamav" && echo -e "[\033[33m*\033[0m] Stop amavis / clamav" >> /tmp/server_log.txt
  
    /etc/init.d/amavis stop >> $LOG 2>&1
  	/etc/init.d/clamav-daemon stop >> $LOG 2>&1
  	/etc/init.d/clamav-freshclam stop >> $LOG 2>&1
  	
  	chkconfig --levels 235 amavis off >> $LOG 2>&1
  	chkconfig --levels 235 clamav-daemon off >> $LOG 2>&1
 	chkconfig --levels 235 clamav-freshclam off >> $LOG 2>&1

  # New ISP Config install looks for dovecot-sql.conf in a new location
  ln -s /etc/dovecot/dovecot-sql.conf /etc/dovecot-sql.conf >> $LOG 2>&1
  ln -s /etc/dovecot/dovecot.conf /etc/dovecot.conf >> $LOG 2>&1

  echo -e "[\033[33m*\033[0m] Restart Postfix" && echo -e "[\033[33m*\033[0m] Restart Postfix" >> /tmp/server_log.txt
  /etc/init.d/postfix restart >> $LOG 2>&1
}

  install_ISPconfig(){
  echo -e "[\033[33m*\033[0m] Downloading ISPConfig" && echo -e "[\033[33m*\033[0m] Downloading ISPConfig" >> /tmp/server_log.txt
  #ISPConfig
  cd /tmp
  wget http://www.ispconfig.org/downloads/ISPConfig-3-stable.tar.gz >> $LOG 2>&1
  tar xfz ISPConfig-3-stable.tar.gz >> $LOG 2>&1
  cd ispconfig3_install/install/  >> $LOG 2>&1
  
  echo -e "[\033[33m*\033[0m] Setting up ISPConfig" && echo -e "[\033[33m*\033[0m] Setting up ISPConfig" >> /tmp/server_log.txt
 
  autoinstall='$autoinstall'
  
  cat <<EOF >  autoinstall.php
<?php
$autoinstall['language'] = 'en'; // de, en (default)
$autoinstall['install_mode'] = 'standard'; // standard (default), expert

$autoinstall['hostname'] = '$hostname'; // default
$autoinstall['mysql_hostname'] = 'localhost'; // default: localhost
$autoinstall['mysql_root_user'] = 'root'; // default: root
$autoinstall['mysql_root_password'] = '$(cat /tmp/mysqlpw.conf)';
$autoinstall['mysql_database'] = 'dbispconfig'; // default: dbispcongig
$autoinstall['mysql_charset'] = 'utf8'; // default: utf8
$autoinstall['http_server'] = 'apache'; // apache (default), nginx
$autoinstall['ispconfig_port'] = '8080'; // default: 8080
$autoinstall['ispconfig_use_ssl'] = 'y'; // y (default), n

/* SSL Settings */
$autoinstall['ssl_cert_country'] = 'US';
$autoinstall['ssl_cert_state'] = 'California';
$autoinstall['ssl_cert_locality'] = 'Los Angeles';
$autoinstall['ssl_cert_organisation'] = 'Questa Volta';
$autoinstall['ssl_cert_organisation_unit'] = 'IT department';
$autoinstall['ssl_cert_common_name'] = $autoinstall['hostname'];
?>
EOF



  php install.php --autoinstall=autoinstall.php >> $LOG 2>&1
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
install_locate_nano
script_update_1
install_ISPconfig
script_update_2
initialize_ISPConfig
install_roundcube
send_install_report

