#!/usr/bin/env bash
# Re-encode source videos in Asset/ to web-optimized 1080p H.264 in Asset/web/.
# Run from the repo root:  bash scripts/encode-web.sh
#
# Output:
#   - H.264 High profile, CRF 23, preset slow, yuv420p
#   - Longest side capped at 1920 (no upscaling)
#   - AAC 128 kbps stereo audio
#   - faststart atom so the browser can start playback before the full download

set -euo pipefail

SRC_DIR="Asset"
OUT_DIR="Asset/web"

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "error: ffmpeg not found on PATH."
    echo "install it and re-open your shell:  winget install Gyan.FFmpeg"
    exit 1
fi

mkdir -p "$OUT_DIR"
shopt -s nullglob nocaseglob

fmt_mb() { awk -v b="$1" 'BEGIN{printf "%.1f MB", b/1048576}'; }

total_in=0
total_out=0
count=0

for input in "$SRC_DIR"/*.mp4; do
    [[ "$input" == "$OUT_DIR"/* ]] && continue

    name=$(basename "$input")
    # normalize extension to lowercase .mp4 on output
    base="${name%.*}"
    output="$OUT_DIR/${base}.mp4"

    if [[ -f "$output" && "$output" -nt "$input" ]]; then
        in_bytes=$(wc -c <"$input")
        out_bytes=$(wc -c <"$output")
        total_in=$((total_in + in_bytes))
        total_out=$((total_out + out_bytes))
        count=$((count + 1))
        printf "[skip] %-30s  %s -> %s  (already up-to-date)\n" \
            "$name" "$(fmt_mb "$in_bytes")" "$(fmt_mb "$out_bytes")"
        continue
    fi

    printf "[encode] %s\n" "$name"
    ffmpeg -hide_banner -loglevel error -stats -y -i "$input" \
        -c:v libx264 -preset slow -crf 23 \
        -profile:v high -level 4.1 \
        -pix_fmt yuv420p \
        -vf "scale='min(1920,iw)':-2:flags=lanczos" \
        -c:a aac -b:a 128k -ac 2 \
        -movflags +faststart \
        "$output"

    in_bytes=$(wc -c <"$input")
    out_bytes=$(wc -c <"$output")
    pct=$(awk -v a="$out_bytes" -v b="$in_bytes" 'BEGIN{printf "%.0f", (a*100)/b}')
    total_in=$((total_in + in_bytes))
    total_out=$((total_out + out_bytes))
    count=$((count + 1))
    printf "  %s -> %s  (%s%% of source)\n\n" \
        "$(fmt_mb "$in_bytes")" "$(fmt_mb "$out_bytes")" "$pct"
done

echo "================================================"
printf "  Files processed:  %d\n" "$count"
printf "  Source total:     %s\n" "$(fmt_mb "$total_in")"
printf "  Optimized total:  %s\n" "$(fmt_mb "$total_out")"
if [[ "$total_in" -gt 0 ]]; then
    ratio=$(awk -v a="$total_out" -v b="$total_in" 'BEGIN{printf "%.0f", (a*100)/b}')
    saved=$(awk -v a="$total_out" -v b="$total_in" 'BEGIN{printf "%.1f", (b-a)/1048576}')
    printf "  Ratio:            %s%% of source  (saved %s MB)\n" "$ratio" "$saved"
fi
echo "================================================"
echo "Output folder: $OUT_DIR"
echo "Upload these files to R2 under the same keys your site already uses."
