with builtins;
lfinal:
with lfinal;
plus@{ self, inputs, pname

# TODO: Maybe use `functionArgs' instead, excluding specific arguments?
# These have to be explicitly inherited in the output,
# as they may not be provided by the end user
, doCheck ? false, group ? (iron.getGroup type), type ? "general"
, parallel ? true, channel ? "nixpkgs", overlayset ? { }, callPackageset ? { }

, overlays ? { }, supportedSystems ?
  iron.bases.treads.inputs.flake-utils-plus.lib.defaultSystems
, outputsBuilder ? (_: { }), ... }:
args@{ preOutputs ? { }, preOverlays ? { }

  # If provided, `args.lib or lfinal' will be extended with this function
, extensor ? null

  # If provided, `args.lib or lfinal' will be extended with this set
, extension ? null

, isApp ? false, mkFlake ? false, channelNames ? { }, patchGlobally ? false
, languages ? false, base ? false, ... }:
ottrs:
with ottrs;
let inherit (iron) fold;
in iron.foldOrFlake mkFlake [
  (fupRemove preOutputs)
  (if mkFlake then {
    channels.${channel} = {
      ${
        iron.optionalName (!((plus.channels.${channel} or { }) ? input)) "input"
      } = inputs.${channel} or iron.bases.treads.inputs.${channel};
      overlaysBuilder = channels:
        unique (flatten [
          ((plus.channels.${channel}.overlaysBuilder or (_: [ ])) channels)
          ((preOutputs.channels.${channel}.overlaysBuilder or (_: [ ]))
            channels)
          ((plus.channels.${channel}.overlaysBuilder or (_: [ ])) channels)
          self.overlay
        ]);
    };
    outputsBuilder = channels:
      let pkgs = channels.${channel};
      in fold.merge [
        (systemOutputs pkgs.stdenv.targetPlatform.system channels pkgs)
        ((plus.outputsBuilder or (_: { })) channels)
        ((preOutputs.outputsBuilder or (_: { })) channels)
        (outputsBuilder channels)
      ];
  } else
    (iron.bases.treads.inputs.flake-utils.lib.eachSystem supportedSystems
      (system:
        let
          superpkgs = {
            inputs = fold.set [
              (filterAttrs (n: v:
                (iron.any [
                  (has.prefix n (flatten [
                    "nixos-"
                    "nixpkgs-"
                    (channelNames.prefix or [ ])
                  ]))
                  (has.infix n (channelNames.suffix or [ ]))
                  (has.suffix n (channelNames.suffix or [ ]))
                  (elem n (flatten [ "nixpkgs" (channelNames.names or [ ]) ]))
                ]) && ((v.legacyPackages.x86_64-linux or { }) ? nix)) inputs)
              (mapAttrs (n: getAttr "input")
                (filterAttrs (n: hasAttr "input") channelConfigs))
            ];
            configs = mapAttrs (n: v:
              fold.merge [
                { inherit system; }
                (removeAttrs (channelConfigs.${n} or { }) [ "input" "patches" ])
              ]) superpkgs.inputs;
            nixpkgs = mapAttrs (n: src:
              if (((channelConfigs.${n} or { }) ? patches)
                || patchGlobally) then
                ((import src superpkgs.configs.${n}).applyPatches {
                  inherit src;
                  patches = flatten [
                    (channelConfigs.${n}.patches or { })
                    (optionals patchGlobally [

                    ])
                  ];
                  name = "mkOutputPatches";
                })
              else
                src) superpkgs.inputs;
          };
          channels = mapAttrs (n: v:
            iron.mkPkgs self.overlays inputs.${n}.legacyPackages.${system} v
            superpkgs.configs.${n}) superpkgs.nixpkgs;
          pkgs = channels.${channel};
        in fold.set [
          { inherit superpkgs; }
          (systemOutputs system channels pkgs)
        ])))
  ({
    overlays = fold.set [

      # For some reason, the binary cache isn't hit without the following blocks before:
      # `(removeAttrs bothOverlays [ "__unfix__" "__extend__" ])'
      # NOTE: The `iron-treads' prefixes are for ordering purposes:
      # https://en.wikipedia.org/wiki/ASCII#Printable_characters
      # (optionalAttrs base (listToAttrs (map (pkg:
      #   let inputChannel = args.baseChannel or channel;
      #   in nameValuePair "!iron-treads-${pkg}-${inputChannel}"
      #   (final: prev:
      #     let
      #       default =
      #         inputs.${inputChannel}.legacyPackages.${prev.targetPlatform.system}.${pkg};
      #     in {
      #       ${pkg} = default;
      #       "${pkg}Packages" = default.pkgs;
      #     })) (filter (hasPrefix "python")
      #       iron.attrs.packages.python))))

      # TODO
      # (map (group:
      #   (mapAttrs' (n: v:
      #     let
      #       inputChannel = if (n == "null") then
      #         (args.baseChannel or channel)
      #       else
      #         n;
      #     in nameValuePair
      #     "#iron-treads-${group}-${inputChannel}"
      #     (iron.update.${group}.replace.inputList.super
      #       (final: prev:
      #         inputs.${inputChannel}.legacyPackages.${prev.stdenv.targetPlatform.system})
      #       (toList v)))
      #     (iron.getOfficialOverlays group inputs overlayset)))
      #   (attrNames iron.attrs.versions))

      (let
        inputChanneler = n:
          if (n == "null") then (args.baseChannel or channel) else n;
      in map (group:
        (mapAttrsToList (N: V:
          iron.mapAttrNames
          (n: v: "#iron-treads-${group}-${inputChanneler N}-${n}") V) (mapAttrs
            (n: v:
              iron.update.${group}.replace.inputList.attrs (final: prev:
                inputs.${
                  inputChanneler n
                }.legacyPackages.${prev.stdenv.targetPlatform.system})
              (toList v)) (iron.getOfficialOverlays group inputs overlayset))))
      (attrNames iron.attrs.versions))

      # (mapAttrs' (n: v:
      #   let
      #     inputChannel = if (n == "null") then
      #       (args.baseChannel or channel)
      #     else
      #       n;
      #   in nameValuePair "#iron-treads-general-${inputChannel}"
      #   (final: prev:
      #     genAttrs (toList v) (flip getAttr
      #       inputs.${inputChannel}.legacyPackages.${prev.stdenv.targetPlatform.system})))
      #   (iron.getOfficialOverlays "general" inputs overlayset))

      (removeAttrs bothOverlays [ "__unfix__" "__extend__" ])

      (overlayset.preOverlays or { })
      preOverlays
      (map (p: libify (p inputs)) (attrValues iron.inputPkgsToOverlays))
      (map (a: a inputs) (attrValues iron.inputAppsToOverlays))
      (map (o: libify (self.overlayset.${o} or { }))
        (attrNames iron.attrs.versions))
      { lib = final: prev: { inherit lib; }; }
      (mapAttrs (n: v: final: prev:
        let pkg = v.package or v;
        in {
          ${n} = callPackageFilter {
            inherit final pkg;
            inheritance = fold.set [
              { pname = n; }
              (args.inheritance or { })
              (v.inheritance or { })
            ];
          };
        }) self.callPackages)
      {
        inherit default;
        ${pname} = default;
      }
      (overlayset.overlays or { })
    ];
    callPackage = let e = tryEval callPackage;
    in if e.success then callPackage else null;
    callPackages = iron.getCallPackages plus args;
    mkOutputs = plus.mkOutputs or mkOutputs;
    inherit lib type group channel doCheck callPackageset overlayset parallel;
    valiant = true;
  })
  (fupRemove plus)
  (iron.swapSystemOutputs supportedSystems (removeAttrs self supportedSystems))
  {
    defaultOverlay = composeManyExtensions (attrValues self.overlays);
    overlay = self.defaultOverlay;
  }
]
