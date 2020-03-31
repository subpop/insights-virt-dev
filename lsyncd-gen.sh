#!/bin/bash

set -xe

HOSTNAME=$(hostnamectl status --static)

cat <<EOF > lsyncd-$HOSTNAME.conf
settings {
	logfile = "$(dirname $PWD)/lsyncd-$HOSTNAME.log"
}
EOF

for NAME in rhel8 rhel7 rhel6; do
	for ENV in dev test; do
		HOST="ic-$NAME-$ENV-$HOSTNAME"
		IP=""
		if [ "$(virsh list | grep $HOST)" != "" ]; then
			IP=$(virsh -c qemu:///system net-dhcp-leases default | grep $HOST | awk '{print $5}' | cut -d/ -f1)
		fi
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
