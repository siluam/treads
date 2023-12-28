silicon: lib:
with builtins;
with lib;
with silicon; {
  makefile = let
    inherit (iron)
      getFromAttrsDefault fold filters mkWithPackages getOverrider dontCheck
      mapPassName mkBuildInputs;
    merger = args@{ group ? "general", type ? "general", ... }:
      getFromAttrsDefault [
        (args.groups.${group} or { })
        (args.types.${type} or { })
      ];
    base = args@{ pname, pkgs, group ? "general", type ? "general", ... }:
      let
        removals = flatten [ "propagatedBuildInputs" (attrNames dependents) ];
        bases = fold.stringMerge [
          {
            buildInputs = filters.has.list [
              iron.attrs.buildInputs.general
              (iron.attrs.buildInputs.${group}.apps or [ ])
              (if (isDerivation pname) then
                [ (pname.buildInputs or [ ]) ]
              else [
                (pkgs.${pname}.buildInputs or [ ])
                ((getAttrFromPath iron.attrs.packageSets.${group}
                  pkgs).${pname}.buildInputs or [ ])
              ])
            ] pkgs;
          }
          (removeAttrs (args.groups.${group} or { }) removals)
          (removeAttrs (args.types.${type} or { }) removals)
        ];
        dependents = fold.stringMerge [
          (mapPassName {
            nativeBuildInputs = attr:
              filters.has.list [
                bases.buildInputs
                (if (isDerivation pname) then
                  [ (pname.${attr} or [ ]) ]
                else [
                  (pkgs.${pname}.${attr} or [ ])
                  ((getAttrFromPath iron.attrs.packageSets.${group}
                    pkgs).${pname}.${attr} or [ ])
                ])
                (merger args attr [ ])
              ] pkgs;
          })
        ];
      in pkgs.mkShell (fold.set [ bases dependents ]);
    default = args@{ pname, pkgs, parallel ? true, group ? "general"
      , type ? "general", ... }:
      base ((fold.merge [
        {
          groups.${group}.buildInputs = toList (mkWithPackages pkgs.${type} [
            ((mkBuildInputs.${group} or (_: { ... }: _)) {
              inherit type parallel;
            })
            (merger args "propagatedBuildInputs" [ ])
          ] pname);
        }
        (removeAttrs args [ "pkgs" ])
      ]) // {
        inherit pkgs;
      });
    mkfiles = genAttrs (attrNames iron.attrs.versions) (group:
      args@{ pname, pkgs, ... }:
      iron.makefile.default (fold.set [
        args
        {
          inherit group;
          pname =
            (getAttrFromPath iron.attrs.packageSets.${group} pkgs).${pname}.${
              getOverrider group
            } dontCheck;
        }
      ]));
  in fold.set [
    mkfiles
    {
      inherit base default;
      general = args@{ ... }: base (removeAttrs args [ "group" "type" ]);
      echo = fold.set [
        {
          default = var: pkgs: envs:
            fold.shell pkgs [ envs { shellHook = "echo \$${var}; exit"; } ];
          general = var:
            args@{ pkgs, ... }:
            iron.makefile.echo.default var pkgs (iron.makefile.general args);
        }
        (mapAttrs (n: v: var:
          args@{ pkgs, ... }:
          iron.makefile.echo.default var pkgs (v args)) mkfiles)
      ];
      path = mapAttrs (n: v: v "PATH") iron.makefile.echo;
    }
  ];

  makefiles = args@{ pname, pkgs, parallel ? true, group ? "general"
    , type ? "general", ... }:
    let
      inherit (iron) attrs fold makefile mapAttrNames;
      not-general = !((group == "general") && (type == "general"));
      packages = if group == "emacs" then
        (attrNames pkgs.groups.emacs)
      else
        attrs.packages.${group};
      mkfiles = let
        typefiles = genAttrs packages
          (type: makefile.${group} (fold.set [ args { inherit type; } ]));
      in fold.set [
        { general = makefile.general args; }
        (optionals not-general [
          typefiles
          { ${group} = typefiles.${attrs.versions.${group}}; }
        ])
      ];
      mkpaths = mapAttrs (n: makefile.path.default pkgs) mkfiles;
    in fold.set [
      {
        makefile = mkfiles.${type};
        makefile-path = mkpaths.${type};
      }
      (mapAttrNames (n: v: "makefile-${n}") mkfiles)
      (mapAttrNames (n: v: "makefile-${n}-path") mkpaths)
      (optionalAttrs (group == "python") (let
        pythonpaths = mapAttrs' (n: v:
          nameValuePair "makefile-${n}-pythonpath"
          (makefile.echo.default "PYTHONPATH" pkgs v))
          (filterAttrs (n: v: elem n packages) mkfiles);
      in fold.set [
        pythonpaths
        { makefile-pythonpath = pythonpaths."makefile-${type}-pythonpath"; }
      ]))
    ];
}
