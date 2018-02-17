# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    { name="luksroot"; device="/dev/sda2"; preLVM=true; }
  ];

  boot.cleanTmpDir = true;

  networking.hostName = "mir"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "sun12x22";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     wget htop
     dmenu st
     emacs tmux git
     firefox
     alacritty
    
     vanilla-dmz lxappearance-gtk3 elementary-icon-theme gnome3.gnome_themes_standard
     xdg-user-dirs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  nixpkgs.config.dwm = {
    name = "dwm-6.1";
    patches = [
       /home/nanda/code/dotfiles/dwm/config.def.h.patch
    ];
  };

  security.wrappers.slock = { source="${pkgs.slock}/bin/slock"; };

  services.acpid.enable = true;  
  services.ntp.enable = true;
  services.redshift = {
    enable = true;
    provider = "geoclue2";
    brightness.day = "0.8";
    brightness.night = "0.4";
  };

  services.xserver = {
    enable = true;
    startDbusSession = true;
    layout = "us";
    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
        xsetroot -cursor_name left_ptr
        xset r rate 200 30
      '';
    };

    desktopManager.default = "none";
    desktopManager.wallpaper.mode = "fill";

    windowManager = {
      default = "dwm";
      dwm.enable = true;
    };

    xkbOptions = "ctrl:nocaps";
    xkbVariant = "mac";
    synaptics = {
      enable = true;
      accelFactor = "0.005";
      twoFingerScroll = true;
      palmDetect = true;
      tapButtons = true;
      buttonsMap = [1 3 2];
    };
  };
  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  users.extraUsers.nanda = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "audio" ];
     createHome = true;
  };

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    fontconfig.dpi = 220;

    fonts = with pkgs; [
      ubuntu_font_family
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}
