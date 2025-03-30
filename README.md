# backdoorhuntforctfs

🔍 A single-file Linux backdoor detection script for CTFs, forensic analysis, and VM challenges.

## What it does

`backdoorhuntforctfs.sh` is a standalone Bash script that scans for common persistence techniques and indicators of compromise. It's optimized for quick deployment in CTFs, cyber exercises, or audit VMs. It's not gonna be successful 100% of the time, and it's not gonna do the work for you, you still have to check them manually.

## Features

- Checks crontab entries, systemd services, shell aliases, user logins
- Scans `.bashrc`, `.profile`, and `authorized_keys` for injected commands
- Detects processes running from `/tmp`, `/dev`, `/var`
- Looks for hidden files with suspicious content
- Lists uncommon SUID/SGID binaries
- Inspects `sudoers` and `sudoers.d` rules for privilege abuse


## Usage

```bash
chmod +x backdoorhuntforctfs.sh
./backdoorhuntforctfs.sh
```

No root needed, but some checks (like SUID scan) might give more results with `sudo`.

## Typical Output

```
[*] Checking crontabs...
No suspicious user crontab entries.
/etc/cron.d/php: suspicious line...

[*] Checking systemd services...
some-service.service

[*] Checking hidden files in home directories for suspicious content...
Suspicious hidden file: /home/user/.malicious
```

## Why it works

Challenge creators leave some clear hints most of the time for you to capture the flag and that's what we're going based of. This script uses grep-based heuristics to catch the most common ones — clean, simple, effective.

## Packaging

This script is designed to be:
- copied easily into a VM
- run without dependencies
- reviewed and audited in seconds
