silicon: lib:
with builtins;
with lib;
with silicon; {
  inputTypeTo = func: suffix:
    mapAttrs (n: v: func (v + suffix)) iron.attrs.inputPrefixes;
  inputPkgsTo = flip iron.inputTypeTo "Pkg";
  inputAppsTo = flip iron.inputTypeTo "App";
  inputBothTo = func:
    genAttrs (attrNames iron.attrs.inputPrefixes) (pkg: inputs:
      ((iron.inputPkgsTo func).${pkg} inputs)
      // ((iron.inputAppsTo func).${pkg} inputs));

  inputToOverlays = prefix: inputs:
    iron.fold.set (mapAttrsToList
      (N: V: filterAttrs (n: v: iron.libbed n) (V.overlays or { }))
      (filterAttrs (n: v: hasPrefix "${prefix}-" n) inputs));
  inputTypeToOverlays = with iron; inputTypeTo inputToOverlays;
  inputPkgsToOverlays = iron.inputTypeToOverlays "Pkg";
  inputAppsToOverlays = iron.inputTypeToOverlays "App";
  inputBothToOverlays = with iron; inputBothTo inputToOverlays;

  inputToPackages = prefix': inputs:
    let prefix = prefix' + "-";
    in map (removePrefix prefix)
    (attrNames (filterAttrs (n: v: hasPrefix prefix n) inputs));
  inputTypeToPackages = with iron; inputTypeTo inputToPackages;
  inputPkgsToPackages = iron.inputTypeToPackages "Pkg";
  inputAppsToPackages = iron.inputTypeToPackages "App";
  inputBothToPackages = with iron; inputBothTo inputToPackages;
}
