{ ... }:

let
  sshPublicKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU6iRY3yHvhu1GeQg7AdLOsYEIpqNE2ik9u/kmHA+TmX6PsqtfGyNpiS+fEgTd8ZrFetFhUR5wmJazVw7Xjjt+K8JkXl1mUvXzbfat8AoONnr7f6cqH8+B022g7Nb3hh4/4mhCP+jIjZ9T22bIhzJGTaH18yf/L8zJK7baOpJv2jPpEyNbl4mj5AWXtYXq8tt2LHG1yiNT9HDHFHUx+XZZY2npIieiyuFNieClIkxzIyQw1j5M0D7lstz3Mqe5KyhoBZRVXSI4njCzl3YL0JQHbT3qD+9SAaq/nlWizaMM5056pdRrgqmEWyDGdrdgPzt0240NKLlxKRsplqUFeM7z imran@giratina"
  ];
in {
  services.openssh = {
    enable = true;
    ports = [ 2255 ];
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  users.users = {
    minidepot.openssh.authorizedKeys.keys = sshPublicKeys;
  };

  # Add mosh for unreliable connections
  programs.mosh.enable = true;

  services.fail2ban.enable = true;
}
