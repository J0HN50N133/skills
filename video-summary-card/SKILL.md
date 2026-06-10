---
name: video-summary-card
description: >
  Generate high-density Chinese infographic images from various content sources (video, web pages, articles).
  Use this skill WHENEVER the user provides a URL (Bilibili, YouTube, or any web page) and wants a summary
  infographic image. Also trigger when the user mentions: summarizing content into an image/poster/card,
  generating an infographic, making a visual summary, or any request combining a URL with image generation.
---

# Universal Summary Card Generator

Generate high-density Chinese infographic images from any URL content. The output is a 16:9
poster-style image that presents the core arguments, data, and structure in a visually compelling way.

## Multi-Phase Workflow

---

## Phase 1: Content Extraction (Script-Based)

**Goal**: Extract structured content from the URL using appropriate extractors.
**Executor**: Run `scripts/extract-content.sh` - automatically detects URL type and calls corresponding extractor.

### 1.1 Run Extraction Script

```bash
cd /Users/johnsonlee/.codebuddy/skills/video-summary-card
./scripts/extract-content.sh <URL>
```

The script will:
1. Detect URL type using regex (Bilibili, YouTube, PDF, or Web)
2. Call appropriate extractor (`opencli` for videos, `web_fetch` for web pages)
3. Save unified JSON to `/tmp/summary-card-content.json`

### 1.2 URL Type Detection

The script matches against these patterns:

| Pattern | Content Type | Extractor |
|---------|--------------|-----------|
| `bilibili.com/video/BV...` or `b23.tv` | Bilibili Video | `opencli bilibili` |
| `youtube.com/watch?v=` or `youtu.be` | YouTube Video | `opencli youtube` |
| `*.pdf` | PDF Document | `pdf` skill (TODO) |
| `*` (default) | Web Page | `web_fetch` tool |

### 1.3 Output Format

Extracted content is saved to `/tmp/summary-card-content.json`:
```json
{
  "source_type": "bilibili|youtube|web|pdf",
  "metadata": {
    "title": "...",
    "author": "...",
    "duration": "...",  // for videos
    "publish_date": "...",
    "url": "..."
  },
  "content": {
    "full_text": "...",  // main content text
    "summary": "...",    // if available
    "subtitles": [...]   // for videos
  },
  "stats": {  // if available
    "views": "...",
    "likes": "...",
    "word_count": "..."
  }
}
```

**Phase 1 Complete**: Script outputs "✅ Phase 1 Complete: Content extracted successfully"

---

## Phase 2: Content Synthesis (Agent-Based)

**Goal**: Analyze extracted content and produce a structured Chinese summary.
**Executor**: Agent reads `/tmp/summary-card-content.json` and synthesizes.

### 2.1 Read Extracted Content

```bash
# Verify Phase 1 completed successfully
cat /tmp/summary-card-content.json
```

### 2.2 Synthesize Structured Summary

As an agent, read the full content and produce a dense, structured Chinese summary:

**Required fields** (save to `/tmp/summary-card-synthesis.json`):

```json
{
  "core_topic": "核心主题 (1句话)",
  "narrative_structure": "内容结构描述",
  "key_data_points": [
    {
      "label": "数据点标签",
      "value": "数值",
      "context": "上下文"
    }
  ],
  "memorable_quotes": ["金句1", "金句2"],
  "sections": [
    {
      "title": "板块标题",
      "content": "板块内容",
      "visual_suggestion": "可视化建议"
    }
  ],
  "takeaway_quote": "最重要的收获",
  "source_metadata": {
    "title": "原标题",
    "author": "作者/来源",
    "stats": "统计数据"
  }
}
```

**Adapt synthesis based on content type**:
- **Videos**: Use timestamps to structure sections, extract spoken data points
- **Web pages**: Use headings/sections, extract written data and quotes
- **PDFs**: Use chapters/sections, extract figures and tables

Keep it dense — every sentence should carry information. Avoid filler.

### 2.3 Save Synthesis

```bash
# Save the synthesis JSON
# (Agent should write this file based on the template above)
```

**Phase 2 Complete**: Notify user "✅ Content synthesized, preparing visualization..."

---

## Phase 3: Art Style Selection & Image Generation

**Goal**: Choose art style and generate the infographic image.
**Executor**: Script + Agent collaboration.

### 3.1 Choose Art Style

- If the user explicitly specifies an art style (e.g., "吉卜力风", "迷宫饭画风"), use it.
- Otherwise, pick one randomly from the pool in `references/anime-styles.md`.
- **Seed**: Use the URL or content ID (BV号, video ID, or URL hash) for reproducibility.
- Announce which style was picked to the user.

Style selection algorithm:
```python
import hashlib
content_id = extract_id_from_url(url)  # BV号, video ID, or URL hash
seed = int(hashlib.md5(content_id.encode()).hexdigest(), 16)
style_index = seed % 10  # 10 styles available
```

### 3.2 Build Image Prompt

Read `references/prompt-template.md` for the full template structure.

**Adaptations for different content types**:
- **Videos**: Use video title/author, timestamp-based structure
- **Web pages**: Use article title/source, section-based structure
- **PDFs**: Use document title/author, chapter-based structure

The prompt must:
- Start with "A 16:9 infographic illustration in the [STYLE] art style"
- All on-image text MUST be in **Chinese** (labels, titles, annotations, quotes)
- Cover these zones systematically:
  - **Title area**: Content title adapted to a compelling Chinese headline
  - **Center**: The main visual metaphor
  - **Corner panels**: Supporting evidence — data comparisons, key numbers, formulas
  - **Character elements**: Characters in the chosen art style interacting with concepts
  - **Bottom ribbon**: Key takeaway quote or slogan
- Describe visual hierarchy and color palette consistent with chosen style
- End with quality booster

Write the full prompt in **English** but specify all visible text must be Chinese.

### 3.3 Generate Image

```bash
opencli chatgpt image "<prompt>" -f plain
```

The command saves the image to `~/Pictures/chatgpt/` and prints the file path.

### 3.4 Report Results

Show the user:
- The generated image file path
- The ChatGPT conversation link
- A quick summary of which style was used and what the image covers
- Key data points visualized

If the user is on WSL, offer to open the folder in Windows Explorer:
```bash
explorer.exe "$(wslpath -w ~/Pictures/chatgpt)" 2>/dev/null
```

---

## Error Handling

- If Phase 1 fails (content extraction): Notify user with specific error, suggest alternative extraction method
- If Phase 2 fails (synthesis): Proceed with raw content, notify user of degraded quality
- If Phase 3 fails (image generation): Retry with simplified prompt, notify user

## Notes

- Phases are sequential and explicit - each phase must complete before the next begins
- Phase 1 is script-based for speed and reliability
- Phase 2 is agent-based for intelligent content understanding
- Phase 3 combines both for optimal image generation
- The skill is now content-type agnostic - works with any URL that can be extracted
