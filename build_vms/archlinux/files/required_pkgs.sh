#!/usr/bin/bash
echo "[INFO] Installing packages for gitlab-runner";
pacman -Syy --noconfirm;
pacman -Sy --noconfirm cmake doxygen graphviz pacman
pacman -Sy --noconfirm git git-lfs gitlab-runner
systemctl enable gitlab-runner
echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/admins"
chmod 440 "/etc/sudoers.d/admins"
echo "[INFO] Installation completed for gitlab-runner";
