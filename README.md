This is my personal "Insights" virtual development bootstrap setup.

## Required Packages ##

* jq
* cloud-utils
* lsyncd (optional)
* [`vm`](https://github.com/subpop/vm)

## Usage ##

Running `make` without any target will spawn 6 virtual machines:

* ic-rhel6-dev-${HOSTNAME}
* ic-rhel6-test-${HOSTNAME}
* ic-rhel7-dev-${HOSTNAME}
* ic-rhel7-test-${HOSTNAME}
* ic-rhel8-dev-${HOSTNAME}
* ic-rhel8-test-${HOSTNAME}

A custom cloud-init ISO is created for each machine. In order to
register the host with RHSM during cloud-init, specify `RHSM_USERNAME` and
`RHSM_PASSWORD` as make variables:

```bash
make RHSM_USERNAME=myuser RHSM_PASSWORD=**********
```

The cloud-config sets the `root` password to `redhat`, copies `~/.ssh/id_rsa.pub`
into `root`'s `authorized_keys` file and attempts to register the machine with
RHSM.

A virtual machine is then created for each machine listed above.

## File sync ##

You can optionally generate an `lsyncd` config file to sync local directory
to each machine. The `lsync-gen.sh` script will look up each virtual machine,
find its IP address, and add a `sync` block to the config file.
