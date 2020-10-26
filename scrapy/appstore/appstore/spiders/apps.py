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
        for quote in response.css('div.apps-grid__content__item'):
            yield {
                'path': quote.css('a::attr(href)').get()
            }

        for next_page in response.css('div.pagination > div:nth-child(2) > a'):
            yield response.follow(next_page, self.parse)
