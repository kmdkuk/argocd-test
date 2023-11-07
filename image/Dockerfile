FROM nginx:latest

LABEL org.opencontainers.image.source=https://github.com/kmdkuk/argocd-test
LABEL org.opencontainers.image.description="ArgoCDImageUpdater test"
LABEL org.opencontainers.image.licenses=MIT

COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /var/www/index.html

EXPOSE 8080
