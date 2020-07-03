#!/bin/bash

# Global variables
declare SCRIPT_NAME="${0##*/}"
declare SCRIPT_DIR="$(cd ${0%/*} ; pwd)"
declare ROOT_DIR="$PWD"

TOKEN=45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221
REPORT=$1
PARENTDIR=($(dirname $PWD))
OUTPUTDIR=$PARENTDIR/apps

fetch_all_pdf() {
    while IFS=, read name hash; do
        echo "Fetching PDF for $name and saving to $OUTPUTDIR/$name/report.pdf"
        curl -s -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$hash" -H "Authorization:$TOKEN" --output "$OUTPUTDIR/$name/report.pdf"
    done < <(curl -s --url "http://localhost:8000/api/v1/scans?page=1&page_size=50" -H "Authorization:$TOKEN" | jq -c -r '.content|.[]|[.APP_NAME,.MD5]| @csv' | tr -d \")
}

fetch_all_json() {
    while IFS=, read name hash; do
        echo "Fetching JSON for $name and saving to $OUTPUTDIR/$name/report.json"
        curl -s -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$hash" -H "Authorization:$TOKEN" --output "$OUTPUTDIR/$name/report.json"
    done < <(curl -s --url "http://localhost:8000/api/v1/scans?page=1&page_size=50" -H "Authorization:$TOKEN" | jq -c -r '.content|.[]|[.APP_NAME,.MD5]| @csv' | tr -d \")
}

fetch_report_pdf() {
    eval $(curl -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$REPORTHASH" -H "Authorization:$TOKEN" >$APKNAME.pdf)
    exit
}

fetch_report_json() {
    eval $(curl -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$REPORTHASH" -H "Authorization:$TOKEN" >$APKNAME.json)
    exit
}

fetch_reports() {
    eval $(curl -X POST --url http://localhost:8000/api/v1/download_pdf --data "hash=$REPORTHASH" -H "Authorization:$TOKEN" >$APKNAME.pdf)
    eval $(curl -X POST --url http://localhost:8000/api/v1/report_json --data "hash=$REPORTHASH" -H "Authorization:$TOKEN" >$APKNAME.json)
    exit
}

list_scans() {
    curl --url "http://localhost:8000/api/v1/scans?page=1&page_size=50" -H "Authorization:$TOKEN"| jq -c -r '.content|.[]|[.APP_NAME,.MD5]'
}

while [ "$1" != "" ]; do
    case $1 in
    -p)
        fetch_all_pdf
        ;;
    -j)
        fetch_all_json
        ;;
    pdf)
        shift
        APKNAME=$1
        shift
        REPORTHASH=$1
        fetch_report_pdf
        ;;
    json)
        shift
        APKNAME=$1
        shift
        REPORTHASH=$1
        fetch_report_json
        ;;
    reports)
        shift
        APKNAME=$1
        shift
        REPORTHASH=$1
        fetch_reports
        ;;
    -l)
        list_scans
        ;;
    *)
        usage
        exit 1
        ;;
    esac
    shift
done