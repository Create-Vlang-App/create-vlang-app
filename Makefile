# Create Vlang App — root task entrypoints
CORE := modules/create_vlang_app_core
CLI := modules/create_vlang_app
VMODULES_DIR := $(CURDIR)/.vmodules

.PHONY: test fmt fmt-check vet build clean help ensure-vmodules

help:
	@echo "Targets: test fmt fmt-check vet build clean"

ensure-vmodules:
	@mkdir -p $(VMODULES_DIR)
	@ln -sfn $(CURDIR)/$(CORE) $(VMODULES_DIR)/create_vlang_app_core

test: ensure-vmodules
	cd $(CORE) && v test .
	cd $(CLI) && VMODULES=$(VMODULES_DIR) v test .

fmt:
	cd $(CORE) && v fmt -w .
	cd $(CLI) && v fmt -w .

fmt-check:
	cd $(CORE) && v fmt -verify .
	cd $(CLI) && v fmt -verify .

vet: ensure-vmodules
	cd $(CORE) && v vet .
	cd $(CLI) && VMODULES=$(VMODULES_DIR) v vet .

build: ensure-vmodules
	cd $(CLI) && VMODULES=$(VMODULES_DIR) v -o $(CURDIR)/create-vlang-app .

clean:
	rm -f create-vlang-app
	rm -rf $(VMODULES_DIR)
