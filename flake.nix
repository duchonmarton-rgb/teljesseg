{
  description = "TeX and Lean 4 development environment for the Riemann-Roch notes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      tex = pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-medium
          amscls
          amsfonts
          amsmath
          babel-english
          babel-hungarian
          biber
          biblatex
          booktabs
          enumitem
          fontspec
          geometry
          hyperref
          latex-bin
          latexmk
          luaotfload
          mathtools
          microtype
          nicematrix
          pgf
          standalone
          tikz-cd
          chktex
          titlesec
          unicode-math
          xcolor
          ;
      };

      fonts = [
        pkgs.lexend
        pkgs.nerd-fonts.tinos
      ];

      osFontDir = lib.concatStringsSep ":" [
        "${pkgs.lexend}/share/fonts/variable/lexend/lexend"
        "${pkgs.lexend}/share/fonts/truetype/lexend/lexend"
        "${pkgs.lexend}/share/fonts/truetype/public/lexend"
        "${pkgs.nerd-fonts.tinos}/share/fonts/truetype/NerdFonts/Tinos"
      ];

      texCacheSetup = ''
        mkdir -p .cache/{texmf-var,texmf-config,luaotfload}
        export TEXMFHOME=$(pwd)/.cache
        export TEXMFCONFIG=$(pwd)/.cache/texmf-config
        export TEXMFVAR=$(pwd)/.cache/texmf-var
        export LUAOTFLOAD_CACHE=$(pwd)/.cache/luaotfload
        export OSFONTDIR="${osFontDir}"
      '';

      buildTexDocument = {
        name,
        texRoot ? "tex",
        mainFile ? "main.tex",
      }:
        pkgs.stdenvNoCC.mkDerivation {
          pname = "repartitions-${name}";
          version = "1";
          src = self;

          nativeBuildInputs = [pkgs.coreutils tex] ++ fonts;
          phases = ["unpackPhase" "buildPhase" "installPhase"];

          buildPhase = ''
            runHook preBuild
            ${texCacheSetup}
            luaotfload-tool --update --force
            cd ${texRoot}
            latexmk -interaction=nonstopmode -f -pdf -lualatex \
              -pretex="\pdfvariable suppressoptionalinfo 521\relax" \
              -shell-escape \
              -usepretex ${mainFile}
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp ${lib.removeSuffix ".tex" mainFile}.pdf $out/${name}.pdf
            runHook postInstall
          '';
        };

      watchLatex = pkgs.writeShellApplication {
        name = "watch-latex";
        runtimeInputs = [tex pkgs.coreutils];
        text = ''
          target="''${1:-tex/main.tex}"
          exec latexmk -pvc -pdf -lualatex -interaction=nonstopmode -shell-escape "$target"
        '';
      };

      devTools =
        [
          pkgs.alejandra
          pkgs.coreutils
          pkgs.fd
          pkgs.git
          pkgs.lean4
          pkgs.nil
          pkgs.ripgrep
          pkgs.texlab
          watchLatex
          tex
        ]
        ++ fonts;
    in {
      packages = {
        tex = buildTexDocument {name = "tex";};
        main = self.packages.${system}.tex;
        default = self.packages.${system}.tex;
      };

      devShells.default = pkgs.mkShell {
        packages = devTools;

        shellHook = ''
          ${texCacheSetup}

          echo "Riemann-Roch notes development shell"
          echo "TeX:  latexmk -pdf -lualatex tex/main.tex"
          echo "Watch: watch-latex [tex/main.tex]"
          echo "Build: nix build .#tex"
          echo "Lean: cd lean && lake build"
        '';
      };
    });
}
