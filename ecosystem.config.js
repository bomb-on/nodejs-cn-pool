module.exports = {
  apps: [
    {
      name: 'api',
      script: 'init.js',
      args: '--module=api',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'blockManager',
      script: 'init.js',
      args: '--module=blockManager',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'worker',
      script: 'init.js',
      args: '--module=worker',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'payments',
      script: 'init.js',
      args: '--module=payments',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'remoteShare',
      script: 'init.js',
      args: '--module=remoteShare',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'longRunner',
      script: 'init.js',
      args: '--module=longRunner',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
    {
      name: 'pool',
      script: 'init.js',
      args: '--module=pool',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    },
  ]
};
