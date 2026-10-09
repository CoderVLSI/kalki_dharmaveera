# HANDOFF: Kalki Dharmaveera (read this first in a new session)

Repo: `CoderVLSI/kalki_dharmaveera`, branch **`claude/friendly-albattani-ctqtyg`** (develop and push only here; never open a PR unless asked).
Read `PLAN.md` (vision, canon rules, milestones) and `README.md` (controls, build notes) too.

## What the user wants
A mythic action game: **Kalki** (10th avatar of Vishnu) destroys **Kali's host (the "Mlechhas", defined by conduct, never by real ethnicity/religion; see PLAN.md 2.2)** and restores **Satya Yuga**. Sources: Kalki Purana + the 18 Mahapuranas, with tagged fictional additions. Rule-based, data-driven (no runtime AI). Voice by **ElevenLabs**. They test on an **Android phone** (APK sideload).

## User preferences (important)
- Wants things **done for them**: avoid asking them to do tedious manual steps (they said "too tedious, too much"). Decide sensibly and act; ask only when truly blocked.
- **Minimise credits** (ElevenLabs especially). Generate voice only for new lines; the script is idempotent.
- Casual tone ("bro"); keep replies short and plain. They interrupt tool calls often; that is not rejection of the goal.
- Never print or commit secrets. Never ask them to paste tokens into chat.

## Current state (v0.5.3)
Playable prototype in Godot 4.7.2 (GL Compatibility, GDScript):
- Player: Kalki on Devadatta (`assets/models/kalki_devadatta_rigged.glb`, rigged/animated by `tools/blender/rig_kalki.py`; animations idle/walk/trot/gallop/slash/rear/victory). Gaits, slash, Astra (rear-up shockwave), dash.
- Enemies from `data/enemies.json` (raider, archer, banner-bearer) and the **Koka and Vikoka twin boss** (spawns at 80% Dharma; each revives after 6 s unless both are down together; Dharma capped at 95 until both die).
- World flips Kali Yuga to Satya Yuga with Dharma; pillars Tapas/Shaucha/Daya/Satya at 25/50/75/100.
- Audio: `Sfx` autoload; procedural SFX/music (`tools/audio/make_sfx.py`, free) + 12 ElevenLabs voice lines (`tools/audio/gen_voice.py`, `data/voices.json`, model eleven_flash_v2_5, ~0.5 credit/char).
- Touch controls (`scripts/touch_controls.gd`), title screen (key art), Narayana cameo (`assets/models/narayana.glb`).
- Enemies now use rigged CC-BY Sketchfab models (v0.5.3): raider = Zombie Warrior (idle/walk/run), archer = Low Poly Goblin, banner-bearer = 3DRT Fantasy Warrior (single long take sliced into idle/attack_a/attack_b by `tools/blender/prep_character.py`), Koka/Vikoka = Armored King tinted purple/blue. Bound in `data/enemies.json` (`model`, `height`, `turn`, `lift`, `anims`); `Enemy._build_model` loads them, capsule is the fallback. Credits in `docs/ATTRIBUTION.md`. Test: `res://tests/enemy_models_test.tscn`.
- Prologue (v0.5.3, `scripts/prologue.gd`, plays after the title; skippable; `KALKI_NOPROLOGUE=1` skips it): Brahma and the devatas petition Narayana, he vows to be born as Kalki in Shambhala, cut to a placeholder cradle for the newborn (no Bala Kalki model yet). Lines `prologue_plea/vow/birth` in `data/dialogue.json` (canon-adapted, [VERIFY]); voiced for ~183 credits (Brahma = ElevenLabs Daniel). Tests: `res://tests/prologue_test.tscn`; capture helper `prologue_view.tscn`.
- Latest APK: `dist/KalkiDharmaveera-v0.5.3-android.apk` (~59 MB, arm64, debug-signed, sideload only).
- Canon index draft: `docs/sources/CANON_INDEX.md` (UNVERIFIED rows exist; primary-text sites were blocked).

## Rebuild the environment (cloud container is ephemeral)
```
tools/setup_env.sh                 # Godot 4.7.2, Blender (apt) + numpy/requests, Godot MCP, Blender MCP add-on
tools/install_export_templates.sh  # ~1.3 GB, needed to export
tools/fetch_assets.sh              # original high-poly model drops from GitHub releases `kalki` and `narayana` (git-ignored)
tools/build_android.sh             # signed APK -> dist/  (installs JDK/apksigner, fake SDK at /opt/android-sdk, debug keystore)
```
After cloning: `godot --headless --path . --import` once. ffmpeg is already present.
Release signing uses env vars `GODOT_ANDROID_KEYSTORE_RELEASE_PATH/USER/PASSWORD` (build_android.sh sets them to a throwaway debug keystore).
Blender MCP needs Xvfb: `xvfb-run -a blender --python tools/blender_mcp_launcher.py` (port 9876). `.mcp.json` is in the repo.

## Tests (run before every push; all must pass)
```
godot --headless --path . --quit-after 300                 # must print no SCRIPT ERROR / Parse Error
godot --headless --path . res://tests/move_test.tscn       # camera-relative movement/facing
godot --headless --path . res://tests/boss_test.tscn       # twin rule, expects RESULT failures=0
godot --headless --path . res://tests/enemy_models_test.tscn  # enemy models/clips, expects RESULT failures=0
godot --headless --path . res://tests/prologue_test.tscn      # prologue plays + skips, expects RESULT failures=0
godot --headless --path . --script tests/facing_test.gd    # model faces -Z (it prints; needs no autoload)
```
Visual check without a GPU: `KALKI_DEMO=1 [KALKI_TOUCH=1] [KALKI_DHARMA=82] xvfb-run -a godot --path . --rendering-driver opengl3 --write-movie /tmp/out/f.png --fixed-fps 10 --quit-after 40`. (`KALKI_DEMO` cycles animations and skips the title.)
**Gate pushes on test success**; an earlier push shipped a parse error because the command chain did not stop on it.

## Lessons learned (do not repeat)
- Blender coords: Z up, horse faces **-Y**; glTF/Godot front is +Z; player model is rotated PI so forward is -Z. In the rig a **positive X rotation swings a hoof toward the tail**: forward swing is negative; knee fold only while swinging forward. `RIG_DIAG=1` prints a gait pass/fail.
- Godot rewrites `editor_settings-4.7.tres` on exit; Android SDK must live at `/root/Android/Sdk` (symlink to `/opt/android-sdk`) and the debug keystore at `/root/.local/share/godot/keystores/debug.keystore`.
- `assets/source/.gdignore` keeps raw model drops out of the APK (otherwise 106 MB).
- Boot splash must be PNG. Godot's movie-maker WAV is 32-bit (decode with ffmpeg).
- Autoloads are not available to `--script` SceneTree scripts; run tests as scenes.
- `SendUserFile` limit is 30 MB (APK is 48 MB), so the user downloads the APK from the GitHub file page.
- Sandbox network allowlist blocks most text/asset sites; GitHub, npm, PyPI, apt, conda are open.

## Models: what is real and what is stand-in (v0.5.x)
- Enemies, trees (dead/alive crossfade by Dharma), mountains, Shambhala village + shrine, four Dharma pillars (rise when restored), Earth, cradle, newborn, lotus: CC-BY Sketchfab models (`tools/blender/prep_prop.py`, `prep_character.py`; credits in `docs/ATTRIBUTION.md`). Helpers in `scripts/props.gd`.
- **No vigrahas for devatas** (user: idols make no sense; devatas are living beings). Sketchfab has only statues of them, so the prologue shows them as columns of rising light until the user's own models arrive.
- **The user generates the character models with Hyper3D Rodin** (Brahma, Shiva, baby Kalki, Kalki at 4-5 yr, teen Kalki, adult/on-foot Kalki). Do not search for these. Slots: drop `assets/models/char_<slot>.glb` (`brahma`, `shiva`, `kalki_baby`, `kalki_child`, `kalki_teen`, `kalki`); `Props.character(slot, height)` fits them (static meshes) and the prologue picks up `brahma`, `shiva`, `kalki_baby` automatically. Child/teen/adult slots are not wired to gameplay yet (Shambhala boyhood chapter).

- **Shuka** (v0.5.3, `scripts/companion.gd`): a CC-BY macaw ("parrot rebuilt") recoloured green by a hue-shift shader hovers beside Kalki. Stand-in only (macaw, flap loop); the user's own `char_shuka.glb` replaces it automatically.

## Canon reference (user-supplied PDF)
`docs/sources/Kalki_Purana_Game_Reference.pdf` is now the canon authority (A/B/C/G tiers, 18-mission campaign M00-M17, roster, rules). Digest and reconciliation: `docs/sources/KALKI_REFERENCE_NOTES.md`; data: `data/missions.json`, `data/characters.json`. PDF's requested next build: the vertical slice **M03 + M04 + M10**. Subtitles now show source tier plus "ADAPTED DIALOGUE - NOT A VERSE".

## Pending / next (in priority order)
1. **More Sketchfab assets**: token and downloads work (`api.sketchfab.com` and media hosts reachable; `python3 -I tools/sketchfab_fetch.py search/get`). Done: enemy models (above). Still wanted: a proper on-foot Kalki (none of the found models fit; search for a rigged hero/prince with walk+run+attack), temple/ruin props, weapons. Models need `prep_character.py` (it normalises to 1 m tall, feet at 0; then tune `height`/`turn`/`lift` in enemies.json by eye with `KALKI_LINEUP=1` on the enemy test, since skinned bounds cannot be measured in Godot). Never leave render captures inside the project (they get packed into the APK); write to /tmp.
2. **Button icons**: the user showed emblems (sword, Sudarshana Chakra, Devadatta medallion) for SLASH/ASTRA/DASH, but the files never reached disk. Ask for them via a GitHub release only if still wanted, otherwise draw simple icons.
3. **Menu**: the user's menu mockup has baked-in text with typos (RITHS, EXIT twice). Build Start/Options/Exit in code over calm art; crop the placeholder studio logos and App Store/Google Play badges out of key art copies.
4. Koka and Vikoka arena moment (fanfare, warning), difficulty tuning, on-foot chapters (Shambhala, Parashurama), more voice only as needed.
5. Verify canon refs once text sites are reachable (`docs/sources/CANON_INDEX.md` section 4).

## Credits spent so far (ElevenLabs)
About 520 credits (15 lines). Account: Creator tier, ~88k credits were left at the start of audio work.
