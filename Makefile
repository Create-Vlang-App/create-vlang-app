# Create Vlang App — root task entrypoints
CORE := modules/create_vlang_app_core
CLI := modules/create_vlang_app
# Expose core to the CLI via V's module lookup path
export VFLAGS += -path $(CURDIR)/$(CORE)

.PHONY: test fmt vet build clean help

help:
	@echo "Targets: test fmt vet build clean"

test:
	cd $(CORE) && v test .
	cd $(CLI) && v $(VFLAGS) test .

fmt:
	cd $(CORE) && v fmt -w .
	cd $(CLI) && v fmt -w .

fmt-check:
	cd $(CORE) && v fmt -verify .
	cd $(CLI) && v fmt -verify .

vet:
	cd $(CORE) && v vet .
	cd $(CLI) && v $(VFLAGS) vet .

build:
	cd $(CLI) && v $(VFLAGS) -o $(CURDIR)/create-vlang-app .

clean:
	rm -f create-vlang-app
