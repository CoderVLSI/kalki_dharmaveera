"""Prep a static (unrigged) Sketchfab model: decimate to a triangle budget, shrink textures,
scale to a real-world height with the base on y=0 and the footprint centred, export a GLB.

  blender -b --python tools/blender/prep_prop.py -- <in.gltf> <out.glb> <height_m> [max_tris] [tex_px]
"""
import bpy, sys, mathutils
a = sys.argv[sys.argv.index("--") + 1:]
IN, OUT, H = a[0], a[1], float(a[2])
MAXT = int(a[3]) if len(a) > 3 else 8000
TEX = int(a[4]) if len(a) > 4 else 512
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
meshes = [o for o in bpy.data.objects if o.type == "MESH"]
for o in meshes:   # Rodin exports a 2-bone stub rig and morph targets; drop both (we rig ourselves)
    for m in [m for m in o.modifiers if m.type == "ARMATURE"]:
        o.modifiers.remove(m)
    if o.data.shape_keys:
        for k in list(o.data.shape_keys.key_blocks)[::-1]:
            o.shape_key_remove(k)
    o.parent = None
for ob in [ob for ob in bpy.data.objects if ob.type == "ARMATURE"]:
    bpy.data.objects.remove(ob)
tris = sum(len(p.vertices) - 2 for o in meshes for p in o.data.polygons)
ratio = min(1.0, MAXT / max(tris, 1))
if ratio < 1.0:
    for o in meshes:
        bpy.context.view_layer.objects.active = o
        d = o.modifiers.new("dec", "DECIMATE"); d.ratio = ratio
        bpy.ops.object.modifier_apply(modifier=d.name)
for img in bpy.data.images:
    # colour and normal maps keep TEX; metal/roughness/emissive maps barely show, so they get half (size budget)
    lim = TEX // 2 if any(k in img.name.lower() for k in ("metal", "rough", "emiss")) else TEX
    if max(img.size) > lim:
        img.scale(lim, lim)
lo = mathutils.Vector((1e9,) * 3); hi = mathutils.Vector((-1e9,) * 3)
for o in meshes:
    for v in o.data.vertices:
        w = o.matrix_world @ v.co
        lo = mathutils.Vector(map(min, lo, w)); hi = mathutils.Vector(map(max, hi, w))
h = hi.z - lo.z
fit = bpy.data.objects.new("Fit", None); bpy.context.scene.collection.objects.link(fit)
for o in [o for o in bpy.data.objects if o.parent is None and o is not fit]:
    o.parent = fit
s = H / h
fit.scale = (s,) * 3
fit.location = (-(lo.x + hi.x) / 2 * s, -(lo.y + hi.y) / 2 * s, -lo.z * s)
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_image_format="JPEG", export_jpeg_quality=85)
print("EXPORTED", OUT, "tris", sum(len(p.vertices) - 2 for o in meshes for p in o.data.polygons), "src height", round(h, 3))
