create html dir:
  file.directory:
   - name: /var/www/nginx/html
   - user: root
   - group: root
   - mode: 755
   - makedirs: True

add index.html:
  file.managed:
    - name: /var/www/nginx/html/index.html
    - source:
      - salt://nginx/site/index.html
    - user: root
    - group: root
    - mode: 644

install nginx:
  pkg.installed:
    - name: nginx
    - enable: True

configure nginx:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/nginx.conf

create ssl folder:
  file.directory:
    - name: /etc/nginx/ssl
    - user: root
    - group: root
    - mode: 600
    - makedirs: True

copy ssl key-chain:
  file.managed:
    - name: /etc/nginx/ssl/ca-chain.cert.pem
    - source: salt://ssl/ca-chain.cert.pem

copy ssl cert:
  file.managed:
    - name: /etc/nginx/ssl/{{ grains['fqdn'] }}.cert.pem
    - contents_pillar: files:ssl:{{ grains['fqdn'] }}.cert.pem

copy ssl key:
  file.managed:
    - name: /etc/nginx/ssl/{{ grains['fqdn'] }}.key.pem
    - contents_pillar: files:ssl:{{ grains['fqdn'] }}.key.pem

configure default site:
  file.managed:
    - name: /etc/nginx/sites-available/default
    - source: salt://nginx/sites-available/default
    - template: jinja

enable site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/default
    - target: /etc/nginx/sites-available/default

restart nginx:
  module.run:
    - name: service.restart
    - m_name: nginx

