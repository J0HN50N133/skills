#!/usr/bin/env python3
"""
Phase 2: Content Synthesis Script
Reads extracted content and produces structured Chinese summary
"""

import json
import sys
from pathlib import Path

INPUT_FILE = "/tmp/summary-card-content.json"
OUTPUT_FILE = "/tmp/summary-card-synthesis.json"


def load_extracted_content():
    """Load extracted content from Phase 1"""
    if not Path(INPUT_FILE).exists():
        print(f"❌ Error: {INPUT_FILE} not found. Run Phase 1 first.")
        sys.exit(1)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


def synthesize_video_content(content_data):
    """Synthesize video content (Bilibili/YouTube)"""
    full_text = content_data.get('content', {}).get('full_text', '')
    summary = content_data.get('content', {}).get('summary', '')
    metadata = content_data.get('metadata', {})

    # This is where the agent would do intelligent synthesis
    # For now, we'll create a structure for the agent to fill

    synthesis = {
        "core_topic": "",  # Agent fills this
        "narrative_structure": "",  # Agent fills this
        "key_data_points": [],  # Agent extracts this
        "memorable_quotes": [],  # Agent extracts this
        "sections": [],  # Agent creates this
        "takeaway_quote": "",  # Agent selects this
        "source_metadata": {
            "title": metadata.get('title', ''),
            "author": metadata.get('author', ''),
            "duration": metadata.get('duration', ''),
            "stats": content_data.get('stats', {})
        }
    }

    return synthesis


def synthesize_web_content(content_data):
    """Synthesize web page content"""
    full_text = content_data.get('content', {}).get('full_text', '')
    metadata = content_data.get('metadata', {})

    synthesis = {
        "core_topic": "",  # Agent fills this
        "narrative_structure": "",  # Agent fills this
        "key_data_points": [],  # Agent extracts this
        "memorable_quotes": [],  # Agent extracts this
        "sections": [],  # Agent creates this
        "takeaway_quote": "",  # Agent selects this
        "source_metadata": {
            "title": metadata.get('title', ''),
            "author": metadata.get('author', ''),
            "url": metadata.get('url', ''),
            "word_count": content_data.get('content', {}).get('word_count', 0)
        }
    }

    return synthesis


def main():
    print("🎯 Phase 2: Content Synthesis")
    print("=" * 50)

    # Load content from Phase 1
    content_data = load_extracted_content()
    source_type = content_data.get('source_type', 'unknown')

    print(f"📖 Source Type: {source_type}")
    print(f"📄 Content loaded from {INPUT_FILE}")
    print("")

    # Synthesize based on content type
    if source_type in ['bilibili', 'youtube', 'video']:
        print("🎬 Synthesizing video content...")
        synthesis = synthesize_video_content(content_data)
    elif source_type in ['web', 'pdf']:
        print("📄 Synthesizing text content...")
        synthesis = synthesize_web_content(content_data)
    else:
        print(f"⚠️  Unknown source type: {source_type}")
        synthesis = {"error": "Unknown source type"}

    # Save template for agent to fill
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(synthesis, f, ensure_ascii=False, indent=2)

    print(f"✅ Synthesis template saved to {OUTPUT_FILE}")
    print("")
    print("🤖 Next: Agent should read this file and fill in the synthesis fields")
    print("   - core_topic")
    print("   - narrative_structure")
    print("   - key_data_points")
    print("   - memorable_quotes")
    print("   - sections")
    print("   - takeaway_quote")
    print("")
    print("✅ Phase 2 Complete: Synthesis template ready")


if __name__ == "__main__":
    main()
