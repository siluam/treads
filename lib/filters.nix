silicon: lib:
with builtins;
with lib;
with silicon; {

  # `filters.has.list' is an incomplete function; the general form of `withPackages~ is ~(pkgs: ...)',
  # where the full form of `filters.has.list' would be `(pkgs: filters.has.list [...] pkgs)'.
  has = {
    attrs = list: attrs:
      let l = unique (flatten list);
      in iron.fold.set [
        (iron.getAttrs l attrs)
        (iron.genAttrNames (filter isDerivation l) (drv: drv.pname or drv.name))
        (filter isAttrsOnly l)
      ];
    list = list: attrs: attrValues (iron.filters.has.attrs list attrs);
  };

  keep = let inherit (iron) has dirCon flattenToList;
  in {
    prefix = keeping: attrs:
      if ((keeping == [ ]) || (keeping == "")) then
        attrs
      else
        (filterAttrs (n: v: has.prefix n (toList keeping)) attrs);
    suffix = keeping: attrs:
      if ((keeping == [ ]) || (keeping == "")) then
        attrs
      else
        (filterAttrs (n: v: has.suffix n (toList keeping)) attrs);
    infix = keeping: attrs:
      if ((keeping == [ ]) || (keeping == "")) then
        attrs
      else
        (filterAttrs (n: v: has.infix n (toList keeping)) attrs);
    elem = keeping: attrs:
      if ((keeping == [ ]) || (keeping == "")) then
        attrs
      else
        (iron.getAttrs (map toString (flattenToList keeping)) attrs);
    inherit (dirCon.attrs) dirs others files sym unknown;
    readDir = {
      dirs = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "directory") then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "directory") then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "directory") then
                (has.infix n (toList keeping))
              else
                true) attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "directory") then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
      others = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v != "directory") then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v != "directory") then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v != "directory") then
                (has.infix n (toList keeping))
              else
                true) attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v != "directory") then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
      files = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "regular") then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "regular") then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "regular") then (has.infix n (toList keeping)) else true)
              attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "regular") then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
      sym = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "symlink") then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "symlink") then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "symlink") then (has.infix n (toList keeping)) else true)
              attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "symlink") then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
      unknown = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "unknown") then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "unknown") then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "unknown") then (has.infix n (toList keeping)) else true)
              attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if (v == "unknown") then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
      static = {
        prefix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if ((v == "regular") || (v == "unknown")) then
                (has.prefix n (toList keeping))
              else
                true) attrs);
        suffix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if ((v == "regular") || (v == "unknown")) then
                (has.suffix n (toList keeping))
              else
                true) attrs);
        infix = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if ((v == "regular") || (v == "unknown")) then
                (has.infix n (toList keeping))
              else
                true) attrs);
        elem = keeping: attrs:
          if ((keeping == [ ]) || (keeping == "")) then
            attrs
          else
            (filterAttrs (n: v:
              if ((v == "regular") || (v == "unknown")) then
                (elem n (map toString (flattenToList keeping)))
              else
                true) attrs);
      };
    };
  };
  remove = let inherit (iron) has dirCon flattenToList;
  in {
    prefix = ignores: filterAttrs (n: v: !(has.prefix n (toList ignores)));
    suffix = ignores: filterAttrs (n: v: !(has.suffix n (toList ignores)));
    infix = ignores: filterAttrs (n: v: !(has.infix n (toList ignores)));
    elem = ignores: flip removeAttrs (flattenToList ignores);
    dirs = dirCon.attrs.others;
    files = filterAttrs (n: v: v != "regular");
    others = dirCon.attrs.dirs;
    sym = filterAttrs (n: v: v != "symlink");
    unknown = filterAttrs (n: v: v != "unknown");
    readDir = {
      dirs = {
        prefix = ignores:
          filterAttrs
          (n: v: (!(has.prefix n (toList ignores))) && (v == "directory"));
        suffix = ignores:
          filterAttrs
          (n: v: (!(has.suffix n (toList ignores))) && (v == "directory"));
        infix = ignores:
          filterAttrs
          (n: v: (!(has.infix n (toList ignores))) && (v == "directory"));
        elem = ignores:
          filterAttrs
          (n: v: (!(elem n (flattenToList ignores))) && (v == "directory"));
      };
      others = {
        prefix = ignores:
          filterAttrs (n: v:
            if (v != "directory") then
              (!(has.prefix n (toList ignores)))
            else
              true);
        suffix = ignores:
          filterAttrs (n: v:
            if (v != "directory") then
              (!(has.suffix n (toList ignores)))
            else
              true);
        infix = ignores:
          filterAttrs (n: v:
            if (v != "directory") then
              (!(has.infix n (toList ignores)))
            else
              true);
        elem = ignores:
          filterAttrs (n: v:
            if (v != "directory") then
              (!(elem n (flattenToList ignores)))
            else
              true);
      };
      files = {
        prefix = ignores:
          filterAttrs (n: v:
            if (v == "regular") then
              (!(has.prefix n (toList ignores)))
            else
              true);
        suffix = ignores:
          filterAttrs (n: v:
            if (v == "regular") then
              (!(has.suffix n (toList ignores)))
            else
              true);
        infix = ignores:
          filterAttrs (n: v:
            if (v == "regular") then
              (!(has.infix n (toList ignores)))
            else
              true);
        elem = ignores:
          filterAttrs (n: v:
            if (v == "regular") then
              (!(elem n (flattenToList ignores)))
            else
              true);
      };
      sym = {
        prefix = ignores:
          filterAttrs (n: v:
            if (v == "symlink") then
              (!(has.prefix n (toList ignores)))
            else
              true);
        suffix = ignores:
          filterAttrs (n: v:
            if (v == "symlink") then
              (!(has.suffix n (toList ignores)))
            else
              true);
        infix = ignores:
          filterAttrs (n: v:
            if (v == "symlink") then
              (!(has.infix n (toList ignores)))
            else
              true);
        elem = ignores:
          filterAttrs (n: v:
            if (v == "symlink") then
              (!(elem n (flattenToList ignores)))
            else
              true);
      };
      unknown = {
        prefix = ignores:
          filterAttrs (n: v:
            if (v == "unknown") then
              (!(has.prefix n (toList ignores)))
            else
              true);
        suffix = ignores:
          filterAttrs (n: v:
            if (v == "unknown") then
              (!(has.suffix n (toList ignores)))
            else
              true);
        infix = ignores:
          filterAttrs (n: v:
            if (v == "unknown") then
              (!(has.infix n (toList ignores)))
            else
              true);
        elem = ignores:
          filterAttrs (n: v:
            if (v == "unknown") then
              (!(elem n (flattenToList ignores)))
            else
              true);
      };
      static = {
        prefix = ignores:
          filterAttrs (n: v:
            if ((v == "regular") || (v == "unknown")) then
              (!(has.prefix n (toList ignores)))
            else
              true);
        suffix = ignores:
          filterAttrs (n: v:
            if ((v == "regular") || (v == "unknown")) then
              (!(has.suffix n (toList ignores)))
            else
              true);
        infix = ignores:
          filterAttrs (n: v:
            if ((v == "regular") || (v == "unknown")) then
              (!(has.infix n (toList ignores)))
            else
              true);
        elem = ignores:
          filterAttrs (n: v:
            if ((v == "regular") || (v == "unknown")) then
              (!(elem n (flattenToList ignores)))
            else
              true);
      };
    };
  };
}
