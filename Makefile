THEME_NAME = bsod
THEME_DIR = /boot/grub2/themes
GRUB_CONFIG = /boot/grub2/grub.cfg
MKCONFIG = grub2-mkconfig
RESOLUTION ?= 1920x1080
DISTRO := $(shell if [ -f /etc/fedora-release ]; then echo fedora; \
            elif [ -f /etc/debian_version ]; then echo debian; \
            elif [ -f /etc/arch-release ]; then echo arch; \
            fi)

.PHONY: all install fedora debian arch help uninstall deps dev-deps test

help:
	@echo "bsol GRUB Theme Installer"
	@echo "Usage:"
	@echo "  sudo make install  - Automatically detect distro and install"
	@echo "  sudo make fedora   - Install on Fedora"
	@echo "  sudo make debian   - Install on Debian"
	@echo "  sudo make arch     - Install on Arch Linux"
	@echo "  sudo make uninstall - Remove the theme"
	@echo "  make deps          - Install system dependencies"
	@echo "  make dev-deps      - Install development dependencies (QEMU, preview tool)"
	@echo "  make test          - Preview theme in QEMU"
	@echo "  sudo make install RESOLUTION=1920x1200 - Install with custom resolution"

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
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)" RESOLUTION=$(RESOLUTION)

debian:
	$(eval THEME_DIR := /boot/grub/themes)
	$(eval MKCONFIG := update-grub)
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)" RESOLUTION=$(RESOLUTION)

arch:
	$(eval THEME_DIR := /boot/grub/themes)
	$(eval MKCONFIG := grub-mkconfig -o /boot/grub/grub.cfg)
	@$(MAKE) build-install THEME_DIR=$(THEME_DIR) MKCONFIG="$(MKCONFIG)" RESOLUTION=$(RESOLUTION)

build-install:
	@echo "Installing $(THEME_NAME) theme to $(THEME_DIR)..."
	mkdir -p $(THEME_DIR)/$(THEME_NAME)
	cp -r $(THEME_NAME)/* $(THEME_DIR)/$(THEME_NAME)/
	@echo "Updating /etc/default/grub..."
	sed -i '/^GRUB_THEME=/d' /etc/default/grub
	echo 'GRUB_THEME="$(THEME_DIR)/$(THEME_NAME)/theme.txt"' >> /etc/default/grub
	@echo "Updating GRUB_GFXMODE to $(RESOLUTION)..."
	sed -i '/^GRUB_GFXMODE=/d' /etc/default/grub
	echo 'GRUB_GFXMODE="$(RESOLUTION)"' >> /etc/default/grub
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

deps:
ifeq ($(DISTRO),fedora)
	sudo dnf install -y grub2-tools sed grep
else ifeq ($(DISTRO),debian)
	sudo apt-get update && sudo apt-get install -y grub-common sed grep
else ifeq ($(DISTRO),arch)
	sudo pacman -S --noconfirm grub sed grep
else
	@echo "Could not detect distribution. Please install dependencies manually."
endif

dev-deps:
ifeq ($(DISTRO),fedora)
	pip3 install --user grub2-theme-preview
	sudo dnf install -y qemu python3-pip
else ifeq ($(DISTRO),debian)
	pip3 install --user grub2-theme-preview
	sudo apt-get update && sudo apt-get install -y qemu-system-x86 python3-pip
else ifeq ($(DISTRO),arch)
	pip3 install --user grub2-theme-preview
	sudo pacman -S --noconfirm qemu python-pip
else
	@echo "Could not detect distribution. Please install dev-dependencies manually."
endif

test:
	@if command -v grub2-theme-preview >/dev/null 2>&1; then \
		grub2-theme-preview --resolution $(RESOLUTION) $(THEME_NAME); \
	fi
