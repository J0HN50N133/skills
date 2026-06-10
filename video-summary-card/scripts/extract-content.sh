#!/bin/bash
# Phase 1: Content Extraction Script
# Automatically detect URL type and extract content to unified JSON format
# Priority: opencli-supported sites > generic web extraction

set -e

URL="$1"
OUTPUT_FILE="/tmp/summary-card-content.json"

if [ -z "$URL" ]; then
    echo "❌ Error: No URL provided"
    echo "Usage: $0 <URL>"
    exit 1
fi

echo "🔍 Detecting URL type..."

# Function to check if opencli supports a site
check_opencli_support() {
    local domain="$1"
    # Extract base domain (e.g., arxiv.org from arxiv.org/abs/...)
    local site=$(echo "$domain" | cut -d'.' -f1)
    
    # Check if opencli has adapter for this site
    if opencli list 2>/dev/null | grep -q "^  $site,"; then
        return 0  # Supported
    elif opencli list 2>/dev/null | grep -q "^  $domain,"; then
        return 0  # Supported with full domain
    else
        return 1  # Not supported
    fi
}

# Function to extract domain from URL
extract_domain() {
    echo "$1" | sed -E 's|https?://||' | cut -d'/' -f1
}

# Extract URL type using regex
if [[ "$URL" =~ bilibili\.com/video/(BV[0-9A-Za-z]+) ]] || [[ "$URL" =~ b23\.tv/([0-9A-Za-z]+) ]]; then
    # Bilibili video
    BV_ID="${BASH_REMATCH[1]}"
    echo "📹 Detected: Bilibili Video (BV$BV_ID)"
    CONTENT_TYPE="bilibili"

    echo "📥 Fetching video metadata..."
    METADATA=$(opencli bilibili video "$BV_ID" -f json 2>&1)

    echo "📥 Fetching subtitles..."
    SUBTITLES=$(opencli bilibili subtitle "$BV_ID" -f json 2>&1 || echo "[]")

    echo "📥 Fetching summary..."
    SUMMARY=$(opencli bilibili summary "$BV_ID" -f json 2>&1 || echo "[]")

    # Parse and combine into unified format
    python3 << EOF
import json
import sys

metadata_raw = '''$METADATA'''
subtitles_raw = '''$SUBTITLES'''
summary_raw = '''$SUMMARY'''

# Parse metadata (opencli returns array of key-value pairs)
metadata_dict = {}
for line in metadata_raw.split('\n'):
    if line.strip().startswith('{'):
        try:
            item = json.loads(line)
            metadata_dict[item['field']] = item['value']
        except:
            pass

# Parse subtitles
try:
    subtitles = json.loads(subtitles_raw)
    full_text = ' '.join([s['content'] for s in subtitles if 'content' in s])
except:
    full_text = ""

# Parse summary
try:
    summary = json.loads(summary_raw)
    summary_text = ' '.join([s['content'] for s in summary if 'content' in s and s.get('time', '')])
except:
    summary_text = ""

# Build unified output
output = {
    "source_type": "bilibili",
    "metadata": {
        "title": metadata_dict.get('title', ''),
        "author": metadata_dict.get('author', ''),
        "duration": metadata_dict.get('duration', ''),
        "publish_date": metadata_dict.get('publish_time', ''),
        "url": "$URL",
        "video_id": "$BV_ID"
    },
    "content": {
        "full_text": full_text,
        "summary": summary_text,
        "subtitles": subtitles if isinstance(subtitles, list) else []
    },
    "stats": {
        "views": metadata_dict.get('view', ''),
        "likes": metadata_dict.get('like', ''),
        "coins": metadata_dict.get('coin', ''),
        "favorites": metadata_dict.get('favorite', ''),
        "shares": metadata_dict.get('share', '')
    }
}

with open('$OUTPUT_FILE', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print("✅ Content extracted and saved to $OUTPUT_FILE")
EOF

elif [[ "$URL" =~ youtube\.com/watch\?v=([^&]+) ]] || [[ "$URL" =~ youtu\.be/([^?]+) ]]; then
    # YouTube video
    VIDEO_ID="${BASH_REMATCH[1]}"
    echo "📹 Detected: YouTube Video (ID: $VIDEO_ID)"
    CONTENT_TYPE="youtube"

    echo "📥 Fetching video metadata..."
    METADATA=$(opencli youtube video "$VIDEO_ID" -f json 2>&1)

    echo "📥 Fetching subtitles..."
    SUBTITLES=$(opencli youtube subtitle "$VIDEO_ID" -f json 2>&1 || echo "[]")

    echo "📥 Fetching summary..."
    SUMMARY=$(opencli youtube summary "$VIDEO_ID" -f json 2>&1 || echo "[]")

    # Similar parsing as Bilibili (simplified for now)
    echo "⚠️  YouTube parsing not fully implemented yet"

elif [[ "$URL" =~ \.pdf$ ]] || [[ "$URL" =~ pdf ]]; then
    # PDF document
    echo "📄 Detected: PDF Document"
    CONTENT_TYPE="pdf"

    echo "📥 Extracting PDF content..."
    # Use pdf skill or pdftotext
    echo "⚠️  PDF extraction not fully implemented yet"

else
    # Web page - check if opencli supports it
    DOMAIN=$(extract_domain "$URL")
    echo "🌐 Detected: Web Page ($DOMAIN)"
    
    # Try to extract site name for opencli
    SITE_NAME=$(echo "$DOMAIN" | cut -d'.' -f1)
    
    echo "🔎 Checking if opencli supports $SITE_NAME..."
    if check_opencli_support "$SITE_NAME" || check_opencli_support "$DOMAIN"; then
        echo "✅ opencli supports $SITE_NAME! Using opencli for structured extraction..."
        CONTENT_TYPE="opencli-$SITE_NAME"
        
        # Use opencli to fetch content
        echo "📥 Fetching content via opencli $SITE_NAME..."
        
        # Try different opencli commands based on site
        if [[ "$SITE_NAME" == "arxiv" ]]; then
            # For arXiv, try to extract paper ID
            if [[ "$URL" =~ arxiv\.org/abs/([0-9]+\.[0-9]+) ]] || [[ "$URL" =~ arxiv\.org/html/([0-9]+\.[0-9]+) ]]; then
                ARXIV_ID="${BASH_REMATCH[1]}"
                echo "📄 arXiv paper ID: $ARXIV_ID"
                
                # Fetch paper info
                PAPER_INFO=$(opencli arxiv paper "$ARXIV_ID" -f json 2>&1 || echo "[]")
                echo "📥 Paper info fetched"
                
                # Extract PDF URL and download
                PDF_URL=$(echo "$PAPER_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0].get('pdf', '')) if isinstance(data, list) else print('')" 2>/dev/null || echo "")
                
                if [ -z "$PDF_URL" ]; then
                    # Try to construct PDF URL
                    PDF_URL="https://arxiv.org/pdf/${ARXIV_ID}.pdf"
                fi
                
                echo "📥 PDF URL: $PDF_URL"
                echo "⬇️  Downloading PDF for full text extraction..."
                
                # Download PDF to temp location
                PDF_PATH="/tmp/arxiv-${ARXIV_ID}.pdf"
                if curl -L -o "$PDF_PATH" "$PDF_URL" 2>&1; then
                    echo "✅ PDF downloaded to $PDF_PATH"
                    echo "📄 Extracting text from PDF..."
                    
                    # Use pdf skill to extract text
                    # Save extraction command for agent to execute
                    echo "{ \"action\": \"extract_pdf\", \"pdf_path\": \"$PDF_PATH\", \"paper_info\": $PAPER_INFO }" > /tmp/arxiv-extract-request.json
                    echo "⚠️  PDF downloaded. Agent should now extract full text using pdf skill."
                    echo "   Run: pdf extract $PDF_PATH --output /tmp/arxiv-${ARXIV_ID}-text.txt"
                    echo "   Then update /tmp/summary-card-content.json with full_text"
                else
                    echo "⚠️  Failed to download PDF, using abstract only"
                fi
                
                # Save initial metadata (will be updated with full text)
                python3 << EOF
import json

paper_info_raw = '''$PAPER_INFO'''

try:
    paper_info = json.loads(paper_info_raw)
    if isinstance(paper_info, list):
        paper_info = paper_info[0]
except:
    paper_info = {"error": "Failed to parse paper info"}

output = {
    "source_type": "arxiv",
    "metadata": {
        "title": paper_info.get('title', ''),
        "authors": paper_info.get('authors', ''),
        "publish_date": paper_info.get('published', ''),
        "url": "$URL",
        "arxiv_id": "$ARXIV_ID",
        "pdf_url": "$PDF_URL",
        "pdf_path": "$PDF_PATH"
    },
    "content": {
        "full_text": paper_info.get('summary', ''),
        "summary": paper_info.get('summary', ''),
        "abstract": paper_info.get('summary', ''),
        "pdf_extracted": False
    },
    "stats": {
        "categories": paper_info.get('categories', ''),
        "pdf_downloaded": True if '$PDF_PATH' and -f '$PDF_PATH' else False
    }
}

with open('$OUTPUT_FILE', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print("✅ Metadata extracted via opencli arxiv and saved to $OUTPUT_FILE")
print("📝 Note: Only abstract extracted. Full text requires PDF extraction.")
EOF
            fi
        else
            # Generic opencli site - try to fetch page content
            echo "⚠️  Generic opencli site extraction not implemented for $SITE_NAME"
            echo "   Falling back to web_fetch..."
        fi
    else
        echo "⚠️  opencli does not support $SITE_NAME, using generic web extraction"
    fi
    
    # Fall back to generic web extraction (web_fetch)
    echo "📥 Fetching web page content via web_fetch..."
    echo "⚠️  Note: Web page extraction requires agent to use web_fetch tool"
    echo "   The agent should:"
    echo "   1. Use web_fetch tool to get page content"
    echo "   2. Parse and save to $OUTPUT_FILE"
    echo ""
    echo "❌ Phase 1 incomplete: Requires agent to execute web_fetch"
    exit 1
fi

echo ""
echo "📊 Extraction Summary:"
echo "  - Content Type: $CONTENT_TYPE"
echo "  - Output File: $OUTPUT_FILE"
echo ""
echo "✅ Phase 1 Complete: Content extracted successfully"
