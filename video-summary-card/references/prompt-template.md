# ChatGPT Image Prompt Template

Use this structure when building the image generation prompt. Replace `{PLACEHOLDERS}`
with content derived from the video summary.

## Build instructions

The final prompt is composed by filling `references/prompt-template.md` with the
video-specific content synthesized in step 3. When assembling:

1. **Title**: Adapt the video title into a compelling Chinese headline that captures
   the core insight — not just a literal translation.
2. **Structure**: Identify 4-5 key concept zones from the video. Each becomes a visual panel.
3. **Content density**: Every zone should contribute a data point, formula, comparison,
   or quote. Never add decorative-only text.
4. **Style binding**: Replace `{STYLE_DESCRIPTION}` with the chosen style's visual traits
   from `references/anime-styles.md`.
5. **Character cameo**: For each zone, describe how a character in the chosen style
   interacts with the concept (observing, pointing, reacting).

## Template

```
A 16:9 infographic illustration in the {STYLE_NAME} ({STYLE_CN}) art style —
{STYLE_DESCRIPTION}.

LAYOUT: The composition is structured as an educational poster with decorative
borders and ornate section dividers. ALL visible text must be in CHINESE.

TITLE AREA (top, spanning full width):
A bold Chinese headline: "{CHINESE_TITLE}"
Below it, a subtitle line with video author and core stats.

CENTER ZONE (largest, dominant visual):
{MAIN_VISUAL_METAPHOR} — describe the central diagram, mechanism, or scene that
embodies the video's core concept. Characters from {STYLE_NAME} interact with it:
{CHARACTER_ACTION_IN_CENTER}.

TOP-LEFT PANEL:
{LEFT_PANEL_CONTENT} — a self-contained insight with labeled data comparison.
Include specific numbers and a brief annotation explaining the contrast.

TOP-RIGHT PANEL:
{RIGHT_PANEL_CONTENT} — a key formula or probability calculation shown on a
parchment scroll or chalkboard. The formula should be visually prominent.

BOTTOM-LEFT PANEL:
{BOTTOM_LEFT_CONTENT} — a real-world application or consequence of the concept,
with a metaphorical scene and characters reacting.

BOTTOM-RIGHT PANEL:
{BOTTOM_RIGHT_CONTENT} — supporting mathematical structure or data fingerprint
visualization, showing how the abstract concept manifests concretely.

RIBBON (bottom edge, spanning full width):
A flowing banner with the key Chinese takeaway quote: "{TAKEAWAY_QUOTE}"

VISUAL HIERARCHY: Title text largest → section headers medium → body annotations smaller.
Color palette and rendering consistent with {STYLE_NAME}: {STYLE_COLOR_NOTES}.
Scholarly adventure mood, hand-drawn quality, warm tones.
```

## Quality checks

Before submitting the prompt, verify:

- [ ] Every panel contains specific data/numbers/quotes from the video — not generic filler
- [ ] All text described for the image body is Chinese
- [ ] The style description is concrete (linework, palette, texture) not just the name
- [ ] At least one panel includes a formula or quantitative comparison
- [ ] The takeaway quote is a memorable closing line from the video (or a faithful adaptation)
- [ ] Dimensions specified as 16:9
- [ ] Prompt is in English, but all on-image text is specified in Chinese
