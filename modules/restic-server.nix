{ config, pkgs, ... }:

let
  resticRepo = "/mnt/backup/restic_repo";
  resticOffsiteRepo = "rclone:onedrive:backup";
in {
  # Mount backup drive
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/62f089d4-627b-4812-8e58-f7ae47fc9f2b";
    fsType = "ext4";
  };

  # Declare sops secrets
  sops.secrets.restic-onsite-pass = {
    owner = "restic";
  };
  sops.secrets.restic-offsite-pass = {
    owner = "restic";
  };
  sops.secrets.rclone-config = {
    owner = "restic";
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
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.restic}/bin/restic copy";
      User = "restic";
      SupplementaryGroups = config.users.groups.keys.name;
    };
    # timerConfig = {
    #   OnCalendar = ""; # TODO
    #   RandomizedDelaySec = "1h";
    # };
  };

  # TODO define prune service

  # TODO define offsite prune service
}
