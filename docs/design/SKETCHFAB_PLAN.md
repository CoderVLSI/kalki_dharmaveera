# Plan: sourcing 3D assets from Sketchfab

**Status:** blocked on two things only the account owner can change (see "Unblock"). Everything else is ready: `tools/sketchfab_fetch.py` does search + download + attribution once unblocked.
Probe on 8 Oct 2026: `sketchfab.com` is reachable, but `api.sketchfab.com`, `media.sketchfab.com`, `static.sketchfab.com`, `cdn.sketchfab.com` return 403 from the sandbox, and the site's search page is a JavaScript shell that returns no model data without the API.

## 1. What we need (priority order)
| # | Asset | Why | Search ideas | Acceptance |
|---|---|---|---|---|
| 1 | **Standing humanoid warrior** (rigged, with walk/run/attack) | on-foot Kalki, companions, and real enemy models | `rigged warrior sword`, `indian warrior`, `prince armor` | Humanoid skeleton, animations present, <= 30k tris, CC0/CC-BY |
| 2 | **Enemy soldiers** (2-3 variants, rigged) | replace capsule placeholders for Kali's host | `rigged soldier`, `demon warrior`, `raider` | animated, distinct silhouettes, <= 15k tris |
| 3 | **Temples / ruins / gateway** | Shambhala, Simhala, Kali's citadel set pieces | `hindu temple low poly`, `stone ruins`, `shikhara` | CC0/CC-BY, <= 20k tris each |
| 4 | **Environment props** (banners, torches, pillars, dead trees, lotus, stupa) | dressing; dead/alive pairs for the Dharma flip | `war banner`, `dead tree`, `lotus` | <= 5k tris each |
| 5 | **Weapons** (Ratnamaru-style sword, chakra, conch, mace) | separate sword for on-foot Kalki, pickups | `curved sword jeweled`, `sudarshana chakra` | PBR, <= 8k tris |
| 6 | **Horse** (rigged, animated) *optional* | a separate Devadatta if we split rider from horse | `rigged horse animated` | gallop/idle/rear anims |

Rule of thumb: the phone build must stay under ~60 MB, so prefer low-poly and 1K textures; we decimate and shrink anyway (`tools/blender/prep_static.py`).

## 2. Licence rules
- Only **CC0** and **CC-BY** (and CC-BY-SA only if you accept share-alike). **No** NC or ND licences (a game is a commercial-capable product; ND forbids modification).
- Every CC-BY asset needs credit. `sketchfab_fetch.py` appends author, title, URL and licence to `docs/ATTRIBUTION.md` and the game's credits screen reads it.
- Sketchfab **Store** (paid) models are out of scope. AI-generated models: check the per-model licence anyway.
- Use the **official Data API** with your own token. No scraping.

## 3. Unblock (you do this once)
1. **Network allowlist** for the cloud environment: `api.sketchfab.com`, `media.sketchfab.com`, `static.sketchfab.com`, `cdn.sketchfab.com` (also `sketchfab-prod-media.s3.amazonaws.com`, already reachable).
2. **API token:** create it at sketchfab.com > Settings > Password & API, then add it to the environment secrets as `SKETCHFAB_API_TOKEN`. Never paste it into chat or commit it.

A new session is not required after changing the allowlist (the main site became reachable mid-session when you added it).

**Fallback without the API:** download models in your browser (Download > glTF), zip them, and attach them to a GitHub release like `kalki` and `narayana`; I import them from there.

## 4. Pipeline once unblocked
1. `python3 tools/sketchfab_fetch.py search "rigged warrior" --animated --max-faces 30000` lists candidates (name, uid, licence, faces, animated).
2. You approve uids (I never download a model nobody has shortlisted).
3. `python3 tools/sketchfab_fetch.py get <uid>` downloads the glTF zip to `assets/source/sketchfab/<uid>/` (git-ignored), records attribution.
4. Blender: `tools/blender/prep_static.py` (decimate, 1K textures) or a rig-retarget script for characters.
5. Godot: import, test in the animation panel, add to `data/` rule tables. Rebuild the APK.

## 5. Budget and risk
- Cost: free (no credits).
- Biggest risk is rigging mismatches (bone names/scales), solved by retargeting in Blender onto our own skeleton.
- Second risk is APK size, solved by the poly and texture budgets above.
