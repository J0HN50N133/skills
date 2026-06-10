# Logical-Flow Infographic Template v3

## Core Design: Visual Storytelling with Guided Reading Path

### Problem with Current Design
- ❌ No visual hierarchy (all panels equal weight)
- ❌ No reading order (viewer doesn't know where to start)
- ❌ No narrative logic (data is scattered)
- ❌ Decorative > Informative

### Solution: Comic-Style Visual Flow

## Design Principles

### 1. Visual Hierarchy (视觉层次)
```
TITLE (最大, 最醒目)
  ↓
LEADING PANEL (引导面板 - 第二大的视觉元素)
  ↓
SUPPORTING PANELS (支撑面板 - 中等大小, 按逻辑排列)
  ↓
KEY TAKEAWAY (底部横幅 - 总结性, 视觉收束)
```

### 2. Reading Path (阅读路径)
Use visual cues to guide the eye:
- **Arrow indicators** (箭头指示)
- **Number badges** (编号标签: ① ② ③ ④)
- **Character gaze direction** (角色视线引导)
- **Color flow** (颜色渐变引导)

### 3. Narrative Structure (叙事结构)
Choose ONE of these structures based on content type:

#### For Videos/Documentaries: "Story Arc"
```
① HOOK (开场hook) → ② PROBLEM (问题) → ③ ANALYSIS (分析) 
→ ④ SOLUTION (解决方案) → ⑤ INSIGHT (洞察)
```

#### For Academic Papers: "Paper Structure"
```
① MOTIVATION (研究动机) → ② METHOD (方法) → ③ RESULT (结果)
→ ④ COMPARISON (对比) → ⑤ CONCLUSION (结论)
```

#### For Technical Content: "Problem-Solution"
```
① CHALLENGE (挑战) → ② ANALYSIS (分析) → ③ APPROACH (方法)
→ ④ IMPLEMENTATION (实现) → ⑤ IMPACT (影响)
```

### 4. Panel Size Coding (面板大小编码)
- **HERO PANEL** (40% of space): Core concept/visual metaphor
- **DATA PANELS** (30%): Key numbers, charts, comparisons
- **SUPPORT PANELS** (20%): Details, examples, quotes
- **BANNER** (10%): Takeaway message

---

## Template: Logical-Flow Infographic

```
A 16:9 infographic in {STYLE} style.

CRITICAL: Design with CLEAR VISUAL HIERARCHY and READING ORDER.
Number each section ①-⑤ to indicate reading sequence.

TITLE (TOP, LARGEST TEXT):
"{COMPELLING_CHINESE_TITLE}"
Subtitle: {SOURCE_INFO}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SECTION ① (TOP-LEFT, MEDIUM SIZE) - "开场: {TOPIC}"
[Hook the viewer - the problem/question]
- Key data point: {NUMBER}
- Visual: {ICON/CHART}
- Character: Pointing at the problem

SECTION ② (TOP-RIGHT, MEDIUM SIZE) - "核心: {CORE_CONCEPT}"
[Main technical content]
- Formula/algorithm: {FORMULA}
- Visual: {DIAGRAM}
- Character: Explaining/teaching

SECTION ③ (CENTER, LARGEST) - "深度: {DEEP_DIVE}"
[Most important visualization - the "hero" image]
- System architecture / comparison chart
- Visual metaphor: {METAPHOR}
- Character: Interacting with the system

SECTION ④ (BOTTOM-LEFT, SMALL-MEDIUM) - "数据: {EVIDENCE}"
[Supporting data / case study]
- Numbers: {DATA_POINTS}
- Visual: {TABLE/CHART}
- Character: Showing surprise/realization

SECTION ⑤ (BOTTOM-RIGHT, SMALL-MEDIUM) - "启示: {INSIGHT}"
[Takeaway / future direction]
- Quote: {QUOTE}
- Visual: {ICON}
- Character: Looking to the future

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BOTTOM BANNER (FULL WIDTH):
"💡 {KEY_TAKEAWAY_MESSAGE}"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VISUAL GUIDES (MANDATORY):
- Add arrows: ① → ② → ③ → ④ → ⑤
- Number badges on each section (large, visible)
- Character line-of-sight should flow with reading order
- Use {ACCENT_COLOR} for important numbers, {MUTED_COLOR} for background

STYLE: {STYLE_KEYWORDS}
```

---

## Example: arXiv LLM Training Paper (Logical Flow)

```
A 16:9 infographic in My Neighbor Totoro style (soft watercolor, gentle academic).

ALL TEXT CHINESE. Reading order clearly marked ①-⑤.

TITLE (TOP, 48pt equivalent):
"大规模AI模型训练：系统协同设计的艺术"
Subtitle: arXiv:2407.20018 | Jiangfei Duan et al. | 2024-07

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

① TOP-LEFT (30% width) - "为什么需要关注？"
Problem: LLaMA-3训练需要16K H100 GPU, 54天
Data: MFU仅38-41% (意味着61-62%的计算浪费)
Visual: 一个大大的"?"气泡, Totoro困惑地挠头
Number badge: ① (red, prominent)

② TOP-RIGHT (30% width) - "三大挑战SER"
Framework: 
- Scalability: 万卡协同
- Efficiency: MFU优化  
- Reliability: 容错
Visual: 三个挑战用图标表示, 38-41%用仪表盘显示
Number badge: ② (orange)

③ CENTER (40% width, HERO PANEL) - "训练系统全貌"
Core visualization: 4-layer architecture
- Layer 1: 应用 (GPT/LLaMA)
- Layer 2: 并行策略 (5种)
- Layer 3: 优化技术 (计算/内存/通信)
- Layer 4: 基础设施 (GPU/网络/存储)
Visual: 分层蛋糕图, Totoro在每层加优化
Number badge: ③ (green, largest)

④ BOTTOM-LEFT (25% width) - "关键数据"
LLaMA-3: 16K GPUs, 54天, 15T tokens
检查点: 980GB
网络: 900GB/s NVSwitch
Visual: 数据表格, Totoro指着表格
Number badge: ④ (blue)

⑤ BOTTOM-RIGHT (25% width) - "未来方向"
光学计算、协同设计、新架构
Quote: "每一层优化都能提升整体性能"
Visual: Totoro眺望远方,  sunrise背景
Number badge: ⑤ (purple)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BOTTOM BANNER:
"💡 从芯片到集群, 从计算到通信 — LLM训练是系统工程的终极考验"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VISUAL GUIDES:
- Arrows: ① → ② → ③ → ④ → ⑤ (gold arrows)
- Number badges: Large, colorful, positioned top-right of each panel
- Totoro gaze: ①困惑 → ②理解 → ③掌握 → ④惊讶 → ⑤展望
- Accent color: Warm orange for numbers, soft green for background

STYLE: Soft watercolor, moss green + warm brown, gentle but informative.
```

---

## Quality Checklist (UPDATED)

- [ ] **Reading order clear**: Numbers ①-⑤ visible on each panel
- [ ] **Visual hierarchy**: Title > Hero panel > Data panels > Banner
- [ ] **Narrative flow**: Hook → Problem → Analysis → Evidence → Insight
- [ ] **Data density**: Each panel has 3+ specific numbers/formulas
- [ ] **Visual guides**: Arrows or character gaze directing flow
- [ ] **Takeaway prominent**: Banner message is the "so what?"
- [ ] **Style description concise**: Under 30 words
- [ ] **Prompt length**: Under 1200 words (reduce timeout risk)
