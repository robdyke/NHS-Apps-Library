# JQ

```bash
find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -r -f jq/app_info.jq > "$file"tmp; done
find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -r -f jq/code_analysis.jq >> "$file"tmp; done
find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -r -f jq/manifest_analysis.jq >> "$file"tmp; done
find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -r -f jq/trackers.jq >> "$file"tmp; done
find -maxdepth 3 -name '*.jsontmp' | while read file; do cat "${file}" |jq -s 'add' > "${file%.jsontmp}"-summary.json; done
find -maxdepth 3 -name '*.jsontmp' | while read file; do rm "${file}"; done
```

`find -maxdepth 3 -name '*-summary.json' | while read file; do cat "${file}" |jq -r -f jq/to_csv.jq >> out.csv; done`

```bash
find -maxdepth 3 -name '*.jsontmp' | while read file; do mv "${file}" "${file%.jsontmp}"-summary.json; done
```