#!/bin/sh

DURATION=$(</dev/stdin)
if (($DURATION <= 2500)); then
    exit 60
else
    if ! curl --silent --fail grocy.embassy &>/dev/null; then
        echo "Web interface is unreachable" >&2
        exit 1
    fi
fi