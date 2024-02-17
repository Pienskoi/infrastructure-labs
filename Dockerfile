FROM nginx:1.25.4-alpine

WORKDIR /usr/share/nginx/html

COPY webapp/ .

