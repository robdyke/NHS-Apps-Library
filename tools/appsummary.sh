#!/bin/bash

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"
PARENTDIR=($(dirname $PWD))

TOKEN=45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221

usage() {
  echo -e "\e[31mUsage: $0 {-ai|-am|-ac|-at|-af|-as} APP_NAME"
  echo -e "\e[31mUsage: $0 {-ls}"
  echo -e "\e[31mUsage: $0 {-ar} APP_NAME APP_HASH"
  echo -e "\e[31mUsage: $0 {--all-report|--all-summary}"
  echo ""
}

function list_scans() {
    curl -s --url "http://localhost:8000/api/v1/scans?page=1&page_size=$SCANS" -H "Authorization:$TOKEN"| jq -c -r '.content|.[]|[.APP_NAME,.MD5]|@csv'
}

function fetch_report() {
    echo -e "\e[32mINFO: Fetching PDF / JSON for $APP_NAME"
    mkdir -p "${ROOT_DIR}/apps/$APP_NAME"
    eval $(curl -s -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$APP_HASH" -H "Authorization:$TOKEN" > "${ROOT_DIR}/apps/$APP_NAME/report.pdf")
    eval $(curl -s -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$APP_HASH" -H "Authorization:$TOKEN" > "${ROOT_DIR}/apps/$APP_NAME/report.json")
}

function fetch_all_report() {
    while IFS=, read APP_NAME APP_HASH; do
        echo "Fetching PDF / JSON for $APP_NAME and saving to $ROOT_DIR/apps/$APP_NAME"
        curl -s -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$APP_HASH" -H "Authorization:$TOKEN" --output "$ROOT_DIR/apps/$APP_NAME/report.pdf"
        curl -s -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$APP_HASH" -H "Authorization:$TOKEN" --output "$ROOT_DIR/apps/$APP_NAME/report.json"
    done < <(curl -s --url "http://localhost:8000/api/v1/scans?page=1&page_size=50" -H "Authorization:$TOKEN" | jq -c -r '.content|.[]|[.APP_NAME,.MD5]| @csv' | tr -d \")
}

function app_info() {
    echo -e "\e[32mINFO: Creating info summary for $APP_NAME"
    cat "${ROOT_DIR}/apps/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_info.jq | tee -a "${ROOT_DIR}/apps/$APP_NAME/summary.json"
}

function app_manifest() {
    echo -e "\e[32mINFO: Creating manifest analysis for $APP_NAME"
    cat "${ROOT_DIR}/apps/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_manifest_analysis.jq | tee -a "${ROOT_DIR}/apps/$APP_NAME/summary.json"
}

function app_code() {
    echo -e "\e[32mINFO: Creating code analysis for $APP_NAME"
    cat "${ROOT_DIR}/apps/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_code_analysis.jq | tee -a "${ROOT_DIR}/apps/$APP_NAME/summary.json"
}

function app_tracker() {
    echo -e "\e[32mINFO: Creating tracker analysis for $APP_NAME"
    cat "${ROOT_DIR}/apps/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_trackers.jq | tee -a "${ROOT_DIR}/apps/$APP_NAME/summary.json"
}

function app_additional_fields() {
    echo -e "\e[32mINFO: Creating additional fields for $APP_NAME"
    jo -p "privacyURLcorrect=" "prominantTracking=" "completeTracking=" "DPIA=" "cookies=" "privacyScore=" "store=" "category=" | tee -a "${ROOT_DIR}/apps/$APP_NAME"/summary.json
}

function app_summary() {
    echo -e "\e[32mInfo: Creating summary JSON for $APP_NAME"
    cat "${ROOT_DIR}/apps/$APP_NAME/summary.json" |jq -s '.|add' | tee "${ROOT_DIR}/apps/$APP_NAME/summary.json"
}

function all_summary_to_json_csv(){
    echo -e "\e[32mInfo: Creating summary JSON and CSV"
    cat ${ROOT_DIR}/apps/*/summary.json | tee -a ${ROOT_DIR}/summary.tmp
    cat ${ROOT_DIR}/summary.tmp|jq -s . | tee ${ROOT_DIR}/summary.json
    echo "name,version,securityscore,avg_cvss,trackers_found,code_high,code_good,code_info,code_warning,manifest_high,manifest_medium,manifest_info,privacyURL,privacyURLcorrect,prominantTracking,completeTracking,DPIA,cookies,privacyScore,store,category" > ${ROOT_DIR}/summary.csv
    cat ${ROOT_DIR}/summary.json |jq -r '.[]|[.name, .version, .securityscore, .avg_cvss, .trackers_found, .code_high, .code_good, .code_info, .code_warning, .manifest_high, .manifest_medium, .manifest_info, .privacy_url, .privacyURLcorrect, .prominantTracking, .completeTracking, .DPIA, .cookies, .privacyScore, .store, .category]|@csv' >> ${ROOT_DIR}/summary.csv
    rm ${ROOT_DIR}/summary.tmp
    echo -e "\e[32mInfo: Created summary JSON and CSV"
}

if [[ -z "$1" ]]; then
    usage;
    exit;
else
   while [ "$1" != "" ]; do
    case $1 in
    -i)
        shift
        APP_NAME=$1
        app_info
        ;;
    -m)
        shift
        APP_NAME=$1
        app_manifest
        ;;
    -c)
        shift
        APP_NAME=$1
        app_code
        ;;
    -t)
        shift
        APP_NAME=$1
        app_tracker
        ;;
    -f)
        shift
        APP_NAME=$1
        app_additional_fields
        ;;
    -s)
        shift
        APP_NAME=$1
        app_summary
        ;;
    --summary)
        shift
        APP_NAME=$1
        app_info
        app_manifest
        app_code
        app_tracker
        app_additional_fields
        app_summary
        ;;
    -ls)
        shift
        SCANS=${1:-5}
        list_scans
        ;;
    --report)
        shift
        APP_NAME=$1
        shift
        APP_HASH=$1
        fetch_report
        ;;
    --all-report)
        shift
        APP_NAME=$1
        shift
        APP_HASH=$1
        fetch_all_report
        ;;
    --all-summary)
        shopt -s dotglob
            find apps/* -prune -type d | while IFS= read -r d; do 
                APP_NAME=$(echo "${d}" |cut -d / -f 2)
                echo "${APP_NAME}"
        app_info
        app_manifest
        app_code
        app_tracker
        app_additional_fields
        app_summary
        done
        ;;
    --out)
        all_summary_to_json_csv
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done
fi
