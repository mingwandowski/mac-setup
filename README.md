# mac-setup — my macOS bootstrap

This repository contains a small set of files to bootstrap a fresh macOS machine for development.

What is here
- `Brewfile` — list of packages and casks for Homebrew.
- `setup.sh` — interactive script to install Homebrew (if missing), run `brew bundle`, set Git identity, and optionally generate an SSH key.

How to use

1. Clone the repo and run the script:

```bash
git clone <your-repo-url> mac-setup
cd mac-setup
chmod +x setup.sh
./setup.sh
```

2. Follow prompts for Git name/email and SSH key generation (if you choose to create one).

Notes
- The script will try to install everything listed in `Brewfile`. If some items fail, the script continues and prints a warning.
- App Store apps or apps that require UI consent still need manual steps.

Mannual download apps:
- ClashX Pro
- ChipTone
- MyWallpaper
- Aseprite
- Color Picker
- Pixel Cake
- Red Note