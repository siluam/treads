silicon: lib:
with builtins;
with lib;
with silicon; {
  libbed = hasSuffix "-lib";
  liberate = n: if (iron.libbed n) then n else (n + "-lib");
  libify = iron.mapAttrNames (n: v: iron.liberate n);
  genLibs = f: mapAttrs' (n: v: nameValuePair (iron.liberate n) (f n v));
}
