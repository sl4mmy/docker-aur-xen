# Copyright (c) 2017-2018 Kent R. Spillner <kspillner@acm.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

NAME = aur-xen
VERSION = 4.10.1

ARCH_VERSION = `/bin/date +%Y.%m`
DATE = `/bin/date +%Y-%m-%d`

DOCKER_FLAGS ?= --memory=4GB --rm=true
DOCKER_MOUNTS ?= --mount type=bind,source=$(PWD)/pkg,destination=/opt/output
DOCKER_REPOSITORY ?= sl4mmy

all: Dockerfile pkg/ mingw-w64-binutils-2.29-1-x86_64.pkg.tar.xz
	docker build --rm=true --tag="$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)" $(DOCKER_FLAGS) .

Dockerfile: Dockerfile.in Makefile
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >$(@)

pkg/:
	mkdir pkg

attach:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-attach" $(DOCKER_MOUNTS) --entrypoint=/bin/bash "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

run:
	docker run --interactive=true --tty=true --rm=true --name="$(NAME)-$(VERSION)-run" $(DOCKER_MOUNTS) "$(DOCKER_REPOSITORY)/$(NAME):$(VERSION)"

update: Dockerfile.in
	git subtree pull --prefix $(NAME) https://aur.archlinux.org/xen.git master --squash
	sed "s/\$${ARCH_VERSION}/$(ARCH_VERSION)/; s/\$${VERSION}/$(VERSION)/; s/\$${REPOSITORY}/$(DOCKER_REPOSITORY)/; s/\$${DATE}/$(DATE)/" $(<) >Dockerfile
	$(MAKE)

clean:
	-rm -f Dockerfile
	-rm -rf pkg/

.PHONY: all attach clean run update
