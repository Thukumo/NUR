{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  yogabook = { config, lib, pkgs, ... }@args:
    let
      yogabook-linux-src = import ../pkgs/yogabook-src.nix pkgs;
    in
      (import "${yogabook-linux-src}/nix/module.nix") args;
}
