silicon: lib:
with builtins;
with lib;
with silicon; {
  mkInputs = inputs': pure:
    mapAttrs (n: v: v (inputs'.${n}.pkgs or inputs'.${n} or [ ])) {
      python = inputs:
        { type ? "general", parallel ? true, ... }:
        flatten [
          inputs
          (optional (type == "hy") "pytest-hy")
          (optional parallel "pytest-xdist")
          (optional (!pure) "pytest-ignore")
        ];
    };
  mkBuildInputs = iron.mkInputs iron.attrs.buildInputs false;
  mkCheckInputs = iron.mkInputs iron.attrs.checkInputs true;
}
