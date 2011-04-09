# -*- coding: utf-8 -*-
# twitter.models


# Create your models here.

from pyamf.amf3 import ByteArray

class TweetModel(object):
    username = ''
    status = ''
    icon = ByteArray()