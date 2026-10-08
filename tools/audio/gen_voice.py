"""Generate voice lines with ElevenLabs (build time only; the game makes no network calls).
   ELEVENLABS_API_KEY=... python3 tools/audio/gen_voice.py [--dry-run]
Idempotent: only (re)generates lines whose voice_text/voice/model changed (hash manifest).
The API key is read from the environment and never written anywhere.
"""
import os, sys, json, hashlib, urllib.request, urllib.error
ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
dialogue = json.load(open(os.path.join(ROOT, "data", "dialogue.json")))
cfg = json.load(open(os.path.join(ROOT, "data", "voices.json")))
out_dir = os.path.join(ROOT, "assets", "audio", "voice"); os.makedirs(out_dir, exist_ok=True)
man_path = os.path.join(out_dir, "manifest.json")
manifest = json.load(open(man_path)) if os.path.exists(man_path) else {}
dry = "--dry-run" in sys.argv
key = os.environ.get("ELEVENLABS_API_KEY", "")
if not key and not dry:
    sys.exit("ELEVENLABS_API_KEY not set")
total = 0
for line_id, line in dialogue.items():
    if line_id.startswith("_"): continue
    text = line.get("voice_text", line["text"]); voice = cfg["voices"][line["speaker"]]["voice_id"]
    h = hashlib.sha256(f'{text}|{voice}|{cfg["model_id"]}'.encode()).hexdigest()[:16]
    path = os.path.join(out_dir, line_id + ".mp3")
    if manifest.get(line_id) == h and os.path.exists(path):
        print("skip ", line_id); continue
    total += len(text)
    if dry: print("would generate", line_id, len(text), "chars"); continue
    body = json.dumps({"text": text, "model_id": cfg["model_id"],
                       "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.25}}).encode()
    req = urllib.request.Request(
        f'https://api.elevenlabs.io/v1/text-to-speech/{voice}?output_format={cfg["output_format"]}', data=body,
        headers={"xi-api-key": key, "Content-Type": "application/json", "Accept": "audio/mpeg"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r: audio = r.read()
    except urllib.error.HTTPError as e:
        sys.exit(f"{line_id}: HTTP {e.code} {e.read()[:200]!r}")
    open(path, "wb").write(audio); manifest[line_id] = h
    json.dump(manifest, open(man_path, "w"), indent=2)
    print("wrote", line_id, len(audio), "bytes")
print("characters billed this run:", total, f"(~{total // 2} credits at flash rate)")
