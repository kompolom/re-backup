#!/bin/sh

set -e

SETUP_DIR="/setup.d/"

if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

# shellcheck disable=SC2034
if /usr/bin/find "$SETUP_DIR" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
    echo >&3 "$0: $SETUP_DIR is not empty, will attempt to perform configuration"

    echo >&3 "$0: Looking for shell scripts in $SETUP_DIR"
    find "$SETUP_DIR" -follow -type f -print | sort -V | while read -r f; do
        case "$f" in
            *.sh)
                if [ -x "$f" ]; then
                    echo >&3 "$0: Launching $f";
                    "$f"
                else
                    # warn on shell scripts without exec bit
                    echo >&3 "$0: Ignoring $f, not executable";
                fi
                ;;
            *) echo >&3 "$0: Ignoring $f";;
        esac
    done

    echo >&3 "$0: Configuration complete; ready for start up"
else
    echo >&3 "$0: No files found in $SETUP_DIR, skipping configuration"
fi

exit 0
