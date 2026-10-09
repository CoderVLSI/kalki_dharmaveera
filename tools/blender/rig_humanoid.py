"""Rig a static humanoid GLB (prepped by prep_prop.py: base on z=0, facing -Y in Blender) with a
simple game skeleton and auto weights, add idle / walk / bless loops, export a GLB.

  blender -b --python tools/blender/rig_humanoid.py -- <in.glb> <out.glb> [profile]

Character side: facing -Y, the character's right is -X. Bones are placed from body proportions
(fractions of height) and the skeleton is posed procedurally, so extra arms (Brahma) simply follow
the nearest bone. Check the result with a render before shipping.
"""
import bpy, sys, math, mathutils
from mathutils import Vector, Matrix

a = sys.argv[sys.argv.index("--") + 1:]
IN, OUT = a[0], a[1]
PROFILE = a[2] if len(a) > 2 else "default"   # "brahma": gentler blessing so the book arm does not smear
RIGID = PROFILE == "robot"   # hard armour plates: every vertex follows exactly one bone, so panels never stretch
BLESS = 0.4 if PROFILE in ("brahma", "parashurama") else 1.0
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
MESHES = [o for o in bpy.data.objects if o.type == "MESH"]   # one body, or separate armour parts (robot)
for _m in MESHES:
    _m.parent = None
pts = [m.matrix_world @ v.co for m in MESHES for v in m.data.vertices]
H = max(p.z for p in pts)

P = {   # per-profile landmarks, fractions of H; unknown profile names use the default body
    "parashurama": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.07, ex=0.10, wx=0.12, ez=0.66, wz=0.52, hz=0.45, leg=0.045),
    "slim": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.07, ex=0.10, wx=0.12, ez=0.66, wz=0.52, hz=0.45, leg=0.045),
    "kalki": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.12, ex=0.20, wx=0.18, ez=0.62, wz=0.49, hz=0.44, leg=0.07),
    "robot": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.12, ex=0.20, wx=0.18, ez=0.62, wz=0.49, hz=0.44, leg=0.07),
}.get(PROFILE, None) or {
    "default": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.13, ex=0.19, wx=0.23, ez=0.66, wz=0.52, hz=0.45, leg=0.09),
}["default"]


def V(x, z, y=0.0):
    return Vector((x * H, y * H, z * H))


bpy.ops.object.armature_add(enter_editmode=True, location=(0, 0, 0))
arm = bpy.context.object
arm.name = "Armature"
eb = arm.data.edit_bones
eb.remove(eb[0])
bones = {}


def bone(name, head, tail, parent=None):
    b = eb.new(name)
    b.head, b.tail = head, tail
    if parent:
        b.parent = bones[parent]
        b.use_connect = False
    bones[name] = b
    return b


p = P
bone("Hips", V(0, p["hip"]), V(0, p["hip"] + 0.07))
bone("Spine", V(0, p["hip"] + 0.07), V(0, p["chest"] - 0.06), "Hips")
bone("Chest", V(0, p["chest"] - 0.06), V(0, p["neck"]), "Spine")
bone("Neck", V(0, p["neck"]), V(0, p["neck"] + 0.04), "Chest")
bone("Head", V(0, p["neck"] + 0.04), V(0, 0.99), "Neck")
for side, sgn in (("L", 1), ("R", -1)):          # L = +X (character's left, facing -Y)
    bone(f"Thigh_{side}", V(sgn * p["leg"], p["hip"]), V(sgn * p["leg"], p["knee"]), "Hips")
    bone(f"Shin_{side}", V(sgn * p["leg"], p["knee"]), V(sgn * p["leg"], p["ankle"]), f"Thigh_{side}")
    bone(f"Foot_{side}", V(sgn * p["leg"], p["ankle"]), V(sgn * p["leg"], 0.0, -0.06), f"Shin_{side}")
    bone(f"UpperArm_{side}", V(sgn * p["sx"], p["chest"]), V(sgn * p["ex"], p["ez"]), "Chest")
    bone(f"ForeArm_{side}", V(sgn * p["ex"], p["ez"]), V(sgn * p["wx"], p["wz"]), f"UpperArm_{side}")
    bone(f"Hand_{side}", V(sgn * p["wx"], p["wz"]), V(sgn * p["wx"], p["hz"]), f"ForeArm_{side}")
bpy.ops.object.mode_set(mode="OBJECT")

# skin: inverse-distance weights to the bone segments (top 4 per vertex). Rodin meshes are not
# watertight, so Blender's heat-diffusion auto weights fail; this blends smoothly and never fails.
segs = [(bn.name, bn.head_local.copy(), bn.tail_local.copy()) for bn in arm.data.bones]


def seg_dist(pt, h, t):
    d = t - h
    u = max(0.0, min(1.0, (pt - h).dot(d) / max(d.length_squared, 1e-9)))
    return (pt - (h + d * u)).length



def skin_mesh(mesh):
    mesh.parent = arm
    mesh.matrix_parent_inverse = arm.matrix_world.inverted()
    mod = mesh.modifiers.new("Armature", "ARMATURE"); mod.object = arm
    for bn in arm.data.bones:
        mesh.vertex_groups.new(name=bn.name)
    # Red cloth (sashes, drapes) must not ride up with the arms even when it hangs right beside a hand:
    # sample the colour map at each vertex and keep red, low-hanging vertices off the arm bones.
    import array
    tex = None
    for node in mesh.active_material.node_tree.nodes if mesh.active_material and mesh.active_material.use_nodes else []:
        if node.type == "BSDF_PRINCIPLED" and node.inputs["Base Color"].is_linked:
            src = node.inputs["Base Color"].links[0].from_node
            if src.type == "TEX_IMAGE" and src.image:
                tex = src.image
    tex_px = None
    if tex:
        tw, th = tex.size
        tex_px = array.array("f", tex.pixels[:])
    uv = mesh.data.uv_layers.active
    vert_uv = {}
    if uv and tex_px:
        for loop in mesh.data.loops:
            vert_uv.setdefault(loop.vertex_index, uv.data[loop.index].uv)


    def is_red(vi):
        if vi not in vert_uv or not tex_px:
            return False
        u, vv = vert_uv[vi]
        x, y = int(max(0, min(1, u)) * (tw - 1)), int(max(0, min(1, vv)) * (th - 1))
        i = (y * tw + x) * 4
        r, g, b = tex_px[i], tex_px[i + 1], tex_px[i + 2]
        return r > 0.45 and g < 0.22 and b < 0.22 and r > 2.2 * max(g, b)


    part_bone = None
    if RIGID and len(MESHES) > 1:   # a separate armour part moves as one solid piece with the bone most of it sits on
        votes = {}
        for v in mesh.data.vertices:
            q = mesh.matrix_world @ v.co
            n0 = min(((seg_dist(q, h, t), n) for n, h, t in segs))[1]
            votes[n0] = votes.get(n0, 0) + 1
        top = max(votes, key=votes.get)
        if votes[top] >= 0.6 * len(mesh.data.vertices):
            part_bone = top
    for v in mesh.data.vertices:
        pt = mesh.matrix_world @ v.co
        red_low = pt.z < 0.66 * H and is_red(v.index)
        # inside an arm's thickness (0.05H) the arm bone wins outright; beyond it the influence falls off
        # fast, so hip sashes and robes that hang beside the hands do not ride up with the arm
        def eff(n, d):
            if n.startswith(("Hand", "ForeArm", "UpperArm")):
                return 99.0 if red_low else max(0.0, d - 0.05 * H) * 3.0
            return d
        ds = sorted(((eff(n, seg_dist(pt, h, t)), n) for n, h, t in segs))[:4]
        ws = [1.0 / (d + 0.02 * H) ** 4 for d, n in ds]
        if RIGID:   # near-rigid: two bones with a steep falloff, so panels stay solid but joints do not tear
            ds = ds[:2]
            ws = [1.0 / (d + 0.01 * H) ** 10 for d, n in ds]
        if part_bone:
            ds, ws = [(0.0, part_bone)], [1.0]
        tot = sum(ws)
        for (d, n), w in zip(ds, ws):
            mesh.vertex_groups[n].add([v.index], w / tot, "REPLACE")



for _m in MESHES:
    skin_mesh(_m)

# ---------- procedural animation (armature-space rotations about each bone head) ----------
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="POSE")
rest = {b.name: b.matrix_local.copy() for b in arm.data.bones}
order = ["Hips", "Spine", "Chest", "Neck", "Head"] + [f"{k}_{s}" for s in "LR" for k in ("Thigh", "Shin", "Foot", "UpperArm", "ForeArm", "Hand")]
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION"
for _m in MESHES:
    _m.hide_viewport = True


def pose(d, hips_dz=0.0):
    """d: bone -> (axis 'X'|'Z', degrees) in armature space. Parent-first so children inherit."""
    for name in order:
        pb = arm.pose.bones[name]
        base = rest[name]
        head = base.translation
        deg = d.get(name)
        if deg is None and name != "Hips":
            pb.matrix = pb.parent.matrix @ pb.parent.matrix.inverted() @ base if False else base
        m = base
        if deg is not None:
            R = Matrix.Rotation(math.radians(deg[1]), 4, deg[0])
            m = Matrix.Translation(head) @ R @ Matrix.Translation(-head) @ base
        if name == "Hips":
            m = Matrix.Translation((0, 0, hips_dz * H)) @ m
        # a child must follow its (already posed) parent: express the target relative to the rest parent
        if pb.parent:
            parent_delta = pb.parent.matrix @ rest[pb.parent.name].inverted()
            m = parent_delta @ m
        pb.matrix = m
        bpy.context.view_layer.update()


def key(frame):
    for pb in arm.pose.bones:
        pb.keyframe_insert("rotation_quaternion", frame=frame)
        pb.keyframe_insert("location", frame=frame)


def make(name, frames, fn, loop=True):
    act = bpy.data.actions.new(name)
    arm.animation_data_create()
    arm.animation_data.action = act
    n = frames
    for f in range(0, n + 1):
        t = (f % n) / n if loop else f / n
        d, dz = fn(t)
        pose(d, dz)
        key(f + 1)
    arm.animation_data.action = None
    tr = arm.animation_data.nla_tracks.new(); tr.name = name
    tr.strips.new(name, 1, act)


def sw(t, amp, phase=0.0):
    return amp * math.sin(2 * math.pi * t + phase)


def idle(t):
    return ({"Spine": ("X", -sw(t, 1.2)), "Chest": ("X", -sw(t, 1.0, 0.4)), "Head": ("Z", sw(t, 3.0, 1.0)),
             "UpperArm_L": ("X", sw(t, 1.5)), "UpperArm_R": ("X", -sw(t, 1.5))}, 0.002 * math.sin(2 * math.pi * t))


def walk(t):
    s = sw(t, 28)                       # +ve = L leg forward; for a downward bone forward = -theta
    kneeL = 38 * max(0.0, math.cos(2 * math.pi * t))
    kneeR = 38 * max(0.0, -math.cos(2 * math.pi * t))
    return ({"Thigh_L": ("X", -s), "Thigh_R": ("X", s), "Shin_L": ("X", kneeL), "Shin_R": ("X", kneeR),
             "UpperArm_L": ("X", 0.55 * s), "UpperArm_R": ("X", -0.55 * s),
             "ForeArm_L": ("X", -12), "ForeArm_R": ("X", -12),
             "Spine": ("Z", sw(t, 3)), "Chest": ("Z", -sw(t, 3)), "Head": ("Z", sw(t, 2))},
            0.012 * abs(math.sin(2 * math.pi * t)) - 0.006)


def run(t):
    s = sw(t, 46)
    kneeL = 70 * max(0.0, math.cos(2 * math.pi * t))
    kneeR = 70 * max(0.0, -math.cos(2 * math.pi * t))
    return ({"Thigh_L": ("X", -s), "Thigh_R": ("X", s), "Shin_L": ("X", kneeL), "Shin_R": ("X", kneeR),
             "UpperArm_L": ("X", 0.8 * s), "UpperArm_R": ("X", -0.8 * s),
             "ForeArm_L": ("X", -40), "ForeArm_R": ("X", -40),
             "Spine": ("X", -8), "Chest": ("Z", -sw(t, 5)), "Head": ("X", 4)},
            0.03 * abs(math.sin(2 * math.pi * t)) - 0.01)


def slash(t):                           # right arm (character's right, -X) cuts overhead to low; torso twists with it
    def ease(a, b, u):
        u = max(0.0, min(1.0, u)); u = u * u * (3 - 2 * u); return a + (b - a) * u
    if t < 0.35:   up, tw = ease(0, -150, t / 0.35), ease(0, 22, t / 0.35)       # wind up
    elif t < 0.6:  up, tw = ease(-150, -25, (t - 0.35) / 0.25), ease(22, -26, (t - 0.35) / 0.25)   # strike
    else:          up, tw = ease(-25, 0, (t - 0.6) / 0.4), ease(-26, 0, (t - 0.6) / 0.4)          # recover
    return ({"UpperArm_R": ("X", up), "ForeArm_R": ("X", up * 0.2), "Spine": ("Z", tw), "Chest": ("Z", tw * 0.5),
             "Thigh_R": ("X", 12 if 0.3 < t < 0.65 else 0), "Thigh_L": ("X", -8 if 0.3 < t < 0.65 else 0)}, 0.0)


def bless(t):                           # left arm (+X, the free hand) raised in blessing, held, lowered
    up = math.sin(math.pi * min(1.0, t * 1.15)) ** 0.6 if t < 0.87 else 0.0
    return ({"UpperArm_L": ("X", -60 * up * BLESS), "ForeArm_L": ("X", -35 * up * BLESS), "Head": ("X", -4 * up),
             "Spine": ("X", -2 * up)}, 0.0)


make("idle", 72, idle)
make("walk", 24, walk)
make("run", 16, run)
make("bless", 72, bless, loop=False)
if PROFILE == "kalki":
    make("slash", 24, slash, loop=False)
bpy.ops.object.mode_set(mode="OBJECT")
for _m in MESHES:
    _m.hide_viewport = False
bpy.context.scene.frame_set(1)
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_image_format="JPEG", export_jpeg_quality=85,
                          export_animations=True, export_animation_mode="NLA_TRACKS", export_skins=True)
print("EXPORTED", OUT, "bones", len(arm.data.bones))
