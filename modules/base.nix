# modules/default.nix -- Baseline config for the Raspi 4

{ pkgs, ... }:

{
  boot = {
    # Use raspi bootloader
    loader.grub.enable = false;
    loader.raspberryPi = {
      enable = true;
      version = 4;
    };

    # Raspi 4 kernel
    kernelPackages = pkgs.linuxPackages_rpi4;
  };

  # Add 2GB swap
  swapDevices = [{
    device = "/var/swapfile";
    size = 2048;
  }];

  # Networking -- I only use Ethernet, no wireless here
  networking.hostName = "minidepot";
  networking.interfaces.eth0.useDHCP = true;

  # If wireless is needed, uncomment this
  # hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/New_York";

  # Users
  users.users = {
    root = {
      hashedPassword =
        "$6$lAAHWHKiwDlnOh7j$CbaK9HYEN0u9Or/74P8UlppCHk0R9/9RQD/rLXc5TdiXCA1zeTouOnF9Uoay0Z5RrqSYSWxcLSBToWFNIj0590";
    };

    minidepot = {
      isNormalUser = true;
      hashedPassword =
        "$6$xfohTi0lIuOTH$b6lJ/EVAKNYpL2utymuYWFg/ziaA2tHTYlvWY3hfjXJV8qbRuaOH1Gm64.B/MS/KPVilHKR0fBq.249ar.wlB.";
      extraGroups = [ "wheel" ];
    };
  };

  nix.trustedUsers = [ "@wheel" ];

  # SOPS secrets management
  sops.defaultSopsFile = ../secrets/secrets.yaml;

  system.stateVersion = "20.09";
}
