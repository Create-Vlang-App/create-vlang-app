# Create Vlang App — root task entrypoints
CORE := modules/create_vlang_app_core
CLI := modules/create_vlang_app
# CLI must see core; keep default vlib on the lookup path
CLI_VFLAGS := -path @vlib:$(CURDIR)/$(CORE)

.PHONY: test fmt fmt-check vet build clean help

help:
	@echo "Targets: test fmt fmt-check vet build clean"

test:
	cd $(CORE) && v test .
	cd $(CLI) && v $(CLI_VFLAGS) test .

fmt:
	cd $(CORE) && v fmt -w .
	cd $(CLI) && v fmt -w .

fmt-check:
	cd $(CORE) && v fmt -verify .
	cd $(CLI) && v fmt -verify .

vet:
	cd $(CORE) && v vet .
	cd $(CLI) && v $(CLI_VFLAGS) vet .

build:
	cd $(CLI) && v $(CLI_VFLAGS) -o $(CURDIR)/create-vlang-app .

clean:
	rm -f create-vlang-app
