# High-Density Image Prompt Template v2

## Design Principles

1. **Information First**: Every panel must contain specific data, numbers, or formulas
2. **Minimal Style Description**: 1-2 sentences for art style, not a paragraph
3. **Structured Data Visualization**: Use charts, tables, comparison matrices
4. **Concise Prompt**: Under 1500 words to avoid timeout

## Prompt Template

```
A 16:9 technical infographic in {STYLE_NAME} art style ({STYLE_VISUAL_HINTS}).

ALL TEXT IN CHINESE. 16:9 aspect ratio.

TITLE: {CHINESE_TITLE}
SUBTITLE: {SOURCE_INFO}

LAYOUT (6 panels + bottom banner):

┌─────────────────────────────────────────────────────────┐
│  PANEL 1 (TOP-LEFT)  │  PANEL 2 (TOP-RIGHT)             │
├─────────────────────────────────────────────────────────┤
│  PANEL 3 (CENTER - LARGEST)                             │
├─────────────────────────────────────────────────────────┤
│  PANEL 4 (BOTTOM-LEFT) │  PANEL 5 (BOTTOM-RIGHT)       │
└─────────────────────────────────────────────────────────┘
│  BOTTOM BANNER: {TAKEAWAY_QUOTE}                        │
└─────────────────────────────────────────────────────────┘

PANEL 1: {PANEL_1_TITLE}
{具体数据/图表描述 - 必须包含实际数字}
Example: "功率密度对比表: CPU 3-5kW | GPU 10/20/40/80/100kW+"

PANEL 2: {PANEL_2_TITLE}
{公式/算法/流程图 - 必须包含技术细节}
Example: "MFU = (有用计算量) / (峰值FLOPS × 时间) = 38-41%"

PANEL 3: {PANEL_3_TITLE - CENTER}
{核心可视化 - 系统架构图/对比图}
Example: "数据中心冰山图: 水面上是GPU集群, 水面下是冷却+供电设施"

PANEL 4: {PANEL_4_TITLE}
{应用场景/案例研究 - 具体例子}
Example: "XAI孟菲斯集群: 10万H100, 100万加仑/天, 150MW"

PANEL 5: {PANEL_5_TITLE}
{解决方案/技术对比 - 表格或矩阵}
Example: "优化技术对比: 计算(FP8) | 内存(ZeRO) | 通信(RDMA)"

BOTTOM BANNER: {TAKEAWAY_QUOTE}

STYLE: {3-5 key visual keywords only, not a paragraph}
```

## Example: High-Density Prompt for arXiv LLM Training Paper

```
A 16:9 technical infographic in My Neighbor Totoro art style (soft watercolor, green nature background, gentle atmosphere).

ALL TEXT IN CHINESE. 16:9 aspect ratio.

TITLE: 大规模语言模型分布式训练系统综述
SUBTITLE: arXiv:2407.20018 | 2024-07 | 9章节 | 200+参考文献

PANEL 1 (TOP-LEFT): 训练规模演变
- LLaMA-2: 2K A100, 21天
- LLaMA-3: 16K H100, 54天  
-  MFU仅38-41% (模型FLOPs利用率)
- 图表: GPU数量柱状图 + MFU饼图

PANEL 2 (TOP-RIGHT): 三大核心挑战 (SER框架)
- 可扩展性(Scalability): 万卡集群协同
- 效率(Efficiency): MFU优化空间62-59%
- 可靠性(Reliability): 周/月级训练容错
- 公式: MFU = (有效计算) / (峰值FLOPS × 时间)

PANEL 3 (CENTER): 训练系统分层架构图
```
[顶层] 应用层: GPT/LLaMA训练任务
  ↓
[第二层] 并行策略: 数据|张量|流水线|序列|专家
  ↓
[第三层] 优化技术: 计算(混合精度) | 内存(ZeRO) | 通信(RDMA)
  ↓  
[底层] 基础设施: GPU集群 + InfiniBand网络 + 并行文件系统
```
- Totoro角色: 大Totoro在顶层规划, 中小Totoro在各层优化

PANEL 4 (BOTTOM-LEFT): 关键基础设施参数
- GPU: NVIDIA H100, 80GB HBM3
- 网络: NVSwitch 900GB/s, InfiniBand NDR 400Gbps
- 存储: 检查点980GB (70B模型)
- 数据: 15T tokens ≈ 30TB
- 可视化: 参数对比表

PANEL 5 (BOTTOM-RIGHT): 优化技术分类树
- 计算优化: Attention算子 | FP8混合精度
- 内存优化: 重计算 | ZeRO分片 | 内存整理 | CPU/SSD卸载
- 通信优化: All-Reduce优化 | 通信调度 | 网内聚合
- 可视化: 三级优化技术矩阵

BOTTOM BANNER: "LLM训练是硬件-网络-存储-调度协同设计的系统工程"

STYLE: Soft watercolor texture, moss green + warm brown palette, gentle academic atmosphere.
```

## Quality Checklist

Before generating, verify:
- [ ] Each panel has at least 3-5 specific data points
- [ ] At least one panel contains a formula or algorithm
- [ ] All numbers are from the actual content (not generic)
- [ ] Prompt length under 1500 words
- [ ] Style description under 50 words
- [ ] Chinese text is technically accurate (not machine translation)
