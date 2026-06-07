{
  runNixOSTest,
  lib,
  nom-test,
}:

let
  testedNixVersions = [
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
          nix.package = pkgs.nixVersions.${nixVersion};
        };

      testScript = /* python */ ''
        start_all()
        machine.succeed("nix-store -r /nix/store/y7ji7mwys7g60j2w8bl93cmfbvd3xi3r-busybox-static-x86_64-unknown-linux-musl-1.35.0/bin/")
        machine.succeed("bash -c 'export TESTS_FROM_FILE=true; cd ${lib.getOutput "test" nom-test}; ./golden-tests 2>&1'")
      '';
    };
in
lib.genAttrs testedNixVersions doTestForNixVersion
