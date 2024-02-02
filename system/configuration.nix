{ inputs, pkgs, stdenv, lib, config, modulesPath, ... }:

let
  cpkgs = inputs.hydra-test.packages.aarch64-linux;
in {
  imports =
    [ # Include the results of the hardware scan.
      (modulesPath + "/installer/scan/not-detected.nix")
      # inputs.nix13s.nixosModules.nix13s
    ];

  nixpkgs.overlays = [
    (final: super: {
      libvirt = super.libvirt.override(_: {
        enableZfs = false;
      });
      zfs = super.zfs.overrideAttrs(_: {
        meta.platforms = [];
      });
    })
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.auto-optimise-store = true;
    settings = {
      substituters = [
        "https://cache.useless-thing.net/"
      ];
      trusted-public-keys = [
        "cache.useless-thing.net:gifkyXgOeSVeFzqi4kVhjry2SmW4g0L6lnxCmrqZczg="
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    useOSProber = true;
    device = "nodev";
    extraPerEntryConfig = "devicetree ${builtins.toString cpkgs.linux_x13s}/dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";
  };
  boot.kernelPackages = pkgs.linuxPackagesFor cpkgs.linux_x13s;
  boot.kernelParams = [
    "earlyprintk=efi" "loglevel=7" "console=tty0"
    "clk_ignore_unused" "firmware_class.path=${
      builtins.toString cpkgs.x13s-firmware
    }/lib/firmware"
  ];

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  programs.dconf.enable = true;
  programs.ssh.askPassword = "";
  programs.slock.enable = true;

  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.tapping = false;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "altgr-intl";

  #programs.xwayland.enable = true;
  #programs.river.enable = true;
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.displayManager.sddm.wayland.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.stumpwm.enable = true;

  console = {
    keyMap = "us";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  users.users.Us0r = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  environment.systemPackages = with pkgs; [
    man-pages man-pages-posix
    cpkgs.qrtr cpkgs.pd-mapper
  ];

  fonts.packages = [
    pkgs.iosevka
    cpkgs.iosevka-term
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  systemd.services.pd-mapper = {
    enable = true;
    description = "pd-mapper qualcom battery";
    serviceConfig = {
      ExecStart = "${cpkgs.pd-mapper}/bin/pd-mapper";
      User = "root";
      Type = "simple";
    };
    wantedBy = [ "multi-user.target" ];
  };

  #virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.kresd.enable = true;
  services.logrotate.enable = false;

  services.syncthing = {
    enable = true;
    user = "Us0r";
    configDir = "/home/Us0r/.config/syncthing";
  };

  services.tlp = {
    enable = true;
    settings = {
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
    };
  };

  services.fwupd.enable = true;

  networking.hostName = "ribes-uva-crispa";
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  networking.firewall.allowedTCPPorts = [ 22000 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It’s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e1c8ea9d-82b1-4e5a-a0f1-be1a5d099160";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/FE80-11C1";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  #networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlP6p1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  hardware.enableAllFirmware = lib.mkForce true;
  hardware.firmware = lib.mkForce [
    cpkgs.x13s-firmware
  ];

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
  ];

  documentation.dev.enable = true;
  documentation.man.generateCaches = true;
}
