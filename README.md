# Kalki Dharmaveera

A mythic action game about Kalki, the tenth avatar of Vishnu, riding out of Shambhala to destroy the hosts of Kali and restore Satya Yuga. Godot 4.7, GDScript, rule-based and data-driven. See [`PLAN.md`](PLAN.md).

## Prototype (v0.1): mounted combat slice

Play as Kalki on the white horse Devadatta. Ride down Kali's host (invented raiders, archers, banner-bearers). Each kill raises **Dharma**; at 25/50/75/100 a pillar (Tapas, Shaucha, Daya, Satya) is restored and the world turns from ash-red Kali Yuga to golden Satya Yuga.

| Key | Action |
|---|---|
| WASD / arrows | Move (camera-relative) |
| Shift / Ctrl | Gallop / walk (default is trot) |
| LMB or J | Sword slash |
| F or K | Astra: Devadatta rears, shockwave |
| Space | Dash (brief invulnerability) |
| Q / E, right-drag, wheel | Camera orbit / zoom |
| T or the right-hand panel | **Animation test**: play any of idle, walk, trot, gallop, slash, rear, victory |
| R | Restart |

Run: open the folder in Godot 4.7 (or `godot --path .`). First open imports the models.

Rule tables live in `data/*.json` (enemies, world state, spawn table, dialogue with canon tiers). Debug env vars: `KALKI_DEMO=1` (auto-cycles animations), `KALKI_DHARMA=100` (preview the Satya Yuga world).

## Android (phone) test build
`dist/KalkiDharmaveera-v0.2.1-android.apk`: arm64, debug-keystore signed, sideload only. On the phone: download the file from GitHub, allow "install unknown apps" for your browser, install, play in landscape.
Sound: procedural SFX + ambience (Kali drone to Satya tanpura as Dharma rises), ElevenLabs voices for Narayana, Shuka and the Narrator (M or the panel button mutes).
Touch controls: drag the left side to move, drag the right side to turn the camera, SLASH / ASTRA / DASH buttons, RUN toggles gallop. Rebuild with `tools/build_android.sh`.

## Assets and tools
- `assets/models/kalki_devadatta_rigged.glb`: your mounted model, decimated to 45k tris, rigged and animated by `tools/blender/rig_kalki.py`.
- `assets/models/narayana.glb`: your Narayana model, decimated by `tools/blender/prep_static.py`.
- Original high-poly drops live in the `kalki` / `narayana` GitHub releases: `tools/fetch_assets.sh`.
- `tools/setup_env.sh` rebuilds the Godot + Blender + MCP environment.
