# bsol GRUB Theme Makefile

THEME_NAME = bsol
THEME_DIR = /boot/grub2/themes
GRUB_CONFIG = /boot/grub2/grub.cfg
MKCONFIG = grub2-mkconfig

# Detect distribution if not specified
DISTRO := $(shell if [ -f /etc/fedora-release ]; then echo fedora; \
            elif [ -f /etc/debian_version ]; then echo debian; \
            elif [ -f /etc/arch-release ]; then echo arch; \
            fi)

.PHONY: all install fedora debian arch help uninstall

help:
	@echo "bsol GRUB Theme Installer"
	@echo "Usage:"
	@echo "  sudo make install  - Automatically detect distro and install"
	@echo "  sudo make fedora   - Install on Fedora"
	@echo "  sudo make debian   - Install on Debian"
	@echo "  sudo make arch     - Install on Arch Linux"
	@echo "  sudo make uninstall - Remove the theme"

install:
ifeq ($(DISTRO),fedora)
	@$(MAKE) fedora
else ifeq ($(DISTRO),debian)
	@$(MAKE) debian
else ifeq ($(DISTRO),arch)
	@$(MAKE) arch
else
	@echo "Could not detect distribution. Please use 'make fedora', 'make debian', or 'make arch' explicitly."
	@exit 1
endif

fedora:
	$(eval THEME_DIR := /boot/grub2/themes)
	$(eval MKCONFIG := grub2-mkconfig -o /boot/grub2/grub.cfg)
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)"

debian:
	$(eval THEME_DIR := /boot/grub/themes)
	$(eval MKCONFIG := update-grub)
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)"

arch:
	$(eval THEME_DIR := /boot/grub/themes)
	$(eval MKCONFIG := grub-mkconfig -o /boot/grub/grub.cfg)
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)"

build-install:
	@echo "Installing $(THEME_NAME) theme to $(THEME_DIR)..."
	mkdir -p $(THEME_DIR)/$(THEME_NAME)
	cp -r $(THEME_NAME)/* $(THEME_DIR)/$(THEME_NAME)/
	@echo "Updating /etc/default/grub..."
	sed -i '/^GRUB_THEME=/d' /etc/default/grub
	echo 'GRUB_THEME="$(THEME_DIR)/$(THEME_NAME)/theme.txt"' >> /etc/default/grub
	@echo "Updating GRUB configuration..."
	$(MKCONFIG)
	@echo "Done!"

uninstall:
	@echo "Identifying theme directory..."
	$(eval THEME_DIR := $(shell if [ -d /boot/grub2/themes/$(THEME_NAME) ]; then echo /boot/grub2/themes; else echo /boot/grub/themes; fi))
	@echo "Removing $(THEME_NAME) theme from $(THEME_DIR)..."
	rm -rf $(THEME_DIR)/$(THEME_NAME)
	@echo "Removing GRUB_THEME from /etc/default/grub..."
	sed -i '/^GRUB_THEME=/d' /etc/default/grub
	@echo "Updating GRUB configuration..."
	@if [ -f /etc/fedora-release ]; then grub2-mkconfig -o /boot/grub2/grub.cfg; \
	 elif [ -f /etc/debian_version ]; then update-grub; \
	 elif [ -f /etc/arch-release ]; then grub-mkconfig -o /boot/grub/grub.cfg; \
	 fi
	@echo "Uninstall complete!"
