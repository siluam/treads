silicon: lib:
with builtins;
with lib;
with silicon;
let inherit (iron) fpipe filters mapAttrNames dirCon fold callPackageFilter;
in rec {
  name = { file, suffix ? ".nix", }:
    let base-file = baseNameOf (toString file);
    in if (isInt suffix) then
      (let
        hidden = hasPrefix "." base-file;
        split-file = remove "" (splitString "." base-file);
      in if (hidden && ((length split-file) == 1)) then
        base-file
      else
        concatStringsSep "." (take ((length split-file) - suffix) split-file))
    else
      (removeSuffix suffix base-file);
  list = args@{ dir, idir ? dir, ignores ? { }, iter ? 0, keep ? false
    , keeping ? { }, local ? false, file ? {
      prefix = {
        pre = "";
        post = "";
      };
      suffix = "";
    }, recursive ? false, root ? false, names ? false, suffix ? ".nix", }:
    let
      func = dir:
        let
          stringDir = toString dir;
          stringyDir = toString idir;
          fk = filters.keep;
          fr = filters.remove;
          pre-orders = flatten [
            (optional (keeping.files or false) fk.files)
            (optional (keeping.unknown or false) fk.unknown)
            (fk.prefix (keeping.prefix or [ ]))
            (fk.infix (keeping.infix or [ ]))
            (fk.readDir.files.suffix (keeping.suffix or [ ]))
            (fk.readDir.files.elem (keeping.elem or [ ]))
            (fk.readDir.unknown.suffix (keeping.suffix or [ ]))
            (fk.readDir.unknown.elem (keeping.elem or [ ]))
            (fk.readDir.static.suffix (keeping.suffix or [ ]))
            (fk.readDir.static.elem (keeping.elem or [ ]))
            (optional (ignores.files or false) fr.files)
            (optional (ignores.unknown or false) fr.unknown)
            (fr.prefix (ignores.prefix or [ ]))
            (fr.infix (ignores.infix or [ ]))
            (fr.readDir.files.suffix (ignores.suffix or [ ]))
            (fr.readDir.files.elem (ignores.elem or [ ]))
            (fr.readDir.unknown.suffix (ignores.suffix or [ ]))
            (fr.readDir.unknown.elem (ignores.elem or [ ]))
            (fr.readDir.static.suffix (ignores.suffix or [ ]))
            (fr.readDir.static.elem (ignores.elem or [ ]))
          ];
          orders = flatten [
            (optional (keeping.dirs or false) fk.dirs)
            (optional (keeping.others or false) fk.others)
            (optional (keeping.sym or false) fk.sym)
            (fk.suffix (keeping.suffix or [ ]))
            (fk.elem (keeping.elem or [ ]))
            (optional (ignores.dirs or false) fr.dirs)
            (optional (ignores.others or false) fr.others)
            (optional (ignores.sym or false) fr.sym)
            (fr.suffix (ignores.suffix or [ ]))
            (fr.elem (ignores.elem or [ ]))
          ];
          pipe-list = flatten [
            (mapAttrNames (n: v:
              pipe "${removePrefix stringyDir stringDir}/${n}" [
                (splitString "/")
                (remove "")
                (concatStringsSep "/")
              ]))
            pre-orders
          ];
          items = let
            filtered-others = fpipe pipe-list (dirCon.attrs.others dir);
            filtered-dirs = fpipe [
              pipe-list
              (optionals recursive (mapAttrsToList (n: v:
                list (args // {
                  dir = "${stringyDir}/${n}";
                  inherit idir;
                  iter = iter + 1;
                }))))
            ] (dirCon.attrs.dirs dir);
          in fold.set [ filtered-others filtered-dirs ];
          process = fpipe [
            pipe-list
            orders
            (if names then
              (mapAttrNames (file: v: name { inherit suffix file; }))
            else [
              (mapAttrNames (n: v: (file.prefix.pre or "") + n))
              (mapAttrNames (n: v:
                if keep then
                  n
                else if local then
                  "./${n}"
                else if root then
                  "/${n}"
                else
                  "${stringDir}/${n}"))
              (mapAttrNames
                (n: v: (file.prefix.post or "") + n + (file.suffix or "")))
            ])
            attrNames
          ];
        in if (iter == 0) then (process items) else items;
    in flatten (map func (toList dir));
  import = args@{ call ? null, dir, inheritance ? null, suffix ? ".nix"
    , files ? false, ... }:
    map (file:
      if files then
        file
      else if (call != null) then
        (callPackageFilter {
          inherit inheritance;
          final = call;
          pkg = file;
        })
      else if (inheritance == null) then
        (import file)
      else
        (import file inheritance))
    (list (removeAttrs args [ "call" "inheritance" "files" ]));
  set = args@{ call ? null, dir, inheritance ? null, suffix ? ".nix"
    , files ? false, ... }:
    listToAttrs (map (file:
      nameValuePair (name { inherit file suffix; }) (if files then
        file
      else if (call != null) then
        (callPackageFilter {
          inherit inheritance;
          final = call;
          pkg = file;
        })
      else if (inheritance == null) then
        (import file)
      else
        (import file inheritance)))
      (list (removeAttrs args [ "call" "inheritance" "files" ])));
  overlaySet = args@{ call ? null, dir, inheritance ? null, func ? null
    , suffix ? ".nix", ... }:
    listToAttrs (map (pkg:
      let filename = name { inherit file suffix; };
      in nameValuePair filename (if (func != null) then
        (func pkg)
      else if ((isInt call) && (call == 1)) then
        (final: prev: {
          "${filename}" = callPackageFilter { inherit final pkg inheritance; };
        })
      else if ((isInt call) && (call == 0)) then
        (final: prev: {
          "${filename}" = callPackageFilter {
            inherit pkg inheritance;
            final = prev;
          };
        })
      else if (call != null) then
        (final: prev: {
          "${filename}" = callPackageFilter {
            inherit pkg inheritance;
            final = call;
          };
        })
      else if (inheritance == null) then
        (import pkg)
      else
        (import pkg inheritance))) (list
          (removeAttrs (recursiveUpdate args { ignores.dirs = true; }) [
            "call"
            "inheritance"
            "func"
          ])));
}
