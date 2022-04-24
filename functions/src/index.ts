import * as functions from 'firebase-functions';
import * as admin from "firebase-admin";
import { initializeApp, deleteApp } from 'firebase/app';
import { doc, setDoc, getFirestore, getDoc } from 'firebase/firestore';

const Flickr = require('flickr-sdk');

const firebaseConfig = {
  apiKey: 'AIzaSyDsrf5DPQo-W2brH6kjotiO-ggw4zJX7FM',
  authDomain: 'jwst-7a859.firebaseapp.com',
  projectId: 'jwst-7a859',
  storageBucket: 'jwst-7a859.appspot.com',
  messagingSenderId: '583265588703',
  appId: '1:583265588703:web:dfbd774ccd8d84e5ada06a',
  measurementId: 'G-BRLKESYNT7',
};

exports.scheduledFunction = functions.pubsub
  .schedule('every 24 hours')
  .onRun((context) => {
    const app = initializeApp(firebaseConfig);
    const database = getFirestore(app);

    var flickr = new Flickr('3afb5a0a0a71a40b46a44d573425d3db');

    var count = 0;
    var deleted = false;

    flickr.photosets
      .getList({ user_id: '50785054@N03' })
      .then((res: { body: { photosets: { photoset: any } } }) => {
        const photosets = res.body.photosets.photoset;

        photosets.slice(0, 2).forEach(async (photoset: any) => {
          const title = photoset.title._content;
          const id = photoset.id;
          const urls: string[] = [];

          console.log(id);

          var docSnap = null;

          try {
            const docRef = doc(database, 'images', title);
            docSnap = await getDoc(docRef);
          } catch (rtt) {
            console.log('err');
          }

          if (docSnap?.exists()) {
            if (!deleted) {
              deleted = true;
              deleteApp(app).catch((err) => {
                console.log(err);
              });
            }
            return;
          } else {
            flickr.photosets
              .getPhotos({ photoset_id: id, user_id: '50785054@N03' })
              .then((res: { body: { photoset: { photo: any } } }) => {
                const photos = res.body.photoset.photo;

                photos.forEach(
                  (photo: {
                    server: any;
                    id: any;
                    secret: any;
                    title: any;
                  }) => {
                    const server = photo.server;
                    const ph_id = photo.id;
                    const ph_scr = photo.secret;
                    const title = photo.title;
                    const url = `${title}t1t11ehttps://live.staticflickr.com/${server}/${ph_id}_${ph_scr}.jpg`;
                    urls.push(url);
                  },
                );
              })
              .catch(function (err: any) {
                console.error('bonk', err);
              })
              .finally(async () => {
                await setDoc(doc(database, 'images', title), {
                  body: 'random',
                  heading: title,
                  url: urls,
                });

                count += 1;

                if (count === photosets.length) {
                  deleteApp(app);
                }
              });
          }
        });
      });
  });

admin.initializeApp(functions.config().firebase);


// const payload = (title: string, val: string, sender: string) => ({
//   notification: {
//     title: title,
//     body: val,
//   },
//   data: {
//     sender: sender,
//   },
// });

export const onCreateMessage = functions.firestore
  .document("/images/{documentName}")
  .onCreate((snapshot, context) => {

    const documentName = context.params.documentName;

    console.log(`New photoset ${documentName}`);
    return;

  //   return admin.database()
  //       .ref(`/fcmTokens/${messageData.toUser}`)
  //       .once("value")
  //       .then((FCMToken) => {
  //         const msgPayload = payload(
  //             messageData.username,
  //             messageData.message,
  //             messageData.idUser,
  //         );

  //         console.log(FCMToken.val().token);
  //         console.log("Sending message");

  //         const options = {
  //           priority: "high",
  //         };

  //         admin.messaging()
  //             .sendToDevice([FCMToken.val().token], msgPayload, options)
  //             .then((response) => {
  //               console.log("Successfully sent message:", response);
  //               return {success: true};
  //             }).catch((error) => {
  //               return {error: error.code};
  //             });
  //       });
  });