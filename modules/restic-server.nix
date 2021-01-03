{ config, lib, pkgs, ... }:

let
  inherit (lib) concatStringsSep listToAttrs mkForce nameValuePair;

  resticRepo = "/mnt/backup/restic_repo";
  resticOffsiteRepo = "rclone:onedrive:backup";

  # Arguments for many of each snapshot type to keep
  pruneOpts = concatStringsSep " " [
    "--keep-daily 28"
    "--keep-weekly 16"
    "--keep-monthly 18"
    "--keep-yearly 10"
  ];
  pruneCmd = "${pkgs.restic}/bin/restic forget --prune ${pruneOpts}";

  # Base serviceConfig for restic services
  resticServiceWithCmd = cmd: {
    Type = "oneshot";
    ExecStart = cmd;
    User = "restic";
    SupplementaryGroups = config.users.groups.keys.name;
  };
in {
  # Mount backup drive
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/62f089d4-627b-4812-8e58-f7ae47fc9f2b";
    fsType = "ext4";
  };

  # Declare sops secrets
  sops.secrets = {
    restic-onsite-pass = { owner = "restic"; };
    restic-offsite-pass = { owner = "restic"; };
    rclone-config = {
      owner = "restic";
      # rclone needs write access to the residing directory
      path = "/var/tmp/restic-home/rclone.conf";
    };
  };

  # Workaround for letting rclone write temp files next to rclone.conf secret
  users.extraUsers.restic = {
    home = mkForce "/var/tmp/restic-home";
    createHome = true;
  };

  services.restic.server = {
    enable = true;
    dataDir = resticRepo;
    appendOnly = true; # Prunes are done server-side, clients only add snapshots
    listenAddress = ":6053";
    prometheus = true;
    extraFlags = [ "--no-auth" ]; # No need for HTTP authentication for now
  };

  # Allow TCP access to restic server port
  networking.firewall.allowedTCPPorts = [ 6053 ];

  # Service to copy backup snapshots offsite
  systemd.services.restic-copy-offsite = {
    environment = {
      RESTIC_PASSWORD_FILE = config.sops.secrets.restic-onsite-pass.path;
      RESTIC_REPOSITORY = resticRepo;

      RESTIC_PASSWORD_FILE2 = config.sops.secrets.restic-offsite-pass.path;
      RESTIC_REPOSITORY2 = resticOffsiteRepo;

      RCLONE_CONFIG = config.sops.secrets.rclone-config.path;
    };
    restartIfChanged = false;
    serviceConfig = resticServiceWithCmd "${pkgs.restic}/bin/restic copy";
  };
  # Run every Sunday at about noon
  systemd.timers.restic-copy-offsite = {
    timerConfig = {
      OnCalendar = "Sunday 12:00";
      RandomizedDelaySec = "1h";
      Persistent = true; # Start at next reboot if timer was missed
    };
    wantedBy = [ "timers.target" ];
  };

  # Service to prune onsite respository
  systemd.services.restic-prune-onsite = {
    environment = {
      RESTIC_PASSWORD_FILE = config.sops.secrets.restic-onsite-pass.path;
      RESTIC_REPOSITORY = resticRepo;
    };
    restartIfChanged = false;
    serviceConfig = resticServiceWithCmd pruneCmd;
  };

  # TODO define offsite prune service
}
