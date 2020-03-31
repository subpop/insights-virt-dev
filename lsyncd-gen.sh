#!/bin/bash

#set -xe

HOSTNAME=$(hostnamectl status --static)

cat <<EOF > lsyncd-$HOSTNAME.conf
settings {
	logfile = "$(dirname $PWD)/lsyncd-$HOSTNAME.log"
}
EOF

for NAME in rhel8 rhel7 rhel6; do
	for ENV in dev test; do
		HOST="ic-$NAME-$ENV-$HOSTNAME"
		MAC=$(vm inspect --format json $HOST | jq --raw-output .Devices.Interfaces[0].MAC.Address)
		IP=$(arp -a | grep $MAC | awk '{print $2}' | sed -s "s/[\(\)]//g")
		if [ "$IP"  != "" ]; then
			cat <<EOF >> lsyncd-$HOSTNAME.conf 
-- $HOST - $MAC
sync {
	default.rsyncssh,
	source="$(dirname $PWD)",
	host="${IP}",
	targetdir="/root/Projects",
	exclude = { '*.log' },
	rsync = {
		archive = true,
		compress = true,
		_extra = {"--no-owner", "--no-group"}
	},
	ssh = {
		options = {["StrictHostKeyChecking"] = "no", ["User"] = "root"},
		identityFile = "~/.ssh/id_rsa"
	}
}
EOF
		fi
	done
done
