Noduo Games – Free Sample Pack - Free Godot Sample (5 models)

Open this folder in Godot 4.3 or newer (Import > project.godot), then press F5: NoduoGamesFreeSamplePack/Demo.tscn shows every model.

Contents

- NoduoGamesFreeSamplePack/models/<Name>.glb: model with embedded PBR textures (PNG): base color, normal map (OpenGL convention, as Godot expects), ORM (R = ambient occlusion, white: no baked AO; G = roughness; B = metallic).
- NoduoGamesFreeSamplePack/scenes/<Name>.tscn: Node3D + the model (MeshInstance3D after import) + StaticBody3D with a box CollisionShape3D measured on the mesh.
- NoduoGamesFreeSamplePack/Demo.tscn: all models on a ground plane, camera, light and sky.
- You can copy the NoduoGamesFreeSamplePack folder anywhere in your own project: scene paths are relative.

Models

- CannonTower: 20344 triangles, 2.53 x 3.00 x 2.15 m, textures 2048x2048 (source: albedo 8K + PBR 4K), collision: box
- CheckoutCounter: 13764 triangles, 2.20 x 1.04 x 1.17 m, textures 2048x2048 (source: albedo 8K + PBR 4K), collision: box
- StockedShopShelf: 26699 triangles, 1.82 x 2.00 x 0.55 m, textures 2048x2048 (source: albedo 8K + PBR 4K), collision: box
- Haystack: 20562 triangles, 1.68 x 1.80 x 1.68 m, textures 2048x2048 (source: albedo 8K + PBR 4K), collision: box
- JingleBell: 20538 triangles, 0.12 x 0.20 x 0.12 m, textures 2048x2048 (source: albedo 8K + PBR 4K), collision: box

AI disclosure: the base models were generated with Meshy AI (meshy-6, meshy-7.1, paid commercial plan). Our pipeline (Game Asset Factory) then normalized scale and pivot, rebuilt the texture sets from the lossless source maps, measured box collisions and wrote the Godot scenes. Nothing in this sample is presented as made without AI.

License: see LICENSE.txt (non-exclusive). Provenance of each model: PROVENANCE.csv.
