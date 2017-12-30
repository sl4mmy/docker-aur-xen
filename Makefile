NAME = aur-xen-builder
VERSION = 4.9.0

ARCH_VERSION = `/bin/date +%Y.%m`
DATE = `/bin/date +%Y-%m-%d`

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_MOUNTS ?= --mount type=tmpfs,destination=/opt/aur-xen/src,tmpfs-size=1G --mount type=bind,source=$(PWD)/pkg,destination=/opt/aur-xen/output
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile build.sudoers pkg/ usr_bin_makepkg.diff
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .

Dockerfile: Dockerfile.in
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >$(@)

pkg/:
	mkdir pkg

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" $(DOCKER_MOUNTS) --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" $(DOCKER_MOUNTS) "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

update: Dockerfile.in
	git subtree pull --prefix aur-xen https://aur.archlinux.org/xen.git master --squash
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >Dockerfile
	$(MAKE)

clean:
	-rm Dockerfile
	-rm -rf pkg/

.PHONY: all attach clean run update
