# Scrapy

## Notes

```sh
python3 -m venv venv
source venv/bin/activate
```

```sh
cd scrapy/appstore
scrapy shell "http://www.nhs.uk/apps-library/acr-digital-urinalysis"
```

```sh
cd scrapy/appstore
scrapy crawl apps -O output/path.json
```

```sh
for i in `cat scrapy/appstore/output/apps.json |jq -cr '.[].playid'|grep -v null`; do echo $i; gplaycli -dc angler -c gplaycli.conf -f out/ -d $i; done
python mass_static_analysis.py -s 127.0.0.1:8000  -k 683be48c292716252e1a09b8341f5ef29612c18b28b7661ec83e241c93b7d43f -d ../../NHS-Apps-Library/out/
```
