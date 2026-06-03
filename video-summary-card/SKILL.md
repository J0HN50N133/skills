---
name: video-summary-card
description: >
  When a user provides a video URL (Bilibili, YouTube, etc.) and wants a summary infographic image.
  Use this skill WHENEVER the user mentions: summarizing a video into an image/poster/card, generating
  a video infographic, making a visual summary from video content, or any request combining a video URL
  with image generation. Also trigger when the user pastes a video link and asks to "summarize",
  "visualize", "make a card for", or "generate an image from" it.
---

# Video Summary Card Generator

Generate high-density Chinese infographic images from video content. The output is a 16:9
poster-style image that presents the video's core arguments, data, and structure in a visually
compelling way.

## Workflow

### 1. Parse URL → determine platform

Extract the domain and match against known platforms:

| Pattern | Platform | opencli prefix |
|---------|----------|----------------|
| `bilibili.com/video/BV...` or `b23.tv` | Bilibili | `bilibili` |
| `youtube.com/watch?v=` or `youtu.be` | YouTube | `youtube` |

Extract the video ID from the URL. For Bilibili, it's the BV号 (e.g., `BV1TEVK6aE1G`).

### 2. Fetch video content via opencli

Run these in parallel:

```bash
opencli <site> video <id> -f json      # title, author, duration, stats, description
opencli <site> subtitle <id> -f json   # full subtitle text with timestamps
opencli <site> summary <id> -f json    # AI-generated chapter summary (if available)
```

If `subtitle` or `summary` fails, proceed with whatever data is available. The `video`
metadata is the minimum required.

### 3. Synthesize the content

Read the subtitle file (may be large, saved to disk) and produce a structured Chinese summary:

- **Core topic**: What is the video fundamentally about? (1 sentence)
- **Narrative structure**: How does the argument unfold? Opening hook → key demonstrations → mathematical/technical core → real-world applications → closing message.
- **Key data points**: Numbers, formulas, probabilities, comparisons cited in the video.
- **Memorable quotes or slogans**: Closings, punchlines, moral takeaways (in Chinese).

Keep it dense — every sentence should carry information. Avoid filler.

### 4. Choose art style

- If the user explicitly specifies an art style (e.g., "吉卜力风", "迷宫饭画风"), use it.
- Otherwise, pick one randomly from the pool in `references/anime-styles.md`. Seed with
  the video BV号 or ID for reproducibility across re-runs for the same video.
- Announce which style was picked to the user.

### 5. Build the image prompt

Read `references/prompt-template.md` for the full template structure. The prompt must:

- Start with "A 16:9 infographic illustration in the [STYLE] art style"
- All on-image text MUST be in **Chinese** (labels, titles, annotations, quotes)
- Cover these zones systematically:
  - **Title area**: Video title translated/adapted to a compelling Chinese headline
  - **Center**: The main visual metaphor (e.g., Galton board, bell curve, mechanism diagram)
  - **Corner panels**: Supporting evidence — data comparisons, formulas, before/after, key numbers
  - **Character elements**: Characters in the chosen art style interacting with the concepts
  - **Bottom ribbon**: Key takeaway quote or slogan
- Describe visual hierarchy: title largest → section headers → body annotations
- Specify color palette, linework, and rendering details consistent with the chosen style
- End with a quality/style booster: "scholarly adventure mood, hand-drawn ink lines, warm tones..."

Write the full prompt in **English** (ChatGPT/DALL-E understands English prompts better)
but specify that all visible text in the image must be Chinese.

### 6. Generate the image

```bash
opencli chatgpt image "<prompt>" -f plain
```

The command saves the image to `~/Pictures/chatgpt/` and prints the file path.

### 7. Report results

Show the user:
- The generated image file path
- The ChatGPT conversation link
- A quick summary of which style was used and what the image covers

If the user is on WSL, offer to open the folder in Windows Explorer:
```bash
explorer.exe "$(wslpath -w ~/Pictures/chatgpt)" 2>/dev/null
```
