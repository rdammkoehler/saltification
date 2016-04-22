remove nginx:
  pkg.purged:
    - pkgs:
      - nginx
      - nginx-core
      - nginx-common

remove nginx dir:
  file.absent:
    - name: /etc/nginx

remove html dir:
  file.absent:
    - name: /var/www
