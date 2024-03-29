import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import flickrapi


cred = credentials.Certificate("jwst-7a859-firebase-adminsdk-qk36p-c328858c5c.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

api_key = "3afb5a0a0a71a40b46a44d573425d3db"
api_secret = "0b0bfd746220fb47"

flickr = flickrapi.FlickrAPI(api_key, api_secret, format='parsed-json')
sets   = flickr.photosets.getList(user_id='50785054@N03')

flickr = flickrapi.FlickrAPI(api_key, api_secret)

for photoset in sets["photosets"]["photoset"][2:3]:
    urls = []
    title = photoset['title']['_content']
    for photo in flickr.walk_set(photoset['id']):
        server = photo.get('server')
        ph_id = photo.get('id')
        ph_scr = photo.get('secret')
        urls.append(f"{photo.get('title')}t1t11ehttps://live.staticflickr.com/{server}/{ph_id}_{ph_scr}.jpg")

    doc_ref = db.collection(u'images').document(title)
    doc_ref.set({
        u'body': u'random',
        u'heading': title,
        u'url': urls
    })
