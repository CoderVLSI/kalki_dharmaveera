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

## Current state (v0.7.1)
Playable prototype in Godot 4.7.2 (GL Compatibility, GDScript):
- Player: Kalki on Devadatta (`assets/models/kalki_devadatta_rigged.glb`, rigged/animated by `tools/blender/rig_kalki.py`; animations idle/walk/trot/gallop/slash/rear/victory). Gaits, slash, Astra (rear-up shockwave), dash.
- Enemies from `data/enemies.json` (raider, archer, banner-bearer) and the **Koka and Vikoka twin boss** (spawns at 80% Dharma; each revives after 6 s unless both are down together; Dharma capped at 95 until both die).
- World flips Kali Yuga to Satya Yuga with Dharma; pillars Tapas/Shaucha/Daya/Satya at 25/50/75/100.
- Audio: `Sfx` autoload; procedural SFX/music (`tools/audio/make_sfx.py`, free) + 12 ElevenLabs voice lines (`tools/audio/gen_voice.py`, `data/voices.json`, model eleven_flash_v2_5, ~0.5 credit/char).
- Touch controls (`scripts/touch_controls.gd`), title screen (key art), Narayana cameo (`assets/models/narayana.glb`).
- Enemies now use rigged CC-BY Sketchfab models (v0.7.1): raider = Zombie Warrior (idle/walk/run), archer = Low Poly Goblin, banner-bearer = 3DRT Fantasy Warrior (single long take sliced into idle/attack_a/attack_b by `tools/blender/prep_character.py`), Koka/Vikoka = Armored King tinted purple/blue. Bound in `data/enemies.json` (`model`, `height`, `turn`, `lift`, `anims`); `Enemy._build_model` loads them, capsule is the fallback. Credits in `docs/ATTRIBUTION.md`. Test: `res://tests/enemy_models_test.tscn`.
- Prologue (v0.7.1, `scripts/prologue.gd`, plays after the title; skippable; `KALKI_NOPROLOGUE=1` skips it): Brahma and the devatas petition Narayana, he vows to be born as Kalki in Shambhala, cut to a placeholder cradle for the newborn (no Bala Kalki model yet). Lines `prologue_plea/vow/birth` in `data/dialogue.json` (canon-adapted, [VERIFY]); voiced for ~183 credits (Brahma = ElevenLabs Daniel). Tests: `res://tests/prologue_test.tscn`; capture helper `prologue_view.tscn`.
- Latest APK: `dist/KalkiDharmaveera-v0.7.1-android.apk` (~59 MB, arm64, debug-signed, sideload only).
- Canon index draft: `docs/sources/CANON_INDEX.md` (UNVERIFIED rows exist; primary-text sites were blocked).

Windows build: `tools/build_windows.sh` -> `dist/KalkiDharmaveera-v<ver>-windows.zip` (single unsigned .exe, ~88 MB zipped; GitHub's hard limit is 100 MB per file, so if it grows past that, host it in a release asset instead).

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
- **Delivered (release `Divine`, 9 Oct 2026):** Shiva, Baby Kalki (seated infant) and Brahmadeva (four faces, four arms) from Hyper3D Rodin, prepped with `tools/blender/prep_prop.py` (16k/12k/16k tris; 512 px, baby 1024) into `assets/models/char_shiva.glb`, `char_kalki_baby.glb`, `char_brahma.glb`; used in the prologue (Brahma and Shiva flank the Lord, baby in the cradle). Raw ~35 MB pbr GLBs stay in the release only. Still to come from the user: Parashurama, Kalki adult/teen/child, Shuka, Kuthodari, Vikanja.
- **Rigging** (v0.7.1): `tools/blender/rig_humanoid.py <static.glb> <out.glb> [shiva|brahma]` builds a 17-bone game skeleton from body proportions, skins with inverse-distance weights (Blender auto-weights fail on Rodin meshes, which are not watertight), and keys three loops: `idle`, `walk`, `bless` (left arm raised; gentler for Brahma). Shiva and Brahma are rigged this way (static originals live in the `Divine` release as base_basic_pbr.glb). Brahma's two extra arms just follow the nearest bone. Reuse the script for Parashurama and the Kalki ages (character's right is -X in Blender; front is -Y). Baby Kalki is left static.
- **The user generates the character models with Hyper3D Rodin** (Brahma, Shiva, baby Kalki, Kalki at 4-5 yr, teen Kalki, adult/on-foot Kalki). Do not search for these. Slots: drop `assets/models/char_<slot>.glb` (`brahma`, `shiva`, `kalki_baby`, `kalki_child`, `kalki_teen`, `kalki`); `Props.character(slot, height)` fits them (static meshes) and the prologue picks up `brahma`, `shiva`, `kalki_baby` automatically. Child/teen/adult slots are not wired to gameplay yet (Shambhala boyhood chapter).

- **Shuka** (v0.7.1, `scripts/companion.gd`): a CC-BY macaw ("parrot rebuilt") recoloured green by a hue-shift shader hovers beside Kalki. Stand-in only (macaw, flap loop); the user's own `char_shuka.glb` replaces it automatically.

## Quality pass (v0.7.1)
Project render settings now set (MSAA 2x phone / 4x PC, anisotropic 4x/16x, bigger soft shadows), bloom + contrast/saturation in the world environment, ground bump map, prologue SubViewport MSAA 4x. Hero models re-prepped from the `Divine` release at 28k tris (Shiva, Brahma) / 22k (baby) with 1024 px maps (was 16k/12k, 512), Koka/Vikoka and the Warrior at 1024. Tuned prologue camera (tighter wide shot, close-up on the newborn). Size budget: GitHub rejects files over 100 MB and the Windows zip is ~90 MB, so raise texture sizes only with a size check (`tools/build_windows.sh`).

## Languages (v0.7.1): English, Hindi, Telugu
`Game.lang` (saved in `user://settings.cfg`, default = device language if hi/te; test hook `KALKI_LANG=hi|te|en`). Text: `data/dialogue.json` (`text`, `text_hi`, `text_te`) and `data/strings.json` (all UI: HUD, title, touch buttons, enemy names, overlays). Language picker on the title screen and a button in the HUD (rebuilds the scene). Fonts: bundled Noto Sans Devanagari/Telugu (OFL) in `assets/fonts`; a CanvasLayer blocks theme inheritance, so every UI root calls `Game.skin()`. **Voice (credit-saving):** English voices every line; Hindi/Telugu voice only the 5 key story lines (3 prologue lines, Narayana's charge, the victory line; `voiced_langs` in dialogue.json), the rest are subtitle-only. hi/te use ElevenLabs `eleven_v4_turbo` (Flash has no Telugu; both bill 0.5 credit/char), files `<id>.hi.mp3` / `<id>.te.mp3`; cost ~481 credits (962 chars). Premade English voices speak hi/te with an accent; recast in `data/voices.json` if a native voice is wanted. The Hindi/Telugu translations are mine and should be reviewed by a native speaker before release. `tools/audio/gen_voice.py` is idempotent per language.

## Canon reference (user-supplied PDF)
`docs/sources/Kalki_Purana_Game_Reference.pdf` is now the canon authority (A/B/C/G tiers, 18-mission campaign M00-M17, roster, rules). Digest and reconciliation: `docs/sources/KALKI_REFERENCE_NOTES.md`; data: `data/missions.json`, `data/characters.json`. PDF's requested next build: the vertical slice **M03 + M04 + M10**. Subtitles now show source tier plus "ADAPTED DIALOGUE - NOT A VERSE".

## Pending / next (in priority order)
1. **More Sketchfab assets**: token and downloads work (`api.sketchfab.com` and media hosts reachable; `python3 -I tools/sketchfab_fetch.py search/get`). Done: enemy models (above). Still wanted: a proper on-foot Kalki (none of the found models fit; search for a rigged hero/prince with walk+run+attack), temple/ruin props, weapons. Models need `prep_character.py` (it normalises to 1 m tall, feet at 0; then tune `height`/`turn`/`lift` in enemies.json by eye with `KALKI_LINEUP=1` on the enemy test, since skinned bounds cannot be measured in Godot). Never leave render captures inside the project (they get packed into the APK); write to /tmp.
2. **Button icons**: the user showed emblems (sword, Sudarshana Chakra, Devadatta medallion) for SLASH/ASTRA/DASH, but the files never reached disk. Ask for them via a GitHub release only if still wanted, otherwise draw simple icons.
3. **Menu**: the user's menu mockup has baked-in text with typos (RITHS, EXIT twice). Build Start/Options/Exit in code over calm art; crop the placeholder studio logos and App Store/Google Play badges out of key art copies.
4. Koka and Vikoka arena moment (fanfare, warning), difficulty tuning, on-foot chapters (Shambhala, Parashurama), more voice only as needed.
5. Verify canon refs once text sites are reachable (`docs/sources/CANON_INDEX.md` section 4).

## Credits spent so far (ElevenLabs)
About 1,000 credits (15 en lines + 5 hi + 5 te). Account: Creator tier, ~88k credits were left at the start of audio work.
