#!/bin/bash

clear

stty erase '^?'
    
echo -n "Database Name: "
read DBNAME

echo -n "Database User: "
read DBUSER

echo -n "Database Password: "
read DBPASS

echo -n "Admin Password: "
read ADMIN_PASS

echo -n "Store URL (with trailing slash): "
read URL

    echo "Now installing Magento without sample data..."
    
    echo
    echo "Downloading packages..."
    echo
    
    wget http://www.magentocommerce.com/downloads/assets/1.8.1.0/magento-1.8.1.0.tar.gz
    
    echo
    echo "Extracting data..."
    echo
    
    tar xf magento-1.8.1.0.tar.gz
    
    echo
    echo "Moving files..."
    echo
    
    mv magento/* magento/.htaccess .
    
    echo
    echo "Setting permissions..."
    echo
    
    chmod 550 mage
    
    echo
    echo "Initializing PEAR registry..."
    echo
    
    ./mage mage-setup .
    ./mage config-set preferred_state stable
    
    echo
    echo "Installing core extensions..."
    echo
    
    ./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force
    
    echo
    echo "Refreshing indexes..."
    echo
    
    /usr/local/bin/php -f shell/indexer.php reindexall
    
    echo
    echo "Cleaning up files..."
    echo
    
    rm -rf magento/ magento-1.8.1.0.tar.gz
    rm -rf *.sample *.txt
    
    echo
    echo "Installing Magento..."
    echo
    
    php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "en_US" \
    --timezone "America/Phoenix" \
    --default_currency "USD" \
    --db_host "localhost" \
    --db_name "$DBNAME" \
    --db_user "$DBUSER" \
    --db_pass "$DBPASS" \
    --url "$URL" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Store" \
    --admin_lastname "Owner" \
    --admin_email "email@address.com" \
    --admin_username "admin" \
    --admin_password "$ADMIN_PASS" \
    
    echo
    echo "Finished installing the latest stable version of Magento without Sample Data"
    echo
    
    echo "+=================================================+"
    echo "| MAGENTO LINKS"
    echo "+=================================================+"
    echo "|"
    echo "| Store: $URL"
    echo "| Admin: ${URL}admin/"
    echo "|"
    echo "+=================================================+"
    echo "| ADMIN ACCOUNT"
    echo "+=================================================+"
    echo "|"
    echo "| Username: admin"
    echo "| Password: $ADMIN_PASS"
    echo "|"
    echo "+=================================================+"
    echo "| DATABASE INFO"
    echo "+=================================================+"
    echo "|"
    echo "| Database: $DBNAME"
    echo "| Username: $DBUSER"
    echo "| Password: $DBPASS"
    echo "|"
    echo "+=================================================+"
    
    exit
fi