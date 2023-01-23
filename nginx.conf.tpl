events {
  worker_connections 1024;
}

http {
    upstream logbroker {
        {{ ['server '] | product(groups['logbroker']) | map('join') | product(';') | map('join') | join('\n\t') }}
    }

    server {
        listen 80;

        location / {
            proxy_pass http://logbroker;
        }
    }
}