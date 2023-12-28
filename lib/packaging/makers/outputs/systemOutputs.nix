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
in system: channels: pkgs: {
  inherit channels pkgs;
  ${iron.optionalName (!mkFlake) "legacyPackages"} = pkgs;
  packages = filterPackages system (filters.has.attrs [
    (subtractLists (attrNames
      (inputs.${channelTool}.pkgs or inputs.${channelTool}.legacyPackages or inputs.${channelTool}.packages or inputs.treads.pkgs).${system})
      (attrNames pkgs))
    (attrNames self.overlays)
    { default = plus.packages.${system}.default or pkgs.${pname}; }
  ] pkgs);
  defaultPackage = self.packages.${system}.default;
  package = self.defaultPackage.${system};
  apps = let
    prefix = ''
      if [ -d "$1" ]; then
        dir="$1"
        shift 1
      else
        dir="$(${pkgs.git}/bin/git rev-parse --show-toplevel)" || "./."
      fi
      confnix=$(mktemp)
      cp "${inputs.bundle or inputs.valiant or inputs.moth or inputs.bakery or inputs.oreo or inputs.treads or "$dir"}/default.nix" $confnix
      substituteStream() {
          local var=$1
          local description=$2
          shift 2

          while (( "$#" )); do
              case "$1" in
                  --replace)
                      pattern="$2"
                      replacement="$3"
                      shift 3
                      local savedvar
                      savedvar="''${!var}"
                      eval "$var"'=''${'"$var"'//"$pattern"/"$replacement"}'
                      if [ "$pattern" != "$replacement" ]; then
                          if [ "''${!var}" == "$savedvar" ]; then
                              echo "substituteStream(): WARNING: pattern '$pattern' doesn't match anything in $description" >&2
                          fi
                      fi
                      ;;

                  --subst-var)
                      local varName="$2"
                      shift 2
                      # check if the used nix attribute name is a valid bash name
                      if ! [[ "$varName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
                          echo "substituteStream(): ERROR: substitution variables must be valid Bash names, \"$varName\" isn't." >&2
                          return 1
                      fi
                      if [ -z ''${!varName+x} ]; then
                          echo "substituteStream(): ERROR: variable \$$varName is unset" >&2
                          return 1
                      fi
                      pattern="@$varName@"
                      replacement="''${!varName}"
                      eval "$var"'=''${'"$var"'//"$pattern"/"$replacement"}'
                      ;;

                  --subst-var-by)
                      pattern="@$2@"
                      replacement="$3"
                      eval "$var"'=''${'"$var"'//"$pattern"/"$replacement"}'
                      shift 3
                      ;;

                  *)
                      echo "substituteStream(): ERROR: Invalid command line argument: $1" >&2
                      return 1
                      ;;
              esac
          done

          printf "%s" "''${!var}"
      }

      # put the content of a file in a variable
      # fail loudly if provided with a binary (containing null bytes)
      consumeEntire() {
          # read returns non-0 on EOF, so we want read to fail
          if IFS=''' read -r -d ''' $1 ; then
              echo "consumeEntire(): ERROR: Input null bytes, won't process" >&2
              return 1
          fi
      }

      substitute() {
          local input="$1"
          local output="$2"
          shift 2

          if [ ! -f "$input" ]; then
              echo "substitute(): ERROR: file '$input' does not exist" >&2
              return 1
          fi

          local content
          consumeEntire content < "$input"

          if [ -e "$output" ]; then chmod +w "$output"; fi
          substituteStream content "file '$input'" "$@" > "$output"
      }

      substituteInPlace() {
          local -a fileNames=()
          for arg in "$@"; do
              if [[ "$arg" = "--"* ]]; then
                  break
              fi
              fileNames+=("$arg")
              shift
          done

          for file in "''${fileNames[@]}"; do
              substitute "$file" "$file" "$@"
          done
      }
    '';
    shell = devShell: pure:
      pkgs.writeShellScriptBin "shell" ''
        ${prefix}
        substituteInPlace $confnix \
          --replace "(getFlake (toString ./.))" "(getFlake (toString ./.)).devShells.${system}.${devShell}" \
          --replace ".defaultNix" ".defaultNix.devShells.${system}.${devShell}" \
          --replace "./." "$dir" \
          --replace "./flake.lock" "$dir/flake.lock"
        trap "rm $confnix" EXIT
        nix-shell --show-trace ${
          if pure then "--pure" else "--impure"
        } $confnix "$@"
      '';

    # Adapted From: https://github.com/NixOS/nix/issues/3803#issuecomment-748612294
    #               https://github.com/nixos/nixpkgs/blob/master/pkgs/stdenv/generic/setup.sh#L818
    repl = pkgs.writeShellScriptBin "repl" ''
      ${prefix}
      substituteInPlace $confnix \
        --replace "./." "$dir" \
        --replace "./flake.lock" "$dir/flake.lock"
      trap "rm $confnix" EXIT
      nix --show-trace -L repl $confnix
    '';

    repls = genAttrs [ "repl" "${pname}-repl" ] (flip mkApp repl);
  in fold.set [
    (mapAttrs mkApp self.packages.${system})
    repls
    (map (pure:
      mapAttrs' (n: v:
        let name = "nix-shell-${if pure then "pure-" else ""}${n}";
        in nameValuePair name (mkApp name (shell n pure)))
      self.devShells.${system}) [ true false ])
  ];
  defaultApp = self.apps.${system}.default;
  app = self.defaultApp.${system};
  devShell =
    pkgs.mkShell { buildInputs = [ pkgs.busybox self.package.${system} ]; };
  defaultDevShell = self.devShell.${system};
  devShells = with pkgs;
    let
      devShells = fold.set [
        (mapAttrs (n: v: mkShell { buildInputs = [ pkgs.busybox v ]; })
          (fold.set [
            self.packages.${system}
            { "iron-envrc" = [ git bundle ]; }
          ]))
        (makefiles { inherit pname parallel type group pkgs; })
        {
          default = self.devShell.${system};
          ${pname} = self.devShell.${system};
        }
      ];
    in fold.set [
      devShells
      (mapAttrs' (n: v:
        let name = "${n}-devenv";
        in nameValuePair name (iron.bases.treads.inputs.devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              packages = with v;
                unique (flatten [
                  buildInputs
                  nativeBuildInputs
                  propagatedBuildInputs
                  propagatedNativeBuildInputs
                ]);
              enterShell = v.shellHook;
            }
            (preOutputs.devShells.${system}.${name} or { })
            (plus.devShells.${system}.${name} or { })
          ];
        })) devShells)
    ];
}
