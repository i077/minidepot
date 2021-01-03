{ ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 2222 ];
  };
}
