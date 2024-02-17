FROM nginx:1.25.4-alpine

WORKDIR webapp
COPY . /usr/share/nginx/html
