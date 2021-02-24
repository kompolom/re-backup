#!/bin/sh

if [ -z "${ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

if [ "$1" = "backup" ] || [ "$1" = "restore" ]; then
    if /usr/bin/find "/backup-scripts.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        echo >&3 "Looking for shell scripts in /backup-scripts.d/"
        ERR_CODE=0
        for f in $(find "/backup-scripts.d/" -follow -type f -print | sort -V); do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo >&3 "Launching $f";
                        if /backup-wrapper.sh "$f" "$@"; then
                          echo >&3 "$f: Success"
                          [ "$1" = "restore" ] && break
                        else
                          ERR_CODE=$?
                          echo >&3 "$f: Fail. Error code: $ERR_CODE"
                          [ "$1" = "restore" ] && exit $ERR_CODE
                        fi
                    else
                        # warn on shell scripts without exec bit
                        echo >&3 "Ignoring $f, not executable";
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
        echo >&3 "No files found in /backup-scripts.d/"
    fi
else
  exec "$@"
fi
