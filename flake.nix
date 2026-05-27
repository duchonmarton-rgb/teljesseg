{
  description = "Minimal LaTeX Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachSystem flake-utils.lib.allSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-medium
          pgf
          tikz-cd
          fontspec
          enumitem
          unicode-math
          amsmath
          amsfonts
          mathtools
          xcolor
          hyperref
          booktabs
          titlesec
          microtype
          geometry
          nicematrix
          latex-bin
          latexmk
          luaotfload
          babel-hungarian
          standalone
          ;
      };
      # rebuild document.tex on change
      watchlatex = pkgs.stdenvNoCC.mkDerivation {
        name = "watch-latex";
        src = null;
        buildInputs = [tex pkgs.coreutils];
        phases = ["installPhase"];
        installPhase = ''
            mkdir -p $out/bin
            cat > $out/bin/watch-latex << 'EOF'
          #!/usr/bin/env bash
          exec latexmk -pvc -pdf -lualatex -interaction=nonstopmode -shell-escape document.tex \
            > watchlatex.log 2>&1
          EOF
            chmod +x $out/bin/watch-latex
        '';
      };

      texFiles =
        builtins.filter
        (n: pkgs.lib.hasSuffix ".tex" n)
        (builtins.attrNames (builtins.readDir self));

      stripExt = name:
        builtins.substring 0 (builtins.stringLength name - 4) name;

      buildTex = file: let
        name = stripExt file;
      in
        pkgs.stdenvNoCC.mkDerivation rec {
          pname = "latex-${name}";
          version = "1";
          src = self;

          buildInputs = [pkgs.coreutils tex pkgs.lexend pkgs.nerd-fonts.tinos];
          phases = ["unpackPhase" "buildPhase" "installPhase"];

          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}"

            mkdir -p .cache/{texmf-var,texmf-config,luaotfload}
            export TEXMFHOME=$(pwd)/.cache
            export TEXMFCONFIG=$(pwd)/.cache/texmf-config
            export TEXMFVAR=$(pwd)/.cache/texmf-var
            export LUAOTFLOAD_CACHE=$(pwd)/.cache/luaotfload
            export OSFONTDIR="${pkgs.lexend}/share/fonts/variable/lexend/lexend:${pkgs.lexend}/share/fonts/truetype/lexend/lexend:${pkgs.lexend}/share/fonts/truetype/public/lexend:${pkgs.nerd-fonts.tinos}/share/fonts/truetype/NerdFonts/Tinos"
            export SOURCE_DATE_EPOCH=$(date +%s)

            luaotfload-tool --update --force

            latexmk -interaction=nonstopmode -f -pdf -lualatex \
               -pretex="\pdfvariable suppressoptionalinfo 521\relax" \
               -shell-escape \
               -usepretex ${file}
          '';

          installPhase = ''
            mkdir -p $out
            cp ${stripExt file}.pdf $out/
          '';
        };

      individual =
        builtins.listToAttrs
        (map (f: {
            name = stripExt f;
            value = buildTex f;
          })
          texFiles);

      all = pkgs.symlinkJoin {
        name = "latex-all";
        paths = builtins.attrValues individual;
      };
    in {
      packages = individual // {inherit all;};

      devShells.default = pkgs.mkShell rec {
        buildInputs = [
          pkgs.coreutils
          tex
          pkgs.lexend
          pkgs.nerd-fonts.tinos
          watchlatex
          pkgs.texlab
        ];
        shellHook = ''
          mkdir -p .cache/{texmf-var,texmf-config,luaotfload}
          export TEXMFHOME=$(pwd)/.cache
          export TEXMFCONFIG=$(pwd)/.cache/texmf-config
          export TEXMFVAR=$(pwd)/.cache/texmf-var
          # cache fonts
          export LUAOTFLOAD_CACHE=$(pwd)/.cache/luaotfload
          # tinos and lexend fonts
          export OSFONTDIR="${pkgs.lexend}/share/fonts/variable/lexend/lexend:${pkgs.lexend}/share/fonts/truetype/lexend/lexend:${pkgs.lexend}/share/fonts/truetype/public/lexend:${pkgs.nerd-fonts.tinos}/share/fonts/truetype/NerdFonts/Tinos"
          # add binaries to path
          export PATH="${pkgs.lib.makeBinPath buildInputs}:$PATH"

          echo "latex devshell"
          echo "run:"
          echo "watch-latex to start detached live compilation"
          echo "----------------------------------------------"
          echo "to build a pdf from document.tex, run:"
          echo "  nix build .#document"
          echo "to build all documents <file.tex>, run:"
          echo "  nix build .#all"
        '';
      };
    });
}
