# cat apps/Hospify/Hospify.json | jq -s -f jq/manifest_analysis.jq
# find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -f jq/manifest_analysis.jq >> "$file"tmp; done

map({level: .manifest_analysis[].stat})
| group_by(.level)
| map({level: .[0].level, count: length})
| map({manifest: .level, count: .count})
| reduce .[] as $d ({}; .[$d.manifest] = $d.count)
| with_entries(if .key == "high" then .key = "manifest_high" else . end)
| with_entries(if .key == "info" then .key = "manifest_info" else . end)
| with_entries(if .key == "medium" then .key = "manifest_medium" else . end)
| {manifest_high: .manifest_high, manifest_medium: .manifest_medium, manifest_info: .manifest_info}