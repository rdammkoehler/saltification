create html dir:
  file.directory:
   - name: /var/www/html
   - user: root
   - group: root
   - mode: 755
   - makedirs: True

add index.html:
  file.managed:
    - name: /var/www/html/index.html
    - source:
      - salt://nginx/site/index.html
    - user: root
    - group: root
    - mode: '0644'

install nginx:
  pkg.installed:
    - name: nginx
    - enable: True

configure nginx:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/nginx.conf

configure default site:
  file.managed:
    - name: /etc/nginx/sites-available/default
    - source: salt://nginx/sites-available/default

enable site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/default
    - target: /etc/nginx/sites-available/default

restart nginx:
  module.run:
    - name: service.restart
    - m_name: nginx

