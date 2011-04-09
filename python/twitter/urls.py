# -*- coding: utf-8 -*-
# twitter.urls
# 

# Following few lines is an example urlmapping with an older interface.

from kay.routing import (
  ViewGroup, Rule #@UnresolvedImport
)

view_groups = [
  ViewGroup(
    Rule('/', endpoint='index', view='twitter.views.index'),
    Rule('/gateway', endpoint='gateway', view='twitter.views.gateway'),
    Rule('/oauth', endpoint='oauth', view='twitter.twitterutil.oauth'),
    Rule('/oauth_cb', endpoint='oauth_cb', view='twitter.twitterutil.oauth_cb'),
    Rule('/redirect', endpoint='redirectParent', view='twitter.views.redirectParent'),
    Rule('/GFGAETWeet.html', endpoint='redirect', view='twitter.views.redirectIndex')
  )
]

