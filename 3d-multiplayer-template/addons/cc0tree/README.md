# CC0Tree Showcase (Godot 4)

A small viewer for the free CC0Tree low-poly model library. Install it into your project (it lives in `addons/cc0tree/`), open `showcase.tscn` or `asset_overview.tscn`, and press **Run Current Scene** (F6). Godot 4.3 or newer.

It has two scenes, and **Tab** switches between them:

- `showcase.tscn` is the turntable. It shows one model at a time on a spinning pedestal.
- `asset_overview.tscn` is the grid. It shows every model with its name underneath.

## Controls (turntable)

- **Left / Right** (or the on-screen arrows): previous / next model
- **Space**: pause or resume the spin
- **Mouse drag / wheel**: rotate and zoom
- **Tab**: go to the grid

## Adding models

Drop any `.fbx`, `.glb` or `.gltf` file (and its texture) into `addons/cc0tree/models/`. Both scenes find it automatically.
Keep each `.fbx` next to its `PG_*.png` texture so the texture links.

## Editing the look

Open either scene in Godot. Everything is a normal node you can select and change: lights, camera, background, text, buttons, and in the grid scene every model and every name.

- **asset_overview.tscn:** the grid is saved in the scene, so you can see it in the editor and move or delete anything. If you add models to `addons/cc0tree/models/` or change the grid numbers in the Inspector, select the root node and press **Rebuild grid** (this re-creates the grid, so any hand edits to it are replaced).
- **showcase.tscn:** shows the first model as a preview in the editor. Select the root node to change camera angle, spin speed and zoom limits.
- **model_library.gd:** has a small `BRIGHTEN` table that slightly lightens a few very dark models when they are shown. It never changes the model or texture files.

## License

Everything is CC0 / public domain. More models: https://skywolfgamestudios.github.io/CC0Tree/
