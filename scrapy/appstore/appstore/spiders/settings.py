# Automatically created by: portia
import os

SPIDER_MANAGER_CLASS = 'slybot.spidermanager.SlybotSpiderManager'
EXTENSIONS = {
    'slybot.closespider.SlybotCloseSpider': 1
}
ITEM_PIPELINES = {
    'slybot.dupefilter.DupeFilterPipeline': 1,
    'slybot.meta.DropMetaPipeline': 2
}
SPIDER_MIDDLEWARES = {
    # as close as possible to spider output
    'slybot.spiderlets.SpiderletsMiddleware': 999
}
DOWNLOADER_MIDDLEWARES = {
    'slybot.pageactions.PageActionsMiddleware': 700,
    'scrapy_splash.middleware.SplashCookiesMiddleware': 723,
    'slybot.splash.SlybotJsMiddleware': 725
}
PLUGINS = [
    'slybot.plugins.scrapely_annotations.Annotations',
    'slybot.plugins.selectors.Selectors'
]
SLYDUPEFILTER_ENABLED = True
SLYDROPMETA_ENABLED = False
DUPEFILTER_CLASS = 'scrapy_splash.SplashAwareDupeFilter'
FEED_EXPORTERS = {
    'csv': 'slybot.exporter.SlybotCSVItemExporter',
}
CSV_EXPORT_FIELDS = None

PROJECT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

try:
    from local_slybot_settings import *
except ImportError:
    pass
try:
    from slybot_settings import *
except ImportError:
    pass
