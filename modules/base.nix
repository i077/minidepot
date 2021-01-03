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
  networking.hostName = "minisilo";
  networking.interfaces.eth0.useDHCP = true;

  # If wireless is needed, uncomment this
  # hardware.enableRedistributableFirmware = true;

  time.timeZone = "America/New_York";

  # Users
  users.users = {
    root = {
      hashedPassword =
        "$6$90j83ybRsVCZn$/X3kl0UTMetLagKxu8OC/.eShNAogJsFZ3idoVInW7N6MjV.1yDKZPDjsasRb87IzFkkNbzTho7q./MQzGFRN0";
    };

    minisilo = {
      isNormalUser = true;
      hashedPassword = "";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU6iRY3yHvhu1GeQg7AdLOsYEIpqNE2ik9u/kmHA+TmX6PsqtfGyNpiS+fEgTd8ZrFetFhUR5wmJazVw7Xjjt+K8JkXl1mUvXzbfat8AoONnr7f6cqH8+B022g7Nb3hh4/4mhCP+jIjZ9T22bIhzJGTaH18yf/L8zJK7baOpJv2jPpEyNbl4mj5AWXtYXq8tt2LHG1yiNT9HDHFHUx+XZZY2npIieiyuFNieClIkxzIyQw1j5M0D7lstz3Mqe5KyhoBZRVXSI4njCzl3YL0JQHbT3qD+9SAaq/nlWizaMM5056pdRrgqmEWyDGdrdgPzt0240NKLlxKRsplqUFeM7z imran@giratina"
      ];
    };
  };

  system.stateVersion = "20.09";
}
