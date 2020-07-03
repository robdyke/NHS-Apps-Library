# cat apps/Hospify/Hospify.json | jq -s -f jq/code_analysis.jq
# find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -f jq/code_analysis.jq >> "$file"tmp; done

map({name: .name, level: .code_analysis[].level})
| group_by(.level)
| map({level: .[0].level, count: length})
| map({code: .level, count: .count})
| reduce .[] as $d ({}; .[$d.code] = $d.count)
| with_entries(if .key == "high" then .key = "code_high" else . end)
| with_entries(if .key == "info" then .key = "code_info" else . end)
| with_entries(if .key == "warning" then .key = "code_warning" else . end)
| with_entries(if .key == "good" then .key = "code_good" else . end)
| {code_high: .code_high, code_warning: .code_warning, code_good: .code_good, code_info: .code_info}
