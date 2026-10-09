"""Convert a Rodin OBJ drop (base.obj + texture_diffuse/normal/roughness/metallic .png) to a PBR GLB.

  blender -b --python tools/blender/obj_to_glb.py -- <dir_with_base.obj> <out.glb>
"""
import bpy, sys, os
a = sys.argv[sys.argv.index("--") + 1:]
D, OUT = a[0], a[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.wm.obj_import(filepath=os.path.join(D, "base.obj"))
ob = [o for o in bpy.data.objects if o.type == "MESH"][0]
mat = bpy.data.materials.new("m"); mat.use_nodes = True
nt = mat.node_tree; nt.nodes.clear()
out = nt.nodes.new("ShaderNodeOutputMaterial"); b = nt.nodes.new("ShaderNodeBsdfPrincipled")
nt.links.new(b.outputs["BSDF"], out.inputs["Surface"])


def tex(name, noncolor=False):
    p = os.path.join(D, name)
    if not os.path.exists(p):
        return None
    t = nt.nodes.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(p)
    if noncolor:
        t.image.colorspace_settings.name = "Non-Color"
    return t


t = tex("texture_diffuse.png")
if t: nt.links.new(t.outputs["Color"], b.inputs["Base Color"])
t = tex("texture_normal.png", True)
if t:
    n = nt.nodes.new("ShaderNodeNormalMap"); nt.links.new(t.outputs["Color"], n.inputs["Color"]); nt.links.new(n.outputs["Normal"], b.inputs["Normal"])
t = tex("texture_roughness.png", True)
if t: nt.links.new(t.outputs["Color"], b.inputs["Roughness"])
t = tex("texture_metallic.png", True)
if t: nt.links.new(t.outputs["Color"], b.inputs["Metallic"])
ob.data.materials.clear(); ob.data.materials.append(mat)
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_image_format="JPEG", export_jpeg_quality=90)
print("EXPORTED", OUT)
