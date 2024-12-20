<ol>
<li>Download Arch Linux ISO</li>
<li>Burn it to a USB flash</li>
<li>Boot it (make sure <b>secure boot</b> is disabled).</li>
</ol>

### 1. [Optional] Connect to Wi-Fi (on Ethernet, you don't have to do this):
<pre>
  $ iwctl
  [iwd]# station wlan0 get-networks
  [iwd]# station wlan0 connect <Network's name>
  [iwd]# exit
  $ ping google.com
</pre>

### 2. Synchronize packages:
<pre>
  $ pacman -Syy
</pre>

### 3. Disk partitioning (using fdisk):
<pre>
  $ fdisk /dev/nvme0n1
  <i>[repeat this command until existing partitions are deleted]</i>
  Command (m for help): <b>d</b>
  Command (m for help): <b>d</b>
  Command (m for help): <b>d</b>

  <i>[create partition 1: <b>efi</b>]</i>
  Command (m for help): <b>n</b>
  Partition number (1-128, default 1): <b>Enter</b>
  First sector (..., default 2048): <b>Enter</b>
  Last sector ...: <b>+512M</b>

  <i>[create partition 2: <b>swap</b>]</i>
  Command (m for help): <b>n</b>
  Partition number (2-128, default 2): <b>Enter</b>
  First sector (..., default ...): <b>Enter</b>
  Last sector ...: <b>+64G</b> <i>// Double size of your RAM</i>

  <i>[create partition 3: <b>/</b>]</i>
  Command (m for help): <b>n</b>
  Partition number (3-128, default 3): <b>Enter</b>
  First sector (..., default ...): <b>Enter</b>
  Last sector ...: <b>Enter</b>

  <i>[change partition types]</i>
  Command (m for help): <b>t</b>
  Partition number (1-3, default 1): <b>1</b>
  Partion type or alias (type L to list all): <b>uefi</b>
  
  Command (m for help): <b>t</b>
  Partition number (1-3, default 2): <b>2</b>
  Partion type or alias (type L to list all): <b>swap</b>
  
  Command (m for help): <b>t</b>
  Partition number (1-3, default 3): <b>3</b>
  Partion type or alias (type L to list all): <b>linux</b>

  <i>[write partitioning to disk]</i>
  Command (m for help): <b>w</b>
</pre>

### 4. Create filesystems on created disk partitions:
<pre>
  $ mkfs.fat -F 32 /dev/nvme0n1p1
  $ mkswap /dev/nvme0n1p2
  $ mkfs -t ext4 /dev/nvme0n1p3
</pre>

### 5. Mount all filesystems to /mnt:
<pre>
  $ mount /dev/nvme0n1p3 /mnt
  $ mkdir -p /mnt/boot/efi
  $ mount /dev/nvme0n1p1 /mnt/boot/efi
  $ swapon /dev/nvme0n1p2
</pre>

### 6. Install essential packages into new filesystem and generate fstab:
<pre>
  <i>[install amd-ucode for AMD chipset or intel-ucode for INTEL chipset]</i>
  $ pacstrap -i /mnt base linux linux-firmware sudo nano amd-ucode
  $ genfstab -U -p /mnt > /mnt/etc/fstab
</pre>

### 7. Basic configuration of new system:
<pre>
  $ arch-chroot /mnt
  <i>[uncomment your locales, i.e. 'en_US.UTF-8' or 'pt_BR.UTF-8']</i>
  $ nano /etc/locale.gen
  $ locale-gen
  $ echo "LANG=en_US.UTF-8" > /etc/locale.conf
  $ ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  $ hwclock --systohc
</pre>

### 8. Setup hostname and usernames:
<pre>
  $ echo <i>yourhostname</i> > /etc/hostname
  $ nano /etc/hosts
      <i>127.0.0.1 localhost</i>
      <i>::1 localhost</i>
      <i>127.0.1.1 yourhostname</i>
  $ useradd -m -G wheel,storage,power,audio,video -s /bin/bash yourusername
  $ passwd root
  $ passwd yourusername
  $ EDITOR=nano visudo
      <i>[uncomment following line]</i>
      <i>%wheel ALL=(ALL) ALL</i>
</pre>

### 9. Install and setup GRUB:
<pre>
  $ pacman -S grub efibootmgr
  $ grub-install /dev/nvme0n1
  $ grub-mkconfig -o /boot/grub/grub.cfg
</pre>

### 10. Setup networking:
<pre>
  $ pacman -S dhcpcd networkmanager resolvconf
  $ systemctl enable dhcpcd
  $ systemctl enable NetworkManager
  $ systemctl enable systemd-resolved
</pre>

### 11. Exit chroot, unmount all disks and reboot:
<pre>
  $ exit
  $ umount /mnt/boot/efi
  $ umount /mnt
  $ reboot
</pre>

<h1 align="center">
    Setup Hyprland
</h1>

### 12. Activate time synchronization using NTP:
<pre>
  $ timedatectl set-ntp true
</pre>

### 13. [Optional] Connect to Wi-Fi using nmcli:
<pre>
  $ nmcli device wifi connect <Network's name> password <Network's password>
</pre>

### 14. Install useful packages:
<pre>
  $ sudo pacman -S dbus base-devel git btop wget curl
  $ sudo pacman -S openssh bash-completion fuse2
  $ sudo pacman -S ripgrep fd python make eza
  $ sudo pacman -S grim slurp firefox nwg-look
  $ sudo pacman -S python-gobject lib32-systemd
</pre>

### 15. Install fonts:
<pre>
  $ sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation 
  $ sudo pacman -S terminus-font ttf-font-awesome noto-fonts
  $ sudo pacman -S noto-fonts-emoji ttf-ubuntu-font-family
  $ sudo pacman -S ttf-roboto ttf-jetbrains-mono ttf-droid
</pre>

### 16. Enable multilib (32-bit packages):
<pre>
  $ sudo nano /etc/pacman.conf
  <i>[uncomment [multilib] section]</i>
  $ sudo pacman -Sy
</pre>

### 17. Install sound drivers and sound support:
<pre>
  $ sudo pacman -S pipewire wireplumber pipewire-audio
  $ sudo pacman -S pipewire-alsa pipewire-pulse pipewire-jack
  $ sudo pacman -S lib32-pipewire
</pre>

### 18. [Optional] Enable bluetooth support:
<pre>
  $ sudo pacman -S bluez bluez-utils
  $ sudo systemctl enable bluetooth
</pre>

### 19. [Optional] Run service that will discard unused blocks on mounted filesystems. This is useful for SSDs and thinly-provisioned storage:
<pre>
  $ sudo systemctl enable fstrim.timer
</pre>

### 20. Install GPU drivers (and packages for gaming):
<b>AMD</b>
<pre>
  $ sudo pacman -S xf86-video-amdgpu mesa lib32-mesa
  $ sudo pacman -S vulkan-radeon lib32-vulkan-radeon
</pre>

<b>NVIDIA</b>
<pre>
  $ sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils
</pre>

### 21. Reboot:
<pre>
  $ reboot
</pre>

### 22. Install yay:
<pre>
  $ git clone https://aur.archlinux.org/yay.git
  $ cd yay
  $ makepkg -si
  $ cd ..
  $ rm -r yay
</pre>

### 23. Install Hyprland:
<pre>
  $ sudo pacman -S hyprland
  $ sudo pacman -S dunst xdg-desktop-portal-hyprland
  $ sudo pacman -S qt5-wayland qt6-wayland
  $ yay -S hyprpolkitagent wlogout qimgv-git
  $ sudo pacman -S waybar rofi alacritty hyprlock
  $ sudo pacman -S hyprpaper cliphist thunar
  $ sudo pacman -S tumbler ffmpegthumbnailer
</pre>

### 24. Setup your dotfiles...

### 25. Install additional softwares:
<pre>
  $ sudo pacman -S steam discord spotify-launcher fastfetch
  $ yay -S pwvucontrol visual-studio-code-bin
  <i>[install vencord]</i>
  $ sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"
</pre>

### 26. Solving common bugs:
<pre>
  In games with anticheat (Elden Ring, for example), you need to add the following parameters on Steam launch:
  <b>env --unset=SDL_VIDEODRIVER %command%</b>

  If some electron apps don't open (vscode, discord...):
  <b>open nwg-look. On "Mouse cursor" section, just click on any theme. This will solve the bug.</b>

  If you're experiencing a connect problem on Ubisoft Connect, install the following package:
  <b>$ sudo pacman -S lib32-gnutls</b>
</pre>
