silicon: lib:
with builtins;
with lib;
with silicon;
let
  folders = {
    set = list:
      foldr mergeAttrs { } (let _ = flatten list;
      in if (any isFunction _) then
        (trace _ (abort "Sorry; a wild function appeared!"))
      else
        _);
    recursive = list:
      foldr recursiveUpdate { } (let _ = flatten list;
      in if (any isFunction _) then
        (trace _ (abort "Sorry; a wild function appeared!"))
      else
        _);

    # TODO: Does flattening the list result in a stack overflow, or disable lazy attribute access?
    #       If not, update all instances of `fold.merge` accordingly.
    merge = list:
      foldr recursiveUpdateAll { } (let _ = flatten list;
      in if (any isFunction list) then
        (trace _ (abort "Sorry; a wild function appeared!"))
      else
        _);
    stringMerge = list:
      foldr iron.recursiveUpdateAllStrings { } (let _ = flatten list;
      in if (any isFunction list) then
        (trace _ (abort "Sorry; a wild function appeared!"))
      else
        _);
    # merge = list:
    #   foldr recursiveUpdateAll { }
    #   (if (any (item: !(isAttrs item)) list) then
    #     (trace list
    #       (abort "Sorry; only attribute sets are allowed to be merged!"))
    #   else
    #     list);
    # stringMerge = list:
    #   foldr iron.recursiveUpdateAllStrings { }
    #   (if (any (item: !(isAttrs item)) list) then
    #     (trace list
    #       (abort "Sorry; only attribute sets are allowed to be merged!"))
    #   else
    #     list);

  };
  inherit (iron) filters;
in folders.set [
  folders
  {
    # Adapted From: https://gist.github.com/adisbladis/2a44cded73e048458a815b5822eea195
    shell = pkgs: envs:
      foldr (new: old:
        pkgs.mkShell {
          buildInputs =
            filters.has.list [ new.buildInputs old.buildInputs ] pkgs;
          nativeBuildInputs =
            filters.has.list [ new.nativeBuildInputs old.nativeBuildInputs ]
            pkgs;
          propagatedBuildInputs = filters.has.list [
            new.propagatedBuildInputs
            old.propagatedBuildInputs
          ] pkgs;
          propagatedNativeBuildInputs = filters.has.list [
            new.propagatedNativeBuildInputs
            old.propagatedNativeBuildInputs
          ] pkgs;
          shellHook = new.shellHook + "\n" + old.shellHook;
        }) (pkgs.mkShell { })
      (map (e: if (isAttrsOnly e) then (pkgs.mkShell e) else e) (flatten envs));
    debug = mapAttrs (n: v: list: v (traceVal (flatten list))) folders;
    deebug = mapAttrs (n: v: list: v (iron.traceValSeq (flatten list))) folders;
  }
]
