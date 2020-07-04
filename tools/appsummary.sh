#!/bin/bash

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
# declare ROOT_DIR="$PWD"
declare ROOT_DIR=($(dirname $PWD))

OUTDIR=out

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
    mkdir -p "${ROOT_DIR}/$OUTDIR/$APP_NAME"
    mkdir -p "${ROOT_DIR}/$OUTDIR/$APP_NAME"
    eval $(curl -s -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$APP_HASH" -H "Authorization:$TOKEN" > "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.pdf")
    eval $(curl -s -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$APP_HASH" -H "Authorization:$TOKEN" > "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.json")
}

function fetch_all_report() {
    while IFS=, read APP_NAME APP_HASH; do
        echo "Fetching PDF / JSON for $APP_NAME and saving to $ROOT_DIR/$OUTDIR/$APP_NAME"
        mkdir -p "${ROOT_DIR}/$OUTDIR/$APP_NAME"
        # curl -s -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$APP_HASH" -H "Authorization:$TOKEN" --output "$ROOT_DIR/$OUTDIR/$APP_NAME/report.pdf"
        curl -s -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$APP_HASH" -H "Authorization:$TOKEN" --output "$ROOT_DIR/$OUTDIR/$APP_NAME/report.json"
    done < <(curl -s --url "http://localhost:8000/api/v1/scans?page=1&page_size=50" -H "Authorization:$TOKEN" | jq -c -r '.content|.[]|[.APP_NAME,.MD5]| @csv' | tr -d \")
}

function app_info() {
    echo -e "\e[32mINFO: Creating info summary for $APP_NAME"
    cat "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_info.jq | tee -a "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function app_manifest() {
    echo -e "\e[32mINFO: Creating manifest analysis for $APP_NAME"
    cat "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_manifest_analysis.jq | tee -a "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function app_code() {
    echo -e "\e[32mINFO: Creating code analysis for $APP_NAME"
    cat "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_code_analysis.jq | tee -a "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function app_tracker() {
    echo -e "\e[32mINFO: Creating tracker analysis for $APP_NAME"
    cat "${ROOT_DIR}/$OUTDIR/$APP_NAME/report.json"|jq -s -r -f ${ROOT_DIR}/tools/jq/app_trackers.jq | tee -a "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function app_additional_fields() {
    echo -e "\e[32mINFO: Creating additional fields for $APP_NAME"
    jo -p "privacy_url_correct=" "privacy_prominantTracking=" "privacy_completeTracking=" "privacy_DPIA=" "privacy_cookies=" "privacy_privacyScore=" "app_store=" "app_category=" | tee -a "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function app_summary() {
    echo -e "\e[32mInfo: Creating summary JSON for $APP_NAME"
    cat "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json" |jq -s '.|add' | tee "${ROOT_DIR}/$OUTDIR/$APP_NAME/summary.json"
}

function all_summary_to_json_csv(){
    echo -e "\e[32mInfo: Creating summary JSON and CSV"
    touch ${ROOT_DIR}/summary.tmp
    cat ${ROOT_DIR}/$OUTDIR/*/summary.json | tee -a ${ROOT_DIR}/summary.tmp
    cat ${ROOT_DIR}/summary.tmp|jq -s --sort-keys . | tee ${ROOT_DIR}/summaries/summary.json
    echo "app_name,app_version,app_store,app_category,security_score,security_avg_cvss,code_high,code_good,code_info,code_warning,manifest_high,manifest_medium,manifest_info,privacy_trackers_found,privacy_url,privacy_url_correct,privacy_prominantTracking,privacy_completeTracking,privacy_DPIA,privacy_cookies,privacy_privacyScore" > ${ROOT_DIR}/summaries/summary.csv
    cat ${ROOT_DIR}/summaries/summary.json |jq -r '.[]|[.app_name, .app_version, .app_store, .app_category, .security_score, .security_avg_cvss, .code_high, .code_good, .code_info, .code_warning, .manifest_high, .manifest_medium, .manifest_info, .privacy_trackers_found, .privacy_url, .privacy_url_correct, .privacy_prominantTracking, .privacy_completeTracking, .privacy_DPIA, .privacy_cookies, .privacy_privacyScore]|@csv' >> ${ROOT_DIR}/summaries/summary.csv
    rm ${ROOT_DIR}/summary.tmp
    echo -e "\e[32mInfo: Created summary JSON and CSV"
}

function all_trackers(){
    echo -e "\e[32mInfo: Creating trackers.csv"
    find "${ROOT_DIR}/apps/"* -maxdepth 3 -name 'summary.json' | while read file; do  cat "$file"|jq -r '.privacy_trackers[]' >> trackers.out; done
    cat trackers.out |sort|uniq -c > $ROOT_DIR/summaries/trackers.csv
    rm trackers.out
    echo -e "\e[32mInfo: Created trackers.csv"
}

function run_tests(){
    echo -e "\e[32mTEST: SCRIPT_DIR is $SCRIPT_DIR"
    echo -e "\e[32mTEST: ROOT_DIR is $ROOT_DIR"
    # echo -e "\e[32mTEST: PARENT_DIR is $PARENT_DIR"
}

function merge_json(){
    shopt -s dotglob
    find "${ROOT_DIR}/apps/"* -prune -type d | while IFS= read -r d; do
        APP_NAME=$(echo "${d}" |rev|cut -d / -f 1|rev)
        echo "${APP_NAME}"
        jq -s add "${ROOT_DIR}/out/${APP_NAME}/summary.json" "${ROOT_DIR}/apps/${APP_NAME}/summary.json" | jq --sort-keys . | tee "${ROOT_DIR}/out/${APP_NAME}/summary.json"
    done
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
        fetch_all_report
        ;;
    --all-trackers)
        all_trackers
        ;;
    --all-summary)
        shopt -s dotglob
            find "${ROOT_DIR}/${OUTDIR}/"* -prune -type d | while IFS= read -r d; do 
                APP_NAME=$(echo "${d}" |rev|cut -d / -f 1|rev)
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
    --test)
        run_tests
        ;;
    --merge)
        merge_json
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done
fi
