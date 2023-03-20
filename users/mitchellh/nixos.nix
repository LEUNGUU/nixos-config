{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  users.users.yuriliang = {
    isNormalUser = true;
    home = "/home/yuriliang";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$H/3lsLZiSUzLtBtA$T6xDoy0OAtqPWLYE0JRHyFmpV4NsQK4kf0nscATyrwP1Jm4n5NGOIMdYoeLWbs/HRfcvQG.BT7Tsan9RQQBPX1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbTIKIPtrymhvtTvqbU07/e7gyFJqNS4S0xlfrZLOaY mitchellh"
    ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
