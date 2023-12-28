inputs: outputs: lfinal: lprev:
with builtins;
with lfinal;
let
  silicon = rec {
    inherit (inputs.siluam.lib) isAttrsOnly recursiveUpdateAll;

    extendIron = lib: func:
      lib.extend (final: prev: {
        iron = prev.iron.extend (self: super: func final prev self super);
      });

    # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/fixed-points.nix#L71
    mergeExtensions = f: g: final: prev:
      let
        fApplied = f final prev;
        prev' = recursiveUpdateAll prev fApplied;
      in recursiveUpdateAll fApplied (g final prev');

    # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/fixed-points.nix#L80
    mergeManyExtensions = foldr (x: y: mergeExtensions x y) (final: prev: { });

    # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/fixed-points.nix#L40
    mergeExtends = f: rattrs: self:
      let super = rattrs self;
      in (recursiveUpdateAll super (f self super));

    # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/fixed-points.nix#L107
    mkMergeExtensibleWithCustomName = extenderName: rattrs:
      fix' (self:
        (rattrs self) // {
          ${extenderName} = f:
            mkMergeExtensibleWithCustomName extenderName
            (mergeExtends f rattrs);
        });

    # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/fixed-points.nix#L89
    mkMergeExtensible = mkMergeExtensibleWithCustomName "extend";

    importSilicon = dir: imports: inheritance:
      let
        iS = ext: file:
          import (dir + "/${file}${if ext then ".nix" else ""}") silicon
          inheritance;
      in foldr recursiveUpdateAll (genAttrs imports (iS true)) (map (iS false)
        (let
          ignoredImports = map (name: name + ".nix") (imports ++ [ "default" ]);
        in attrNames (removeAttrs (readDir dir) ignoredImports)));
  };
in with silicon; {
  iron = mkMergeExtensible (lself:
    foldr recursiveUpdateAll silicon [
      (importSilicon ./. [ "filters" "attrs" "fold" "imports" ] lfinal)
      {
        attrs = {
          versions = { };
          inputPrefixes = { };
          packages = { };
        };
        inherit (inputs.siluam.lib) mapAttrNames recursiveUpdateAll';
        optionalName = cond: name: if cond then name else null;
        importIron = dir: inheritance: kr:
          iron.fold.merge [
            (iron.imports.set {
              inherit dir inheritance;
              keeping.elem = kr;
            })
            (iron.imports.list {
              inherit dir inheritance;
              remove = {
                dirs = true;
                elem = kr ++ [ (dir + "/default.nix") ];
              };
              recursive = true;
            })
          ];
        listToString = map (v: ''"${v}"'');
        recursiveUpdateAllStrings = recursiveUpdateAll' "\n";
        bases = {
          treads = { inherit inputs outputs; };
          siluam = {
            outputs = inputs.siluam;
            inherit (inputs.siluam) inputs;
          };
        };
        deepEval = e: tryEval (deepSeq e e);

        passName = n: v: v n;
        mapPassName = mapAttrs iron.passName;

        # Adapted From: https://github.com/NixOS/nixpkgs/blob/master/lib/attrsets.nix#L406
        genAttrNames = values: f:
          listToAttrs (map (v: nameValuePair (f v) v) values);

        filterAttrs = f: list: filterAttrs (n: v: (elem n list) && (f v));
        filterAttrs' = f: list: filterAttrs (n: v: (elem n list) && (f n v));

        flattenToList = item: unique (flatten (toList item));

        has = let inherit (iron) flattenToList;
        in {
          prefix = string: list:
            any (flip hasPrefix (toString string)) (flattenToList list);
          suffix = string: list:
            any (flip hasSuffix (toString string)) (flattenToList list);
          infix = string: list:
            any (flip hasInfix (toString string)) (flattenToList list);
        };

        readFileExists = file: optionalString (pathExists file) (readFile file);
        readDirExists = dir: optionalAttrs (pathExists dir) (readDir dir);
        dirCon = let
          ord = func: dir:
            filterAttrs func
            (if (isAttrsOnly dir) then dir else (iron.readDirExists dir));
        in rec {
          attrs = {
            dirs = ord (n: v: v == "directory");
            others = ord (n: v: v != "directory");
            files = ord (n: v: v == "regular");
            sym = ord (n: v: v == "symlink");
            unknown = ord (n: v: v == "unknown");
          };
          dirs = dir: attrNames (attrs.dirs dir);
          others = dir: attrNames (attrs.others dir);
          files = dir: attrNames (attrs.files dir);
          sym = dir: attrNames (attrs.sym dir);
          unknown = dir: attrNames (attrs.unknown dir);
        };

        # Adapted From: https://github.com/nixos/nixpkgs/blob/master/lib/debug.nix
        traceValSeqFn = f: v: traceSeq (f v) v;
        traceValSeq = iron.traceValSeqFn id;

        any = any id;
        all = all id;

        inheritAttr = name: attrs: { ${name} = attrs.${name}; };

        versionIs = rec {
          # a is older than or equal to b
          ote = a: b: elem (compareVersions a b) [ (0 - 1) 0 ];
          # a is newer than or equal to b
          nte = a: b: elem (compareVersions a b) [ 0 1 ];
        };
        channel = let inherit (iron) fold attrs versionIs has;
        in fold.set [
          (mapAttrs (n: v: v attrs.channel.value) versionIs)
          {
            mus = c: has.suffix c [ "-master" "-unstable" "-small" ];
            musd = c: pkg: default:
              if (iron.channel.mus c) then pkg else default;
          }
        ];
        changed = let inherit (iron) attrs versionIs;
        in genAttrs (remove "changed" (attrNames attrs.versions))
        (pkg: final: prev:
          mapAttrs (n: v: v final.${pkg} prev.${pkg}) versionIs);

        multiSplitString = splits: string:
          if splits == [ ] then
            string
          else
            (remove "" (flatten (map (iron.multiSplitString (init splits))
              (splitString (last splits) string))));

        dontCheck = old: {
          doCheck = false;
          pythonImportsCheck = [ ];
          postCheck = "";
          checkPhase = "";
          doInstallCheck = false;
          ${
            if (hasInfix ''"(progn (add-to-list 'load-path \"$LISPDIR\")''
              (old.postInstall or "")) then
              "postInstall"
            else
              null
          } = "";
        };

        functors.xelf = { __functor = self: x: let xelf = x self; in x xelf; };

        fpipe = pipe-list: flip pipe (flatten pipe-list);
        removeFix = let sortFunc = sort (a: b: (length a) > (length b));
        in rec {
          default = func: fixes: iron.fpipe (map func (sortFunc fixes));
          prefix = default removePrefix;
          suffix = default removeSuffix;
          infix = fixes:
            replaceStrings (sortFunc fixes) (genList (i: "") (length fixes));
        };
        mif = {
          list = optionals;
          list' = optional;
          set = optionalAttrs;
          num = condition: value: if condition then value else 0;
          null = iron.optionalName;
          str = optionalString;
          True = condition: value: if condition then value else true;
          False = condition: value: if condition then value else false;
          fn = condition: fn: value: if condition then (fn value) else value;
        };
        mifNotNull = {
          default = a: b: if (a != null) then a else b;
          list = a: optionals (a != null);
          list' = a: optional (a != null);
          set = a: optionalAttrs (a != null);
          num = a: b: if (a != null) then b else 0;
          null = a: b: if (a != null) then b else null;
          nullb = a: b: c: if (a != null) then b else c;
          str = a: optionalString (a != null);
          True = a: b: if (a != null) then b else true;
          False = a: b: if (a != null) then b else false;
        };
      }
    ]);
}
