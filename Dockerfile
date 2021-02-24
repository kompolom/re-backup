FROM rclone/rclone
MAINTAINER master@kompolom.ru

RUN apk add restic mysql-client postgresql-client --no-cache && mkdir /backup-scripts.d
COPY *.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["backup"]