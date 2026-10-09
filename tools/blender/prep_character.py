"""Prep a rigged/animated Sketchfab character for the phone build: shrink textures, optionally
slice one long take into named clips, keep skin + animations, export a GLB.

  blender -b --python tools/blender/prep_character.py -- <in.gltf> <out.glb> [tex_px] [clip=start-end ...]
  e.g. ... warrior.gltf out.glb 1024 idle=0-80 attack_a=125-180
Without clip args the animations already in the file are exported as they are.
"""
import bpy, sys
a = sys.argv[sys.argv.index("--") + 1:]
IN, OUT = a[0], a[1]
TEX = int(a[2]) if len(a) > 2 else 1024
CLIPS = [(c.split("=")[0], *map(int, c.split("=")[1].split("-"))) for c in a[3:]]

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
for img in bpy.data.images:
    if max(img.size) > TEX:
        img.scale(TEX, TEX)

for mat in bpy.data.materials:      # spec-gloss files import as Glossy+Diffuse: rebuild as Principled
    if not mat.use_nodes or any(n.type == "BSDF_PRINCIPLED" for n in mat.node_tree.nodes):
        continue
    nt = mat.node_tree
    imgs = [n.image for n in nt.nodes if n.type == "TEX_IMAGE" and n.image]
    diffuse = next((i for i in imgs if "diffuse" in i.name.lower() or "basecolor" in i.name.lower()), None)
    normal = next((i for i in imgs if "normal" in i.name.lower()), None)
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial"); bsdf = nt.nodes.new("ShaderNodeBsdfPrincipled")
    nt.links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Roughness"].default_value = 0.7
    if diffuse:
        t = nt.nodes.new("ShaderNodeTexImage"); t.image = diffuse
        nt.links.new(t.outputs["Color"], bsdf.inputs["Base Color"])
    if normal:
        t = nt.nodes.new("ShaderNodeTexImage"); t.image = normal; t.image.colorspace_settings.name = "Non-Color"
        nm = nt.nodes.new("ShaderNodeNormalMap")
        nt.links.new(t.outputs["Color"], nm.inputs["Color"]); nt.links.new(nm.outputs["Normal"], bsdf.inputs["Normal"])

arm = next((o for o in bpy.data.objects if o.type == "ARMATURE"), None)
if CLIPS and arm and arm.animation_data and arm.animation_data.action:
    src = arm.animation_data.action
    for name, f0, f1 in CLIPS:
        act = src.copy(); act.name = name
        for fc in act.fcurves:
            kp = fc.keyframe_points
            for i in reversed(range(len(kp))):      # trim to the clip range
                if kp[i].co.x < f0 or kp[i].co.x > f1:
                    kp.remove(kp[i])
            for k in fc.keyframe_points:      # rebase to frame 1
                k.co.x -= f0 - 1; k.handle_left.x -= f0 - 1; k.handle_right.x -= f0 - 1
        act.use_fake_user = True
        track = arm.animation_data.nla_tracks.new(); track.name = name
        track.strips.new(name, 1, act)
    arm.animation_data.action = None
    bpy.data.actions.remove(src)

# Normalise: evaluate the skinned meshes at the first frame, then scale to 1 m tall with the feet
# on z=0 and the body centred, via a parent empty. The game then only multiplies by a height.
import mathutils
bpy.context.scene.frame_set(1)
dg = bpy.context.evaluated_depsgraph_get()
lo = mathutils.Vector((1e9,) * 3); hi = mathutils.Vector((-1e9,) * 3)
for ob in [o for o in bpy.data.objects if o.type == "MESH"]:
    ev = ob.evaluated_get(dg); me = ev.to_mesh()
    for v in me.vertices:
        w = ob.matrix_world @ v.co
        lo = mathutils.Vector(map(min, lo, w)); hi = mathutils.Vector(map(max, hi, w))
    ev.to_mesh_clear()
h = hi.z - lo.z
fit = bpy.data.objects.new("Fit", None); bpy.context.scene.collection.objects.link(fit)
for ob in [o for o in bpy.data.objects if o.parent is None and o is not fit]:
    ob.parent = fit
fit.scale = (1 / h,) * 3
fit.location = (-(lo.x + hi.x) / 2 / h, -(lo.y + hi.y) / 2 / h, -lo.z / h)
print("SOURCE HEIGHT", round(h, 3), "units")

bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_image_format="JPEG",
                          export_jpeg_quality=85, export_animations=True,
                          export_animation_mode="NLA_TRACKS" if CLIPS else "ACTIONS",
                          export_skins=True)
print("EXPORTED", OUT)
