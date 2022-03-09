# vim: set fdm=marker :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Switch to Linux-zen
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Boot/Networking/Locale/Time {{{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "YPC-NIXOS"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Enable networkManager

  # Set your time zone.
  time.timeZone = "Asia/Beirut";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  # }}}

  qt5.enable = false;
  # qt5.platformTheme = "kvantum";
  # qt5.style = "adwaita-dark";

  programs = {
    fish.enable = true;
    sway = {
      enable = true;
      extraSessionCommands = ''
        if [ -n "$DESKTOP_SESSION" ];then
        eval $(gnome-keyring-daemon --start)
        export SSH_AUTH_SOCK
        fi
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    kdeconnect.enable = true;
    qt5ct.enable = true; # disabled cause gnome doesn't like 🙂
    adb.enable = true;
    xonsh.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    git = {
      enable = true;
      config = {
        credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
        init = { defaultBranch = "main"; };
        url = { "https://github.com/" = { insteadOf = [ "gh:" "github:" ]; }; };
      };
    };
  };
  # Enable screen sharing via xdg-portal for sway
  xdg.portal.wlr.enable = true;

  # Enable PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  boot.plymouth.enable = true;

  # X11 Stuff {{{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Pantheon Desktop Environment.
  # services.xserver.desktopManager.pantheon.enable = true;
  # services.xserver.displayManager.lightdm.greeters.pantheon.enable = false;
  # services.xserver.displayManager.lightdm.enable = false;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.defaultSession = "sway";

  services.gnome.tracker-miners.enable = false;
  services.gnome.tracker.enable = false;


  # Enable KDE Plasma
  # services.xserver.desktopManager.plasma5.enable = true;
  # programs.ssh.askPassword =
  #   "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  # Use Qt5ct
  environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # }}}

  services.xserver.extraLayouts.usmod = {
    description = ''
      Modified to:
        - swap brackets and paranthesis
        - swap RAlt for Super (Useful on external keyboard)
    '';
    languages = [ "eng" ];
    symbolsFile = ./extra/usmod;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.vex = {
    name = "vex";
    members = [ "vex" ];
    gid = 1000;
  };
  users.users.vex = {
    isNormalUser = true;
    extraGroups = [
      "wheel"          # Enable ‘sudo’ for the user.
      "networkmanager" # Enable the user to modify network properties.
      "adbusers"       # Allow me to use ADB
    ];
    shell = pkgs.fish; # Change user shell to fish
  };

  # Installed programs {{{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.overlays = [
    (import (builtins.fetchTarball
      "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz")) # Installing Emacs 28+ will require nix-community/emacs-overlay:
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = (with pkgs; [
    emacsPgtkGcc
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    deluge # Everything download related
    ripgrep
    coreutils
    clang
    gcc # C/C++ Compilers
    tealdeer # Docs/Help
    firefox
    elinks
    chromium # Web browsers
    exa
    fd # Rust cli utils
    xterm
    alacritty # Terminal emulators
    pavucontrol
    htop
    btop # System monitors
    neofetch # System info fetchers
    keepassxc # Password managers
    rclone
    fuzzel
    wofi # Menues
    pamixer
    brightnessctl # Hardware clis
    sway-contrib.grimshot
    gnome.nautilus
    cinnamon.nemo
    dolphin # Graphical file managers
    mpd
    mpc_cli
    ncmpcpp # Music
    mako
    waybar # Ricing necessities
    networkmanagerapplet # Networking
    git
    oh-my-fish
    inkscape
    gimp
    krita # Image editors
    zip
    unzip
    atool
    p7zip # Archive managers
    mpv # Video Players
    texlive.combined.scheme-full # LaTeX
    nushell # Shells
    ghc
    cabal-install
    haskell-language-server # Everything haskell
    jetbrains.idea-community
    vscodium-fhs
    # pomotroid make derivation
    # PixivUtil2 make derivation
    evolution
    # xdman probably no need for derivation
    imv
    sxiv # Image Viewers
    # jetbrains.pycharm-community
    tdesktop # Telegram desktop
    lxappearance
    tela-icon-theme # Theming
    gtk-engine-murrine
    gtk_engines
    gsettings-desktop-schemas
    python3
    pipenv # Python + utils
    html-tidy
    ktlint
    nixfmt
    shellcheck # Code checkers/formatters...
    openjdk
    killall
    gnumake
    cmake # Build systems
    sqlite # Databases
    editorconfig-core-c
    jq
    pandoc
    libvterm
    libtool
    bintools-unwrapped
    rnix-lsp
    nethogs
    kotlin
    haskellPackages.hoogle
    zathura
    zoom-us
    android-file-transfer
    android-tools
    (nnn.override { withNerdIcons = true; })
    qutebrowser
    nyxt
    nix-index
    tridactyl-native
    qalculate-gtk
    libqalculate
    translate-shell
    glib
    libnotify
    rtags
    racer
    rustup
    rust-analyzer-unwrapped
    xdg-utils
    archivemount
    sshfs
    trash-cli
    fastjar
    mediainfo
    imagemagick
    unrar-wrapper
    tmux
    tabbed
    brave
    # busybox
    rofi-unwrapped
    gnome.pomodoro
    gnome.adwaita-icon-theme
    hicolor-icon-theme
    geogebra6
    libsForQt5.qtstyleplugin-kvantum
    konsole
    ark
    ffmpeg-full
    ffmpegthumbnailer
    ffmpegthumbs
    filelight
    wl-clipboard
    grim
    xmlformat
    ncdu
    duf
    plasma5Packages.dolphin-plugins
    libsForQt5.kdegraphics-thumbnailers
    lldb
    nodejs
    gdb
    lldb_9
    languagetool
    grip
    nixos-generators
    wordnet
    gnome.seahorse # conflicts with kde for some dumb reason
    ydotool
    poppler_utils
    kde-gtk-config
    nixos-option
    yaru-theme
    libsecret
    spotify
    clipman
    exfatprogs
    gdb
    gh
    gparted
    gradle
    grim
    libreoffice
    onlyoffice-bin
    parted
    poppler_utils
    starship
    texlab
    wl-clipboard
    xmlformat
    pantheon.elementary-calendar
  ]) ++ (with pkgs.python39Packages; [ # Include python39Packages
    isort
    nose
    pytest
    pip
    jsbeautifier
    setuptools
    conda
    yt-dlp
    pygments
  ]); # pckgsEnd }}}

  # Fonts {{{
  fonts = {
    # Install fonts
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" ]; })
      fira
      iosevka
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      libertinus
      emacs-all-the-icons-fonts
      cantarell-fonts
      libertinus
      open-sans
      vistafonts
      corefonts
      carlito
    ];
    fontconfig = {
      defaultFonts.monospace = [
        "Iosevka SS05"
        "Iosevka Term SS05"
        "Iosevka"
        "FiraCode Nerd Font"
        "Noto Naskh Arabic UI"
        "Hack"
      ];
      defaultFonts.sansSerif = [
        "Open Sans"
        "Cantarell"
        "Noto Kufi Arabic"
        "Noto Naskh Arabic UI"
        "Fira Sans"
        "Inter"
        "Noto Sans"
        "Noto Sans CJK JP Light"
      ];
      defaultFonts.serif = [
        "Libertinus Serif"
        "Calendas Plus"
        "Times New Roman"
        "Noto Naskh Arabic UI"
        "Noto Serif"
        "Noto Serif CJK JP"
        "Noto Serif CJK TC"
        "Noto Serif CJK HK"
      ];
      includeUserConf = true;
    };
  };
  # }}}

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable Hoogle, the haskell documentation search engine
  services.hoogle.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable GVFS (for MTP)
  services.gvfs.enable = true;

  # Override the stupid fontconfig generated by kde
  environment.etc."fonts/conf.d/52-nixos-default-fonts.conf".enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
