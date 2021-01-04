{ config, pkgs, ... }:

{
  # Declare DynDNS URL
  sops.secrets.dyndns-url.owner = "dyndns";

  users.users.dyndns.extraGroups = [ config.users.groups.keys.name ];

  # Much of this is taken from the cfdyndns module from nixpkgs
  systemd.services.dyndns = {
    description = "Dynamic DNS client";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    startAt = "5min";
    serviceConfig = {
      Type = "simple";
      User = "dyndns";
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
    script = ''
      export DYNDNS_URL="$(cat ${config.sops.secrets.dyndns-url.path})"
      ${pkgs.curl}/bin/curl $DYNDNS_URL
    '';
  };

  # Run every 15 minutes
  systemd.timers.dyndns = {
    description = "Run dynamic DNS updater";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitInactiveSrc = "15min";
    };
  };
}
