# Notes

'python mass_static_analysis.py -s 127.0.0.1:8000  -k <rest_api_key> -d /home/files/'

'robd@nuc:~/projects/apps/Mobile-Security-Framework-MobSF/scripts$ python3.6 mass_static_analysis.py -s 127.0.0.1:8000  -k 45a5ac0c6084ec1293b7574623f45da889d77da3e5dd772fc828bedfa66e6221 -d /home/robd/projects/apps/NHS-Apps-Library/APKS -r 1'


```sh
cat apps/ThinkNinja/report.json |jq -s -r -f tools/jq/app_info.jq > thinkninja.json
cat apps/ThinkNinja/report.json |jq -s -r -f tools/jq/app_manifest_analysis.jq >> thinkninja.json
cat apps/ThinkNinja/report.json |jq -s -r -f tools/jq/app_code_analysis.jq >> thinkninja.json
cat apps/ThinkNinja/report.json |jq -s -r -f tools/jq/app_trackers.jq >> thinkninja.json
jo -p "privacy_url_correct=" "privacy_prominantTracking=" "privacy_completeTracking=" "privacy_DPIA=" "cookies=" "privacyScore=" "store=" "category=" >> thinkninja.json
cat thinkninja.json|jq -s '.|add' > apps/ThinkNinja/report-summary.json
```