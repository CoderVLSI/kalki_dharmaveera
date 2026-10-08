"""Start the MCP-for-Blender socket server from inside a running Blender.

Usage (headless box, needs xvfb):
    xvfb-run -a blender --python tools/blender_mcp_launcher.py

The add-on drains its command queue from a bpy.app.timers callback, which only
fires in a real event loop, so plain `blender --background` will not work.
"""
import os
import addon_utils
import bpy

PORT = int(os.environ.get("BLENDER_MCP_PORT", "9876"))
MODULE = "blender_mcp"


def start():
    addon_utils.enable(MODULE, default_set=True, persistent=True)
    mod = __import__(MODULE)
    bpy.context.scene.blendermcp_port = PORT
    server = mod.BlenderMCPServer(port=PORT)
    server.start()
    bpy.types.blendermcp_server = server
    print(f"[kalki] Blender MCP listening on localhost:{PORT}", flush=True)
    return None


# Defer one tick so the UI/event loop is up before the server registers timers.
bpy.app.timers.register(start, first_interval=1.0)
