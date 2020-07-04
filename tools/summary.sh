#!/bin/bash

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"
PARENTDIR=($(dirname $PWD))

usage() {
  echo -e "\e[31mUsage: $0 {-d|-n|-p|-t|-c|-j}"
  echo ""
  echo "Options                                 "
  echo "    -d: Remove all summaries            "
  echo "    -n: Create new summaries            "
  echo "    -p: Pretify report JSON             "
  echo "    -t: Generate tracker summary        "
  echo "    -s: Generate summary CSV and JSON   "
}

pretty_json(){

    echo -e "\e[32mInfo: Pretifying JSON of every app"
    find $PARENTDIR/apps -maxdepth 3 -name '*report*.json' | while read file; do  cat "$file"|jq --sort-keys . > "$file"tmp; mv "$file"tmp "$file";done
    echo -e "\e[32mInfo: Pretifying JSON of every app"

}

del_summary(){

    echo -e "\e[31mInfo: Removing summary.json for every app"
    find $PARENTDIR/apps -maxdepth 3 -name '*summary.json' | while read file; do rm "${file}"; done
    find $PARENTDIR/apps -maxdepth 3 -name '*.jsontmp' | while read file; do rm "${file}"; done
    echo -e "\e[31mInfo: Removed summary.json for every app"

}

new_summary() {
    echo -e "\e[32mInfo: Creating new summary.json for every app"
    find $PARENTDIR/apps -maxdepth 3 -name '*report.json' | while read file; do  cat "$file"|jq -s -r -f jq/app_info.jq > "$file"tmp; done
    find $PARENTDIR/apps -maxdepth 3 -name '*report.json' | while read file; do  cat "$file"|jq -s -r -f jq/app_code_analysis.jq >> "$file"tmp; done
    find $PARENTDIR/apps -maxdepth 3 -name '*report.json' | while read file; do  cat "$file"|jq -s -r -f jq/app_manifest_analysis.jq >> "$file"tmp; done
    find $PARENTDIR/apps -maxdepth 3 -name '*report.json' | while read file; do  cat "$file"|jq -s -r -f jq/app_trackers.jq >> "$file"tmp; done
    find $PARENTDIR/apps -maxdepth 3 -name '*.jsontmp' | while read file; do cat "${file}" |jq -s 'add' > "${file%.jsontmp}"-summary.json; done
    find $PARENTDIR/apps -maxdepth 3 -name '*.jsontmp' | while read file; do rm "${file}"; done
    echo -e "\e[32mInfo: Created new summary.json for every app"
}

all_trackers(){
    echo -e "\e[32mInfo: Creating trackers.csv"
    find $PARENTDIR/apps -maxdepth 3 -name '*summary.json' | while read file; do  cat "$file"|jq -r '.trackers[]' >> trackers.out; done
    cat trackers.out |sort|uniq -c > $PARENTDIR/trackers.csv
    rm trackers.out
    echo -e "\e[32mInfo: Created trackers.csv"
}

summary_to_json_csv(){
    echo -e "\e[32mInfo: Creating summary JSON and CSV"
    echo "" > summary.tmp
    find $PARENTDIR/apps -maxdepth 3 -name '*summary.json' | while read file; do cat "${file}" >> summary.tmp; done
    cat summary.tmp|jq -s . > summary.json
    echo "name,version,securityscore,avg_cvss,trackers_found,code_high,code_good,code_info,code_warning,manifest_high,manifest_medium,manifest_info,privacyURL,privacy_url_correct,prominantTracking,completeTracking,DPIA,cookies,privacyScore,store,category" > summary.csv
    cat summary.json |jq -r '.[]|[.name, .version, .securityscore, .avg_cvss, .trackers_found, .code_high, .code_good, .code_info, .code_warning, .manifest_high, .manifest_medium, .manifest_info, .privacy_url, .privacy_url_correct, .prominantTracking, .completeTracking, .DPIA, .cookies, .privacyScore, .store, .category]|@csv' >> summary.csv
    rm summary.tmp
    mv summary.csv summary.json $PARENTDIR
    echo -e "\e[32mInfo: Created summary JSON and CSV"
}

function app_info() {
    echo -e "\e[32mInfo: Creating app info summary for every app"
    find $PARENTDIR/apps -maxdepth 3 -name 'report.json' | while read file; do mkdir -p "${PARENTDIR}/output/$(basename "${file%.json}")"; cat "$file"|jq -s -r -f jq/app_info.jq | tee "${PARENTDIR}/output/$(basename "${file%.json}")/app-info.json"; done
}

function app_manifest() {
    echo -e "\e[32mInfo: Creating manifest analysis summary for every app"
    find $PARENTDIR/apps -maxdepth 3 -name 'report.json' | while read file; do mkdir -p "${PARENTDIR}/output/$(basename "${file%.json}")"; cat "$file"|jq -s -r -f jq/app_manifest_analysis.jq | tee "${PARENTDIR}/output/$(basename "${file%.json}")/app-manifest.json"; done
    echo -e "\e[32mInfo: Created new summary.json for every app"
}

function app_code() {
    echo -e "\e[32mInfo: Creating code analysis summary for every app"
    find $PARENTDIR/apps -maxdepth 3 -name 'report.json' | while read file; do mkdir -p "${PARENTDIR}/output/$(basename "${file%.json}")"; cat "$file"|jq -s -r -f jq/app_code_analysis.jq | tee "${PARENTDIR}/output/$(basename "${file%.json}")/app-code.json"; done
}

function app_tracker() {
    echo -e "\e[32mInfo: Creating tracker summary for every app"
    find $PARENTDIR/apps -maxdepth 3 -name 'report.json' | while read file; do mkdir -p "${PARENTDIR}/output/$(basename "${file%.json}")"; cat "$file"|jq -s -r -f jq/app_trackers.jq | tee "${PARENTDIR}/output/$(basename "${file%.json}")/app-tracker.json"; done
}


if [[ -z "$1" ]]; then
    usage;
    exit;
else
   while [ "$1" != "" ]; do
    case $1 in
    -d)
        del_summary
        ;;
    -n)
        new_summary
        ;;
    -p)
        pretty_json
        ;;
    -t)
        all_trackers
        ;;
    -s)
        summary_to_json_csv
        ;;
    -ai)
        app_info
        ;;
    -am)
        app_manifest
        ;;
    -ac)
        app_code
        ;;
    -at)
        app_tracker
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done
fi
