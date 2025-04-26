{
  description = "Custom OpenWrt image builder for Linksys WRT3200ACM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    main-flake.url = "github:5ysk3y/nixos-config";
  };

  outputs = { self, nixpkgs, flake-utils, main-flake, ... } @inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; };
        vars = main-flake.vars;
        config = import ./config.nix { inherit vars; };

        sharedInputs = with pkgs; [
          gawk git unzip wget jq zlib libressl python3 pkg-config
          which time file perl rsync cpio gettext ncurses curl gnumake
        ];
        commonExports = ''
          export ROUTER_HOST="''${ROUTER_HOST:-${config.ROUTER_HOST}}"
          export TARGET="''${TARGET:-${config.TARGET}}"
          export PROFILE="''${PROFILE:-${config.PROFILE}}"
          export FILES="''${FILES:-${config.FILES}}"
          export CUSTOM_PACKAGES_FILE="''${CUSTOM_PACKAGES_FILE:-${config.CUSTOM_PACKAGES_FILE}}"
          export EXCLUDE_PACKAGES_FILE="''${EXCLUDE_PACKAGES_FILE:-${config.EXCLUDE_PACKAGES_FILE}}"
        '';
      in
      {
        vars = main-flake.vars;
        devShells.default = pkgs.mkShell {
          name = "nixwrt-devshell";
          buildInputs = sharedInputs;
          shellHook = ''
            ${commonExports}
            echo "📦 OpenWrt dev shell ready. Please check and run ./build.sh to begin."
          '';
        };

        packages.default = pkgs.writeShellApplication {
          name = "nixwrt-imagebuilder";
          runtimeInputs = sharedInputs;
          text = ''
            #!/usr/bin/env bash

            ## Set environment
            ${commonExports}

            ## Run the imagebuilder
            "${self}/build.sh" "$@"

            ## Cleanup
            rm -rf ./imagebuilder
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nixwrt-imagebuilder";
        };
      });
}
