# Kalki Dharmaveera: Game Plan

> Working title: **Kalki Dharmaveera** (the dharma-hero Kalki).
> Premise: Bhagavan Kalki, the tenth avatar of Vishnu, rides out from Shambhala at the end of Kali Yuga, destroys the **Mlechha** hosts of adharma, and re-establishes **Satya Yuga**.
> Status: **Draft v0.1. For your review before any implementation starts.**

---

## 0. How to read this plan

- Sections 1 to 3 are the creative spine: vision, source rules, and the canon map.
- Sections 4 to 6 are the game: story, fictional additions, and rule-based systems.
- Sections 7 to 10 are production: toolchain, 3D model hand-off, voice, repo layout.
- Sections 11 and 12 are milestones and the questions I need you to answer.
- Anything marked **[VERIFY]** is from memory and must be checked against the actual text before it goes into the game. I will not put an unchecked verse reference into player-facing content.

---

## 1. Vision

**One-line pitch:** A third-person, mythic action game where you play Kalki, from a boy in Shambhala to the Sword-Bearer who ends the Kali Yuga. The world visibly turns from grey Kali-Yuga ruin to golden Satya Yuga as you win.

**Design pillars**

1. **Dharma is the mechanic.** The game's core loop is restoring dharma, not just killing enemies. Combat, exploration, and dialogue all push the same *Dharma meter* upward.
2. **The world shows your progress.** Each region has an *Adharma* state and a *Dharma* state: sky, palette, music, foliage, NPC behavior. Liberating a region changes it on screen.
3. **Scripture-first, fiction-second.** Every main-story beat is traceable to a source. Invented content fills gaps, is clearly tagged as invented, and never contradicts canon.
4. **Rule-based and coded.** The game logic is deterministic and data-driven (state machines, rule tables, resource files). There is no generative AI at runtime. See section 6.
5. **Small enough to finish.** Vertical slice first, then chapters. We deliberately keep the scope modest ("or else the game will not be too big," as you said), and use fiction to *compress* the epic into a playable length.

**Target:** PC (Windows/Linux) first, Godot 4 export. Web or Android is a stretch goal after the slice works.

---

## 2. Ground rules for sources and sensitivity

### 2.1 Canon tiers

Every piece of content in the game is tagged with one of three tiers in its data file:

| Tier | Meaning | Example |
|---|---|---|
| `canon` | Directly stated in a cited text | Kalki is born to Vishnuyasha in Shambhala |
| `canon-adapted` | Stated in a text, but compressed, reordered, or dramatized to be playable | A battle that the text covers in a few verses becomes a level |
| `invented` | Our fiction. Must not contradict `canon` | A named region, a side character, a puzzle |

The in-game *Codex* shows the tier to the player, so we are honest about what is scripture and what is ours.

### 2.2 The "Mlechha" question (design guardrail)

"Mlechha" is an old Sanskrit word that, in scripture, is used for people who have abandoned dharma and conduct themselves as oppressors. In the modern world it has been misapplied to real communities. To keep the game faithful to the *scriptural idea* and avoid pointing at any real-world ethnic or religious group:

- In the game, **Mlechhas are defined by conduct, not by identity**: rulers and hosts who plunder, deceive, and oppress, as the Bhagavata describes kings who "behave like thieves" in Kali Yuga (Bhagavata 12.1-12.2 **[VERIFY]**).
- Their look, language, and banners are **fictional** (our own design language), not borrowed from any real culture or faith.
- They are explicitly shown as the **retinue of Kali** (see 3.2), the personified force of adharma, which is how the Kalki Purana frames the war.

This also makes the game better: the enemy is vice and tyranny, which is a stronger theme than "a foreign army."

### 2.3 Texts and copyright

- We work from the **Sanskrit originals** and **public-domain translations** (for example H. H. Wilson's 1840 *Vishnu Purana*, and older public-domain *Bhagavata* translations). Where a modern translation is the only convenient source, we **read it for understanding and paraphrase**, never copy it into the game.
- Sanskrit verses may be quoted as *shlokas* in the Codex and voiced in audio. The English text in the game is our own wording.
- Source notes live in `docs/sources/` (one file per text, with chapter and verse refs, and what we took from it).

---

## 3. Canon map

### 3.1 Source corpus

| Source | Role | Notes |
|---|---|---|
| **Kalki Purana** (an Upapurana, three parts, ~36 chapters) | **Primary** spine for story, characters, wife, weapons, battles | Gives the full life of Kalki; the richest narrative source |
| **Bhagavata Purana** | Birth, Shambhala, horse Devadatta, the sword, and the restoration of Satya Yuga (12.2) **[VERIFY]**; Dharma as a four-legged bull (1.17) **[VERIFY]** | Strongest "mythic tone" source |
| **Vishnu Purana** | Kali Yuga description (Book 6, ch. 1) and Kalki's coming (Book 4, ch. 24) **[VERIFY]** | Public-domain Wilson translation is easy to work from |
| **Agni Purana** | Short avatar narration including Kalki (ch. 16) **[VERIFY]** | Useful for iconography and weapons |
| **Garuda, Matsya, Vayu, Brahmanda, Linga, Padma, Skanda, Brahma Vaivarta, others** | Supporting mentions of Kalki, Vishnuyasha, and the end of the yuga | I will sweep **all 18 Mahapuranas** and record each hit, or its absence, in `docs/sources/` |
| **Mahabharata, Vana Parva (Markandeya's prophecy)** | Optional extra, an early "Kalki Vishnuyasha" passage **[VERIFY]** | Not one of the 18, so only used if you approve |

**Deliverable of the research phase:** `docs/sources/CANON_INDEX.md`, a table of *every* Kalki mention across the 18 Mahapuranas and the Kalki Purana, with reference, a one-line summary, and whether the game uses it.

### 3.2 Key canon elements we intend to use

*(All details to be confirmed during the research phase, **[VERIFY]**.)*

- **Birth:** Shambhala village; father **Vishnuyasha**, mother **Sumati**; elder brothers **Kavi, Prajna, Sumantra** (Kalki Purana).
- **Training:** under **Parashurama** (a Chiranjivi), who instructs him in the Vedas and arms and sends him to worship **Shiva**; Shiva grants him the divine **sword**, the **parrot Shuka** (who carries messages and knows all languages), and the white horse **Devadatta**.
- **Marriage:** **Padmavati / Padma**, princess of **Simhala**, who is an ally of the dharma side, not a damsel.
- **Antagonist:** **Kali**, the personified Age of Strife, with a family of vices (**Dambha** pride, **Lobha** greed, **Krodha** wrath, **Bhaya** fear, **Mrityu** death, and so on) and the demon brothers **Koka and Vikoka**.
- **Dharma's four pillars** (Bhagavata 1.17 **[VERIFY]**): tapas (austerity), shaucha (purity), daya (compassion), satya (truth). Kali Yuga has broken them. Restoring them is our progression system.
- **Ending:** Kali is defeated; Satya Yuga returns; the sages **Devapi and Maru** re-seed the dynasties (Bhagavata 12.2 **[VERIFY]**).

---

## 4. Story structure (chapters)

Six chapters plus a prologue and epilogue. Each lists its canon basis and the gameplay it teaches.

| # | Chapter | Basis | What the player does |
|---|---|---|---|
| 0 | **Prologue: The Fall of Dharma** | Vishnu Purana 6.1, Bhagavata 12.2 | Short narrated cutscene: the Dharma-bull stands on one leg. Sets the tone and teaches nothing mechanical. |
| 1 | **Shambhala** | Kalki Purana, Part 1 | Boyhood tutorial: movement, interaction, talking to the village, first practice-sword lessons. |
| 2 | **The Ashram of Parashurama** | Kalki Purana | Training montage as gameplay: combat basics, the four trials of the pillars, and receiving the sword. |
| 3 | **The Boon of Shiva** | Kalki Purana | A pilgrimage and puzzle chapter. You earn Devadatta and Shuka, which unlock mounted travel and scouting. |
| 4 | **Simhala** | Kalki Purana | Meet Padma. Companion mechanics; a siege-defence set piece. |
| 5 | **The March on Kali's Host** | Kalki Purana + Bhagavata 12.2 | Open-field battles, mounted combat, Koka and Vikoka as boss fights. Regions flip from Adharma to Dharma. |
| 6 | **The Citadel of Kali** | Kalki Purana | Climb through the vices (Dambha, Lobha, Krodha, ...) as mini-bosses, then the final fight with Kali. |
| 7 | **Epilogue: Satya Yuga** | Bhagavata 12.2 | The world fully golden; Devapi and Maru appear. A quiet, free-roam closing scene. |

Chapter order and exact content can shift once the Kalki Purana pass is done.

---

## 5. Fictional additions (explicit register)

We add fiction for three reasons: to make levels, to keep the scope small, and to give the player agency. All of it is tagged `invented`.

- **Named regions between canon locations** (travel stages, hub villages) so each chapter has a playable space.
- **Side characters:** villagers, a blacksmith, ex-soldiers who defect from Kali's host, dharma-allies who join as *Companions*.
- **Mlechha war-bands:** original unit types (see 6.4) with fictional banners and names.
- **Trial levels** for the four pillars (tapas, shaucha, daya, satya), which are our own puzzle and combat challenges built around canonical concepts.
- **Compression:** the Kalki Purana's many battles are consolidated into a handful of boss and set-piece encounters.

**Rule:** invented content may *add*, never *contradict*. If a canon passage conflicts with an invented one, canon wins.

---

## 6. Gameplay systems (coded and rule-based)

You asked for the game to be **coded and rule-based**. I read that as: all behavior is explicit, deterministic code and data, not runtime machine learning or a generative model. If you meant something different, tell me and I will adjust.

### 6.1 Principles

- **Data over code for content:** enemies, dialogue, quests, codex entries, and stat tables are Godot `Resource` files or JSON, so you can edit them without touching scripts.
- **State machines everywhere:** player, enemies, bosses, NPCs, and the quest flow are explicit finite state machines (FSMs) or behavior trees.
- **Seeded randomness only:** anything random uses a seeded RNG, so bugs reproduce.
- **No runtime network calls.** Voice lines are pre-generated (section 9) and shipped as audio files.

### 6.2 Core loop

```
Explore  ->  Encounter adharma (enemies / a corrupted place / a moral choice)
   ->  Act with dharma (fight, spare, protect, speak truth)
   ->  Dharma meter rises  ->  Region flips from Adharma to Dharma state
   ->  New ability / companion / area unlocked
```

### 6.3 Player systems

- **Movement and camera:** third-person, with dodge, sprint, and a mounted mode on Devadatta.
- **Combat:** light and heavy sword strikes, parry, and dodge, in a readable rule-based system (frame data stored in resources). The sword has a charge-up *Astra* special.
- **Shuka (parrot):** scout and hint mechanic. Marks enemies, reveals paths, and carries the voice of the narrator.
- **Dharma meter and the four pillars:** satya, tapas, daya, shaucha. Each pillar is a skill branch that is unlocked by completing its trial and by in-world choices.
- **Companions:** Padma and defectors with simple, rule-driven commands.

### 6.4 Enemy design

| Enemy class | Behavior (rule-based) |
|---|---|
| Foot raider | Chase and melee FSM: patrol, notice, engage, flee at low health |
| Archer | Keeps distance, fires on line of sight, repositions when approached |
| Banner-bearer | Buffs nearby enemies; kill it first |
| Mounted raider | Charge, break away, charge again |
| **Vice mini-bosses** (Dambha, Lobha, Krodha, ...) | Each is a puzzle-fight themed on its vice: pride is broken by humility, greed by refusing the bait, and so on |
| **Koka and Vikoka** | Paired boss; must be separated |
| **Kali** | Multi-phase final boss; each phase restores one pillar |

### 6.5 The world-state rule table

A single `WorldState` resource tracks the Dharma level per region. A rule table maps thresholds to presentation changes: skybox, fog colour, music layer, foliage and prop swaps, NPC idle sets. Same data drives the loading hints and the Codex.

---

## 7. Toolchain

### 7.1 Engine and language

- **Godot 4.x (latest stable)**, 3D, **GDScript**. Exports glTF/GLB straight from Blender.
- **Blender (LTS)** for modelling, rigging, and animation.

### 7.2 MCP servers (so Claude can drive the tools)

| Tool | MCP server | Purpose |
|---|---|---|
| Godot | A Godot MCP server (candidates: `Coding-Solo/godot-mcp` and similar) | Launch the editor/project, run scenes, read debug output, create and edit scenes and scripts |
| Blender | `ahujasid/blender-mcp` (run through `uvx blender-mcp`) plus its Blender add-on | Create and modify objects, materials, lighting, and export from natural-language instructions |

Both will be wired through a project-level `.mcp.json` so the setup is reproducible.

**Honest constraints:**

- This Claude session runs in a **cloud container with no display or GPU**. Godot can run **headless** (import, script checks, tests, export) and Blender can run **in background mode**, but **interactive editing and visual playtesting must happen on your machine.** I can still do the code, scene files, and pipeline work here.
- The Blender MCP expects a running Blender with its add-on listening on a local socket. In a headless container this needs a background-mode launcher script. I will try it and report back.
- MCP servers are installed in the *session* environment. Because the container is ephemeral, I will add a **`tools/setup_env.sh`** script so the whole setup can be rebuilt in one command.

### 7.3 Voice

- **ElevenLabs** (your "element lab"), via the text-to-speech API, used **offline at build time** from a script, with the output audio committed to the repo.
- The API key is **never committed**. It lives in an environment variable (`ELEVENLABS_API_KEY`) or a git-ignored `.env`.

---

## 8. 3D model hand-off (Kalki)

You will upload the Kalki model to the repo. To save a round of conversion, please follow this spec:

**Where to put it:** `assets/source/kalki/` (create it in the repo; a `.gitkeep` and `README.md` are provided there).

| Item | Preferred | Also fine |
|---|---|---|
| Format | **`.glb`** (glTF binary) | `.fbx`, `.blend`, `.gltf` + textures |
| Orientation and scale | Y-up, 1 unit = 1 metre, ~1.8 m tall, facing +Z (Blender: -Y forward on export) | Anything; I can fix it in Blender |
| Pose | T-pose or A-pose, in the rest pose | |
| Rig | Humanoid skeleton (Rigify, Mixamo naming, or Godot-compatible) | Unrigged: I can rig it with Blender |
| Materials | PBR (base colour, normal, roughness/metallic) with 2K textures | |
| Poly budget | Hero character up to ~50k triangles | Higher is fine; I can make LODs |
| Extras | Separate meshes for sword, crown/ornaments, and cloth if possible | Single mesh is fine |

Also useful if you have them: the **horse Devadatta** and **Shuka the parrot**; otherwise I will block them out in Blender with the MCP and you can replace them later.

**File size:** GitHub rejects single files over 100 MB. If the model is bigger, we will turn on **Git LFS** for `*.glb`, `*.fbx`, `*.blend`, and large textures. I'll set that up on request. I have not enabled it yet, to avoid breaking your first push if LFS isn't installed on your side.

---

## 9. Voice pipeline (ElevenLabs)

1. **Script:** all dialogue and narration lives in `data/dialogue/*.json` with a speaker ID, a line ID, the text (English, optionally Hindi and Sanskrit), the canon tier, and emotion and delivery notes.
2. **Voice cast:** one ElevenLabs voice per major speaker (Narrator, Kalki, Parashurama, Padma, Shuka, Kali, villains). Voice IDs are stored in `data/voices.json`. You choose or clone voices from the ElevenLabs library.
3. **Generation:** `tools/gen_voice.py` reads the dialogue files, calls the API, and writes `assets/audio/voice/<speaker>/<line_id>.mp3` (or `.ogg`). It is **idempotent**: it only regenerates lines whose text or voice changed (tracked by a content hash in `assets/audio/voice/manifest.json`).
4. **Playback:** the game looks up audio by line ID. Missing audio falls back to subtitles only, so the game is always playable without the voice assets.
5. **Sanskrit shlokas:** TTS Sanskrit is unreliable. For key verses I recommend either a recorded human reading or IAST/phoneme hints reviewed by someone fluent. We should decide this per verse.
6. **Subtitles:** always on by default; Hindi and Sanskrit lines show Devanagari and a translation.

**Cost note:** ElevenLabs bills per character. The manifest and the "only regenerate changed lines" rule keep this low.

---

## 10. Repository layout (proposed)

```
kalki_dharmaveera/
├── PLAN.md                  <- this file
├── README.md
├── .mcp.json                <- Godot + Blender MCP config
├── .gitignore               <- .godot/, .env, exports, caches
├── project.godot            <- Godot 4 project
├── assets/
│   ├── source/              <- raw uploads (e.g. kalki/ model from you)
│   ├── models/              <- cleaned, game-ready .glb
│   ├── audio/{voice,music,sfx}/
│   └── textures/
├── data/                    <- rule tables, dialogue, enemies, codex (JSON/Resources)
├── scenes/                  <- .tscn
├── scripts/                 <- GDScript (FSMs, systems)
├── tests/                   <- headless GDScript tests
├── tools/                   <- setup_env.sh, gen_voice.py, export scripts
└── docs/
    ├── sources/             <- CANON_INDEX.md + per-text notes
    └── design/
```

---

## 11. Milestones

| M | Name | Output | Done when |
|---|---|---|---|
| M0 | **Plan and environment** | `PLAN.md`, tool install scripts, `.mcp.json` | You approve the plan; Godot and Blender MCP answer a smoke test |
| M1 | **Canon research** | `docs/sources/CANON_INDEX.md` and per-text notes | Every Kalki mention in the 18 Mahapuranas and the Kalki Purana is indexed, and chapter outline v2 is written |
| M2 | **Kalki in-engine** | Your model imported, rigged, and standing in a Godot test scene | Kalki walks, runs, and swings the sword in a grey box level |
| M3 | **Vertical slice**: *Shambhala to Parashurama* | One polished playable chapter with combat, one Dharma-flip region, and voiced narration | A 15 to 20 minute playthrough, start to finish |
| M4 | **Mounted + Shuka + Simhala** | Devadatta, parrot scouting, Padma | Chapters 3 and 4 playable |
| M5 | **March and Citadel** | Chapters 5 and 6, vice bosses, Kali | Full game playable, rough |
| M6 | **Polish and Satya Yuga** | Epilogue, music, VFX, balance, bug-fixing | Release candidate |

Each milestone ends with a commit on the working branch and a short written status.

---

## 12. Open questions for you

1. **Rule-based:** does my reading in section 6 (deterministic, data-driven, no runtime AI) match what you meant?
2. **Camera and style:** third-person action (as planned), or something different (for example top-down, or side-scrolling)?
3. **Art direction:** realistic, stylized/painterly, or inspired by classical Indian art? This decides how we treat your model and the environments.
4. **Languages:** English voice only to begin with, or also Hindi and Sanskrit shlokas from the start?
5. **Platform:** PC only for now?
6. **Mahabharata:** include the Vana Parva Kalki passage as an extra source?
7. **ElevenLabs:** do you already have an account and API key? Which voices do you want?
8. **Is the 3D model already rigged?** And how large are the files (is Git LFS needed)?

---

## 13. Immediate next steps

1. Commit this plan to the repo. **(this commit)**
2. Install Godot, the Godot MCP, Blender, and the Blender MCP in the session environment, and commit a reproducible `tools/setup_env.sh` and `.mcp.json`.
3. You upload the Kalki model to `assets/source/kalki/`.
4. I begin M1 (canon research) in parallel with M2 (importing the model).
