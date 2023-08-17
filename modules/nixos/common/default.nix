{ inputs, ... }:
{
  imports = [
    ./auto-upgrade.nix
    ../../shared/nix-daemon.nix
    ./reboot.nix
    ./security.nix
    ./sops-nix.nix
    ./users.nix
    inputs.sops-nix.nixosModules.sops
    inputs.srvos.nixosModules.mixins-telegraf
    inputs.srvos.nixosModules.server
  ];

  # users in trusted group are trusted by the nix-daemon
  nix.settings.trusted-users = [ "@trusted" ];

  users.groups.trusted = { };

  # Sometimes it fails if a store path is still in use.
  # This should fix intermediate issues.
  systemd.services.nix-gc.serviceConfig = {
    Restart = "on-failure";
  };

  networking.firewall.allowedTCPPorts = [ 9273 ];

  srvos.flake = inputs.self;

  zramSwap.enable = true;

  security.acme.defaults.email = "trash@nix-community.org";
  security.acme.acceptTerms = true;

  networking.domain = "nix-community.org";
}
