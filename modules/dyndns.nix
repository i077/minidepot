{ config, pkgs, ... }:

let
  dyndnsScript = pkgs.writeScript "dyndns.fish" (builtins.readFile ./dyndns.fish);

  interval = "15min";
  record = "minidepot.imranh.xyz";

  serviceUser = "cloudflare-dyndns";
in {
  # Declare API token secret
  sops.secrets.cfdyndns-token.owner = serviceUser;
  sops.secrets.cfdyndns-zoneid.owner = serviceUser;

  users.users.${serviceUser} = {
    home = "/var/empty";
    extraGroups = [ config.users.groups.keys.name ];
    isSystemUser = true;
  };

  # Much of this is taken from the cfdyndns module from nixpkgs
  systemd.services.cloudflare-dyndns = {
    description = "CloudFlare Dynamic DNS client";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    startAt = "5min";
    serviceConfig = {
      Type = "simple";
      User = serviceUser;
      SupplementaryGroups = [ config.users.groups.keys.name ];
    };
    # Dependencies of script
    path = with pkgs; [ fish curl jq ];

    environment = { CLOUDFLARE_RECORD = record; };
    # Export private info inside script
    script = ''
      export CLOUDFLARE_API_TOKEN="$(cat ${config.sops.secrets.cfdyndns-token.path})"
      export CLOUDFLARE_ZONEID="$(cat ${config.sops.secrets.cfdyndns-zoneid.path})"
      ${dyndnsScript}
    '';
  };

  # Run every 15 minutes
  systemd.timers.cloudflare-dyndns = {
    description = "Run CloudFlare ddns updater";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = interval;
      OnUnitInactiveSrc = interval;
    };
  };
}
