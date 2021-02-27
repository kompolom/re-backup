FROM rclone/rclone

RUN apk add restic \
    mysql-client \
    postgresql-client \
    openssh-client --no-cache \
    && mkdir /backup-providers.d && mkdir /setup.d

COPY *.sh /

WORKDIR /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]