#!/bin/bash

#set -xe

HOSTNAME=$(hostnamectl status --static)

cat <<EOF > lsyncd-$HOSTNAME.conf
settings {
	logfile = "./lsyncd-$HOSTNAME.log"
}
EOF

for NAME in rhel8 rhel7 rhel6; do
	for ENV in dev test; do
		HOST="ic-$NAME-$ENV-$HOSTNAME"
		MAC=$(vm inspect --format json $HOST | jq .Devices.Interfaces[0].MAC.Address | sed -s "s/\"//g")
		IP=$(arp -a | grep $MAC | awk '{print $2}' | sed -s "s/[\(\)]//g")
		if [ "$IP"  != "" ]; then
			cat <<EOF >> lsyncd-$HOSTNAME.conf 
-- $HOST - $MAC
sync {
	default.rsyncssh,
	source="./",
	host="$IP",
	targetdir="/root/Projects",
	exclude = { '*.log' },
	rsync = {
		archive = true,
		compress = true
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
