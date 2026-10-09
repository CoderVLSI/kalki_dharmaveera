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
BLESS = 0.4 if PROFILE == "brahma" else 1.0
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
mesh = [o for o in bpy.data.objects if o.type == "MESH"][0]
mesh.parent = None
pts = [mesh.matrix_world @ v.co for v in mesh.data.vertices]
H = max(p.z for p in pts)

P = {   # per-profile landmarks, fractions of H
    "default": dict(hip=0.50, knee=0.27, ankle=0.05, chest=0.80, neck=0.87, sx=0.13, ex=0.19, wx=0.23, ez=0.66, wz=0.52, hz=0.45, leg=0.09),
}[("default")]


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
mesh.parent = arm
mesh.matrix_parent_inverse = arm.matrix_world.inverted()
mod = mesh.modifiers.new("Armature", "ARMATURE"); mod.object = arm
for bn in arm.data.bones:
    mesh.vertex_groups.new(name=bn.name)
segs = [(bn.name, bn.head_local.copy(), bn.tail_local.copy()) for bn in arm.data.bones]


def seg_dist(pt, h, t):
    d = t - h
    u = max(0.0, min(1.0, (pt - h).dot(d) / max(d.length_squared, 1e-9)))
    return (pt - (h + d * u)).length


for v in mesh.data.vertices:
    pt = mesh.matrix_world @ v.co
    ds = sorted(((seg_dist(pt, h, t), n) for n, h, t in segs))[:4]
    ws = [1.0 / (d + 0.03 * H) ** 4 for d, n in ds]
    tot = sum(ws)
    for (d, n), w in zip(ds, ws):
        mesh.vertex_groups[n].add([v.index], w / tot, "REPLACE")

# ---------- procedural animation (armature-space rotations about each bone head) ----------
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="POSE")
rest = {b.name: b.matrix_local.copy() for b in arm.data.bones}
order = ["Hips", "Spine", "Chest", "Neck", "Head"] + [f"{k}_{s}" for s in "LR" for k in ("Thigh", "Shin", "Foot", "UpperArm", "ForeArm", "Hand")]
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION"
mesh.hide_viewport = True


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


def bless(t):                           # left arm (+X, the free hand) raised in blessing, held, lowered
    up = math.sin(math.pi * min(1.0, t * 1.15)) ** 0.6 if t < 0.87 else 0.0
    return ({"UpperArm_L": ("X", -60 * up * BLESS), "ForeArm_L": ("X", -35 * up * BLESS), "Head": ("X", -4 * up),
             "Spine": ("X", -2 * up)}, 0.0)


make("idle", 72, idle)
make("walk", 24, walk)
make("bless", 72, bless, loop=False)
bpy.ops.object.mode_set(mode="OBJECT")
mesh.hide_viewport = False
bpy.context.scene.frame_set(1)
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_image_format="JPEG", export_jpeg_quality=85,
                          export_animations=True, export_animation_mode="NLA_TRACKS", export_skins=True)
print("EXPORTED", OUT, "bones", len(arm.data.bones))
