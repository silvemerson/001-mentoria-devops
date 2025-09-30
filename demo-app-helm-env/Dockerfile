FROM nginx:alpine

# Variáveis de ambiente padrão 
ENV ENVIRONMENT_NAME="development"
ENV ENVIRONMENT_CLASS="dev"


COPY index.html /tmp/index.html

RUN echo '#!/bin/sh' > /docker-entrypoint.d/40-replace-env.sh && \
    echo 'envsubst "\$ENVIRONMENT_NAME \$ENVIRONMENT_CLASS" < /tmp/index.html > /usr/share/nginx/html/index.html' >> /docker-entrypoint.d/40-replace-env.sh && \
    chmod +x /docker-entrypoint.d/40-replace-env.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]