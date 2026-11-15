{
  description = "ADA: assertion-driven main loop for LLM agents (CLI + interactive TUI)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        ada-agent = pkgs.buildGoModule {
          pname = "ada-agent";
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
          src = ./.;
          vendorHash = "sha256-oZ6wWZ+DEYMksB4m82ogTjyZnCs5yOjUD0+qmyJtOC4=";
          subPackages = [ "cmd/ada" "cmd/adax" ];
          env.CGO_ENABLED = 0;
          ldflags = [ "-s" "-w" "-X main.version=${self.shortRev or "dirty"}" ];
          postInstall = ''
            mv $out/bin/ada $out/bin/ada_agent
            mv $out/bin/adax $out/bin/ada
            install -Dm644 README.md -t $out/share/doc/ada-agent
            cp -r benchmarks $out/share/doc/ada-agent/
          '';
          meta = {
            description = "ADA: assertion-driven main loop for LLM agents (CLI + interactive TUI)";
            homepage = "https://github.com/Szmelc-INC/Assertion-Driven-Architecture";
            license = pkgs.lib.licenses.mit;
            mainProgram = "ada";
            platforms = pkgs.lib.platforms.linux;
          };
        };
        default = ada-agent;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ada";
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          packages = with pkgs; [ gopls gotools ];
        };
      });
    };
}
