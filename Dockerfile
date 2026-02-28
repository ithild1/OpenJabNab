# ── Stage 1: Build Qt4 C++ server ────────────────────────────────────────────
FROM ubuntu:18.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository universe \
    && apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libqt4-dev \
        qt4-qmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY server/ ./server/

WORKDIR /src/server
RUN qmake -r && make -j$(nproc)


# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository universe \
    && apt-get update && \
    apt-get install -y --no-install-recommends \
        # Qt4 runtime libraries
        libqtcore4 \
        libqt4-network \
        # Web server + PHP proxy
        nginx \
        php7.2-fpm \
        php7.2-xml \
        # Process manager (runs nginx + php-fpm + openjabnab)
        supervisor \
    && rm -rf /var/lib/apt/lists/*

# Register OpenJabNab library path
COPY --from=builder /src/server/bin/ /opt/openjabnab/bin/
RUN echo "/opt/openjabnab/bin" > /etc/ld.so.conf.d/openjabnab.conf && ldconfig

# Web wrapper
COPY http-wrapper/ /var/www/html/

# Remove default nginx site and install ours
RUN rm -f /etc/nginx/sites-enabled/default
COPY docker/nginx.conf /etc/nginx/sites-enabled/openjabnab.conf

# Redirect nginx logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Supervisord config
COPY docker/supervisord.conf /etc/supervisor/conf.d/openjabnab.conf

# Entrypoint (generates openjabnab.ini from env vars)
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ojn_local is the runtime data dir; pre-create its structure
RUN mkdir -p /var/www/html/ojn_local/bootcode \
             /var/www/html/ojn_local/plugins \
             /var/www/html/ojn_local/tts \
    && chown -R www-data:www-data /var/www/html

# Persistent C++ server data lives in /opt/openjabnab/data/ (mounted as volume).
# Symlinks make the hardcoded relative paths in the binary resolve there transparently.
RUN mkdir -p /opt/openjabnab/data && \
    ln -s /opt/openjabnab/data/accounts /opt/openjabnab/bin/accounts && \
    ln -s /opt/openjabnab/data/bunnies  /opt/openjabnab/bin/bunnies  && \
    ln -s /opt/openjabnab/data/ztamps   /opt/openjabnab/bin/ztamps

WORKDIR /opt/openjabnab/bin

# Web interface (HTTP proxy + admin)
EXPOSE 80
# Nabaztag XMPP device connection
EXPOSE 5222

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
