#!/usr/bin/env bash
# Upload Asset/web/*.mp4 to the issac-3d-asset R2 bucket using the same keys
# the live site references. Re-running is safe — R2 overwrites objects.
#
# Usage:  bash scripts/upload-web.sh

set -euo pipefail

BUCKET="issac-3d-asset"
SRC_DIR="Asset/web"

# file (in Asset/web/) -> R2 key (as the site references it)
declare -A KEYMAP=(
    ["CAT_2023_v1.mp4"]="CAT_2023_v1.mp4"
    ["chikki_v1.mp4"]="chikki_v1.mp4"
    ["citrus_v1.mp4"]="citrus_v1.MP4"
    ["frozenbottle_v1.mp4"]="frozenbottle_v1.mp4"
    ["hero_page_v1.mp4"]="hero_page_v1.mp4"
    ["hyd_vik_v1.mp4"]="hyd_vik_v1.mp4"
    ["kite_v1.mp4"]="kite_v1.mp4"
    ["lakahfay_v1.mp4"]="lakahfay_v1.mp4"
    ["LITTLE SCHOLARS_v1.mp4"]="LITTLE SCHOLARS_v1.mp4"
    ["personal_pj_v1.mp4"]="personal_pj_v1.mp4"
    ["Pure_v1.mp4"]="Pure_v1.mp4"
    ["showreel_v1.mp4"]="showreel_v1.mp4"
)

count=0
total=${#KEYMAP[@]}
for local_name in "${!KEYMAP[@]}"; do
    count=$((count + 1))
    key="${KEYMAP[$local_name]}"
    local_path="$SRC_DIR/$local_name"
    if [[ ! -f "$local_path" ]]; then
        echo "[$count/$total] skip (missing): $local_name"
        continue
    fi
    size=$(wc -c <"$local_path")
    size_mb=$(awk -v b="$size" 'BEGIN{printf "%.1f", b/1048576}')
    echo "[$count/$total] uploading $local_name -> $key  (${size_mb} MB)"
    wrangler r2 object put "$BUCKET/$key" \
        --file "$local_path" \
        --content-type "video/mp4" \
        --remote
done

echo ""
echo "All uploads complete."
