#!/bin/bash

echo "This assumes that you are doing a green-field install.  If you're not, please exit in the next 15 seconds."
# sleep 15
echo "Continuing install, this will prompt you for your password if you're not already running as root and you didn't enable passwordless sudo.  Please do not run me as root!"
if [[ $(whoami) == "root" ]]; then
    echo "You ran me as root! Do not run me as root!"
    exit 1
fi

# GLOBAL VARS
ROOT_SQL_PASS=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)
CURUSER=$(whoami)
[ -z "$HOME" ] && read -r -p "Enter absolute path to user's home folder: " HOME

# LOAD CONFIG
source CONFIG

# CHECK IF ALL VARS ARE SET
[ -z "$COIN_NAME" ] && read -r -p "Enter full coin name: " COIN_NAME
[ -z "$COIN_SYMBOL" ] && read -r -p "Enter coin short symbol: " COIN_SYMBOL
[ -z "$COIN_DAEMON" ] && read -r -p "Enter coin daemon executable name: " COIN_DAEMON
[ -z "$WALLET_DAEMON" ] && read -r -p "Enter wallet daemon executable name: " WALLET_DAEMON

[ -z "$CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX" ] && read -r -p "Enter coin prefix: " CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX
[ -z "$CRYPTONOTE_DISPLAY_DECIMAL_POINT" ] && read -r -p "Enter coin decimal point: " CRYPTONOTE_DISPLAY_DECIMAL_POINT
[ -z "$DIFFICULTY_TARGET" ] && read -r -p "Enter coin difficulty: " DIFFICULTY_TARGET
[ -z "$CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW" ] && read -r -p "Enter coin block maturity depth: " CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW
[ -z "$MINIMUM_FEE" ] && read -r -p "Enter coin minimum fee: " MINIMUM_FEE

[ -z "$DB_PASS" ] && read -r -p "Database password: " DB_PASS

[ -z "$POOL_NAME" ] && read -r -p "Pool name: " POOL_NAME
[ -z "$POOL_HOSTNAME" ] && read -r -p "Pool domain or IP: " POOL_HOSTNAME
[ -z "$POOL_API_URL" ] && read -r -p "Pool API URL: " POOL_API_URL

[ -z "$POOL_ADDRESS" ] && read -r -p "Pool wallet address: " POOL_ADDRESS
[ -z "$FEE_ADDRESS" ] && read -r -p "Pool fee wallet address: " FEE_ADDRESS
[ -z "$COIN_DAEMON_PORT" ] && read -r -p "Coin daemon RPC port: " COIN_DAEMON_PORT
[ -z "$COIN_WDAEMON_PORT" ] && read -r -p "Coin wallet daemon RPC port: " COIN_WDAEMON_PORT
[ -z "$TX_FEE" ] && read -r -p "Transaction fee: " TX_FEE
[ -z "$MAILGUN_KEY" ] && read -r -p "Mailgun key: " MAILGUN_KEY
[ -z "$MAILGUN_URL" ] && read -r -p "Mailgun url: " MAILGUN_URL
[ -z "$EMAIL_FROM" ] && read -r -p "Pool email: " EMAIL_FROM
[ -z "$ADMIN_EMAIL" ] && read -r -p "Admin email: " ADMIN_EMAIL
[ -z "$COIN_MIXIN" ] && read -r -p "Coin mixin value: " COIN_MIXIN

# UPDATE OS AND INSTALL DEPENDENCIES
sudo timedatectl set-timezone Etc/UTC
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $ROOT_SQL_PASS"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $ROOT_SQL_PASS"
printf '[client]\nuser=root\npassword=%s' "$ROOT_SQL_PASS" | sudo tee /root/.my.cnf

sudo DEBIAN_FRONTEND=noninteractive apt -y install \
    git python-virtualenv python3-virtualenv curl ntp build-essential cmake pkg-config mysql-server jq moreutils htop \
    libboost-all-dev libssl-dev libevent-dev libunbound-dev libminiupnpc-dev libunwind8-dev liblzma-dev libldns-dev libexpat1-dev libgtest-dev lmdb-utils libzmq3-dev \
    gcc-5 g++-5 gcc-6 g++-6 gcc-7 g++-7

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 --slave /usr/bin/g++ g++ /usr/bin/g++-5
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7

# SETUP COIN
# bash coin.bash

# REGISTER COIN DAEMON AS A SYSTEM SERVICE
sed -r "s/CURUSER/$CURUSER/g; s/COIN_DAEMON/$COIN_DAEMON/g; s#HOME#$HOME#g;" "$POOL_DIR"/deployment/coind.service | sudo tee /etc/systemd/system/coind.service
sed -r "s/CURUSER/$CURUSER/g; s/WALLET_DAEMON/$WALLET_DAEMON/g; s#POOL_DIR#$POOL_DIR#g; s#HOME#$HOME#g; s/COIN_WDAEMON_PORT/$COIN_WDAEMON_PORT/g;" "$POOL_DIR"/deployment/walletd.service | sudo tee /etc/systemd/system/walletd.service
sudo systemctl daemon-reload
sudo systemctl enable coind
sudo systemctl enable walletd
sudo systemctl start coind
sudo systemctl start walletd

# INSTALL NODE
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
# shellcheck disable=SC1090
source "$HOME"/.nvm/nvm.sh
nvm install v8.9.3

# SETUP POOL
# shellcheck disable=SC2164
cd "$POOL_DIR"
mkdir "$POOL_DB_DIR"
npm install
npm install -g pm2
openssl req -subj "/C=IT/ST=Pool/L=Daemon/O=Mining Pool/CN=mining.pool" -newkey rsa:2048 -nodes -keyout cert.key -x509 -out cert.pem -days 36500
sed -i "s/CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX/${CRYPTONOTE_PUBLIC_ADDRESS_BASE58_PREFIX}/" "$POOL_DIR"/lib/coins/coin.js
[[ ! -z "$COIN_DEV_ADDRESS" ]] && sed -i "s/COIN_DEV_ADDRESS/${COIN_DEV_ADDRESS}/" "$POOL_DIR"/lib/coins/coin.js
[[ ! -z "$POOL_DEV_ADDRESS" ]] && sed -i "s/POOL_DEV_ADDRESS/${POOL_DEV_ADDRESS}/" "$POOL_DIR"/lib/coins/coin.js
mv "$POOL_DIR"/lib/coins/coin.js "$POOL_DIR"/lib/coins/"${COIN_SYMBOL,,}".js
mv "$POOL_DIR"/lib/payment_systems/coin.js "$POOL_DIR"/lib/payment_systems/"${COIN_SYMBOL,,}".js

jq -n --arg hostname "$POOL_HOSTNAME" \
      --arg dbdir "$POOL_DB_DIR" \
      --arg coin "${COIN_SYMBOL,,}" \
      --arg dbhost "$DB_HOSTNAME" \
      --arg db "$DB_NAME" \
      --arg dbuser "$DB_USER" \
      --arg dbpass "$DB_PASS" \
'{"pool_id": 0, "bind_ip": "0.0.0.0", "hostname": $hostname, "db_storage_path": $dbdir, "coin": $coin, "mysql": { "connectionLimit": 20, "host": $dbhost, "database": $db, "user": $dbuser, "password": $dbpass}}' > "$POOL_DIR"/config.json

jq -n --arg coin "${COIN_SYMBOL,,}" \
      --arg func_file "./lib/coins/${COIN_SYMBOL,,}.js" \
      --arg payment_file "./payment_systems/${COIN_SYMBOL,,}.js" \
      --arg sig_digits "$CRYPTONOTE_DISPLAY_DECIMAL_POINT" \
      --arg coin_name "${COIN_NAME^}" \
      --arg mixin "$COIN_MIXIN" \
      --arg short_code "${COIN_SYMBOL^^}" \
'{($coin): {"funcFile": $func_file, "paymentFile": $payment_file, "sigDigits": $sig_digits, "name": $coin_name, "mixIn": $mixin, "shortCode": $short_code}}' > "$POOL_DIR"/coinConfig.json

# SETUP POOL UI
git clone https://github.com/bomb-on/pool_ui.git "$POOL_UI_DIR"
# shellcheck disable=SC2164
cd "$POOL_UI_DIR"
npm install
./node_modules/bower/bin/bower update
./node_modules/gulp/bin/gulp.js build
# shellcheck disable=SC2164
cd build
sudo ln -s "$(pwd)" /var/www
sed -i "s/\\(pool_name: \\).*/\\1\"${POOL_NAME}\",/" "$POOL_UI_DIR"/build/globals.js
sed -i "s/\\(pool_name: \\).*/\\1\"${POOL_NAME}\",/" "$POOL_UI_DIR"/build/globals.default.js
sed -i "s#\\(api_url: \\).*#\\1\"${POOL_API_URL}\",#" "$POOL_UI_DIR"/build/globals.js
sed -i "s#\\(api_url: \\).*#\\1\"${POOL_API_URL}\",#" "$POOL_UI_DIR"/build/globals.default.js
sed -i "s/\\(pool_server: \\).*/\\1\"${POOL_HOSTNAME}\",/" "$POOL_UI_DIR"/build/globals.js
sed -i "s/\\(coin_abbr: \\).*/\\1\"${COIN_SYMBOL^^}\",/" "$POOL_UI_DIR"/build/globals.js
sed -i "s/CRYPTONOTE_DISPLAY_DECIMAL_POINT/${CRYPTONOTE_DISPLAY_DECIMAL_POINT}/" "$POOL_UI_DIR"/build/utils/strings.js
sed -i "s/DIFFICULTY_TARGET/${DIFFICULTY_TARGET}/" "$POOL_UI_DIR"/build/utils/strings.js

# INSTALL AND CONFIGURE CADDY
CADDY_DOWNLOAD_DIR=$(mktemp -d)
# shellcheck disable=SC2164
cd "${CADDY_DOWNLOAD_DIR}"
curl -sL "https://snipanet.com/caddy.tar.gz" | tar -xz caddy init/linux-systemd/caddy.service
sudo mv caddy /usr/local/bin
sudo chown root:root /usr/local/bin/caddy
sudo chmod 755 /usr/local/bin/caddy
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy
sudo groupadd -g 33 www-data
sudo useradd -g www-data --no-user-group --home-dir /var/www --no-create-home --shell /usr/sbin/nologin --system --uid 33 www-data
sudo mkdir /etc/caddy
sudo chown -R root:www-data /etc/caddy
sudo mkdir /etc/ssl/caddy
sudo chown -R www-data:root /etc/ssl/caddy
sudo chmod 0770 /etc/ssl/caddy
sed -i "s/POOL_HOSTNAME/${POOL_HOSTNAME}/" "$POOL_DIR"/deployment/caddyfile
sudo cp "$POOL_DIR"/deployment/caddyfile /etc/caddy/Caddyfile
sudo chown www-data:www-data /etc/caddy/Caddyfile
sudo chmod 444 /etc/caddy/Caddyfile
sudo sh -c "sed 's/ProtectHome=true/ProtectHome=false/' init/linux-systemd/caddy.service > /etc/systemd/system/caddy.service"
sudo chown root:root /etc/systemd/system/caddy.service
sudo chmod 644 /etc/systemd/system/caddy.service
sudo systemctl daemon-reload
sudo systemctl enable caddy.service
sudo systemctl start caddy.service
rm -rf "${CADDY_DOWNLOAD_DIR}"

# IMPORT BASIC MYSQL STUFF
sed -i "s/DB_NAME/${DB_NAME}/g" "$POOL_DIR"/deployment/base.sql
sed -i "s/DB_USER/${DB_USER}/g" "$POOL_DIR"/deployment/base.sql
sed -i "s/DB_PASS/${DB_PASS}/g" "$POOL_DIR"/deployment/base.sql

sed -i "s/COIN_SYMBOL/${COIN_SYMBOL^^}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/POOL_ADDRESS/${POOL_ADDRESS}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/FEE_ADDRESS/${FEE_ADDRESS}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/COIN_DAEMON_PORT/${COIN_DAEMON_PORT}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/COIN_WDAEMON_PORT/${COIN_WDAEMON_PORT}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW/${CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW}/g" "$POOL_DIR"/deployment/base.sql
sed -i "s/CRYPTONOTE_DISPLAY_DECIMAL_POINT/${CRYPTONOTE_DISPLAY_DECIMAL_POINT}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/MINIMUM_FEE/${MINIMUM_FEE}/g" "$POOL_DIR"/deployment/base.sql
sed -i "s/TX_FEE/${TX_FEE}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/MAILGUN_KEY/${MAILGUN_KEY}/" "$POOL_DIR"/deployment/base.sql
sed -i "s#MAILGUN_URL#${MAILGUN_URL}#" "$POOL_DIR"/deployment/base.sql
sed -i "s/EMAIL_FROM/${EMAIL_FROM}/" "$POOL_DIR"/deployment/base.sql
sed -i "s#EMAIL_SIG#${POOL_NAME}#" "$POOL_DIR"/deployment/base.sql
sed -i "s/ADMIN_EMAIL/${ADMIN_EMAIL}/" "$POOL_DIR"/deployment/base.sql
sed -i "s/COIN_MIXIN/${COIN_MIXIN}/" "$POOL_DIR"/deployment/base.sql

mysql -u root --password="${ROOT_SQL_PASS}" < "$POOL_DIR"/deployment/base.sql
mysql -u root --password="${ROOT_SQL_PASS}" "${DB_NAME}" -e "INSERT INTO ${DB_NAME}.config (module, item, item_value, item_type, Item_desc) VALUES ('api', 'authKey', '$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)', 'string', 'Auth key sent with all Websocket frames for validation.')"
mysql -u root --password="${ROOT_SQL_PASS}" "${DB_NAME}" -e "INSERT INTO ${DB_NAME}.config (module, item, item_value, item_type, Item_desc) VALUES ('api', 'secKey', '$(tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1)', 'string', 'HMAC key for Passwords.  JWT Secret Key.  Changing this will invalidate all current logins.')"

# INSTALL LMDB TOOLS
# shellcheck source=install_lmdb_tools.sh
source "$POOL_DIR"/deployment/install_lmdb_tools.sh

# ADD PM2 TO STARTUP AND INSTALL LOGROTATE
# shellcheck disable=SC2164
cd "$HOME"
sudo env PATH="$PATH":"$HOME"/.nvm/versions/node/v8.9.3/bin "$HOME"/.nvm/versions/node/v8.9.3/lib/node_modules/pm2/bin/pm2 startup systemd -u "${CURUSER}" --hp "$HOME"
sudo chown -R "${CURUSER}". "$HOME"/.pm2
pm2 install pm2-logrotate

# START POOL API
# shellcheck disable=SC2164
cd "$POOL_DIR"
pm2 start ecosystem.config.js --only api

function box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

printf '\n\n'
l1="Here are the details about what has been done, write it down or put it in some safe place."
l2="Double check your pool and coin config and ensure all settings are correct! Don't forget to setup wallet daemon!"
l3="When you feel ready, run 'source ~/.bashrc' and start all pool processes with 'pm2 start ecosystem.config.js'."
box_out "ALL DONE!" "" \
        "$l1" "" \
        "POOL INFO:" \
        "Configured coin: $COIN_NAME" \
        "Pool URL: $POOL_HOSTNAME" "" \
        "MYSQL INFO:" \
        "Database host: $DB_HOSTNAME" \
        "Database name: $DB_NAME" \
        "Database username: $DB_USER" \
        "Database password: $DB_PASS" \
        "" "" \
        "$l2" "" \
        "$l3" ""
