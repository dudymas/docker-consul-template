FROM dudymas/consul-template:latest

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update -qq && \
    apt-get -y install nginx && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r nginx && \
    useradd -m -r -g nginx nginx

COPY nginx.service /etc/service/nginx/run
COPY reset_nginx.sh /usr/local/bin/reset_nginx.sh

