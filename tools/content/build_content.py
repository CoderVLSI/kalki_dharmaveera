"""Builds the campaign data files from the authoring modules. Run: python3 tools/content/build_content.py"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
ROOT = os.path.dirname(os.path.dirname(HERE))
import lines_a, lines_b, lines_c, ui_strings, missions_play, codex_data  # noqa: E402,F401


def load(p):
    with open(os.path.join(ROOT, p), encoding="utf-8") as f:
        return json.load(f)


def save(p, d):
    with open(os.path.join(ROOT, p), "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
        f.write("\n")


TIER = {"A": "canon", "B": "canon-adapted", "G": "invented"}

# ---- dialogue
dlg = load("data/dialogue.json")
for l in lines_a.LINES:
    dlg[l["id"]] = {"speaker": l["speaker"], "tier": TIER[l["tier"]], "ref": l["src"], "text": l["en"],
                    "source_tier": l["tier"], "locator": l["src"], "language": "en", "speech_type": l["st"],
                    "text_hi": l["hi"], "text_te": l["te"], "voiced_langs": []}
save("data/dialogue.json", dlg)

# ---- strings
st = load("data/strings.json")
extra = {
    "obj_talk_brhadratha": ("Speak with King Brhadratha", "राजा बृहद्रथ से बात करें", "రాజు బృహద్రథుడితో మాట్లాడండి"),
    "obj_talk_shushanta": ("Speak with Queen Shushanta", "रानी सुशान्ता से बात करें", "రాణి సుశాంతతో మాట్లాడండి"),
    "npc_narayana": ("Lord Narayana", "प्रभु नारायण", "శ్రీమన్నారాయణుడు"),
    "npc_shuka": ("Shuka", "शुक", "శుకుడు"),
}
for k, v in extra.items():
    ui_strings.S(k, *v)
for k, v in ui_strings.STRINGS.items():
    st[k] = v
save("data/strings.json", st)

# ---- enemies
en = load("data/enemies.json")
anim3 = {"idle": "idle", "walk": "walk", "run": "run"}
base = dict(tier="invented", flee_hp_frac=0.0, scale=1.0, lift=0.0, turn=180.0)
new = {
    "construct": dict(base, hp=45, speed=0.0, damage=0, notice=0, attack_range=0, windup=1.0, recover=1.0, dharma=2,
                      color=[0.55, 0.5, 0.45], model="prop_pillar", height=2.3, ai="still", anims={}, turn=0.0, tint_alpha=0.0,
                      name="Training pillar"),
    "android": dict(base, hp=70, speed=4.2, damage=8, notice=36, attack_range=20, preferred_range=11, windup=0.9, recover=1.9,
                    dharma=8, color=[0.3, 0.38, 0.5], model="char_robot", height=2.0, ai="ranged", anims=anim3, tint_alpha=0.18,
                    name="Iron soldier of Kali"),
    "guru": dict(base, tier="canon-adapted", hp=140, speed=5.0, damage=6, notice=60, attack_range=3.0, windup=0.8, recover=1.0,
                 dharma=20, color=[0.9, 0.7, 0.3], model="char_parashurama", height=2.1, anims=anim3, tint_alpha=0.0,
                 spar=True, yield_frac=0.4, name="Parashurama (practice)"),
    "king": dict(base, tier="canon-adapted", hp=120, speed=5.0, damage=6, notice=60, attack_range=3.0, windup=0.8, recover=1.0,
                 dharma=20, color=[0.9, 0.55, 0.15], model="char_ashwatthama", height=2.1, anims=anim3, tint_alpha=0.2,
                 spar=True, yield_frac=0.4, name="King Shashidhvaja"),
    "kuthodari": dict(base, tier="canon-adapted", hp=420, speed=4.2, damage=18, notice=80, attack_range=5.0, windup=1.1, recover=1.4,
                      dharma=30, color=[0.35, 0.2, 0.5], model="char_horned_warlord", height=3.6, anims=anim3, tint_alpha=0.4,
                      boss=True, aoe_radius=6.5, name="Kuthodari"),
    "vikanja": dict(base, tier="canon-adapted", hp=220, speed=5.6, damage=12, notice=80, attack_range=3.6, windup=0.8, recover=1.0,
                    dharma=18, color=[0.55, 0.35, 0.12], model="char_horned_warlord", height=2.5, anims=anim3, tint_alpha=0.35,
                    name="Vikanja"),
    "kali": dict(base, tier="canon-adapted", hp=700, speed=4.6, damage=20, notice=90, attack_range=5.5, windup=1.0, recover=1.3,
                 dharma=40, color=[0.12, 0.05, 0.22], model="char_kali", height=3.4, anims=anim3, tint_alpha=0.25,
                 boss=True, aoe_radius=7.0, name="Kali, the age"),
}
for k, v in new.items():
    en[k] = v
save("data/enemies.json", en)

# ---- codex
save("data/codex.json", {"entries": codex_data.ENTRIES})

# ---- missions
ms = load("data/missions.json")
for m in ms["missions"]:
    pid = m["id"]
    play = missions_play.PLAY.get(pid)
    if play is None:
        print("no play block for", pid)
        continue
    m["play"] = play
    if pid in missions_play.TITLES:
        m["title_hi"], m["title_te"] = missions_play.TITLES[pid]
    m["status"] = "playable"
save("data/missions.json", ms)

# ---- integrity checks
errs = []
for m in ms["missions"]:
    p = m.get("play", {})
    refs = list(p.get("intro", [])) + list(p.get("outro", []))
    for o in p.get("objectives", []):
        for k in ("pre", "post", "lines", "intro"):
            refs += o.get(k, [])
        if "prompt" in o:
            refs.append(o["prompt"])
        for op in o.get("options", []):
            refs += op.get("lines", [])
            if op["text"] not in st:
                errs.append("string " + op["text"])
        if o.get("text") and o["text"] not in st:
            errs.append("string " + o["text"])
        for kk in o.get("kinds", []):
            if kk not in en:
                errs.append("enemy " + kk)
        for w in o.get("waves", []):
            for g in w:
                if g["kind"] not in en:
                    errs.append("enemy " + g["kind"])
        if o.get("type") == "talk" and o["npc"] not in [n["id"] for n in p.get("npcs", [])]:
            errs.append("npc %s in %s" % (o["npc"], m["id"]))
    for n in p.get("npcs", []):
        if n.get("name", "npc_" + n["id"]) not in st:
            errs.append("npc name " + n.get("name", n["id"]))
    for r in refs:
        if r not in dlg:
            errs.append("line " + r)
used = set()
for m in ms["missions"]:
    p = m.get("play", {})
    used |= set(p.get("intro", [])) | set(p.get("outro", []))
    for o in p.get("objectives", []):
        for k in ("pre", "post", "lines", "intro"):
            used |= set(o.get(k, []))
        used |= {o["prompt"]} if "prompt" in o else set()
        for op in o.get("options", []):
            used |= set(op.get("lines", []))
unused = [l["id"] for l in lines_a.LINES if l["id"] not in used]
print("missions:", len(ms["missions"]), "lines:", len(lines_a.LINES), "strings:", len(st))
print("unused lines:", unused)
print("ERRORS:", sorted(set(errs)))
