# Blue Screen of Death GRUB Theme

GRUB2 theme inspired by the iconic Windows "Blue Screen of Death" (BSOD) aesthetic.

![Preview](preview.png)

## Installation

### Prerequisites

- `make`
- `grub2-mkconfig` or `update-grub` (depending on your distro)
- `sed`

### Quick Install

The easiest way to install is to let the `Makefile` detect your distribution:

```bash
sudo make install
```

### Manual Distribution Install

If auto-detection fails:

**Fedora / Red Hat :**
```bash
sudo make fedora
```

**Debian:**
```bash
sudo make debian
```

**Arch Linux:**
```bash
sudo make arch
```

### Custom Resolution

By default, the theme uses `1920x1080`. You can specify a custom resolution during installation:

```bash
sudo make install RESOLUTION=1920x1200
```

## Preview and Testing

You can preview the theme in a QEMU virtual machine before applying it to your system.

### Install Development Dependencies

```bash
make dev-deps
```

### Run Preview

```bash
make test
```

## Uninstallation

To remove the theme and revert to the default GRUB appearance:

```bash
sudo make uninstall
```

## Technical Details

- **Main Config**: `blue-screen/theme.txt`
- **Fonts**: Victor Mono (Italic and Bold Italic)
- **Background**: 1920x1080 PNG
- **Icons**: Located in `blue-screen/icons/`

## Credits

This theme is based on the original [bsol](https://github.com/harishnkr/bsol) theme by @harishnkr.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
