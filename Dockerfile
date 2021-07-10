FROM rclone/rclone:1.55

COPY *.sh /
RUN apk add restic \
    curl \
    mysql-client \
    postgresql-client \
    openssh-client --no-cache \
    && mkdir /backup-providers.d && mkdir /setup.d && \
    ln -s /launcher.sh /usr/local/bin/launcher && \
    ln -s /setup.sh /usr/local/bin/setup

WORKDIR /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]