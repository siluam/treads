silicon: lib:
with builtins;
with lib;
with silicon; {
  getCallPackages = plus: args:
    iron.fold.set [
      (plus.callPackages or { })
      (plus.callPackageset.callPackages or { })
    ];

  getCallPackage = plus: args:
    let
      _ = plus.callPackage or (iron.getCallPackages plus
        args).default or (throw ''
          Sorry! One of the following must be provided:
          - callPackage
          - callPackages.default
          - callPackageset.callPackages.default
          - overlay
          - preOverlays.default
          - overlayset.preOverlays.default
          - overlays.default
          - overlayset.overlays.default
        '');
    in {
      callPackage = _.package or _;
      inheritance = _.inheritance or { };
    };

  getOverlays = plus: args:
    iron.fold.set [
      (args.preOverlays or { })
      (plus.overlayset.preOverlays or { })
      (plus.overlays or { })
      (plus.overlayset.overlays or { })
    ];

  getOverlay = plus: args:
    plus.overlay or (iron.getOverlays plus args).default or null;

  getOfficialOverlays = group: inputs: overlayset:
    iron.fold.set [
      (map (input: input.overlayset.official.${group} or { })
        (attrValues inputs))
      (overlayset.official.${group} or { })
    ];
}
