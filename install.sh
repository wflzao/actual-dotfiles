#!/bin/sh

#variables
cr="\033[1;31m"
cg="\033[1;32m"
cb="\033[1;34m"

printf "${cg}[*] Proceeding Will Replaces Your Previous Config, Make A Backup Before Running It.\n"
printf "${cr}"
read -p "[*] DO YOU WANT TO PROCEED [Y/N] " allowed
dir="$HOME/.config $HOME/Pictures/Wallpapers $HOME/.local/bin $HOME/.fonts"

case $allowed in
  Y*|y*)
    for a in $dir; do 
      mkdir -p $a 
    done
    printf "${cg} [*] Installing NVIDIA drivers\n"
    sudo pacman -S nvidia-settings nvidia-utils lib32-nvidia-utils lib32-opencl-nvidia opencl-nvidia libvdpau libxnvctrl vulkan-icd-loader lib32-vulkan-icd-loader
    printf "${cb} [*] NVIDIA drivers installed"
    printf "${cg} [*] Setting up NVIDIA-settings\n"
    mkdir ~/.config/autostart
    sudo tee /etc/xdg/autostart/nvidia-settings.desktop > /dev/null << EOT
      [Desktop Entry]
      Name=nVidia2
      Comment=Load nVidia Configuration
      Icon=system-run
      Exec=nvidia-settings --config=/etc/.nvidia-settings-rc --load-config-only
      Terminal=false
      Type=Application
      OnlyShowIn=GNOME;XFCE;
      X-GNOME-Autostart-enabled=true
EOT
    sudo cp /etc/xdg/autostart/nvidia-settings.desktop ~/.config/autostart/nvidia-settings.desktop
    sudo tee /etc/profile.d/autostart.sh > /dev/null << EOT
#!/bin/bash
VAL=850
nvidia-settings -a "DigitalVibrance=\$VAL" > /dev/null
nvidia-settings --display :0 -a GPUFanControlState=1 -a GPUTargetFanSpeed=75
EOT
    printf "${cb} [*] NVIDIA-settings set up\n"
    printf "${cg} [*] Removing PC speaker\n"
    sudo tee /etc/modprobe.d/nobeep.conf > /dev/null << EOT
blacklist pcspkr
EOT
    sudo rmmod pcspkr
    printf "${cb} [*] PC speaker removed\n"
    printf "${cg} [*] Removing mouse accel\n"
    sudo tee /etc/X11/xorg.conf.d/50-mouse-acceleration.conf > /dev/null << EOT
Section "InputClass"
	Identifier "My Mouse"
	Driver "libinput"
	MatchIsPointer "yes"
	Option "AccelProfile" "flat"
	Option "AccelSpeed" "0"
EndSection
EOT
    printf "${cb} [*] Mouse accel removed\n"
    printf "${cg} [*] Installing apps\n"
    yay -S kitty rofi ranger polybar gotop sh picom neovim lxappearance flameshot feh zsh fd zathura mpd codium bitwarden dunst xsettingsd pulseaudio zathura-pdf-mupdf spotify tor proxychains
    printf "${cb} [*] Apps installed\n"
    printf "${cg} [*] Installing lightDM greeter\n"
    sudo pacman -S lightdm-webkit2-greeter
    sudo pacman -R eos-lightdm-slick-theme
    sudo pacman -R lightdm-slick-greeter
    yay -S lightdm-webkit2-theme-glorious
    sudo cp ~/Pictures/Wallpapers/* /usr/share/backgrounds/
    sudo sed -i 's/^greeter-session=.*/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf
    sudo sed -i 's/^debug_mode          =.*/debug_mode          = true/' /etc/lightdm/lightdm-webkit2-greeter.conf
    sudo sed -i 's/^webkit_theme        =.*/webkit_theme        = glorious/' /etc/lightdm/lightdm-webkit2-greeter.conf
    printf "${cb} [*] LightDM greeter installed\n"
    printf "${cg} [*] Installing cursor theme\n"
    sudo rm -rf /usr/share/icons/default/*
    sudo cp -rf cursor/. /usr/share/icons/default
    sudo sed -i 's/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=default/' ~/.config/gtk-3.0/settings.ini
    sudo tee ~/.gtkrc-2.0.mine > /dev/null << EOT
gtk-theme-name=paradise
gtk-cursor-theme-name=default
EOT
    printf "${cb} [*] Cursor theme installed"
    printf "${cg} [*] Copying Dotfiles\n"
    printf "${cb} [*] Copying Configs\n"
    cp -ra cfg/. ~/.config
    cp -ra home/. ~/.
    sudo cp -ra home/.themes/. /usr/share/themes/
    sudo sed -i 's/^gtk-theme-name=.*/gtk-theme-name=paradise/' ~/.config/gtk-3.0/settings.ini
    printf "${cg} [*] Configs Copied\n"
    printf "${cb} [*] Copying Wallpapers\n"
    cp -ra walls/. ~/Pictures/Wallpapers
    printf "${cg} [*] Wallpapers Copied\n"
    printf "${cb} [*] Copying Fonts\n"
    cp -ran fonts/. ~/.fonts
    printf "${cg} [*] Fonts Copied\n"
    printf "${cb} [*] Setting up git\n"
    git config --global user.name "wflzao"
    git config --global user.email "wafflemain@protonmail.com"
    git config credential.helper store
    git config --global credential.helper "cache --timeout 7200"
    printf "${cg} [*] Git set up\n"
    printf "${cb} [*] Setting up firefox\n"
    firefox_profiles_dir="$HOME/.mozilla/firefox"
    default_release_dir=""
    while IFS= read -r -d '' profile_dir; do
        if [[ "$profile_dir" == *".default-release" ]]; then
            default_release_dir="$profile_dir"
            break
        fi
    done < <(find "$firefox_profiles_dir" -maxdepth 1 -type d -name "*default-release" -print0)
    if [ -n "$default_release_dir" ]; then
        mkdir -p "$default_release_dir/chrome"
        cp -rf userChrome.css "$default_release_dir/chrome"
    else
        printf "Error: The default-release folder could not be found\n"
    fi
    printf "${cg} [*] Dotfiles Installed\n";;
  *) printf "${cr} [-] Aborting!\n";;
esac
