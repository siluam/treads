silicon: lib:
with builtins;
with lib;
with silicon;
foldr recursiveUpdateAll (importSilicon ./. [ ] lib) [{

  # This generates the packages for only the current project
  groupOutputs = pname: packages: isApp: type:
    let
      inherit (iron) mkWithPackages fold mapAttrNames;
      versions = mapAttrs (n: v: mkWithPackages v [ ] pname) packages;
    in fold.set [
      versions
      (mapAttrNames (n: v: "${n}-${pname}") versions)
      (optionalAttrs (!isApp)
        (genAttrs [ "default" pname ] (package: versions.${type})))
    ];

  # This generates the packages for all the overlays
  withPackages = overlays: packages:
    let inherit (iron) fold mkWithPackages;
    in fold.set [
      (mapAttrs (n: v: mkWithPackages v (attrNames overlays)) packages)
      (listToAttrs (flatten (mapAttrsToList (n: v:
        map (pkg':
          let pkg = removeSuffix "-lib" pkg';
          in nameValuePair "${n}-${pkg}" (mkWithPackages v [ ] pkg))
        (attrNames overlays)) packages)))
    ];

  filterInheritance = pkg: inheritance:
    let args = functionArgs (if (isFunction pkg) then pkg else (import pkg));
    in filterAttrs (n: v: hasAttr n args) inheritance;

  callPackageFilter = { final ? null, new ? null, pkg, inheritance }:
    let
      message = "Sorry; `final` and `new` cannot both be `null`!";
      callPackage = if (new == null) then
        (if (final == null) then (abort message) else final.callPackage)
      else if (final == null) then
        (if (new == null) then (abort message) else new.callPackage)
      else
        (callPackageWith (final // new));
    in callPackage pkg (iron.filterInheritance pkg inheritance);
}]
