{ ... }:

{
  # Mount backup drive
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-uuid/62f089d4-627b-4812-8e58-f7ae47fc9f2b";
    fsType = "ext4";
  };

  services.restic.server = {
    enable = true;
    dataDir = "/mnt/backup/restic_repo";
    appendOnly = true; # Prunes are done server-side, clients only add snapshots
    listenAddress = ":6053";
    prometheus = true;
  };

  # TODO define prune service

  # TODO define copy restic offsite service

  # TODO define offsite prune service
}
