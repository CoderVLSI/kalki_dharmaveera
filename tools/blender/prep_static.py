"""Decimate + shrink textures of a static GLB for in-game use.

  blender -b --python tools/blender/prep_static.py -- <in.glb> <out.glb> [target_tris]
"""
import bpy, sys
a = sys.argv[sys.argv.index("--") + 1:]
IN, OUT = a[0], a[1]
TARGET = int(a[2]) if len(a) > 2 else 40000
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN)
m = [o for o in bpy.data.objects if o.type == "MESH"][0]
bpy.context.view_layer.objects.active = m
tris = sum(len(p.vertices) - 2 for p in m.data.polygons)
d = m.modifiers.new("dec", "DECIMATE"); d.ratio = min(1.0, TARGET / tris)
bpy.ops.object.modifier_apply(modifier=d.name)
for img in bpy.data.images:
    if img.size[0] > 1024:
        img.scale(1024, 1024)
bpy.ops.object.select_all(action="DESELECT"); m.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", use_selection=True,
                          export_image_format="JPEG", export_jpeg_quality=88)
print("EXPORTED", OUT, sum(len(p.vertices) - 2 for p in m.data.polygons), "tris")
