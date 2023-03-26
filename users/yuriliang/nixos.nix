{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/zsh" ];

  users.users.yuriliang = {
    isNormalUser = true;
    home = "/home/yuriliang";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$H/3lsLZiSUzLtBtA$T6xDoy0OAtqPWLYE0JRHyFmpV4NsQK4kf0nscATyrwP1Jm4n5NGOIMdYoeLWbs/HRfcvQG.BT7Tsan9RQQBPX1";
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
