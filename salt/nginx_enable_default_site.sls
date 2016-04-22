/etc/nginx/sites-enabled/default:
  file.symlink:
    - target: /etc/nginx/sites-available/default

/var/www/html/index.html:
  file.managed:
    - source:
      - salt://nginx/site/index.html
    - user: root
    - group: root
    - mode: '0644'
