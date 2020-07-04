# find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -f jq/trackers.jq >> "$file"tmp; done
# cat apps/Hospify/Hospify.json | jq -f jq/trackers.jq

.[]|.trackers.trackers|.[] |= map_values("privacy_trackers")|add
|to_entries
| map( {(.value) : {(.key):null} } )
| reduce .[] as $item ({}; . * $item)
| to_entries
| map({key:.key, value:(.value|keys)})
| from_entries