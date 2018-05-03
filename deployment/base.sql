CREATE DATABASE pool;
GRANT ALL ON DB_NAME.* TO DB_USER@`127.0.0.1` IDENTIFIED BY 'DB_PASS';
GRANT ALL ON DB_NAME.* TO DB_USER@localhost IDENTIFIED BY 'DB_PASS';
FLUSH PRIVILEGES;
USE DB_NAME;
ALTER DATABASE DB_NAME DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE TABLE `balance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_edited` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_address` varchar(128) DEFAULT NULL,
  `payment_id` varchar(128) DEFAULT NULL,
  `pool_type` varchar(64) DEFAULT NULL,
  `bitcoin` tinyint(1) DEFAULT NULL,
  `amount` bigint(26) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `balance_id_uindex` (`id`),
  UNIQUE KEY `balance_payment_address_pool_type_bitcoin_payment_id_uindex` (`payment_address`,`pool_type`,`bitcoin`,`payment_id`),
  KEY `balance_payment_address_payment_id_index` (`payment_address`,`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(40) DEFAULT NULL,
  `mining_address` varchar(200) DEFAULT NULL,
  `active` tinyint(1) DEFAULT '1',
  `ins_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bans_id_uindex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `block_log` (
  `id` int(11) NOT NULL COMMENT 'Block Height',
  `orphan` tinyint(1) DEFAULT '1',
  `hex` varchar(128) NOT NULL,
  `find_time` timestamp NULL DEFAULT NULL,
  `reward` bigint(20) DEFAULT NULL,
  `difficulty` bigint(20) DEFAULT NULL,
  `major_version` int(11) DEFAULT NULL,
  `minor_version` int(11) DEFAULT NULL,
  PRIMARY KEY (`hex`),
  UNIQUE KEY `block_log_hex_uindex` (`hex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(32) DEFAULT NULL,
  `item` varchar(32) DEFAULT NULL,
  `item_value` mediumtext,
  `item_type` varchar(64) DEFAULT NULL,
  `Item_desc` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `config_id_uindex` (`id`),
  UNIQUE KEY `config_module_item_uindex` (`module`,`item`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unlocked_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_time` timestamp NOT NULL DEFAULT '1970-01-01 00:00:01',
  `pool_type` varchar(64) DEFAULT NULL,
  `payment_address` varchar(125) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL COMMENT 'Transaction ID in the transactions table',
  `bitcoin` tinyint(1) DEFAULT '0',
  `amount` bigint(20) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `payment_id` varchar(128) DEFAULT NULL,
  `transfer_fee` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `payments_id_uindex` (`id`),
  KEY `payments_transactions_id_fk` (`transaction_id`),
  KEY `payments_payment_address_payment_id_index` (`payment_address`,`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `pools` (
  `id` int(11) NOT NULL,
  `ip` varchar(72) NOT NULL,
  `last_checkin` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) NOT NULL,
  `blockID` int(11) DEFAULT NULL,
  `blockIDTime` timestamp NULL DEFAULT NULL,
  `hostname` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pools_id_uindex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `port_config` (
  `poolPort` int(11) NOT NULL,
  `difficulty` int(11) DEFAULT '1000',
  `portDesc` varchar(128) DEFAULT NULL,
  `portType` varchar(16) DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  `ssl` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`poolPort`),
  UNIQUE KEY `port_config_poolPort_uindex` (`poolPort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `ports` (
  `pool_id` int(11) DEFAULT NULL,
  `network_port` int(11) DEFAULT NULL,
  `starting_diff` int(11) DEFAULT NULL,
  `port_type` varchar(64) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  `ip_address` varchar(256) DEFAULT NULL,
  `lastSeen` timestamp NULL DEFAULT NULL,
  `miners` int(11) DEFAULT NULL,
  `ssl_port` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `shapeshiftTxn` (
  `id` varchar(64) NOT NULL,
  `address` varchar(128) DEFAULT NULL,
  `paymentID` varchar(128) DEFAULT NULL,
  `depositType` varchar(16) DEFAULT NULL,
  `withdrawl` varchar(128) DEFAULT NULL,
  `withdrawlType` varchar(16) DEFAULT NULL,
  `returnAddress` varchar(128) DEFAULT NULL,
  `returnAddressType` varchar(16) DEFAULT NULL,
  `txnStatus` varchar(64) DEFAULT NULL,
  `amountDeposited` bigint(26) DEFAULT NULL,
  `amountSent` float DEFAULT NULL,
  `transactionHash` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `shapeshiftTxn_id_uindex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bitcoin` tinyint(1) DEFAULT NULL,
  `address` varchar(128) DEFAULT NULL,
  `payment_id` varchar(128) DEFAULT NULL,
  `coin_amt` bigint(26) DEFAULT NULL,
  `btc_amt` bigint(26) DEFAULT NULL,
  `transaction_hash` varchar(128) DEFAULT NULL,
  `submitted_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `mixin` int(11) DEFAULT NULL,
  `fees` bigint(26) DEFAULT NULL,
  `payees` int(11) DEFAULT NULL,
  `exchange_rate` bigint(26) DEFAULT NULL,
  `confirmed` tinyint(1) DEFAULT NULL,
  `confirmed_time` timestamp NULL DEFAULT NULL,
  `exchange_name` varchar(64) DEFAULT NULL,
  `exchange_txn_id` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transactions_id_uindex` (`id`),
  KEY `transactions_shapeshiftTxn_id_fk` (`exchange_txn_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(256) NOT NULL,
  `pass` varchar(64) DEFAULT NULL,
  `email` varchar(256) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `payout_threshold` bigint(16) DEFAULT '0',
  `enable_email` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_id_uindex` (`id`),
  UNIQUE KEY `users_username_uindex` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE `xmrtoTxn` (
  `id` varchar(64) NOT NULL,
  `address` varchar(128) DEFAULT NULL,
  `paymentID` varchar(128) DEFAULT NULL,
  `depositType` varchar(16) DEFAULT NULL,
  `withdrawl` varchar(128) DEFAULT NULL,
  `withdrawlType` varchar(16) DEFAULT NULL,
  `returnAddress` varchar(128) DEFAULT NULL,
  `returnAddressType` varchar(16) DEFAULT NULL,
  `txnStatus` varchar(64) DEFAULT NULL,
  `amountDeposited` bigint(26) DEFAULT NULL,
  `amountSent` float DEFAULT NULL,
  `transactionHash` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `xmrtoTxn_id_uindex` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO DB_NAME.port_config (poolPort, difficulty, portDesc, portType, hidden, `ssl`) VALUES (3333, 5000, 'Low-End Hardware (<500 h/s)', 'pplns', 0, 0);
INSERT INTO DB_NAME.port_config (poolPort, difficulty, portDesc, portType, hidden, `ssl`) VALUES (5555, 10000, 'Medium-Range Hardware (1-2 kh/s)', 'pplns', 0, 0);
INSERT INTO DB_NAME.port_config (poolPort, difficulty, portDesc, portType, hidden, `ssl`) VALUES (7777, 25000, 'High-End Hardware (Anything else!)', 'pplns', 0, 0);
INSERT INTO DB_NAME.users (username, pass, email, admin, payout_threshold) VALUES ('Administrator', null, 'VerySecure!', 1, 0);
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'minerTimeout', '900', 'int', 'Length of time before a miner is flagged inactive.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'banEnabled', 'true', 'bool', 'Enables/disabled banning of "bad" miners.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'banLength', '-15m', 'string', 'Ban duration except perma-bans');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'targetTime', '30', 'int', 'Time in seconds between share finds');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'trustThreshold', '30', 'int', 'Number of shares before miner trust can kick in.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'banPercent', '25', 'int', 'Percentage of shares that need to be invalid to be banned.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'banThreshold', '30', 'int', 'Number of shares before bans can begin');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'trustedMiners', 'true', 'bool', 'Enable the miner trust system');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'trustChange', '1', 'int', 'Change in the miner trust in percent');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'trustMin', '20', 'int', 'Minimum level of miner trust');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'trustPenalty', '30', 'int', 'Number of shares that must be successful to be trusted, reset to this value if trust share is broken');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'retargetTime', '60', 'int', 'Time between difficulty retargets');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('daemon', 'address', '127.0.0.1', 'string', 'Coin Daemon RPC IP');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('daemon', 'port', 'COIN_DAEMON_PORT', 'int', 'Coin Daemon RPC Port');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('wallet', 'address', '127.0.0.1', 'string', 'Coin Daemon RPC Wallet IP');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('wallet', 'port', 'COIN_WDAEMON_PORT', 'int', 'Coin Daemon RPC Wallet Port');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('rpc', 'https', 'false', 'bool', 'Enable RPC over SSL');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'maxDifficulty', '500000', 'int', 'Maximum difficulty for VarDiff');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'minDifficulty', '1000', 'int', 'Minimum difficulty for VarDiff');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'varDiffVariance', '20', 'int', 'Percentage out of the target time that difficulty changes');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'varDiffMaxChange', '125', 'int', 'Percentage amount that the difficulty may change');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'btcFee', '1.5', 'float', 'Fee charged for auto withdrawl via BTC');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'ppsFee', '6.5', 'float', 'Fee charged for usage of the PPS pool');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'pplnsFee', '.5', 'float', 'Fee charged for the usage of the PPLNS pool');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'propFee', '.7', 'float', 'Fee charged for the usage of the proportial pool');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'soloFee', '.4', 'float', 'Fee charged for usage of the solo mining pool');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'exchangeMin', '10', 'float', 'Minimum balance for payout to exchange/payment ID');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'walletMin', '5', 'float', 'Minimum balance for payout to personal wallet');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'devDonation', '0.1', 'float', 'Donation to coin core development');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'poolDevDonation', '0', 'float', 'Donation to pool developer');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'denom', '.0001', 'float', 'Minimum balance that will be paid out to.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'blocksRequired', 'CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW', 'int', 'Blocks required to validate a payout before it''s performed.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'sigDivisor', 'CRYPTONOTE_DISPLAY_DECIMAL_POINT', 'int', 'Divisor for turning coin into human readable amounts CRYPTONOTE_DISPLAY_DECIMAL_POINT');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'feesForTXN', 'TX_FEE', 'int', 'Amount of coin that is left from the fees to pay miner fees.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'maxTxnValue', '250', 'int', 'Maximum amount of coin to send in a single transaction');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'shapeshiftPair', 'xmr_btc', 'string', 'Pair to use in all shapeshift lookups for auto BTC payout');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'coinCode', 'COIN_SYMBOL', 'string', 'Coincode to be loaded up w/ the shapeshift getcoins argument.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'allowBitcoin', 'false', 'bool', 'Allow the pool to auto-payout to BTC via ShapeShift');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'exchangeRate', '0', 'float', 'Current exchange rate');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'bestExchange', 'xmrto', 'string', 'Current best exchange');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'mixIn', 'COIN_MIXIN', 'int', 'Mixin count for coins that support such things.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'statsBufferLength', '480', 'int', 'Number of items to be cached in the stats buffers.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pps', 'enable', 'false', 'bool', 'Enable PPS or not');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pplns', 'shareMulti', '2', 'int', 'Multiply this times difficulty to set the N in PPLNS');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pplns', 'shareMultiLog', '3', 'int', 'How many times the difficulty of the current block do we keep in shares before clearing them out');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'blockCleaner', 'true', 'bool', 'Enable the deletion of blocks or not.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'address', 'POOL_ADDRESS', 'string', 'Address to mine to, this should be the wallet-rpc address.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'feeAddress', 'FEE_ADDRESS', 'string', 'Address that pool fees are sent to.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'mailgunKey', 'MAILGUN_KEY', 'string', 'MailGun API Key for notification');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'mailgunURL', 'MAILGUN_URL', 'string', 'MailGun URL for notifications');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'emailFrom', 'EMAIL_FROM', 'string', 'From address for the notification emails');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'testnet', 'false', 'bool', 'Does this pool use testnet?');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pplns', 'enable', 'true', 'bool', 'Enable PPLNS on the DB_NAME.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('solo', 'enable', 'false', 'bool', 'Enable SOLO mining on the pool');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'feeSlewAmount', '.01', 'float', 'Amount to charge for the txn fee');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'feeSlewEnd', '50', 'float', 'Value at which txn fee amount drops to 0');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'rpcPasswordEnabled', 'false', 'bool', 'Does the wallet use a RPC password?');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'rpcPasswordPath', '', 'string', 'Path and file for the RPC password file location');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'maxPaymentTxns', '5', 'int', 'Maximum number of transactions in a single payment');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'shareHost', 'http://127.0.0.1:8000/leafApi', 'string', 'Host that receives share information');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('email', 'workerNotHashingBody', 'Hello,\n\nYour worker: %(worker)s has stopped submitting hashes at: %(timestamp)s UTC\n\nThank you,\n%(poolEmailSig)s', 'string', 'Email sent to the miner when their worker stops hashing');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('email', 'workerNotHashingSubject', 'Worker %(worker)s stopped hashing', 'string', 'Subject of email sent to miner when worker stops hashing');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'emailSig', 'EMAIL_SIG', 'string', 'Signature line for the emails.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'timer', '60', 'int', 'Number of minutes between main payment daemon cycles');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'timerRetry', '25', 'int', 'Number of minutes between payment daemon retrying due to not enough funds');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'priority', '0', 'int', 'Payout priority setting. 0 = use default (4x fee); 1 = low prio (1x fee)');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('pool', 'geoDNS', '', 'string', 'geoDNS enabled address for the DB_NAME.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('general', 'adminEmail', 'ADMIN_EMAIL', 'string', 'Admin e-mail to sende-mails to when something isn''t working right.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'fee', 'MINIMUM_FEE', 'int', 'Atomic units of coin to use as a fee.');
INSERT INTO DB_NAME.config (module, item, item_value, item_type, Item_desc) VALUES ('payout', 'unlock_time', 'CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW', 'int', 'Number of blocks assumed before the payout unlocks.');
