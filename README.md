# ❄️ Igloo 🏂

A toy Nix REPL built with the Nix C bindings and Odin.

Example usage:

```bash
$ nix develop

$ odin run . -- "builtins.nixVersion"
"2.33.0pre"

$ odin run . -- "(import <nixpkgs> {}).superTuxKart.meta"
{
  unsupported: a thunk
  longDescription: a string
  name: a thunk
  mainProgram: a string
  license: a thunk
  homepage: a string
  unfree: a thunk
  maintainers: a thunk
  available: a thunk
  broken: a thunk
  description: a string
  insecure: a thunk
  outputsToInstall: a thunk
  changelog: a thunk
  position: a thunk
  platforms: a thunk
}

$ odin run . -- "(import <nixpkgs> {}).superTuxKart.meta.longDescription"
"SuperTuxKart is a Free 3D kart racing game, with many tracks,
characters and items for you to try, similar in spirit to Mario
Kart.
"
```
