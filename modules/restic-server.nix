{ pkgs, ... }:

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
  sops.secrets.restic-onsite-pass = {};
  sops.secrets.restic-offsite-pass = {};

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

  # TODO define copy restic offsite service
  systemd.services.restic-copy-offsite = {
    environment = {
      RESTIC_PASSWORD_FILE = null; # TODO
      RESTIC_REPOSITORY = resticRepo;
    };
  };

  # TODO define prune service

  # TODO define offsite prune service
}
