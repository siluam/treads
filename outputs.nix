inputs@{ self, ... }:
with builtins;
let lib = inputs.nixpkgs.lib.extend (import ./lib inputs self);
in with lib;
iron.mkOutputs.general {
  inherit self inputs;
  pname = "treads";
  mkOutputs = iron.mkOutputs.base self.overlays self.pname lib;
} {
  base = true;
  channels.nixpkgs.config = iron.attrs.configs.nixpkgs;
  langOverlays.rich = final: prev:
    iron.update.python.package "rich" (pnpkgs: popkgs: old:
      let
        patches = (old.patches or [ ])
          ++ [ ./patches/rich/__init__.patch ./patches/rich/_inspect.patch ];
      in {
        patchPhase = concatStringsSep "\n"
          (map (patch: "patch -p 1 -uNi ${patch}") patches);
      }) final prev;
}
