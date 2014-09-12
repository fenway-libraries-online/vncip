include config.mk

default:
	@echo "Please specify a target: install | release | clean"

install:
	mkdir -p /usr/local/vncip
	rsync -av --exclude conf/example bin conf lib /usr/local/vncip/

release: release/$(PROG)-$(VERSION).tar.gz

release/$(PROG)-$(VERSION).tar.gz: release/$(PROG)-$(VERSION)
	cd release && tar -czf $(PROG)-$(VERSION).tar.gz $(PROG)-$(VERSION)

release/$(PROG)-$(VERSION):
	mkdir -p release/$(PROG)-$(VERSION)
	rsync -av --exclude-from=MANIFEST.SKIP * release/$(PROG)-$(VERSION)/

clean:
	rm -Rf release/$(PROG)-*

.PHONY: default install release clean
