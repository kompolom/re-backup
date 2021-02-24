RE-BACKUP
=========

Run backup jobs inside docker container. Based on [restic](https://restic.net/) and [rclone](https://rclone.org/).
Image contains only infrastructure, no backup scripts itself.

## How to use

Mount backup scripts to `/backup-scripts.d` directory. Entrypoint will run each script and run function called `backup` in each script. It helps to use different backup tools.

Example below show backup script for a local archive. Let this file named `10-uploads-to-local-archive.sh` in `/backup-scripts.d`:

```shell
#!/bin/sh

SOURCE_DIR=/uploads
BACKUP_DIR=/backup
BACKUP_FILENAME="${SOURCE_DIR##*/}-$(date +"%F-%H-%M-%S").tar.gz"

backup() {
  tar -czf "$BACKUP_DIR/$BACKUP_FILENAME" "$SOURCE_DIR"
}

restore() {
  # shellcheck disable=SC2039
  local backupFile=$1
  [ -z "$backupFile" ] && echo "No backupFile specified">&2 && exit 1
  tar -xvzf "$backupFile" "$SOURCE_DIR"
}

```

By default, function `backup` will be run with passed to container arguments.
Do not forget mount source and backup dirs.