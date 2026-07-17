# John GCloud Setup

Install the latest **John the Ripper (Jumbo)** on **Google Cloud Shell** with a single command.

The script compiles John from source, installs the `wordlists` package, extracts `rockyou.txt`, creates convenient aliases, and provides a complete cleanup option.

---

# Connect to Google Cloud Shell

If you're using the Google Cloud CLI, connect to your Cloud Shell with:

```bash
gcloud cloud-shell ssh
```

---

# Quick Start

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/giriaryan694-a11y/john-gcloud-setup/main/john-gcloud-setup.sh | bash -s -- --install
```

---

## Cleanup

```bash
curl -fsSL https://raw.githubusercontent.com/giriaryan694-a11y/john-gcloud-setup/main/john-gcloud-setup.sh | bash -s -- --clean-up
```

---

## Help

```bash
curl -fsSL https://raw.githubusercontent.com/giriaryan694-a11y/john-gcloud-setup/main/john-gcloud-setup.sh | bash -s -- --help
```

---

# Available Flags

| Flag | Description |
|------|-------------|
| `--install` | Compile and install John the Ripper, install Python `wordlists`, and extract `rockyou.txt`. |
| `--clean-up` | Remove John, downloaded wordlists, aliases, and installed files. |
| `--help` / `-h` | Display the help menu. |

---

# What Gets Installed

```
~/security_tools/
├── john/
└── wordlists/
    └── rockyou.txt
```

Shell aliases:

```text
john
johnny
```

---

# Tested On

- Google Cloud Shell
- Ubuntu-based Cloud Shell
- 2 vCPU
- ~7 GB RAM

---

## Author

**Aryan Giri**

Built for pentesters, students, and CTF players who need a quick John the Ripper setup on Google Cloud Shell.
