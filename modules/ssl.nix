{ config, ... }:

{
  sops.secrets.cf-acme-credentials = { };

  security.acme = {
    acceptTerms = true;
    email = "acme" + "@" + "imranh.xyz";
    certs."minidepot.imranh.xyz" = {
      dnsPropagationCheck = true;
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets.cf-acme-credentials.path;
    };
  };
  systemd.services."acme-minidepot.imranh.xyz".serviceConfig.SupplementaryGroups =
    [ config.users.groups.keys.name ];
  
  users.users.acme.extraGroups = [ config.users.groups.keys.name ];
}
