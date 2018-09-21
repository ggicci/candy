# Candy: ssl_cert

## Prepare

Update your domain's `A` type DNS record to your server's IP address.

## Use in conjunction with Nginx

Sample workflow:

```bash
./ssl_cert.sh # prepare execution environment
docker-compose up --no-start # up container but no start
docker-compose start # start container (daemon)
edit servers/www.example.com.conf # comment 443 conf
docker-compose exec nginx nginx -s reload # reload nginx config
./ssl_cert.sh <your_email> www.example.com
edit servers/www.example.com.conf # uncomment 443 conf
docker-compose exec nginx nginx -s reload # reload nginx config
```

Sample nginx deployment folder structure:

```
nginx
  |- ssl_cert.sh
  |- docker-compose.yml
  |- letsencrypt
  |    |- {etc,log,lib}
  |    |- www
  |         |- www.example.com
  |
  |- servers
       |- www.example.com.conf
```

Sample `docker-compose.yml`:

```yaml
version: "3"
services:
  nginx:
    image: nginx:stable-alpine
    container_name: nginx
    restart: always
    ports:
      - "80"
      - "443"
    volumes:
      - "./servers/:/etc/nginx/conf.d/"
      - "./letsencrypt/www/:/var/www/letsencrypt/"
      - "./letsencrypt/etc/:/etc/certs/"
      - "${HOME}/deploy/www.example.com:/var/www/www.example.com"
    logging:
      options:
        max-size: 50m
```

Sample `servers/www.example.com.conf`:

```conf
server {
    listen 80;
    server_name www.example.com;

    location /.well-known/ {
        root /var/www/letsencrypt/www.example.com;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# server {
#     listen 443 ssl;
#     server_name www.example.com;
#
#     ssl_certificate /etc/certs/live/www.example.com/fullchain.pem;
#     ssl_certificate_key /etc/certs/live/www.example.com/privkey.pem;
#
#     # ...
# }
```
