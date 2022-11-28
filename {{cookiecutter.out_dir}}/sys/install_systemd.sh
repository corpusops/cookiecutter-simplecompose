#!/usr/bin/env bash
set -ex
INSTALLED_SERVICE=${INSTALLED_SERVICE:-/etc/systemd/system/{{cookiecutter.lname}}.service}
SKIP_SYSTEMD=${SKIP_SYSTEMD-}
SKIP_ENABLE_SYSTEMD=${SKIP_ENABLE_SYSTEMD-}
cd $(dirname $(readlink -f $0))
T=$(cd .. && pwd)
cp {{cookiecutter.lname}}.service "$INSTALLED_SERVICE"
sed -i -re "s|^WorkingDirectory=|WorkingDirectory=$T|g" "$INSTALLED_SERVICE"
if [[ -z $SKIP_SYSTEMD ]];then
    systemctl daemon-reload
    if [[ -z $SKIP_ENABLE_SYSTEMD ]];then
    systemctl enable $INSTALLED_SERVICE
    fi
fi
echo "You can start your service with:" >&2
echo "systemctl start $(basename $INSTALLED_SERVICE .service)" >&2
# vim:set et sts=4 ts=4 tw=80:
