silicon: lib:
with builtins;
with lib;
with silicon; {
  channel = rec {
    value = "23.11";
    dashed = replaceStrings [ "." ] [ "-" ] iron.attrs.channel.value;
    comparison = compareVersions iron.bases.treads.inputs.nixpkgs.lib.version
      iron.attrs.channel.value;
    older = comparison == (0 - 1);
    default = comparison == 0;
    newer = comparison == 1;
  };
  configs = {
    nixpkgs = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
      # preBuild = ''
      #     makeFlagsArray+=(CFLAGS="-w")
      #     buildFlagsArray+=(CC=cc)
      # '';
      # permittedInsecurePackages = [
      #     "python2.7-cryptography-2.9.2"
      # ];
    };
  };
  buildInputs.general = [ "yq" "valiant" "git" "busybox" ];
  packageSets = iron.fold.set [
    (mapAttrs (n: v: [ v "pkgs" ]) iron.attrs.versions)
    { general = [ ]; }
  ];
  overriders.default = "overrideAttrs";
}
