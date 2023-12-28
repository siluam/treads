silicon: lib:
with builtins;
with lib;
with silicon;
recursiveUpdateAll (importSilicon ./. [ ] lib) {
  # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/doc/builders/packages/emacs.section.md#configuring-emacs-sec-emacs-config
  mkWithPackages = pkg: pkglist: pname:
    pkg.withPackages (iron.filters.has.list [
      pkglist
      pname
      (optional (pkg.pname == "hy") "hyrule")
    ]);

  mkApp = name: drv:
    let
      DRV = iron.filterAttrs (attr: !(isBool attr)) [ "exe" "executable" ] drv;
    in {
      type = "app";
      program = "${drv}${
          drv.passthru.exePath or "/bin/${
            drv.meta.mainprogram or drv.meta.mainProgram or DRV.exe or DRV.executable or drv.pname or drv.name or name
          }"
        }";
    };

  mkPackages = overlays: packages: pname: isApp: type: currentLanguage:
    let inherit (iron) fold withPackages groupOutputs;
    in fold.set [
      (withPackages overlays packages)
      (optionalAttrs currentLanguage (groupOutputs pname packages isApp type))
    ];

  mkPkgs = overlays: legacyPackages: nixpkgs:
    config@{ ... }:
    legacyPackages // (let pkgs = import nixpkgs config;
    in iron.fold.set (if (isAttrs overlays) then
      (mapAttrsToList (n: v: v pkgs pkgs) overlays)
    else
      (map (v: v pkgs pkgs) overlays)));
}
