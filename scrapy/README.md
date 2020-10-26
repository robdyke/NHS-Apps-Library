# Scrapy

## Notes

```sh
python3 -m venv venv
source venv/bin/activate
```

```sh
cd scrapy/appstore
scrapy shell "http://www.nhs.uk/apps-library/acr-digital-urinalysis
```

```sh
cd scrapy/appstore
scrapy crawl apps -O output/path.json
```