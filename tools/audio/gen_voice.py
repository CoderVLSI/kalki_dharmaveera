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
api_key = os.environ.get("ELEVENLABS_API_KEY", "")
if not api_key and not dry:
    sys.exit("ELEVENLABS_API_KEY not set")
total = 0
# Hindi/Telugu need eleven_v4_turbo (Flash lacks Telugu); both models bill 0.5 credit/char.
LANG_MODEL = {"en": cfg["model_id"], "hi": "eleven_v4_turbo", "te": "eleven_v4_turbo"}
jobs = []
for line_id, line in dialogue.items():
    if line_id.startswith("_"): continue
    for lang in line.get("voiced_langs", ["en"]):
        text = line.get("voice_text", line["text"]) if lang == "en" else line.get("voice_text_" + lang, line.get("text_" + lang))
        if text: jobs.append((line_id, lang, text, line))
for line_id, lang, text, line in jobs:
    voice = cfg["voices"][line["speaker"]]["voice_id"]; model = LANG_MODEL[lang]
    h = hashlib.sha256(f'{text}|{voice}|{model}'.encode()).hexdigest()[:16]
    key = line_id if lang == "en" else f"{line_id}.{lang}"
    path = os.path.join(out_dir, key + ".mp3")
    if manifest.get(key) == h and os.path.exists(path):
        print("skip ", key); continue
    total += len(text)
    if dry: print("would generate", key, len(text), "chars"); continue
    body = json.dumps({"text": text, "model_id": model,
                       "voice_settings": {"stability": 0.5, "similarity_boost": 0.75, "style": 0.25}}).encode()
    req = urllib.request.Request(
        f'https://api.elevenlabs.io/v1/text-to-speech/{voice}?output_format={cfg["output_format"]}', data=body,
        headers={"xi-api-key": api_key, "Content-Type": "application/json", "Accept": "audio/mpeg"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r: audio = r.read()
    except urllib.error.HTTPError as e:
        sys.exit(f"{key}: HTTP {e.code} {e.read()[:200]!r}")
    open(path, "wb").write(audio); manifest[key] = h
    json.dump(manifest, open(man_path, "w"), indent=2)
    print("wrote", key, len(audio), "bytes")
print("characters billed this run:", total, f"(~{total // 2} credits at flash rate)")
