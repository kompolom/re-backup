#!/bin/sh

set -e

launcherHelp() {
  echo "Launch backup or restore process from provider"
  echo "Usage:"
  echo " launcher.sh provider.sh backup|restore|help [provider options & arguments]"
  echo ""
  echo "Commands:"
  echo " backup     Create new backup"
  echo " restore    Restore existing backup"
  echo " help       Print provider-specific help message"
}

printHelp() {
  echo "No help for this provider"
}

postBackup() {
  return 0
}

postRestore() {
  return 0
}

# shellcheck disable=SC1090
if [ -f "$1" ] && [ -r "$1" ]; then
  . "$1"
  shift
fi


case "$1" in
  backup) shift
    backup "$@" && postBackup "$@";;
  restore) shift
    restore "$@" && postRestore "$@";;
  help) shift
    launcherHelp
    echo ""
    printHelp "$@";;
  *) echo "Wrong command '$1'. " >&2
    launcherHelp
    exit 1
esac
