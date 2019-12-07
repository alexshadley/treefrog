#!/bin/bash

cmd="$1"
case $cmd in
    test)
    go test ./...
    ;;
    server)
    ./treefrog "$2"
esac
