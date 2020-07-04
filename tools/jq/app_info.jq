#  find -maxdepth 3 -name '*.json' | while read file; do  cat "$file"|jq -s -f jq/app_info.jq > "$file"tmp; done
# cat apps/Hospify/Hospify.json | jq -f jq/app_info.jq

.[]|{app_name: .app_name, app_version: .version_name, security_score: .security_score, security_avg_cvss: .average_cvss, privacy_trackers_found: .trackers.detected_trackers, privacy_url: .playstore_details.privacyPolicy}