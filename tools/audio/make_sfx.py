"""Procedural SFX + music loops (zero API credits). Deterministic (seeded).
   python3 tools/audio/make_sfx.py   ->  assets/audio/{sfx,music}/*.ogg
"""
import numpy as np, wave, subprocess, os, tempfile

SR = 44100
rng = np.random.default_rng(1008)
OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio")


def t_(sec): return np.arange(int(SR * sec)) / SR
def noise(sec): return rng.standard_normal(int(SR * sec))
def env(sec, attack=0.005, decay=6.0):
    t = t_(sec); a = np.minimum(1.0, t / max(attack, 1e-4)); return a * np.exp(-t * decay)


def fft_filter(x, lo=None, hi=None, roll=200.0):
    X = np.fft.rfft(x); f = np.fft.rfftfreq(len(x), 1 / SR); g = np.ones_like(f)
    if lo: g *= 1 / (1 + np.exp(-(f - lo) / (roll * 0.25)))
    if hi: g *= 1 / (1 + np.exp((f - hi) / (roll * 0.25)))
    return np.fft.irfft(X * g, len(x))


def norm(x, peak=0.8): return x / (np.max(np.abs(x)) + 1e-9) * peak
def sine(f, sec): return np.sin(2 * np.pi * f * t_(sec))
def chirp(f0, f1, sec):
    t = t_(sec); ph = 2 * np.pi * (f0 * t + (f1 - f0) * t ** 2 / (2 * sec)); return np.sin(ph)


def ks_pluck(freq, sec, decay=0.996, brightness=0.5):
    n = int(SR / freq); y = np.zeros(int(SR * sec)); y[:n] = rng.uniform(-1, 1, n) * brightness + rng.uniform(-1, 1, n) * 0.5
    for i in range(n, len(y), n):
        blk = y[i - n:i]; y[i:i + n] = (0.5 * (blk + np.roll(blk, 1)) * decay)[: len(y[i:i + n])]
    return y


def save(name, x, folder="sfx", q=4):
    x = np.clip(x, -1, 1)
    d = os.path.join(OUT, folder); os.makedirs(d, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as f: p = f.name
    with wave.open(p, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((x * 32767).astype(np.int16).tobytes())
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", p, "-c:a", "libvorbis", "-q:a", str(q), os.path.join(d, name + ".ogg")], check=True)
    os.unlink(p)
    print("wrote", folder, name, f"{len(x) / SR:.1f}s")


# ---------------- SFX
def swish():
    s = 0.38; n = fft_filter(noise(s), lo=900, hi=7000)
    bell = np.sin(np.pi * np.clip(t_(s) / s, 0, 1)) ** 2
    return norm(n * bell + 0.25 * chirp(500, 2600, s) * bell, 0.7)

def hit():
    s = 0.28; thump = sine(95, s) * env(s, 0.002, 18) + sine(180, s) * env(s, 0.002, 30) * 0.5
    crack = fft_filter(noise(s), lo=1500, hi=9000) * env(s, 0.001, 45)
    return norm(thump + 0.7 * crack, 0.85)

def die():
    s = 0.6; return norm(chirp(160, 50, s) * env(s, 0.005, 6) + 0.3 * fft_filter(noise(s), hi=900) * env(s, 0.01, 8), 0.8)

def hoof():
    s = 0.16; return norm(sine(120, s) * env(s, 0.001, 38) + 0.5 * fft_filter(noise(s), lo=300, hi=2500) * env(s, 0.001, 55), 0.7)

def dash():
    s = 0.45; n = fft_filter(noise(s), lo=300, hi=3500); bell = np.sin(np.pi * np.clip(t_(s) / s, 0, 1)) ** 1.5
    return norm(n * bell + 0.3 * chirp(200, 900, s) * bell, 0.7)

def boom():  # Astra / rear shockwave
    s = 1.6; low = chirp(110, 38, s) * env(s, 0.004, 2.6)
    shimmer = sum(sine(f, s) * env(s, 0.2, 2.2) for f in (880, 1320, 1760, 2640)) * 0.08
    air = fft_filter(noise(s), lo=200, hi=2500) * env(s, 0.002, 5)
    return norm(low + shimmer + 0.4 * air, 0.9)

def hurt():
    s = 0.3; return norm(chirp(260, 120, s) * env(s, 0.003, 12) + 0.4 * fft_filter(noise(s), hi=1800) * env(s, 0.002, 20), 0.8)

def twang():
    return norm(ks_pluck(330, 0.5, 0.993, 1.0) * 1.0 + 0.4 * fft_filter(noise(0.5), lo=2000, hi=6000) * env(0.5, 0.001, 40), 0.7)

def chime():
    s = 2.4; return norm(sum(sine(f, s) * env(s, 0.003, d) * a for f, d, a in
        ((523.25, 2.2, 1.0), (784.0, 2.6, 0.6), (1046.5, 3.2, 0.5), (1318.5, 3.8, 0.35), (1568, 4.5, 0.25))), 0.8)

def fanfare():  # conch-like sustained swell into a bright chord
    s = 4.0; t = t_(s); sw = np.minimum(1, t / 1.2) * np.exp(-np.maximum(0, t - 2.6) * 1.1)
    conch = (sine(233.1, s) + 0.5 * sine(466.2, s) + 0.3 * sine(699.3, s) + 0.2 * sine(932.4, s)) * (1 + 0.04 * sine(5.5, s)) * sw
    bell = sum(sine(f, s) * env(s, 0.01, 1.4) * 0.25 for f in (523.25, 659.25, 783.99, 1046.5)) * (t > 1.3) * 1.0
    return norm(conch * 0.7 + bell, 0.85)

def click():
    s = 0.07; return norm(sine(900, s) * env(s, 0.001, 70) + 0.3 * sine(1800, s) * env(s, 0.001, 90), 0.6)


# ---------------- music loops (16 s, seamless by circular wrap)
def circ_add(dst, src, at):
    end = at + len(src)
    if end <= len(dst): dst[at:end] += src
    else: k = len(dst) - at; dst[at:] += src[:k]; dst[:end - len(dst)] += src[k:]

def kali_loop():
    s = 16.0; t = t_(s)
    drone = (sine(55, s) + 0.7 * sine(55.4, s) + 0.5 * sine(82.4, s) + 0.3 * sine(110.3, s)) * (0.8 + 0.2 * sine(1 / 8, s))
    wind = fft_filter(noise(s), lo=150, hi=900) * (0.5 + 0.5 * sine(1 / 16, s) ** 2) * 2.5
    drums = np.zeros(len(t))
    for beat in range(8):                       # slow war-drum, accented on 1 and 5
        hit_ = chirp(95, 48, 0.9) * env(0.9, 0.002, 4.2) * (1.0 if beat in (0, 4) else 0.55)
        circ_add(drums, hit_, int(beat * 2.0 * SR))
    x = drone * 0.35 + wind * 0.5 + drums * 0.7
    return norm(x, 0.7)

def satya_loop():
    s = 16.0; t = t_(s); x = np.zeros(len(t))
    sa, pa = 110.0, 165.0                        # tanpura: Pa, Sa, Sa, low Sa
    pattern = [pa, sa * 2, sa * 2, sa]
    for i in range(16):
        circ_add(x, ks_pluck(pattern[i % 4], 3.2, 0.9965, 0.8) * 0.6, int(i * 1.0 * SR))
    pad = (sine(220, s) + 0.6 * sine(277.2, s) * 0 + 0.5 * sine(330, s) + 0.3 * sine(440, s)) * (0.6 + 0.4 * sine(1 / 8, s)) * 0.1
    for f, at in ((880, 2.0), (1318.5, 6.0), (1046.5, 10.0), (1568, 13.5)):
        circ_add(x, sine(f, 2.5) * env(2.5, 0.01, 2.0) * 0.12, int(at * SR))
    air = fft_filter(noise(s), lo=2500, hi=7000) * 0.015
    return norm(x * 0.8 + pad + air, 0.7)


if __name__ == "__main__":
    for n, f in (("swish", swish), ("hit", hit), ("die", die), ("hoof", hoof), ("dash", dash), ("boom", boom),
                 ("hurt", hurt), ("twang", twang), ("chime", chime), ("fanfare", fanfare), ("click", click)):
        save(n, f())
    save("kali_loop", kali_loop(), "music", q=3)
    save("satya_loop", satya_loop(), "music", q=3)
