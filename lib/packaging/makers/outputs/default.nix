silicon: lfinal:
with builtins;
with lfinal;
with silicon; {
  mkNewLanguage = overlay':
    override@{ ... }:
    group':
    plus@{ self, inputs, pname

    # These have to be explicitly inherited in the output,
    # as they may not be provided by the end user
    , group ? override.group or group'
    , type ? override.type or iron.attrs.versions.${group'}
    , doCheck ? override.doCheck or true
    , callPackageset ? override.callPackageset or { }

    , ... }:
    args@{ isApp ? override.isApp or false
    , langOverlays ? override.langOverlays or { }, ... }:
    let
      ottrs = rec {
        inherit (iron) fold;
        currentLanguage = (args.language or "general") == group';
        gottenCallPackage = iron.getCallPackage plus args;
        inherit (ottrs.gottenCallPackage) callPackage;
        inheritance = iron.filterInheritance callPackage
          (gottenCallPackage.inheritance // (args.inheritance or { }));
        default = iron.mifNotNull.default (iron.getOverlay plus args)
          (final: prev:
            iron.update.${group}.call inheritance pname callPackage final prev);
        systemOutputs = pkgs: {
          packages = iron.bases.treads.inputs.flake-utils.lib.filterPackages
            pkgs.stdenv.targetPlatform.system
            (iron.mkPackages self.overlayset.${group} pkgs.groups.${group} pname
              isApp type currentLanguage);
        };
      };
    in with ottrs; {
      plus = fold.merge [
        (if (args.mkFlake or false) then {
          outputsBuilder = channels:
            systemOutputs channels.${plus.channel or "nixpkgs"};
        } else
          (iron.bases.treads.inputs.flake-utils.lib.eachSystem
            (args.supportedSystems or iron.bases.treads.inputs.flake-utils-plus.lib.defaultSystems)
            (system: systemOutputs plus.self.pkgs.${system})))

        # TODO: Do I need this?
        (optionalAttrs currentLanguage {
          inherit (plus) type doCheck callPackageset;
        })

        {
          ${iron.optionalName currentLanguage "overlay"} =
            overlay' group' plus args ottrs;
          overlayset.${group} = fold.set [
            (optionalAttrs currentLanguage { "${pname}-lib" = default; })
            (iron.genLibs (n: v: final: prev:
              let cpkg = v.package or v;
              in iron.update.${group}.call (fold.set [
                { pname = n; }
                (args.inheritance or { })
                (v.inheritance or { })
              ]) n cpkg final prev) (callPackageset.${group} or { }))
            langOverlays
          ];
        }
        plus
      ];
      inherit args;
    };
  foldOrFlake = mkFlake: list:
    let inherit (iron) fold;
    in if mkFlake then
      (inputs.flake-utils-plus.lib.mkFlake (fold.merge list))
    else
      (fold.merge list);

  swapSystemOutputs = supportedSystems: attrs:
    let
      swap = system:
        mapAttrs (n: getAttr system) (filterAttrs (n: isAttrsOnly) attrs);
    in if (isString supportedSystems) then {
      ${supportedSystems} = swap supportedSystems;
    } else
      (genAttrs supportedSystems swap);

  # "Tooled Overlays" are overlays that come with specific tools,
  # like "treads", "moth", "valiant", or "bundle".
  mkOutputs = let
    base = baseOverlays: tooledOverlays: tool: olib:
      let
        inherit (olib) iron;
        inherit (iron)
          mkLanguage mkLanguages foldOrFlake callPackageFilter filterInheritance
          filters has fold getCallPackage getCallPackages getGroup getOverlay
          getOverlays libify makefiles mif mifNotNull mkApp mkPackages
          toPythonApplication update genLibs;
        inherit (iron.bases.treads.inputs.flake-utils.lib)
          eachSystem filterPackages;
        inherit (iron.bases.treads.inputs.flake-utils-plus.lib) defaultSystems;
        bothOverlays = baseOverlays.__extend__
          (if (isFunction tooledOverlays) then
            tooledOverlays
          else
            (_: _: tooledOverlays));
        mkOutputs = base bothOverlays { } tool olib;
      in fold.set [
        {
          base = base bothOverlays;
          general = plus@{ self, inputs, pname

            # TODO: Maybe use `functionArgs' instead, excluding specific arguments?
            # These have to be explicitly inherited in the output,
            # as they may not be provided by the end user
            , doCheck ? false, group ? (getGroup type), type ? "general"
            , parallel ? true, channel ? "nixpkgs", overlayset ? { }
            , callPackageset ? { }

            , overlays ? { }, supportedSystems ? defaultSystems
            , outputsBuilder ? (_: { }), ... }:
            args@{ preOutputs ? { }, preOverlays ? { }

              # If provided, `args.lib or lfinal' will be extended with this function
            , extensor ? null

              # If provided, `args.lib or lfinal' will be extended with this set
            , extension ? null

            , isApp ? false, mkFlake ? false, channelNames ? { }
            , patchGlobally ? false, languages ? false, base ? false, ... }:
            let
              ottrs = {

                composeLanguages = list:
                  recursiveUpdate
                  (foldl (a: b: b a.plus a.args) { inherit plus args; } list) {
                    args.languages = false;
                  };
                channelConfigs = fold.merge [
                  {
                    ${channel} = {
                      ${
                        optionalName
                        (!((args.channels.${channel} or { }) ? input)) "input"
                      } =
                        inputs.${channel} or iron.bases.treads.inputs.${channel};
                      overlays = toList self.overlay;
                    };
                  }
                  (args.channels or { })
                ];
                lib = let base = args.lib or lfinal;
                in if (extensor != null) then
                  (base.extend extensor)
                else if (extension != null) then
                  (base.extend (_: _: extension))
                else
                  base;
                gottenCallPackage = getCallPackage plus args;
                inherit (ottrs.gottenCallPackage) callPackage inheritance;
                default = mifNotNull.default (getOverlay plus args)
                  (final: prev: {
                    # IMPORTANT: Because `attrValues' sorts attribute set items
                    #            alphabetically, if you add a `default' package,
                    #            packages whose names start with letters later on
                    #            in the alphabet will always override earlier
                    #            packages, such as `valiant' overriding `tailapi'.
                    ${pname} = callPackageFilter {
                      inherit final;
                      pkg = callPackage;
                      inheritance = fold.set [
                        { inherit pname; }
                        (args.inheritance or { })
                        gottenCallPackage.inheritance
                      ];
                    };
                  });
                fupRemove = outputs:
                  fold.set [
                    (if mkFlake then
                      (removeAttrs (recursiveUpdate outputs
                        (removeAttrs (outputs.channels.${channel} or { })
                          [ "overlaysBuilder" ])) [ "outputsBuilder" ])
                    else
                      (removeAttrs outputs [ "supportedSystems" ]))
                    (optionalAttrs (outputs ? devShells) {
                      devShells = mapAttrs (N: V:
                        if (elem N supportedSystems) then
                          (filterAttrs (n: v: !(hasSuffix "-devenv" n)) V)
                        else
                          V) outputs.devShells;
                    })
                  ];
                channelTool = plus.channel or tool;
              };
              systemOutputs = import ./systemOutputs.nix lfinal plus args ottrs;
              allOutputs = import ./allOutputs.nix lfinal plus args
                (ottrs // { inherit systemOutputs bothOverlays; });

              # Have to use the modified `mkOutputs'
            in if (isList languages) then
              (mkLanguage self.mkOutputs
                (composeLanguages (map (flip getAttr mkLanguages) languages)))
            else if (isString languages) then
              (mkLanguage self.mkOutputs (mkLanguages.${languages} plus args))
            else if languages then
              (mkLanguage self.mkOutputs
                (composeLanguages (attrValues mkLanguages)))

            else
              allOutputs;
        }
        (mapAttrs (language: v: plus: args:
          mkLanguage mkOutputs (v plus (args // { inherit language; })))
          mkLanguages)
      ];
  in base (makeExtensibleWithCustomName "__extend__" (_: { })) { } "nixpkgs"
  lfinal;

  mkLanguage = mkOutputs: outputs: mkOutputs.general outputs.plus outputs.args;
  mkLanguages = { };
}
