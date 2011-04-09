'''
Created on 2011/04/07

@author: MEGANE
'''

from werkzeug import redirect #@UnresolvedImport
from google.appengine.ext import db
from google.appengine.api import memcache

import tweepy
import config
from models import TweetModel
from pyamf.amf3 import ByteArray
import urllib2

class RequestToken(db.Model):
    token_key = db.StringProperty(required=True)
    token_secret = db.StringProperty(required=True)
    
   
class TweetUtil(object):
    def load( self, sid ):
        access_token = memcache.get(sid)
        models = []
        if access_token:
            try:
                auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
                auth.set_access_token(access_token.key, access_token.secret)
                api = tweepy.API(auth_handler = auth)
                for tweet in tweepy.Cursor(api.home_timeline, count = 100).items(100):
                    model = TweetModel()
                    model.username = tweet.user.screen_name
                    model.status = tweet.text
                    model.icon = ByteArray()
                    model.icon.write(urllib2.urlopen(tweet.user.profile_image_url).read())
                    models.append(model)
                return models
            except:
                return 'Error'
            
    def update(self, sid, text):
        access_token = memcache.get(sid)
        if access_token:
            auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
            auth.set_access_token(access_token.key, access_token.secret)
            api = tweepy.API(auth_handler = auth)
            api.update_status(status=text)
            return 'Success'
        else:
            return 'Error'
        
    def isAuth(self, sid ):
        if memcache.get(str(sid)):
            return True
        return False
        

def oauth(request):
    auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET, config.CALLBACK_URL)
    auth_url = auth.get_authorization_url()
    request_token = RequestToken(token_key = auth.request_token.key, token_secret = auth.request_token.secret)
    request_token.put()
    return redirect(auth_url)

def oauth_cb(request):
    request_token_key = request.args.get("oauth_token")
    request_verifier = request.args.get("oauth_verifier")
    auth = tweepy.OAuthHandler( config.CONSUMER_KEY, config.CONSUMER_SECRET)
    request_token = RequestToken.gql("WHERE token_key=:1", request_token_key).get()
    auth.set_request_token(request_token.token_key, request_token.token_secret)
    access_token = auth.get_access_token(request_verifier)
    cookie = request.cookies
    memcache.set(cookie['KAY_SESSION'],access_token, config.SESSION_EXPIRE)
    return redirect('/redirect')