#  find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -f jq/app_info.jq > "$file"tmp; done
# cat apps/Hospify/Hospify.json | jq -f jq/app_info.jq

.[]|{name: .app_name, version: .version_name, securityscore: .security_score, avg_cvss: .average_cvss, trackers_found: .trackers.detected_trackers, privacy_url: .playstore_details.privacyPolicy}