{ ... }:

{
  services.openssh = {
    enable = true;
    listenAddresses = [ { addr = "0.0.0.0"; port = 2222; } ];
    ports = [ 2222 ];
  };
}
