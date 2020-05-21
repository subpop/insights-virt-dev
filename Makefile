SSH_KEY := $(shell cat ${HOME}/.ssh/id_rsa.pub)
HOSTNAME = $(shell hostnamectl status --static)
RHSM_SERVER_URL := subscription.rhsm.redhat.com

HOSTNAMES = \
	ic-rhel6-dev-${HOSTNAME}  \
	ic-rhel6-test-${HOSTNAME} \
	ic-rhel7-dev-${HOSTNAME}  \
	ic-rhel7-test-${HOSTNAME} \
	ic-rhel8-dev-${HOSTNAME}  \
	ic-rhel8-test-${HOSTNAME}

ISOS = $(addsuffix .iso,$(HOSTNAMES))

.PHONY: create
create: isos
	vm create --name ic-rhel6-dev-${HOSTNAME}  --disk ${PWD}/ic-rhel6-dev-${HOSTNAME}.iso  --detach rhel-6.10
	vm create --name ic-rhel6-test-${HOSTNAME} --disk ${PWD}/ic-rhel6-test-${HOSTNAME}.iso --detach rhel-6.10
	vm create --name ic-rhel7-dev-${HOSTNAME}  --disk ${PWD}/ic-rhel7-dev-${HOSTNAME}.iso  --detach rhel-7.7
	vm create --name ic-rhel7-test-${HOSTNAME} --disk ${PWD}/ic-rhel7-test-${HOSTNAME}.iso --detach rhel-7.7
	vm create --name ic-rhel8-dev-${HOSTNAME}  --disk ${PWD}/ic-rhel8-dev-${HOSTNAME}.iso  --detach rhel-8.1
	vm create --name ic-rhel8-test-${HOSTNAME} --disk ${PWD}/ic-rhel8-test-${HOSTNAME}.iso --detach rhel-8.1

.PHONY: up
up:
	vm up ic-rhel6-dev-${HOSTNAME}
	vm up ic-rhel6-test-${HOSTNAME}
	vm up ic-rhel7-dev-${HOSTNAME}
	vm up ic-rhel7-test-${HOSTNAME}
	vm up ic-rhel8-dev-${HOSTNAME}
	vm up ic-rhel8-test-${HOSTNAME}

.PHONY: down
down:
	-vm down --force --graceful ic-rhel6-dev-${HOSTNAME}
	-vm down --force --graceful ic-rhel6-test-${HOSTNAME}
	-vm down --force --graceful ic-rhel7-dev-${HOSTNAME}
	-vm down --force --graceful ic-rhel7-test-${HOSTNAME}
	-vm down --force --graceful ic-rhel8-dev-${HOSTNAME}
	-vm down --force --graceful ic-rhel8-test-${HOSTNAME}

.PHONY: destroy
destroy:
	-vm destroy --force ic-rhel6-dev-${HOSTNAME}
	-vm destroy --force ic-rhel6-test-${HOSTNAME}
	-vm destroy --force ic-rhel7-dev-${HOSTNAME}
	-vm destroy --force ic-rhel7-test-${HOSTNAME}
	-vm destroy --force ic-rhel8-dev-${HOSTNAME}
	-vm destroy --force ic-rhel8-test-${HOSTNAME}

user-data: user-data.in
	sed \
		-e "s/%RHSM_USERNAME%/${RHSM_USERNAME}/" \
		-e "s/%RHSM_PASSWORD%/${RHSM_PASSWORD}/" \
		-e "s/%RHSM_SERVER_URL%/${RHSM_SERVER_URL}/" \
		-e "s#%SSH_KEY%#${SSH_KEY}#" \
		< $^ > $@

%.iso: user-data
	cloud-localds --dsmode local --hostname $* $@ $^

.PHONY: isos
isos: $(ISOS)

.PHONY: clean
clean:
	rm *.iso user-data
