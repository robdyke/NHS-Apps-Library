import scrapy


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
    
        def extract_with_css(query):
            return response.css(query).get(default='').strip()

        yield {
            'name': extract_with_css('div.aaw-app-details.nshuk-o-grid > div > div.aaw-app-details-head > div > h1::text'),
            'category': extract_with_css('div.aaw-app-details.nshuk-o-grid > div > div.aaw-app-details-head > div > p > a::text'),
            'bio': extract_with_css('div.aaw-app-details.nshuk-o-grid > div > div:nth-child(2) > p::text'),
        }
