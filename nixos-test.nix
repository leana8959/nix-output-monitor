{
  pkgs,
  runNixOSTest,
  lib,
  nom-test,
}:

let

  olderNixVersions = {
    nix_2_18 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nix";
      tag = "2.18.9";
      hash = "sha256-RrOFlDGmRXcVRV2p2HqHGqvzGNyWoD0Dado/BNlJ1SI=";
    })).packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
      pname = "nix";
    });
  };

  testedNixVersions = [
    "nix_2_18"

    "nix_2_28"
    "nix_2_30"
    "nix_2_31"
    "nix_2_34"
  ];

  doTestForNixVersion =
    nixVersion:
    runNixOSTest {
      name = "nom_${nixVersion}";
      nodes.machine =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            # HACK: currently requires impure
            /nix/store/y7ji7mwys7g60j2w8bl93cmfbvd3xi3r-busybox-static-x86_64-unknown-linux-musl-1.35.0
          ];
          nix.package =  olderNixVersions.${nixVersion} or pkgs.nixVersions.${nixVersion};
        };

      testScript = /* python */ ''
        start_all()
        machine.succeed("nix-store -r /nix/store/y7ji7mwys7g60j2w8bl93cmfbvd3xi3r-busybox-static-x86_64-unknown-linux-musl-1.35.0/bin/")
        machine.execute("cp -r ${nom-test}/* .")
        machine.execute("./golden-tests 2>&1")

        machine.copy_from_machine("./test.log", "test.log")
      '';
    };
in
lib.genAttrs testedNixVersions doTestForNixVersion
