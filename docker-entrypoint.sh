#!/bin/sh

if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
  exec 3>&1
else
  exec 3>/dev/null
fi

if [ "$1" = "backup" ]; then
  if /usr/bin/find "/backup-providers.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    ERR_CODE=0
    for f in $(find "/backup-providers.d/" -follow -type f -print | sort -V); do
      case "$f" in
        *.sh)
          prettyF=${f##*/}
          if [ -x "$f" ]; then
            echo >&3 "Launching $prettyF";
            if /launcher.sh "$f" "$@"; then
              echo >&3 "Success: $prettyF"
            else
              ERR_CODE=$?
              echo >&3 "Fail: $prettyF. Error code: $ERR_CODE"
            fi
          else
            echo >&3 "Ignoring $f"
          fi
          ;;
        *) echo >&3 "Ignoring $f";;
      esac
    done

    if [ $ERR_CODE -eq 0 ]; then
      echo >&3 "$1 done"
      exit 0
    else
      echo >&3 "$1 done with errors"
      exit $ERR_CODE
    fi
  else
    echo >&3 "No files found in /backup-providers.d/"
  fi

elif [ "$1" = "restore" ]; then
  backupProviderScript="${2}.sh"
  [ -z "$backupProviderScript" ] && echo "No backup file specified" && exit 1
  shift # restore command
  shift # script name

  if [ -e "/backup-providers.d/$backupProviderScript" ]; then
    echo >&3 "Launching $backupProviderScript";
    if /launcher.sh "/backup-providers.d/$backupProviderScript" "restore" "$@"; then
      echo >&3 "Success: $backupProviderScript"
    else
      ERR_CODE=$?
      echo >&3 "Fail: $backupProviderScript. Error code: $ERR_CODE"
      exit $ERR_CODE
    fi
  else
    echo >&2 "Not found /backup-providers.d/$backupProviderScript"
    exit 1
  fi

else
  exec "$@"
fi
