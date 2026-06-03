# Anime Art Styles Pool

When the user does not specify an art style, pick one randomly from this list.
Use the video ID as a seed for reproducible selection (hash the ID, mod by list length).

| # | Style Name (EN) | Style Name (CN) | Key Visual Traits |
|---|----------------|-----------------|-------------------|
| 1 | Frieren: Beyond Journey's End | 葬送的芙莉莲 | Soft watercolor backgrounds, clean delicate linework, muted earth tones, melancholic atmosphere, elegant character designs |
| 2 | Delicious in Dungeon | 迷宫饭 | Warm earthy palette, textured linework, RPG fantasy aesthetic, detailed monster/food renderings, hand-drawn manga panels |
| 3 | Porco Rosso | 红猪 | Ghibli sky-and-sea blues, vintage 1920s Mediterranean palette, hand-painted celluloid look, mechanical detail on aircraft |
| 4 | My Neighbor Totoro | 龙猫 | Soft rounded shapes, lush green nature backgrounds, warm nostalgic lighting, gentle whimsical character expressions |
| 5 | Paprika | 红辣椒 | Surreal vibrant color explosions, dreamlike transitions, detailed pattern work, bold saturated palette, fluid morphing shapes |
| 6 | Anohana | 未闻花名 | Summer warmth with soft lens flare, subtle pastel colors, delicate emotional character expressions, blooming flower motifs |
| 7 | Spirited Away | 千与千寻 | Ghibli bathhouse aesthetic, rich detailed backgrounds, warm lantern glow, intricate creature designs, gold and red accents |
| 8 | Demon Slayer | 鬼灭之刃 | Dynamic action lines, bold contrast ink-work, elemental color effects (water blue, fire red), ukiyo-e texture patterns |
| 9 | Attack on Titan | 进击的巨人 | Dramatic high-contrast shading, muted military palette, imposing scale, detailed linework on structures and gear |
| 10 | Your Name | 你的名字 | Radiant skies with lens flare, crisp urban backgrounds, soft warm lighting on characters, delicate color grading |

## Usage

```
style_index = hash(video_id) % len(styles)
chosen_style = styles[style_index]
```

Announce to user: "使用「{CN name}」画风生成总结图..."
