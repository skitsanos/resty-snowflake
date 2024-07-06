FROM openresty/openresty:alpine
LABEL authors="skitsanos"

RUN mkdir -p /app/lib && mkdir -p /vendor/lib \
    && apk add --no-cache curl jq libc6-compat perl ca-certificates \
    && opm get bsiara/dkjson \
    && opm get fffonion/lua-resty-openssl \
    && opm get pintsized/lua-resty-http \
    && opm get SkyLothar/lua-resty-jwt \
    && opm get fffonion/lua-resty-openssl \
    && apk del curl

EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]