"""Rig + animate the fused Kalki-on-Devadatta mesh. Run:

  xvfb-run -a blender -b --python tools/blender/rig_kalki.py -- <in.glb> <out.glb> [preview_dir]

Blender coords: Z up, horse faces -Y, sword arm on the -X side.
Weights are distance-to-bone-segment based with hard region rules for the
rider/sword/tail, because the mesh is one fused AI-generated surface.
"""
import bpy, sys, math, mathutils
from mathutils import Vector

args = sys.argv[sys.argv.index("--") + 1:]
IN, OUT = args[0], args[1]
PREVIEW = args[2] if len(args) > 2 else None
CX = 0.07  # horse centre line (x)
TARGET_TRIS = 45000

# ---------------------------------------------------------------- import
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
mesh = [o for o in bpy.data.objects if o.type == "MESH"][0]
mesh.name = "Kalki_Devadatta"
bpy.context.view_layer.objects.active = mesh
mesh.select_set(True)

tris = sum(len(p.vertices) - 2 for p in mesh.data.polygons)
mod = mesh.modifiers.new("dec", "DECIMATE")
mod.ratio = min(1.0, TARGET_TRIS / tris)
bpy.ops.object.modifier_apply(modifier=mod.name)
print("DECIMATED tris", sum(len(p.vertices) - 2 for p in mesh.data.polygons))

# textures: 1K for the game build
for img in bpy.data.images:
    if img.size[0] > 1024:
        img.scale(1024, 1024)

# ---------------------------------------------------------------- bones
# name: (parent, head, tail)
B = {}
def bone(name, parent, head, tail):
    B[name] = (parent, Vector(head), Vector(tail))

bone("root",        None,         (CX, 0, 0),        (CX, 0, 0.25))
bone("spine_rear",  "root",       (CX, 0.45, 0.72),  (CX, 0.05, 0.72))
bone("spine_front", "spine_rear", (CX, 0.05, 0.72),  (CX, -0.48, 0.8))
bone("neck",        "spine_front",(CX, -0.48, 0.82), (CX, -0.72, 1.18))
bone("head",        "neck",       (CX, -0.72, 1.18), (CX, -0.95, 0.93))
bone("tail_1",      "spine_rear", (CX, 0.42, 0.82),  (CX, 0.6, 0.6))
bone("tail_2",      "tail_1",     (CX, 0.6, 0.6),    (CX, 0.72, 0.38))
bone("tail_3",      "tail_2",     (CX, 0.72, 0.38),  (CX, 0.82, 0.12))
# legs: (x,y at hoof), shoulder/hip height, knee height
LEG = {
    "fl": ((-0.06, -0.45), "spine_front", 0.60, 0.33),   # front, x-left
    "fr": (( 0.25, -0.67), "spine_front", 0.60, 0.33),
    "hl": ((-0.10,  0.39), "spine_rear",  0.62, 0.36),
    "hr": (( 0.25,  0.29), "spine_rear",  0.62, 0.36),
}
for k, ((x, y), par, ztop, zknee) in LEG.items():
    bone(f"leg_{k}_up", par,            (x, y, ztop),  (x, y, zknee))
    bone(f"leg_{k}_lo", f"leg_{k}_up",  (x, y, zknee), (x, y, 0.0))
# rider
bone("rider_hips",  "spine_rear", (CX, 0.05, 0.78), (CX, 0.0, 0.98))
bone("rider_torso", "rider_hips", (CX, 0.0, 0.98),  (CX, 0.0, 1.30))
bone("rider_head",  "rider_torso",(CX, 0.0, 1.30),  (CX, 0.0, 1.55))
bone("arm_sword",   "rider_torso",(-0.12, 0.02, 1.28), (-0.42, 0.25, 1.23))   # shoulder -> hand
bone("sword",       "arm_sword",  (-0.42, 0.25, 1.23), (-0.44, 0.95, 1.55))   # hand -> tip
bone("arm_rein",    "rider_torso",(0.22, 0.0, 1.25), (0.2, -0.35, 1.0))

arm_data = bpy.data.armatures.new("Armature")
arm = bpy.data.objects.new("Armature", arm_data)
bpy.context.scene.collection.objects.link(arm)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="EDIT")
for n, (p, h, t) in B.items():
    eb = arm_data.edit_bones.new(n)
    eb.head, eb.tail = h, t
    if (t - h).length < 1e-4:
        eb.tail = h + Vector((0, 0, 0.05))
for n, (p, h, t) in B.items():
    if p:
        arm_data.edit_bones[n].parent = arm_data.edit_bones[p]
bpy.ops.object.mode_set(mode="OBJECT")

# ---------------------------------------------------------------- weights
def seg_dist(p, a, b):
    ab = b - a
    t = max(0.0, min(1.0, (p - a).dot(ab) / max(ab.length_squared, 1e-9)))
    return (p - (a + ab * t)).length

def region_rules(v):
    """Hard assignments -> dict bone:weight, or None for distance weighting."""
    x, y, z = v.x, v.y, v.z
    # sword blade + hand (far side)
    if x < -0.22 and z > 1.12 and y > 0.1:
        return {"sword": 1.0}
    if x < -0.2 and z > 1.1 and -0.1 < y <= 0.1:
        return {"arm_sword": 0.7, "rider_torso": 0.3}
    # rider boots/legs sitting beside the horse flank
    if 0.3 < z < 0.9 and -0.36 < y < 0.28 and abs(x - CX) > 0.2:
        return {"rider_hips": 1.0}
    return None

rider_bones = ["rider_hips", "rider_torso", "rider_head", "arm_sword", "arm_rein"]
horse_bones = [n for n in B if n not in rider_bones + ["sword", "root"]]

def is_rider(v):
    x, y, z = v.x, v.y, v.z
    if z > 0.8 and -0.42 < y < 0.5 and not (y > 0.4 and z < 0.95):
        return True
    return False

for n in B:
    mesh.vertex_groups.new(name=n)
vg = mesh.vertex_groups

sw_seg = {n: (B[n][1], B[n][2]) for n in B}
for v in mesh.data.vertices:
    p = v.co
    hard = region_rules(p)
    if hard:
        for b, w in hard.items():
            vg[b].add([v.index], w, "REPLACE")
        continue
    cand = (rider_bones + ["sword"]) if is_rider(p) else horse_bones
    ds = {b: seg_dist(p, *sw_seg[b]) for b in cand}
    ws = {b: 1.0 / (d + 0.02) ** 4 for b, d in ds.items()}
    top = sorted(ws.items(), key=lambda kv: -kv[1])[:4]
    tot = sum(w for _, w in top)
    for b, w in top:
        vg[b].add([v.index], w / tot, "REPLACE")

mod = mesh.modifiers.new("Armature", "ARMATURE")
mod.object = arm
mesh.parent = arm

# ---------------------------------------------------------------- animation
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode="POSE")
for pb in arm.pose.bones:
    pb.rotation_mode = "QUATERNION"

def rot(pb, axis_world, deg):
    """Rotate pose bone about a rest-pose world axis."""
    m = pb.bone.matrix_local.to_3x3().inverted()
    ax = (m @ Vector(axis_world)).normalized()
    pb.rotation_quaternion = mathutils.Quaternion(ax, math.radians(deg))

def key(frame):
    for pb in arm.pose.bones:
        pb.keyframe_insert("rotation_quaternion", frame=frame)
        pb.keyframe_insert("location", frame=frame)

def reset():
    for pb in arm.pose.bones:
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.location = (0, 0, 0)

X, Y, Z = (1, 0, 0), (0, 1, 0), (0, 0, 1)
P = lambda n: arm.pose.bones[n]

def make_action(name, frames, fn, loop=True):
    act = bpy.data.actions.new(name)
    act.use_fake_user = True
    arm.animation_data_create().action = act
    for f in range(0, frames + 1):
        reset()
        fn(f / frames if loop else f / frames, f)
        key(f + 1)
    return act

# Positive X-rotation swings -Y (front) toward +Z... verified in preview renders.
def idle(t, f):
    s = math.sin(t * 2 * math.pi)
    rot(P("spine_front"), X, 1.2 * s)
    rot(P("neck"), X, -2.0 * s)
    rot(P("head"), X, 1.5 * s)
    rot(P("tail_1"), X, 5 * math.sin(t * 2 * math.pi + 0.5))
    rot(P("tail_2"), X, 7 * math.sin(t * 2 * math.pi + 1.0))
    rot(P("tail_3"), X, 9 * math.sin(t * 2 * math.pi + 1.5))
    rot(P("rider_torso"), X, 1.5 * s)
    rot(P("arm_sword"), Z, 2.0 * s)

def gait(amp_leg, amp_knee, body_pitch, bob, tail_amp, phases):
    def fn(t, f):
        w = t * 2 * math.pi
        for k, ph in phases.items():
            up, lo = P(f"leg_{k}_up"), P(f"leg_{k}_lo")
            rot(up, X, amp_leg * math.sin(w + ph))
            # knee bends (folds toward back) while leg swings forward
            rot(lo, X, -amp_knee * max(0.0, math.sin(w + ph + 0.9)))
        P("root").location = (0, 0, bob * abs(math.sin(w * 2 if bob_double else w)))
        rot(P("spine_front"), X, body_pitch * math.sin(w + 0.6))
        rot(P("neck"), X, -body_pitch * 1.2 * math.sin(w + 0.9))
        rot(P("head"), X, body_pitch * 0.8 * math.sin(w + 1.2))
        for i, n in enumerate(("tail_1", "tail_2", "tail_3")):
            rot(P(n), X, tail_amp * (i + 1) * math.sin(w - 0.6 * (i + 1)))
        rot(P("rider_torso"), X, -3 * math.sin(w + 0.6))
        rot(P("arm_sword"), X, 4 * math.sin(w + 1.0))
    return fn

bob_double = False
# diagonal walk: fl, hr, fr, hl
make_action("walk-loop", 32, gait(18, 22, 1.5, 0.012, 3, {"fl": 0, "hr": math.pi / 2, "fr": math.pi, "hl": 3 * math.pi / 2}))
bob_double = True
make_action("trot-loop", 20, gait(26, 30, 2.0, 0.025, 4, {"fl": 0, "hr": 0, "fr": math.pi, "hl": math.pi}))
bob_double = False
make_action("gallop-loop", 16, gait(42, 50, 5.0, 0.05, 6, {"fl": 0, "fr": 0.5, "hr": 2.2, "hl": 2.7}))
make_action("idle-loop", 48, idle)

def slash(t, f):
    # t in 0..1: wind-up, strike, recover. Rider torso twists, sword arm sweeps.
    def ease(a, b, x):
        u = max(0.0, min(1.0, (x - a) / (b - a))); return u * u * (3 - 2 * u)
    wind = ease(0.0, 0.3, t) * (1 - ease(0.3, 0.38, t))
    strike = ease(0.3, 0.5, t) * (1 - ease(0.62, 1.0, t))
    rot(P("rider_torso"), Z, 25 * wind - 40 * strike)
    rot(P("arm_sword"), X, -45 * wind + 95 * strike)
    rot(P("arm_sword"), Y, 20 * wind - 25 * strike)
    rot(P("sword"), X, -15 * wind + 30 * strike)
    rot(P("rider_head"), Z, -10 * wind + 15 * strike)
    rot(P("spine_front"), X, -2 * wind + 4 * strike)
make_action("slash", 24, slash, loop=False)

def rear(t, f):
    def ease(a, b, x):
        u = max(0.0, min(1.0, (x - a) / (b - a))); return u * u * (3 - 2 * u)
    up = ease(0.0, 0.35, t) * (1 - ease(0.65, 1.0, t))
    # whole body pitches up about the hind hooves; front legs fold, hinds plant
    rot(P("spine_rear"), X, -30 * up)
    rot(P("spine_front"), X, -8 * up)
    rot(P("neck"), X, 10 * up)
    for k in ("fl", "fr"):
        rot(P(f"leg_{k}_up"), X, 55 * up)
        rot(P(f"leg_{k}_lo"), X, -70 * up)
    for k in ("hl", "hr"):
        rot(P(f"leg_{k}_up"), X, 22 * up)
    rot(P("rider_torso"), X, 12 * up)
    rot(P("arm_sword"), X, 45 * up)
    for i, n in enumerate(("tail_1", "tail_2", "tail_3")):
        rot(P(n), X, 8 * (i + 1) * up)
make_action("rear", 40, rear, loop=False)

def victory(t, f):
    s = math.sin(t * 2 * math.pi)
    rot(P("arm_sword"), X, 55 + 4 * s)
    rot(P("sword"), X, 10)
    rot(P("rider_head"), X, -10)
    rot(P("neck"), X, -6 + 1.5 * s)
    rot(P("tail_2"), X, 6 * s)
make_action("victory-loop", 48, victory)

reset()
bpy.ops.object.mode_set(mode="OBJECT")

# ---------------------------------------------------------------- previews
def render_pose(action_name, frame, tag):
    if not PREVIEW:
        return
    act = bpy.data.actions[action_name]
    arm.animation_data.action = act
    bpy.context.scene.frame_set(frame)
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_WORKBENCH"
    sc.display.shading.light = "FLAT"; sc.display.shading.color_type = "TEXTURE"
    sc.render.resolution_x, sc.render.resolution_y = 800, 560
    if not sc.camera:
        cam = bpy.data.objects.new("c", bpy.data.cameras.new("c")); sc.collection.objects.link(cam)
        cam.data.type = "ORTHO"; cam.data.ortho_scale = 2.6
        cam.location = (5, 0, 0.8); cam.rotation_euler = (math.radians(90), 0, math.radians(90))
        sc.camera = cam
        sc.world = bpy.data.worlds.new("w"); sc.world.color = (0.2, 0.2, 0.22)
    sc.render.filepath = f"{PREVIEW}/{tag}.png"
    bpy.ops.render.render(write_still=True)

if PREVIEW:
    render_pose("idle-loop", 1, "rest")
    for a, fr in (("gallop-loop", 1), ("gallop-loop", 5), ("slash", 10), ("slash", 16), ("rear", 14), ("walk-loop", 9)):
        render_pose(a, fr, f"{a}_{fr}")

# ---------------------------------------------------------------- export
arm.animation_data.action = bpy.data.actions["idle-loop"]
bpy.ops.object.select_all(action="DESELECT")
arm.select_set(True); mesh.select_set(True)
bpy.context.view_layer.objects.active = arm
bpy.ops.export_scene.gltf(
    filepath=OUT, export_format="GLB", use_selection=True,
    export_animations=True, export_animation_mode="ACTIONS",
    export_image_format="JPEG", export_jpeg_quality=88,
    export_skins=True, export_apply=False, export_yup=True,
)
print("EXPORTED", OUT)
