{ self, pkgs }:
pkgs.nixosTest {
  name = "test-nixos-module-dnieremote-config-jumpintro-wifi";
  nodes.machine = { config, pkgs, modulesPath, ... }: {
    imports = [
      self.nixosModules.dnieremote
      (modulesPath + "./../tests/common/x11.nix")
      ../../../_common/nixos/stateVersion.nix
    ];

    programs.dnieremote.enable = true;
    programs.dnieremote.jumpIntro = "wifi";
  };

  testScript = ''
    machine.wait_for_unit("default.target")
    machine.wait_for_x()

    machine.execute("dnieremotewizard >&2 &")

    # Wait for the wizard to start and jump into the wifi screen
    machine.wait_for_window('Vinculación dispositivo y DNIe', 30)
    machine.sleep(5)
    machine.screenshot("screen")
  '';
}

