#!/bin/sh

set -e

# shellcheck disable=SC1090
. "$1"
shift

case "$1" in
  backup) shift
    backup "$@";;
  restore) shift
    restore "$@";;
  *) echo "Wrong command $1. Expected backup|restore" >&2 && exit 1
esac
