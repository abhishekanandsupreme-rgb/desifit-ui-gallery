# 04 — Audio Prompts (SFX, notifications, music)

> **Why these prompts omit the brand ingredient:** `desifit-modern-craftsman`
> is a *visual* style reference. Audio prompts translate the brand instead
> into sound language — saffron warmth, fired-clay mood, tabula/tanpura/santoor
> timbres, mid-forward mixes for small speakers. Do NOT prepend the visual
> ingredient here; it would pull the audio toward image styles.

> **How to use:** Google Flow's native audio (Veo 3.1) is strongest when paired
> **with a video clip** — paste the clip prompt from `03_video.md` and describe
> the sound in the same Flow message, or ask Flow to "add sound to this clip".
> For **standalone audio** (pure SFX/music beds), prompt Flow as a sound-design
> session by describing the sound precisely and asking for a loop; export the
> audio track and reuse it in code. Where Flow lacks a dedicated music model,
> these prompts still give the Gemini agent everything needed to synthesize or
> guide the right music bed. Keep every cue ≤ 3s for UI sounds, ≤ 15s for loops.

---

## 1. UI interaction SFX (short, warm, non-annoying)

### Button tap (primary)
```
Generate a warm, premium UI button-tap sound: a soft, rounded "thock" like
pressing a clay tile, 120ms, gentle low-mid warmth, tiny reverb tail, no
metallic click, no harsh high frequencies. Output a short 0.15s loop.
```

### Button tap (secondary / ghost)
```
Generate a lighter UI tap: a subtle dry "tick" with a faint fabric/paper
texture, 80ms, very quiet, no reverb. Output a 0.1s loop.
```

### Stepper tap (workout rep counter)
```
Generate a satisfying stepper click: a crisp but warm single increment "tock"
with a subtle spring-resonance tail, 100ms, slightly brighter than the primary
tap but still rounded. Output a 0.12s loop.
```

### Toggle switch (settings)
```
Generate a tactile toggle-switch sound: a short two-phase "click-clack" like a
physical switch, warm wooden body, 180ms, satisfying but quiet. Output a 0.2s
loop.
```

### Error / cannot-do
```
Generate a gentle UI error sound: a low, warm "uh-uh" two-note descending tone,
soft marimba-like timbre, 400ms, kind and non-alarming, no harsh buzz. Output
a 0.4s clip.
```

---

## 2. Feedback & success sounds

### Success chime (habit checked / goal hit)
```
Generate a short celebratory success chime: two rising notes on a warm
santoor/plucked-string timbre with a soft bell overtone, leaf-green energy
(bright but warm), 600ms, gentle reverb, uplifting without being shrill.
Output a 0.6s clip.
```

### Achievement unlock (badge earned)
```
Generate an achievement-fanfare sound: a warm three-note rising motif on
plucked strings + soft brass, saffron-coloured energy, 1.2s, cinematic but
compact, ending on a soft sparkle. Output a 1.2s clip.
```

### Reward coin (rewards shop)
```
Generate a coin-reward sound: a bright but warm golden "ping" like a clay coin
landing, single note with a soft shimmer tail, 400ms, no harshness. Output a
0.4s loop.
```

### Confetti burst (with celebration clip)
```
Add sound to the celebration confetti clip: a joyful paper-pop burst layered
with a soft success chime and a tiny crowd-cheer whisper, 800ms, warm and
festive, low volume. Output a 0.8s clip.
```

### Scan success (calorie / barcode scanner)
```
Add sound to the scan-line sweep clip: a quiet, satisfying laser-read beep —
soft electronic blip rising to a resolved two-tone confirm, warm rather than
harsh, 350ms. Output a 0.35s clip.
```

### Rest-timer end (workout tracker)
```
Generate a workout rest-timer-end sound: a gentle three-note count-in on a
warm wooden block with a soft chime on the last note, 1s, calm but clearly
signals "go". Output a 1s clip.
```

---

## 3. Ambient & effect loops

### Streak flame flicker (habit tracker)
```
Add sound to the streak-flame clip: a very faint, cozy fire crackle loop —
two or three soft pops per second, low volume, warm, unobtrusive. Output a
4s seamless loop.
```

### Water pour loop (water intake)
```
Add sound to the glass-filling clip: a soft, clear water pour — gentle
splashes and bubbles, no harsh hiss, warm and refreshing, looping seamlessly
with the fill-and-drain cycle. Output a 5s loop.
```

### Boiling kettle (onboarding 2/5)
```
Add sound to the kettle clip: water boiling with a soft rolling hiss and faint
kettle rattle, low volume, warm room tone underneath. Output a 6s loop.
```

### Thali simmer (onboarding 1/5)
```
Add sound to the thali cinemagraph: gentle dal simmer, soft oil crackle, faint
kitchen ambience, warm and appetizing, low volume loop. Output a 6s loop.
```

---

## 4. Music beds (per screen mood)

> Prompt as one Flow audio session per mood; ask for a seamless loop and a
> reduced-volume master. All beds: **no vocals**, warm, budget-speaker-friendly
> (mid-forward, no sub-bass), BPM as noted.

### Welcome / onboarding — "Monsoon Morning" (70 BPM)
```
Create a warm, hopeful instrumental music bed for an Indian fitness app
onboarding: gentle tabla pulse at 70 BPM, soft tanpura drone, a light santoor
melody, warm pads in saffron-and-cream mood (major key), 16-bar seamless loop,
no vocals, no percussion fills, mid-forward mix for small phone speakers.
Output a 30s loop.
```

### Dashboard — "Fired Clay Focus" (90 BPM)
```
Create a subtle, premium instrumental bed for a fitness dashboard: soft
dholak groove at 90 BPM, muted guitar plucks, warm analog synth pad, very low
volume, no melody hooks, 16-bar seamless loop, no vocals. Output a 30s loop.
```

### Workout — "Steel & Sweat" (128 BPM)
```
Create an energetic instrumental workout bed: driving percussion at 128 BPM,
punchy kick, tabla-infused hi-hats, a motivating but not aggressive synth
riff in a warm major key, 16-bar loop with a gentle build every 8 bars, no
vocals. Output a 30s loop.
```

### Recipe / cooking — "Kitchen Jugaad" (80 BPM)
```
Create a light, happy instrumental bed for a recipe screen: cheerful
plucked-string melody (sitar-ish), soft hand-claps, gentle 80 BPM groove,
warm and appetizing mood, 16-bar seamless loop, no vocals. Output a 30s loop.
```

### Sleep — "Night Clay" (50 BPM)
```
Create a deeply calming instrumental bed for a sleep-recovery screen: very
slow 50 BPM, soft tanpura drone, sparse warm bells, no beats, long pads,
dreamy and spacious, no vocals, extremely low volume. Output a 30s loop.
```

### Rewards / leaderboard — "Ghar-Champ Swagger" (100 BPM)
```
Create a playful, rewarding instrumental bed: bouncy 100 BPM groove, warm
brass stabs, conga percussion, golden and celebratory mood, 16-bar seamless
loop, no vocals. Output a 30s loop.
```

### Focus / planner — "Paper & Plan" (85 BPM)
```
Create a calm productivity instrumental bed: soft 85 BPM, gentle piano or
kalimba notes, light shaker, warm neutral mood, sparse arrangement, 16-bar
seamless loop, no vocals. Output a 30s loop.
```

---

## 5. Brand audio

### Brand intro chime (matches 03 §6 brand plate)
```
Add sound to the DesiFit brand intro clip: a short, warm two-note brand
chime — plucked string + soft bell, saffron warmth, 1.5s, ending with a gentle
reverb bloom, no harshness. Output a 1.5s clip.
```

### App notification (general)
```
Generate a warm, friendly app notification sound: a soft two-note "ding-dong"
on a santoor-like timbre, 500ms, clearly audible on a phone speaker but never
startling. Output a 0.5s clip.
```

### Hydration reminder (water intake)
```
Generate a gentle hydration-reminder sound: a soft water-drop "plip" followed
by a single warm chime, 600ms, refreshing and kind, no alarm quality. Output
a 0.6s clip.
```
