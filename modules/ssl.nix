{ ... }:

{
  security.acme = {
    acceptTerms = true;
    email = "acme" + "@" + "imranh.xyz";
    certs."minidepot.imranh.xyz" = {};
  };
}
