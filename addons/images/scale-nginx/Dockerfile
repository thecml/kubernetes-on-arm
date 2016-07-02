FROM hypriot/rpi-alpine-scratch:edge

RUN apk add --update nginx

COPY nginx.conf /etc/nginx/
COPY index.html data.json /usr/share/nginx/html/
