# -*- coding: utf-8 -*-
"""
twitter.views
"""


from kay.utils import render_to_response #@UnresolvedImport
from twitterutil import TweetUtil
#from werkzeug import Request #@UnresolvedImport
from pyamf.remoting.gateway.wsgi import WSGIGateway

# Create your views here.
import uuid

def index(request):
    cookie = request.session
    if not cookie.has_key('sid'):
        cookie['sid'] = str(uuid.uuid4())
    return render_to_response('twitter/index.html')

def gateway(request):
    services = {
        'tweetutil':TweetUtil
    }
    return WSGIGateway(services)

def redirectParent(request):
    return render_to_response('twitter/oauth_cb.html')

from werkzeug import redirect #@UnresolvedImport
def redirectIndex(request):
    return redirect('/')