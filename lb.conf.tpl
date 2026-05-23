upstream backend {
%{ for server in servers ~}
    server ${server}:80;
%{ endfor ~}
    keepalive 32;
}

server {
    listen 80;

    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
    }
}