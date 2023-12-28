silicon: lib:
with builtins;
with lib;
with silicon; {
  getGroup = type:
    let
      packageTypes = remove null
        (mapAttrsToList (n: v: iron.optionalName (elem type v) n)
          iron.attrs.packages);
    in if (hasPrefix "pypy" type) then
      "pypy"
    else if (packageTypes != [ ]) then
      (head packageTypes)
    else if (hasPrefix "emacs" type) then
      "emacs"
    else
      "general";

  getAttrFromPath = set: group: attrByPath [ group ] set.default set;
  getOverrider = iron.getAttrFromPath iron.attrs.overriders;

  getFromAttrs = attr: map (getAttr attr);
  getFromAttrsDefault = list: attr: default:
    map (attrByPath [ attr ] default) list;

  getAttrs = list: filterAttrs (n: v: elem n (unique (flatten list)));
}
