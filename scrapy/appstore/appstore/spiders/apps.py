import scrapy
from urllib.parse import urlparse
class AppsSpider(scrapy.Spider):
    name = 'apps'
    start_urls = ['https://www.nhs.uk/apps-library/'
        # 'https://www.nhs.uk/apps-library/?page=1',
        # 'https://www.nhs.uk/apps-library/?page=2',
        # 'https://www.nhs.uk/apps-library/?page=3',
        # 'https://www.nhs.uk/apps-library/?page=4',
        # 'https://www.nhs.uk/apps-library/?page=5',
        ]

    def parse(self, response):
        app_library_links = response.css('div.apps-grid__content__item > a')

        yield from response.follow_all(app_library_links, self.parse_appdetail)

        pagination_links = response.css('div.pagination > div:nth-child(2) > a')
        yield from response.follow_all(pagination_links, self.parse)

    def parse_appdetail(self, response):
    
        for app in response.css('div.aaw-app-details.nshuk-o-grid>div'):

            # if 'apple' in response.xpath('//*[@id="main-content"]/div[1]/div/div[3]/div/a/@href'): appleurl = response.xpath('//*[@id="main-content"]/div[1]/div/div[3]/div/a/@href')

            app_name = app.css('div.aaw-app-details-head > div.aaw-app-details-head__description > h1::text').get()
            app_categories = app.css('div.aaw-app-details-head > div.aaw-app-details-head__description > p > a::text').getall()
            app_bio = app.css('div.rich-text > p::text').getall()
            app_stores = response.xpath('//*[@id="main-content"]/div[1]/div/div[3]/div/a/@href').getall()
            app_applestore = response.xpath('//a[contains(@href, "apple")]/@href').get()
            app_playstore = response.xpath('//a[contains(@href, "google")]/@href').get()
            if app_playstore:
                app_playparsed = urlparse(response.xpath('//a[contains(@href, "google")]/@href').get())
                app_playid = app_playparsed.query

            yield {
                'app_name': app_name,
                'app_categories': app_categories,
                'app_bio': app_bio,
                'app_stores': app_stores,
                'app_applestore': app_applestore,
                'app_playstore': app_playstore,
                'app_playparsed': app_playparsed,
                'app_playid': app_playid
            }
