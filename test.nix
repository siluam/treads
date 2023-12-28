{
  niv = {
    branch = "nixos-unstable";
    description = "Nix Packages collection";
    homepage = null;
    outPath = "/nix/store/pp307nbzkgsd6393zl2i9j4j86z5nz9b-nixpkgs-src";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "6c43a3495a11e261e5f41e5d7eda2d71dae1b2fe";
    sha256 = "16f329z831bq7l3wn1dfvbkh95l2gcggdwn6rk3cisdmv2aa3189";
    type = "tarball";
    url =
      "https://github.com/NixOS/nixpkgs/archive/6c43a3495a11e261e5f41e5d7eda2d71dae1b2fe.tar.gz";
    url_template = "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz";
  };
  niv-2 = {
    branch = "main";
    description = "Pure Nix flake utility functions [maintainer=@zimbatm]";
    homepage = "";
    outPath = "/nix/store/kzrn28nqs2mxalmhb8rx306j0z14yihv-flake-utils-src";
    owner = "numtide";
    repo = "flake-utils";
    rev = "4022d587cbbfd70fe950c1e2083a02621806a725";
    sha256 = "1kvlxzss3ip8jpvjxz0cq4dxdxy9s2wzc0zkjkkkqskrd2krw2wh";
    type = "tarball";
    url =
      "https://github.com/numtide/flake-utils/archive/4022d587cbbfd70fe950c1e2083a02621806a725.tar.gz";
    url_template = "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz";
  };
  niv-3 = {
    branch = "v1.0.0";
    description = "Pure Nix flake utility functions [maintainer=@zimbatm]";
    homepage = "";
    outPath = "/nix/store/x9lz2yg5hahnac680626qgqsllg7kqkn-flake-utils-src";
    owner = "numtide";
    repo = "flake-utils";
    rev = "04c1b180862888302ddfb2e3ad9eaa63afc60cf8";
    sha256 = "0hynd4rbkbplxzl2a8wb3r8z0h17z2alhhdsam78g3vgzpzg0d43";
    type = "tarball";
    url =
      "https://github.com/numtide/flake-utils/archive/04c1b180862888302ddfb2e3ad9eaa63afc60cf8.tar.gz";
    url_template = "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz";
  };
  niv-4 = {
    branch = "main";
    description = "Pure Nix flake utility functions [maintainer=@zimbatm]";
    homepage = "";
    outPath = "/nix/store/kzrn28nqs2mxalmhb8rx306j0z14yihv-flake-utils-src";
    owner = "numtide";
    repo = "flake-utils";
    rev = "4022d587cbbfd70fe950c1e2083a02621806a725";
    sha256 = "1kvlxzss3ip8jpvjxz0cq4dxdxy9s2wzc0zkjkkkqskrd2krw2wh";
    type = "tarball";
    url =
      "https://github.com/numtide/flake-utils/archive/4022d587cbbfd70fe950c1e2083a02621806a725.tar.gz";
    url_template = "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz";
    version = "v1.0.0";
  };
  npins = {
    hash = "0gxm9qvlaj202ngrvlnivypbiclxizyd6axq9ip5ddj6mf8mfpaj";
    name = "nixpkgs-unstable";
    outPath = "/nix/store/8pmd57f4h0sxwc4hb1djk1i1kr1qcrwr-source";
    type = "Channel";
    url =
      "https://releases.nixos.org/nixpkgs/nixpkgs-24.05pre561758.d6863cbcbbb8/nixexprs.tar.xz";
  };
  npins-2 = {
    hash = "0hynd4rbkbplxzl2a8wb3r8z0h17z2alhhdsam78g3vgzpzg0d43";
    outPath = "/nix/store/wk1zs2zxcb53qzkil3xjfvbc2lv51qzd-source";
    pre_releases = false;
    repository = {
      owner = "numtide";
      repo = "flake-utils";
      type = "GitHub";
    };
    revision = "04c1b180862888302ddfb2e3ad9eaa63afc60cf8";
    type = "GitRelease";
    url = "https://api.github.com/repos/numtide/flake-utils/tarball/v1.0.0";
    version = "v1.0.0";
    version_upper_bound = null;
  };
  flake = {
    _type = "flake";
    checks = null;
    htmlDocs = null;
    inputs = null;
    lastModified = 1702346276;
    lastModifiedDate = "20231212015756";
    legacyPackages = null;
    lib = null;
    narHash = "sha256-eAQgwIWApFQ40ipeOjVSoK4TEHVd6nbSd9fApiHIw5A=";
    nixosModules = null;
    outPath = "/nix/store/dg2g5qwvs36dhfqj9khx4sfv0klwl9f0-source";
    outputs = null;
    rev = "cf28ee258fd5f9a52de6b9865cdb93a1f96d09b7";
    shortRev = "cf28ee2";
    sourceInfo = null;
  };
  flake-2 = {
    _type = "flake";
    inputs = {
      systems = {
        _type = "flake";
        inputs = { };
        lastModified = 1681028828;
        lastModifiedDate = "20230409082708";
        narHash = "sha256-Vy1rq5AaRuLzOxct8nz4T6wlgyUR7zLU309k9mBC768=";
        outPath = "/nix/store/yj1wxm9hh8610iyzqnz75kvs6xl8j3my-source";
        outputs = { };
        owner = "nix-systems";
        repo = "default";
        rev = "da67096a3b9bf56a91d16901293e51ba5b49a27e";
        shortRev = "da67096";
        sourceInfo = {
          lastModified = 1681028828;
          lastModifiedDate = "20230409082708";
          narHash = "sha256-Vy1rq5AaRuLzOxct8nz4T6wlgyUR7zLU309k9mBC768=";
          outPath = "/nix/store/yj1wxm9hh8610iyzqnz75kvs6xl8j3my-source";
          owner = "nix-systems";
          repo = "default";
          rev = "da67096a3b9bf56a91d16901293e51ba5b49a27e";
          shortRev = "da67096";
          type = "github";
        };
        type = "github";
      };
    };
    lastModified = 1701680307;
    lastModifiedDate = "20231204085827";
    lib = {
      allSystems = [
        "aarch64-darwin"
        "aarch64-genode"
        "aarch64-linux"
        "aarch64-netbsd"
        "aarch64-none"
        "aarch64_be-none"
        "arm-none"
        "armv5tel-linux"
        "armv6l-linux"
        "armv6l-netbsd"
        "armv6l-none"
        "armv7a-darwin"
        "armv7a-linux"
        "armv7a-netbsd"
        "armv7l-linux"
        "armv7l-netbsd"
        "avr-none"
        "i686-cygwin"
        "i686-darwin"
        "i686-freebsd13"
        "i686-genode"
        "i686-linux"
        "i686-netbsd"
        "i686-none"
        "i686-openbsd"
        "i686-windows"
        "javascript-ghcjs"
        "m68k-linux"
        "m68k-netbsd"
        "m68k-none"
        "microblaze-linux"
        "microblaze-none"
        "microblazeel-linux"
        "microblazeel-none"
        "mips64el-linux"
        "mipsel-linux"
        "mipsel-netbsd"
        "mmix-mmixware"
        "msp430-none"
        "or1k-none"
        "powerpc-netbsd"
        "powerpc-none"
        "powerpc64-linux"
        "powerpc64le-linux"
        "powerpcle-none"
        "riscv32-linux"
        "riscv32-netbsd"
        "riscv32-none"
        "riscv64-linux"
        "riscv64-netbsd"
        "riscv64-none"
        "rx-none"
        "s390-linux"
        "s390-none"
        "s390x-linux"
        "s390x-none"
        "vc4-none"
        "wasm32-wasi"
        "wasm64-wasi"
        "x86_64-cygwin"
        "x86_64-darwin"
        "x86_64-freebsd13"
        "x86_64-genode"
        "x86_64-linux"
        "x86_64-netbsd"
        "x86_64-none"
        "x86_64-openbsd"
        "x86_64-redox"
        "x86_64-solaris"
        "x86_64-windows"
      ];
      check-utils = null;
      defaultSystems =
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      eachDefaultSystem = null;
      eachDefaultSystemMap = null;
      eachSystem = null;
      eachSystemMap = null;
      filterPackages = null;
      flattenTree = null;
      meld = null;
      mkApp = null;
      simpleFlake = null;
      system = {
        aarch64-darwin = "aarch64-darwin";
        aarch64-genode = "aarch64-genode";
        aarch64-linux = "aarch64-linux";
        aarch64-netbsd = "aarch64-netbsd";
        aarch64-none = "aarch64-none";
        aarch64_be-none = "aarch64_be-none";
        arm-none = "arm-none";
        armv5tel-linux = "armv5tel-linux";
        armv6l-linux = "armv6l-linux";
        armv6l-netbsd = "armv6l-netbsd";
        armv6l-none = "armv6l-none";
        armv7a-darwin = "armv7a-darwin";
        armv7a-linux = "armv7a-linux";
        armv7a-netbsd = "armv7a-netbsd";
        armv7l-linux = "armv7l-linux";
        armv7l-netbsd = "armv7l-netbsd";
        avr-none = "avr-none";
        i686-cygwin = "i686-cygwin";
        i686-darwin = "i686-darwin";
        i686-freebsd13 = "i686-freebsd13";
        i686-genode = "i686-genode";
        i686-linux = "i686-linux";
        i686-netbsd = "i686-netbsd";
        i686-none = "i686-none";
        i686-openbsd = "i686-openbsd";
        i686-windows = "i686-windows";
        javascript-ghcjs = "javascript-ghcjs";
        m68k-linux = "m68k-linux";
        m68k-netbsd = "m68k-netbsd";
        m68k-none = "m68k-none";
        microblaze-linux = "microblaze-linux";
        microblaze-none = "microblaze-none";
        microblazeel-linux = "microblazeel-linux";
        microblazeel-none = "microblazeel-none";
        mips64el-linux = "mips64el-linux";
        mipsel-linux = "mipsel-linux";
        mipsel-netbsd = "mipsel-netbsd";
        mmix-mmixware = "mmix-mmixware";
        msp430-none = "msp430-none";
        or1k-none = "or1k-none";
        powerpc-netbsd = "powerpc-netbsd";
        powerpc-none = "powerpc-none";
        powerpc64-linux = "powerpc64-linux";
        powerpc64le-linux = "powerpc64le-linux";
        powerpcle-none = "powerpcle-none";
        riscv32-linux = "riscv32-linux";
        riscv32-netbsd = "riscv32-netbsd";
        riscv32-none = "riscv32-none";
        riscv64-linux = "riscv64-linux";
        riscv64-netbsd = "riscv64-netbsd";
        riscv64-none = "riscv64-none";
        rx-none = "rx-none";
        s390-linux = "s390-linux";
        s390-none = "s390-none";
        s390x-linux = "s390x-linux";
        s390x-none = "s390x-none";
        vc4-none = "vc4-none";
        wasm32-wasi = "wasm32-wasi";
        wasm64-wasi = "wasm64-wasi";
        x86_64-cygwin = "x86_64-cygwin";
        x86_64-darwin = "x86_64-darwin";
        x86_64-freebsd13 = "x86_64-freebsd13";
        x86_64-genode = "x86_64-genode";
        x86_64-linux = "x86_64-linux";
        x86_64-netbsd = "x86_64-netbsd";
        x86_64-none = "x86_64-none";
        x86_64-openbsd = "x86_64-openbsd";
        x86_64-redox = "x86_64-redox";
        x86_64-solaris = "x86_64-solaris";
        x86_64-windows = "x86_64-windows";
      };
    };
    narHash = "sha256-kAuep2h5ajznlPMD9rnQyffWG8EM/C73lejGofXvdM8=";
    outPath = "/nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source";
    outputs = {
      lib = null;
      templates = {
        check-utils = {
          description = "A flake with tests";
          path =
            /nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source/examples/check-utils;
        };
        default = {
          description = "A flake using flake-utils.lib.eachDefaultSystem";
          path =
            /nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source/examples/each-system;
        };
        each-system = {
          description = "A flake using flake-utils.lib.eachDefaultSystem";
          path =
            /nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source/examples/each-system;
        };
        simple-flake = {
          description = "A flake using flake-utils.lib.simpleFlake";
          path =
            /nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source/examples/simple-flake;
        };
      };
    };
    owner = "numtide";
    repo = "flake-utils";
    rev = "4022d587cbbfd70fe950c1e2083a02621806a725";
    shortRev = "4022d58";
    sourceInfo = {
      lastModified = 1701680307;
      lastModifiedDate = "20231204085827";
      narHash = "sha256-kAuep2h5ajznlPMD9rnQyffWG8EM/C73lejGofXvdM8=";
      outPath = "/nix/store/pgid9c9xfcrbqx2giry0an0bi0df7s5c-source";
      owner = "numtide";
      repo = "flake-utils";
      rev = "4022d587cbbfd70fe950c1e2083a02621806a725";
      shortRev = "4022d58";
      type = "github";
    };
    templates = null;
    type = "github";
  };
}
