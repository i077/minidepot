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
        "$6$XXn8k2FP$L9QLgzqNCzgYUMo/0gRY6Xo2l19ZQNGxoAehZ.T8C33bFi3DUNwikyR.dD4pZtpjN2TUa6AZse1Zf4sY1WiwM/";
    };

    minidepot = {
      isNormalUser = true;
      hashedPassword =
        "$6$xfohTi0lIuOTH$b6lJ/EVAKNYpL2utymuYWFg/ziaA2tHTYlvWY3hfjXJV8qbRuaOH1Gm64.B/MS/KPVilHKR0fBq.249ar.wlB.";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU6iRY3yHvhu1GeQg7AdLOsYEIpqNE2ik9u/kmHA+TmX6PsqtfGyNpiS+fEgTd8ZrFetFhUR5wmJazVw7Xjjt+K8JkXl1mUvXzbfat8AoONnr7f6cqH8+B022g7Nb3hh4/4mhCP+jIjZ9T22bIhzJGTaH18yf/L8zJK7baOpJv2jPpEyNbl4mj5AWXtYXq8tt2LHG1yiNT9HDHFHUx+XZZY2npIieiyuFNieClIkxzIyQw1j5M0D7lstz3Mqe5KyhoBZRVXSI4njCzl3YL0JQHbT3qD+9SAaq/nlWizaMM5056pdRrgqmEWyDGdrdgPzt0240NKLlxKRsplqUFeM7z imran@giratina"
      ];
    };
  };

  nix.trustedUsers = [ "@wheel" ];

  system.stateVersion = "20.09";
}
