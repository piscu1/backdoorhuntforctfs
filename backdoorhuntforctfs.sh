#!/bin/bash

# =============================================================================
# backdoorhuntforctfs - Linux backdoor detection suite for CTFs
# Author: piscu
# =============================================================================

BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}[*] Backdoor Hunt Started at $(date)${NC}"

echo -e "\n${BOLD}[*] Checking crontabs...${NC}"
suspicious=$(crontab -l 2>/dev/null | grep -v '^#' | grep -Ei '(curl|wget|nc|bash|sh|python|perl|exec|reverse)')
if [ -n "$suspicious" ]; then
    echo -e "${BOLD}${suspicious}${NC}"
else
    echo -e "${BOLD}No suspicious user crontab entries.${NC}"
fi
find /etc/cron* -type f -exec grep -H '.' {} \; 2>/dev/null | grep -v '^#' | grep -Ei '(curl|wget|nc|bash|sh|python|perl|exec|reverse)' | while read -r line; do
    echo -e "${BOLD}${line}${NC}"
done

echo -e "\n${BOLD}[*] Checking systemd services...${NC}"
systemctl list-unit-files --type=service | grep enabled | grep -Ei '(backdoor|malware|suspicious|reverse|netcat|nc)' | while read -r line; do
    echo -e "${BOLD}${line}${NC}"
done

echo -e "\n${BOLD}[*] Checking shell aliases...${NC}"
alias | grep -Ei '(rm|cp|mv|ls|sudo)' | while read -r line; do
    echo -e "${BOLD}${line}${NC}"
done

echo -e "\n${BOLD}[*] Checking /etc/rc.local...${NC}"
if [ -f /etc/rc.local ]; then
    grep -v '^#' /etc/rc.local | grep -Ei '(curl|wget|nc|bash|sh|python|perl|exec|reverse)' | while read -r line; do
        echo -e "${BOLD}${line}${NC}"
    done
else
    echo -e "${BOLD}/etc/rc.local not found${NC}"
fi

echo -e "\n${BOLD}[*] Checking user login history...${NC}"
command -v lastlog >/dev/null 2>&1 && lastlog | grep -v 'Never' | while read -r line; do
    echo -e "${BOLD}${line}${NC}"
done || echo -e "${BOLD}lastlog command not found.${NC}"

echo -e "\n${BOLD}[*] Checking authorized_keys...${NC}"
for dir in /home/*; do
    keyfile="$dir/.ssh/authorized_keys"
    if [ -f "$keyfile" ]; then
        grep -Ei '(ssh-rsa|ssh-ed25519|ssh-dss)' "$keyfile" | while read -r line; do
            echo -e "${BOLD}${keyfile}:${NC}"
            echo -e "${BOLD}${line}${NC}"
        done
    fi
done

echo -e "\n${BOLD}[*] Checking processes running from /tmp, /dev, /var...${NC}"
ps axo pid,command | grep -E '/tmp|/dev|/var' | grep -v grep | while read -r line; do
    echo -e "${BOLD}${line}${NC}"
done

echo -e "\n${BOLD}[*] Checking .bashrc and .profile for suspicious commands...${NC}"
for userdir in /home/*; do
    for file in .bashrc .profile; do
        fullpath="$userdir/$file"
        if [ -f "$fullpath" ]; then
            grep -Ei '(alias|curl|wget|nc|bash|sh|python|perl|reverse|exec)' "$fullpath" | while read -r line; do
                echo -e "${BOLD}${fullpath}:${NC}"
                echo -e "${BOLD}${line}${NC}"
            done
        fi
    done
done

echo -e "\n${BOLD}[*] Checking hidden files in home directories with suspicious content...${NC}"
find /home -maxdepth 3 -type f -name ".*" ! -name ".bashrc" ! -name ".profile" -exec grep -lEi 'bash|curl|wget|nc|exec' {} \; 2>/dev/null | while read -r file; do
    echo -e "${BOLD}Hidden suspicious file: $file${NC}"
done

echo -e "\n${BOLD}[*] Checking for uncommon SUID/SGID binaries...${NC}"
find / -perm /6000 -type f 2>/dev/null | grep -vE '/(bin|sbin|usr|lib)' | while read -r line; do
    echo -e "${BOLD}$line${NC}"
done

echo -e "\n${BOLD}[*] Checking /etc/sudoers and /etc/sudoers.d/...${NC}"
[ -f /etc/sudoers ] && grep -v '^#' /etc/sudoers | grep -Ei '(ALL|NOPASSWD|/bin/sh|/bin/bash)' | while read -r line; do
    echo -e "${BOLD}/etc/sudoers: $line${NC}"
done
find /etc/sudoers.d -type f 2>/dev/null | while read -r file; do
    grep -v '^#' "$file" | grep -Ei '(ALL|NOPASSWD|/bin/sh|/bin/bash)' | while read -r line; do
        echo -e "${BOLD}$file: $line${NC}"
    done
done

echo -e "\n${BOLD}[*] Backdoor Hunt Completed at $(date)${NC}"
exit 0
