FROM rclone/rclone:1.55

RUN apk add restic \
    curl \
    mysql-client \
    postgresql-client \
    openssh-client --no-cache \
    && mkdir /backup-providers.d && mkdir /setup.d

COPY *.sh /

WORKDIR /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]