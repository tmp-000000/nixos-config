{ config, ... }:
 
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
 
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
 
    secrets = {
      ssh_private_key = {
        path = "/home/faraquic/.ssh/id_rsa";
        owner = "faraquic";
        group = "users";
        mode = "0600";
      };
      gpg_private_key = {
        path = "/run/secrets/gpg_private_key";
        owner = "faraquic";
        mode = "0600";
      };
    };
  };
 
  systemd.user.services.import-gpg-key = {
    description = "Import GPG private key";
    wantedBy = [ "default.target" ];
    after = [ "sops-nix.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/bin/sh -c 'gpg --batch --import /run/secrets/gpg_private_key'";
    };
  };
}
