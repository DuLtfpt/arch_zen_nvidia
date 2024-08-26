#!/bin/bash

# Script to install NVIDIA drivers, AUR helper (yay), enable multilib, configure GRUB,
# set up early NVIDIA module loading, and configure pacman hook on Arch Linux

echo "Updating the system..."
sudo pacman -Syu --noconfirm

echo "Enabling multilib repository..."
sudo sed -i '/\[multilib\]/,/^Include/ s/^#//' /etc/pacman.conf

echo "Updating package lists after enabling multilib..."
sudo pacman -Sy --noconfirm

echo "Installing base development tools, Linux headers, Git, and Nano..."
sudo pacman -S --needed base-devel linux-headers git nano --noconfirm

echo "Cloning the yay repository..."
cd ~
git clone https://aur.archlinux.org/yay.git

echo "Building and installing yay..."
cd yay
makepkg -si --noconfirm

echo "Installing NVIDIA drivers and related packages with yay..."
yay -S --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings

echo "Editing GRUB configuration to enable NVIDIA DRM modeset..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /etc/default/grub

echo "Updating GRUB configuration..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuring early loading of NVIDIA modules..."
sudo sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
sudo sed -i 's/\<kms\>//g' /etc/mkinitcpio.conf

echo "Regenerating initramfs..."
sudo mkinitcpio -P

echo "Downloading and configuring nvidia.hook..."
cd ~
wget https://raw.githubusercontent.com/korvahannu/arch-nvidia-drivers-installation-guide/main/nvidia.hook

echo "Editing nvidia.hook file..."
sudo sed -i 's/Target=linux/Target=linux-zen/' nvidia.hook
sudo sed -i 's/Target=nvidia/Target=nvidia-dkms/' nvidia.hook

echo "Moving nvidia.hook to /etc/pacman.d/hooks/"
sudo mkdir -p /etc/pacman.d/hooks/
sudo mv ./nvidia.hook /etc/pacman.d/hooks/

echo "Installation complete. Rebooting the system is recommended."

# Optional: Reboot the system
# echo "Rebooting the system..."
# sudo reboot
