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
  boot.loader.timeout = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    { name="luksroot"; device="/dev/sda2"; preLVM=true; }
  ];

  boot.extraModprobeConfig = ''
    options snd_hda_intel index=0 model=intel-mac-auto id=PCH
    options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
    options snd-hda-intel model=mbp101
  '';

  boot.cleanTmpDir = true;

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    facetimehd.enable = true;
    opengl.enable = true;
    opengl.driSupport32Bit = true;
    opengl.extraPackages = with pkgs; [ vaapiIntel ];
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.pulseaudioFull;
    pulseaudio.systemWide = false;
    pulseaudio.support32Bit = true;
    pulseaudio.daemon.config = {
      flat-volumes = "no";
    };
    bluetooth.enable = true;
  };
  sound.mediaKeys.enable = true;

  networking = {
    hostName = "mir"; # Define your hostname.
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    extraHosts = ''
      #127.0.0.1 twitter.com m.twitter.com mobile.twitter.com
      #127.0.0.1 news.ycombinator.com
    '';
    nameservers = ["1.1.1.1"];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "sun12x22";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";
  #time.timeZone = "Asia/Kolkata";

  powerManagement.enable = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget

  environment.systemPackages = with pkgs; [
     wget htop unzip 
     dmenu arandr autorandr 
     dunst libnotify xorg.xmessage
     wirelesstools wpa_supplicant_gui haskellPackages.xmobar slock
     (emacs.override { withGTK2 = false; withGTK3 = true; })
     tmux git
     firefox
     pass browserpass
     alacritty
     gnupg python3
     proselint
     lm_sensors
    
     vanilla-dmz lxappearance-gtk3 elementary-icon-theme gnome3.gnome_themes_standard
     xdg-user-dirs exfat ntfs3g

     dropbox-cli
  ];

  environment.variables = {
    NIX_REMOTE = "daemon";
    EDITOR = "nano";
    #GDK_SCALE = "2"; # For wayland/swaywm
  };
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  programs.light.enable = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.sway-beta.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  
  services.upower.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8000 17500 ];
  networking.firewall.allowedUDPPorts = [ 17500 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", TAG+="uaccess", RUN{builtin}+="uaccess"
  '';

  security.wrappers.slock = { source="${pkgs.slock}/bin/slock"; };

  services.ntp.enable = true;
  services.thermald.enable = true;
  services.acpid.enable = true;  
  services.mbpfan.enable = true;
  services.avahi.enable = true;

  services.tlp = {
    enable = true;
    # My macbook throws a fit of ATA errors when the mode is set to `max_performance`
    # or when switching between modes. So we stick to `medium_power`.
    extraConfig = ''
      SATA_LINKPWR_ON_AC=medium_power
      SATA_LINKPWR_ON_BAT=medium_power
    '';
  };

  services.emacs.enable = true;
  services.actkbd.enable = true;
  services.actkbd.bindings = [
   { keys = [ 224 ]; events = [ "key" "rep" ]; command= "${pkgs.light}/bin/light -U 4"; }
   { keys = [ 225 ]; events = [ "key" "rep" ]; command= "${pkgs.light}/bin/light -A 4"; }
   { keys = [ 113 ]; events = [ "key" "rep" ]; command= "${pkgs.pulseaudioFull.out}/bin/pactl set-sink-mute 0 toggle"; }
   { keys = [ 114 ]; events = [ "key" "rep" ]; command= "${pkgs.pulseaudioFull.out}/bin/pactl set-sink-volume 0 -10%"; }   
   { keys = [ 115 ]; events = [ "key" "rep" ]; command= "${pkgs.pulseaudioFull.out}/bin/pactl set-sink-volume 0 +10%"; }
  ];
  

  services.redshift = {
    enable = true;
    latitude = "37.8136"; longitude = "144.9631";
    brightness.day = "0.8";
    brightness.night = "0.4";
    temperature.day = 5500;
    temperature.night = 5500;    
  };

  services.xserver = {
    enable = true;
    startDbusSession = true;
    layout = "us";
    displayManager = {
      lightdm.enable = true;
      sessionCommands = ''
      '';
    };
    
    desktopManager.xterm.enable = false;
    desktopManager.default = "none";
#    desktopManager.wallpaper.mode = "fill";

    windowManager.default = "xmonad";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;

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
  #services.xserver.enable = true;
  #services.xserver.layout = "us";
  #services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;


  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  systemd.user.services.dunst = {
    description = "dunst";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dunst}/bin/dunst";
      Restart = "always";
    };
  };
  
  #virtualisation.docker.enable = true;

  users.extraUsers.nanda = {
     isNormalUser = true;
     uid = 1000;
     extraGroups = [ "wheel" "audio" "docker" ];
     createHome = true;
  };

  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    fontconfig = {
      enable = true;
      dpi = 200;
    };

    fonts = with pkgs; [
      ubuntu_font_family
      google-fonts
      font-awesome_5
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

}
