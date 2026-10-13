# Playable definitions for M00-M17: the `play` block merged into data/missions.json.
# Coordinates are [x, z]; the player starts near (0, +30) and the story walks toward -z.


def ids(pre, *nums):
    return ["%s_%d" % (pre, n) for n in nums]


def npc(id_, slot, pos, h=1.8, standin=False, tint=None, face=None, name=None, **kw):
    d = {"id": id_, "slot": slot, "pos": pos, "h": h, "face": face or [0, 20]}
    if standin:
        d["standin"] = True
    if tint:
        d["tint"] = tint
    if name:
        d["name"] = name
    d.update(kw)
    return d


def talk(npc_id, text, lines, **kw):
    d = {"type": "talk", "npc": npc_id, "text": text, "lines": lines}
    d.update(kw)
    return d


def reach(pos, text, r=4.0, **kw):
    d = {"type": "reach", "pos": pos, "text": text, "r": r}
    d.update(kw)
    return d


def defeat(text, waves, **kw):
    d = {"type": "defeat", "text": text, "waves": waves}
    d.update(kw)
    return d


def grp(kind, n, radius=22.0):
    return {"kind": kind, "n": n, "radius": radius}


YOUTH = 1.55          # stand-in for the 12-14 year old Kalki until the teen model arrives


def fire(pos):
    return {"model": "prop_candi", "pos": pos, "scale": 1.2}


PLAY = {}

# M00 -- vision of the corrupt age
PLAY["M00"] = {
    "biome": "shambhala", "mode": "foot", "dharma": 8, "start": [0, 30], "bounds": 100, "shuka": False,
    "world": {"village": False, "pillars": False, "props": [
        {"model": "prop_hut_b", "pos": [-22, -10], "scale": 1.4}, {"model": "prop_hut_b", "pos": [26, -26], "scale": 1.4}]},
    "npcs": [npc("refugee", "yajnavalkya", [-4, 8], 1.7, standin=True, tint=[0.45, 0.35, 0.25, 0.4], name="npc_refugee")],
    "intro": ids("m00", 1, 2),
    "objectives": [
        talk("refugee", "obj_talk_refugee", ids("m00", 3, 4, 5)),
        reach([0, -34], "obj_toll", 4.5),
        defeat("obj_tollkeepers", [[grp("raider", 3)], [grp("raider", 2), grp("archer", 1)]], pre=["m00_6"]),
    ],
    "outro": ["m00_7"],
}

# M01 -- Narayana's vow to the gods (existing cinematic prologue)
PLAY["M01"] = {"cine": "prologue"}

# M02 -- the house in Shambhala
PLAY["M02"] = {
    "biome": "shambhala", "mode": "foot", "dharma": 55, "start": [0, 24], "bounds": 90, "shuka": False, "player_h": YOUTH,
    "world": {"props": [{"model": "prop_hut_b", "pos": [-14, -4], "scale": 1.6}, fire([0, -30])]},
    "npcs": [
        npc("vishnuyashas", "vishnuyashas", [8, -4], 1.75, name="npc_vishnuyashas"),
        npc("sumati", "ramadevi", [-8, -6], 1.65, standin=True, tint=[0.9, 0.8, 0.5, 0.18], name="npc_sumati"),
    ],
    "intro": ["m02_1"],
    "objectives": [
        talk("vishnuyashas", "obj_talk_father", ids("m02", 2, 3, 4)),
        talk("sumati", "obj_talk_mother", ids("m02", 5, 6)),
        reach([0, -28], "obj_naming", 4.0, post=ids("m02", 7, 8)),
    ],
    "outro": ["m02_9"],
}

# M03 -- Mahendra gurukula
PLAY["M03"] = {
    "biome": "mahendra", "mode": "foot", "dharma": 60, "start": [0, 28], "bounds": 100, "shuka": False, "player_h": YOUTH,
    "world": {"village": False, "pillars": False},
    "npcs": [npc("parashurama", "parashurama", [0, 2], 2.0, name="npc_parashurama")],
    "intro": ["m03_1"],
    "objectives": [
        talk("parashurama", "obj_talk_guru", ids("m03", 2, 3)),
        defeat("obj_pillars", [[{"kind": "construct", "n": 4, "radius": 12}]]),
        defeat("obj_astra", [[{"kind": "construct", "n": 3, "radius": 30}]], pre=["m03_4"]),
        defeat("obj_spar", [[{"kind": "guru", "n": 1, "radius": 14}]], pre=["m03_5"], post=["m03_6"], hide_npc="parashurama", npc_at=True),
        reach([0, -62], "obj_shrine", 4.5, pre=["m03_7"], post=["m03_8"]),
    ],
    "outro": [],
}

# M04 -- the three gifts
PLAY["M04"] = {
    "biome": "shrine", "mode": "foot", "dharma": 60, "start": [0, 28], "bounds": 100, "shuka": False,
    "world": {"village": False, "pillars": False, "props": [
        {"model": "prop_temple_wall", "pos": [0, -24], "scale": 1.6}, {"model": "prop_bell", "pos": [-8, -16], "scale": 1.2}]},
    "npcs": [npc("shiva", "shiva", [0, -16], 2.3, name="npc_shiva"), npc("parvati", "parvati", [5, -16], 2.0, name="npc_parvati")],
    "intro": ["m04_1"],
    "objectives": [
        reach([0, -2], "obj_approach", 4.0),
        talk("shiva", "obj_talk_shiva", ids("m04", 2, 3, 4, 5)),
        {"type": "cutscene", "effect": "gift", "lines": ["m04_6"]},
        {"type": "mount", "text": "obj_mount", "post": ["m04_7"]},
        {"type": "rings", "text": "obj_rings", "pre": ["m04_8"], "points": [[0, -4], [-14, -22], [14, -42], [-10, -64], [0, -84]], "r": 5.0},
    ],
    "outro": [],
    "grant": ["has_sword", "has_horse", "has_shuka"],
}

# M05 -- Mahishmati and Shuka's scouting
PLAY["M05"] = {
    "biome": "court", "mode": "mounted", "dharma": 62, "start": [0, 40], "bounds": 130,
    "world": {"props": [{"model": "prop_temple_wall", "pos": [0, -50], "scale": 2.0}]},
    "npcs": [npc("vishakhayupa", "ashwatthama", [0, -56], 2.0, standin=True, tint=[0.9, 0.75, 0.3, 0.2], name="npc_vishakhayupa")],
    "intro": ["m05_1"],
    "objectives": [
        reach([0, -40], "obj_gate_mahishmati", 6.0),
        talk("vishakhayupa", "obj_talk_vish", ["m05_2"]),
        {"type": "cutscene", "effect": "scout", "text": "obj_scout", "lines": ids("m05", 3, 4, 5),
         "path": [[30, -70], [70, -120], [30, -170], [-30, -130], [0, -60]]},
    ],
    "outro": ["m05_6"],
}

# M06 -- Simhala and the lotus
PLAY["M06"] = {
    "biome": "simhala", "mode": "foot", "dharma": 70, "start": [0, 30], "bounds": 100,
    "world": {"props": [fire([0, -52]), {"model": "prop_temple_wall", "pos": [0, -20], "scale": 1.8}]},
    "npcs": [
        npc("padmavati", "padmavati", [0, -10], 1.75, name="npc_padmavati"),
        npc("brhadratha", "vishnuyashas", [10, -44], 1.8, standin=True, tint=[0.4, 0.5, 0.9, 0.25], name="npc_brhadratha"),
    ],
    "intro": ["m06_1"],
    "objectives": [
        talk("padmavati", "obj_talk_padma", ids("m06", 2, 3, 4)),
        {"type": "collect", "text": "obj_lotus", "items": [[-22, -22], [24, -30], [-14, -48]], "gain": 3},
        talk("brhadratha", "obj_talk_brhadratha", ["m06_5"]),
        {"type": "rings", "text": "obj_fire", "pre": ["m06_6"], "points": [[5, -52], [0, -57], [-5, -52], [0, -47]], "r": 2.6},
    ],
    "outro": ["m06_7"],
}

# M07 -- the teaching of Ananta (a parable, no combat)
PLAY["M07"] = {
    "biome": "vision", "mode": "foot", "dharma": 70, "start": [0, 18], "bounds": 70, "shuka": False,
    "world": {"village": False, "pillars": False, "mountains": False, "trees": False, "constant_sky": True},
    "npcs": [npc("ananta", "vyasa", [0, -8], 2.0, standin=True, name="npc_ananta")],
    "intro": ["m07_1"],
    "objectives": [
        talk("ananta", "obj_talk_ananta", ["m07_2"]),
        {"type": "choice", "text": "obj_choice", "prompt": "m07_3", "options": [
            {"text": "opt_m07_a", "lines": ["m07_4"]},
            {"text": "opt_m07_c", "lines": ["m07_5"]},
            {"text": "opt_m07_b", "lines": ["m07_6"], "correct": True},
        ]},
        reach([0, -44], "obj_lotus_white", 3.5, pre=["m07_7"]),
    ],
    "outro": [],
}

# M08 -- back to Shambhala
PLAY["M08"] = {
    "biome": "shambhala", "mode": "foot", "dharma": 72, "start": [0, 30], "bounds": 90,
    "world": {"props": [{"model": "prop_hut_b", "pos": [-16, -10], "scale": 1.6}, fire([0, -44])]},
    "npcs": [
        npc("vishnuyashas", "vishnuyashas", [8, -4], 1.75, name="npc_vishnuyashas"),
        npc("padmavati", "padmavati", [-6, -8], 1.75, name="npc_padmavati"),
        npc("yajnavalkya", "yajnavalkya", [14, -22], 1.8, name="npc_yajnavalkya"),
    ],
    "intro": ["m08_1"],
    "objectives": [
        talk("vishnuyashas", "obj_talk_father", ["m08_2"], flags=["boon_father"]),
        talk("padmavati", "obj_talk_padma", ["m08_3"], flags=["boon_lotus"]),
        talk("yajnavalkya", "obj_talk_rishi", ["m08_4"]),
        reach([0, -42], "obj_council", 4.0, pre=["m08_5"]),
    ],
    "outro": ["m08_6"],
}

# M09 -- Kikata, a disputed account: the codex comes first
PLAY["M09"] = {
    "biome": "shrine", "mode": "foot", "dharma": 70, "start": [0, 28], "bounds": 100,
    "npcs": [
        npc("yajnavalkya", "yajnavalkya", [0, 4], 1.8, name="npc_yajnavalkya"),
        npc("refugee", "vishnuyashas", [-6, -26], 1.75, standin=True, tint=[0.5, 0.4, 0.3, 0.4], name="npc_refugee"),
    ],
    "intro": ["m09_1"],
    "objectives": [
        {"type": "codex", "entry": "kikata", "text": "obj_codex"},
        talk("yajnavalkya", "obj_talk_rishi", ["m09_2"]),
        talk("refugee", "obj_talk_refugee", ["m09_3"]),
        defeat("obj_pilgrims", [[grp("raider", 3, 20)], [grp("raider", 2, 20), grp("archer", 2, 26)]], post=["m09_4"]),
    ],
    "outro": [],
}

# M10 -- the giantess of the north
PLAY["M10"] = {
    "biome": "himalaya", "mode": "mounted", "dharma": 62, "start": [0, 34], "bounds": 140,
    "npcs": [npc("yajnavalkya", "yajnavalkya", [0, 18], 1.8, name="npc_yajnavalkya")],
    "intro": ["m10_1"],
    "objectives": [
        talk("yajnavalkya", "obj_talk_rishi", ["m10_2"]),
        {"type": "rings", "text": "obj_ascend", "pre": ["m10_3"], "r": 6.0,
         "points": [[0, -10], [20, -40], [-10, -70], [14, -100], [0, -120]]},
        {"type": "boss", "text": "obj_kuthodari", "kinds": ["kuthodari", "vikanja"], "dist": 26, "intro": ids("m10", 4, 5)},
        {"type": "cutscene", "effect": "brahmastra", "lines": ids("m10", 6, 7)},
    ],
    "outro": ["m10_8"],
}

# M11 -- the two dynasties
PLAY["M11"] = {
    "biome": "kalapa", "mode": "mounted", "dharma": 62, "start": [0, 36], "bounds": 130,
    "npcs": [
        npc("devapi", "vyasa", [-9, -22], 1.95, standin=True, tint=[0.7, 0.8, 1.0, 0.2], name="npc_devapi"),
        npc("maru", "ashwatthama", [9, -22], 2.0, standin=True, tint=[1.0, 0.8, 0.4, 0.2], name="npc_maru"),
    ],
    "intro": ["m11_1"],
    "objectives": [
        reach([0, -8], "obj_reach_kalapa", 6.0),
        talk("devapi", "obj_talk_devapi", ["m11_2"]),
        talk("maru", "obj_talk_maru", ids("m11", 3, 4, 5)),
        defeat("obj_defend_road", [[grp("raider", 3, 26)], [grp("raider", 3, 26), grp("archer", 2, 30)]]),
        {"type": "cutscene", "effect": "chariot", "lines": ["m11_6"]},
    ],
    "outro": ["m11_7"],
}

# M12 -- Dharma without a throne
PLAY["M12"] = {
    "biome": "kalapa", "mode": "foot", "dharma": 35, "start": [0, 30], "bounds": 110, "dharma_ui": True,
    "npcs": [
        npc("dharma", "vyasa", [-7, -2], 1.95, standin=True, tint=[0.6, 0.6, 0.6, 0.35], name="npc_dharma"),
        npc("krita", "lakshmi", [7, -2], 1.8, standin=True, tint=[1.0, 0.9, 0.5, 0.3], name="npc_krita"),
    ],
    "intro": ["m12_1"],
    "objectives": [
        talk("dharma", "obj_talk_dharma", ["m12_2"]),
        talk("krita", "obj_talk_krita", ["m12_3"]),
        defeat("obj_patrol", [[grp("android", 3, 24)], [grp("android", 3, 26)]], pre=["m12_4"], post=["m12_5"], dharma=45),
        reach([0, -70], "obj_march", 5.0),
    ],
    "outro": ["m12_6"],
}

# M13 -- the siege of Visasana
PLAY["M13"] = {
    "biome": "visasana", "mode": "foot", "dharma": 20, "start": [0, 40], "bounds": 110, "dharma_ui": True,
    "world": {"props": [{"model": "prop_temple_wall", "pos": [0, -40], "scale": 2.4}]},
    "intro": ["m13_1"],
    "objectives": [
        defeat("obj_gate_guards", [[grp("android", 3, 24)], [grp("android", 3, 24), grp("archer", 2, 30)]], pre=["m13_2"], dharma=30),
        {"type": "boss", "text": "obj_twins", "kinds": ["koka", "vikoka"], "dist": 30, "intro": ids("m13", 3, 4)},
        {"type": "boss", "text": "obj_kali", "kinds": ["kali"], "dist": 30, "intro": ids("m13", 5, 6), "dharma": 55},
        {"type": "wait", "secs": 0.5, "pre": ["m13_7"]},
    ],
    "outro": ["m13_8"],
}

# M14 -- Bhallata
PLAY["M14"] = {
    "biome": "bhallata", "mode": "foot", "dharma": 68, "start": [0, 30], "bounds": 100,
    "world": {"props": [{"model": "prop_temple_wall", "pos": [0, -34], "scale": 2.0}]},
    "npcs": [
        npc("shashidhvaja", "ashwatthama", [0, -14], 2.0, standin=True, tint=[0.9, 0.6, 0.2, 0.22], name="npc_shashidhvaja"),
        npc("shushanta", "lakshmi", [8, -22], 1.75, standin=True, tint=[0.6, 0.5, 0.9, 0.2], name="npc_shushanta"),
        npc("ramadevi", "ramadevi", [-8, -22], 1.75, name="npc_ramadevi"),
    ],
    "intro": ["m14_1"],
    "objectives": [
        talk("shashidhvaja", "obj_talk_shashidhvaja", ["m14_2"]),
        defeat("obj_duel", [[{"kind": "king", "n": 1, "radius": 12}]], pre=["m14_3"], post=["m14_4"], hide_npc="shashidhvaja", npc_at=True, flags=["ally_shashidhvaja"]),
        talk("shushanta", "obj_talk_shushanta", ids("m14", 5, 6)),
        talk("ramadevi", "obj_talk_ramadevi", ids("m14", 7, 8, 9), flags=["wed_ramadevi"]),
    ],
    "outro": [],
}

# M15 -- Kanchanapuri: the curse, not a combat
PLAY["M15"] = {
    "biome": "kanchana", "mode": "foot", "dharma": 40, "start": [0, 30], "bounds": 100,
    "world": {"props": [{"model": "prop_lotus", "pos": [-30, -20], "scale": 2.2}]},
    "npcs": [npc("sulocana", "lakshmi", [0, -58], 1.75, standin=True, tint=[0.5, 0.9, 0.5, 0.2], name="npc_sulocana")],
    "intro": ["m15_1"],
    "objectives": [
        {"type": "collect", "text": "obj_lotus_shrines", "pre": ["m15_2"], "post": ["m15_3"], "gain": 6,
         "items": [[-22, 10], [18, -8], [-16, -32], [22, -44]],
         "hazards": [{"pos": [-4, 2], "r": 7, "dmg": 4}, {"pos": [4, -22], "r": 8, "dmg": 4}, {"pos": [-2, -42], "r": 7, "dmg": 4}]},
        talk("sulocana", "obj_talk_sulocana", ids("m15", 4, 5, 6)),
    ],
    "outro": ["m15_7"],
}

# M16 -- the throne restored
PLAY["M16"] = {
    "biome": "restored", "mode": "foot", "dharma": 72, "start": [0, 30], "bounds": 120, "dharma_ui": True,
    "npcs": [
        npc("maru", "ashwatthama", [-8, 8], 2.0, standin=True, tint=[1.0, 0.8, 0.4, 0.2], name="npc_maru"),
        npc("devapi", "vyasa", [8, 8], 1.95, standin=True, tint=[0.7, 0.8, 1.0, 0.2], name="npc_devapi"),
    ],
    "intro": ["m16_1"],
    "objectives": [
        talk("maru", "obj_talk_maru", ["m16_2"]),
        talk("devapi", "obj_talk_devapi", ["m16_3"]),
        {"type": "restore", "text": "obj_restore", "pre": ["m16_4"], "post": ["m16_5"], "gain": 6,
         "points": [[-40, -20], [38, -34], [-30, -62], [30, -84]], "r": 5.0},
        defeat("obj_predators", [[grp("raider", 3, 24), grp("archer", 1, 28)], [grp("banner", 1, 28), grp("raider", 3, 24)]], pre=["m16_6"]),
    ],
    "outro": ["m16_7"],
}

# M17 -- dawn of Krita Yuga
PLAY["M17"] = {
    "biome": "vaikuntha", "mode": "foot", "dharma": 85, "start": [0, 30], "bounds": 90, "dharma_ui": True,
    "npcs": [
        npc("padmavati", "padmavati", [-9, -14], 1.75, name="npc_padmavati"),
        npc("ramadevi", "ramadevi", [9, -14], 1.75, name="npc_ramadevi"),
        npc("parashurama", "parashurama", [0, -18], 2.0, name="npc_parashurama"),
        {"id": "narayana", "name": "npc_narayana", "model": "narayana", "scale": 1.9, "pos": [0, -40], "h": 3.2, "face": [0, 20], "radius": 5.0},
    ],
    "intro": ["m17_1"],
    "objectives": [
        reach([0, -8], "obj_ganga", 4.0),
        talk("padmavati", "obj_farewell", ["m17_2"]),
        talk("ramadevi", "obj_farewell", ["m17_3"]),
        talk("parashurama", "obj_farewell", ["m17_4"]),
        {"type": "cutscene", "effect": "dawn", "lines": ids("m17", 5, 6)},
        talk("narayana", "obj_talk_narayana", ["m17_7"]),
        {"type": "codex", "entry": "credits", "text": "obj_codex"},
    ],
    "outro": ["m17_8"],
}

TITLES = {
    "M00": ("युग का बिखराव", "యుగం విచ్ఛిన్నమవుతోంది"), "M01": ("देवताओं की सभा", "దేవతల సభ"),
    "M02": ("शम्भल का घर", "శంభలలోని ఇల్లు"), "M03": ("परशुराम का गुरुकुल", "పరశురాముని గురుకులం"),
    "M04": ("महादेव के तीन उपहार", "మహాదేవుని మూడు కానుకలు"), "M05": ("सिंहल का शुक", "సింహళ చిలుక"),
    "M06": ("सिंहल का कमल", "సింహళ కమలం"), "M07": ("अनन्त का उपदेश", "అనంతుని బోధ"),
    "M08": ("शम्भल वापसी", "శంభలకు తిరుగు ప్రయాణం"), "M09": ("किकट का विवादित आख्यान", "వివాదాస్పద కీకట గాథ"),
    "M10": ("उत्तर की दैत्या", "ఉత్తరపు రాక్షసి"), "M11": ("दो वंश प्रतीक्षा में", "రెండు వంశాలు వేచి ఉన్నాయి"),
    "M12": ("सिंहासन-विहीन धर्म", "సింహాసనం లేని ధర్మం"), "M13": ("कलि की घेराबंदी", "కలి ముట్టడి"),
    "M14": ("जिस राजा ने पहचान लिया", "గుర్తించిన రాజు"), "M15": ("विष-शाप का नगर", "విష శాపపు నగరం"),
    "M16": ("सिंहासन की पुनःस्थापना", "సింహాసన పునఃస్థాపన"), "M17": ("कृतयुग का उदय", "కృత యుగోదయం"),
}
