# Deviations from the Three.js prototype (`game.js`)

This Godot port reproduces the prototype's mechanics and numeric tuning. The
following intentional differences exist.

## Bug fixes (the spec demands it "feel better than the browser version")

- **Cop bullets now actually hit the player.** In `game.js`, cops fire
  `WEAPONS[1]` (KNIFE) — a melee entry with range 2.8, so cop "bullets" die in
  ~0.02 s and travel under 3 m. They also spawn at chest height with a purely
  horizontal direction, while the player's collision point is at `y = 0`, so the
  distance check `< 1` could never pass. Both issues made cops unable to deal
  ranged damage at all. This port fires the **PISTOL** (`WeaponDB.LIST[2]`, as
  spec §11 states), aims at the player's torso, and tests hits against a torso
  point (`y = 1.2`). Cops are now a real threat.
- **The plane can actually take off.** In `game.js` the on-ground branch pins
  `pos.y = 0` every frame, while the airborne branch only runs once `pos.y`
  exceeds `0.12` — so the plane could never leave the runway. This port lets
  the plane rotate and lift off once it reaches takeoff speed with the nose
  pitched up.
- **Plane pitch is on the arrow keys.** In `game.js` the camera block also
  zeroes `mouse.dy` before the plane branch reads it, so mouse pitch was always
  0. This port pitches the nose with the `↑` / `↓` arrow keys (`W`/`S`
  throttle, `A`/`D` turn), which is reliable and frees the mouse in flight.
- Entity hit detection (player bullets vs. NPCs/cops, and cop bullets vs.
  player) uses a torso reference point rather than the ground-level `pos`, so
  combat is reliable regardless of bullet height.

## Gameplay additions

- **Automatic chase camera while driving.** In a car the camera smoothly swings
  to sit behind the car's heading, giving a third-person driver's view with no
  mouse input. The prototype required constant mouse steering of the camera.
  On foot and in the plane the mouse still controls the camera freely.
- **The airport was rebuilt as a south-east grass airfield.** The prototype's
  airport was a flat zone west of downtown. It is now an off-grid airfield in
  the south-east — a long flat grass field reached by a causeway from the city
  road grid. It has two long runways (the main runway is ~690 m) with
  centreline dashes and edge lights, plus generous grass overrun ahead of each
  one so a slow plane rolls onto grass instead of crashing. It keeps a walkable
  terminal (solid walls, a 10 m entrance, glass front, interior floor, pillars,
  ceiling lights, gold roof sign), a control tower, a hangar and an apron. Each
  runway has a parked plane at its near end facing down the runway, and a
  helipad with a parked **helicopter** (vertical takeoff, hover, no runway
  needed) sits east of the runways. The helicopter is a gameplay addition not
  present in the prototype.
- **Iron Man suit.** An armoured suit spawns on open ground near the player.
  Stepping onto it assembles it plate by plate; while worn the player is
  bulletproof, can fly (hold `Space` to thrust, `WASD` to move), fire rapid
  repulsor blasts (left mouse) and explosive missiles (right mouse), and powers
  the suit back down with `F`. Not present in the prototype.
- **Exclusive fullscreen.** The game launches in exclusive fullscreen at the
  monitor's resolution; the prototype ran in a browser canvas.

## Visual / technical simplifications

- **City map** now uses the supplied Juiz de Fora-area GLB/OSM data instead of
  the prototype's procedural LA-style street grid. OSM features provide the
  urban geometry, road routing, named-place labels and building collision;
  game-only businesses and safehouses remain procedural.
- **Map scale** is reduced uniformly to fit the existing playable world and to
  keep its airport, circuit and space facility reachable without changing their
  movement systems.
- Road markings and crossings are provided by the imported map model; no
  additional procedural decals are generated.
- **Sky** uses Godot's `ProceduralSkyMaterial` with day/night colour + sun
  animation instead of the Three.js Preetham `Sky` shader. Fog, lamp/window
  emissive, headlights, and the pulsing airport beacon are all driven by the
  same time-of-day curve as the original.
- Building **windows** are drawn with a single `MultiMesh` (one draw call) whose
  emissive energy animates at night — same look, far cheaper than thousands of
  individual quads.

## Structure

- Input is read directly via physical key codes (`Input.is_physical_key_pressed`)
  rather than a Godot Input Map. This matches the prototype's raw key handling
  and avoids layout-dependent bindings; behaviour is identical to spec §15.
- Script files are consolidated slightly versus the spec's suggested tree
  (e.g. world generation + collision live together in `world.gd`). All
  systems from the spec are present.

## User-authorized movement and death-ragdoll update (2026-10-14)

- On-foot speeds were restored to the values documented in `REBUILD_SPEC.md`:
  4.5 m/s walking and 8.0 m/s sprinting. `tests/movement_audit.tscn` now checks
  the analog walk range and verifies sprint is faster.
- A physical ragdoll is built only for the player after an on-foot death. It
  uses the existing Peter rig, a selected set of 16 major bones, constrained
  joints and temporary nearby collision proxies on a dedicated layer. Respawn
  stops and removes the simulator/proxies, repositions the player, and clears
  residual movement velocity.
- Deaths while in a vehicle, wearing the flight suit, or parachuting do not
  start this ragdoll; those cases remain outside the verified scope. NPCs,
  vehicles and normal movement remain kinematic.

## GMC map integration (2026-11-24)

- The supplied `GMC/map.glb` remains a coordinate reference for Manoel Honório,
  Juiz de Fora, but its flat imported line/surface overlays are hidden.
  `GMC/map_expanded.osm` now drives rebuilt terrain-following roads, mapped
  building footprints, water/green areas, traffic routes and labels. A cropped
  SRTM grid supplies terrain elevation and walkable height.
- Since the OSM extract has only 12 building ways, deterministic procedural
  low-rise and mid-rise infill adds up to 1,670 blocks along local and arterial
  streets. These are explicitly approximated locations, not surveyed
  footprints. Street View was consulted for qualitative street/sidewalk and
  building scale around Av. Gov. Valadares, R. Ewbanck da Câmara and R. Américo
  Lôbo; no Google images or image-derived building geometry is included.
- The game businesses and buyable homes were moved around the mapped streets;
  airport, F1 circuit, estate, wilderness facility and Moon remain separate
  gameplay areas.
- OpenStreetMap ODbL attribution and SRTM provenance are recorded in
  `README.md`.
