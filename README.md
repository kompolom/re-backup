RE-BACKUP
=========

Run backup jobs inside docker container. Based on [restic](https://restic.net/) and [rclone](https://rclone.org/).
Image contains only infrastructure, no backup scripts itself.

## How to use

Mount backup scripts to `/backup-providers.d` directory. Entrypoint will run each script and run function called `backup` in each script. It helps to use different backup tools.

Example below show backup local archive provider. Let this file named `uploads-archive.sh` in `/backup-providers.d`:

```shell
# shellcheck disable=SC2039

SOURCE_DIR=/uploads
BACKUP_DIR=/backup
BACKUP_FILENAME="${SOURCE_DIR##*/}-$(date +"%F").tar.gz"

backup() {
  tar -czf "$BACKUP_DIR/$BACKUP_FILENAME" "$SOURCE_DIR"
}

restore() {
  local fileName=$1
  local backupFile="$BACKUP_DIR/$fileName"
  [ -z "$fileName" ] && echo "No backupFile specified">&2 && exit 1
  if [ ! -e "$backupFile" ]; then echo "File not found" >&2; exit 1; fi

  echo "Restore from $backupFile"
  gzip -t "$backupFile" || exit 1;
  tar -xvzf "$backupFile" -C "$(dirname $SOURCE_DIR)"
}
```

By default, function `backup` will be run with passed to container arguments.
Do not forget mount source and backup dirs.

### Backup provider script format

A Backup provider is POSIX shell script, which defines at least 2 functions: `backup` and `restore`. Additional, script may define `printHelp` function. 

Function should return exit code 0 *only* if backup created/restored successful.

### Docker swarm schedule

[Swarm cronjob](https://crazymax.dev/swarm-cronjob/) may be used to run backup container periodical:

```yml
backup:
    image: appwilio/re-backup
    # ...
    deploy:
      labels:
        - swarm.cronjob.enable=true
        - swarm.cronjob.schedule=15 5 * * *
        - swarm.cronjob.skip-running=true
      mode: replicated
      replicas: 0
      restart_policy:
        condition: none
```

## How to create backup

Backup is default action. If container starts without arguments, backup will be used. Do not forget to mount volume or directory inside container for backup provider script may access it.

Backup action look for scripts in `/backup-providers.d/` and pass each to launcher script. Even if one of providers fails (returns non-zero exit code), other scripts will run. Command exit code will contain last failed backup exit code.

> backup command will try to create as many backups as possible, even if errors.

## How to restore

Restore command may be run by entrypoint script or manually, through running launcher script. As we want only specific backup, only database, or only uploads etc, we should specify which provider should be used and which exactly backup copy should be restored.

### run through entrypoint

To run restore by entrypoint script, we should pass `restore` command to container with provider file name excluding extension.

Example to run with docker-compose. Let our backup service named 'backup', and we use `uploads-archive.sh` provider described above.

```shell
docker-compose run --rm backup restore 'uploads-archive' uploads-latest.tar.gz
```

### run manually

Start container in an interactive mode, run launcher.sh with arguments:

```shell
docker-compose run --rm backup sh
/launcher.sh /backup-providers.d/uploads-archive.sh restore uploads-latest.tar.gz
```

### get help

To see help message pass 'help' command to launcher or run container with it command.

```shell
docker-compose run --rm backup help
```

or manual:

```shell
/launcher.sh help
```