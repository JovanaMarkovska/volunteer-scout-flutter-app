const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateAd = functions.firestore
.document('/ads/{userId}/userAds/{adId}')
.onCreate(async (snapshot,context)=>{
    const adCreated = snapshot.data();
    const userId = context.params.userId;
    const adId = context.params.adId;

    const usersRef = admin.firestore().collection('users');

    const querySnapshot = await usersRef.get();

    // add new post to each user's timeline
    querySnapshot.forEach(doc => {
        const userId = doc.id;

        admin.firestore()
        .collection('timeline')
        .doc(userId).collection('timelineAds').doc(adId)
        .set(adCreated);
    });


})
exports.onDeleteAd = functions.firestore
.document('/ads/{userId}/userAds/{adId}')
.onDelete(async(snapshot,context)=>{
        const userId = context.params.userId;
        const adId = context.params.adId;
        const usersRef = admin.firestore().collection('users');
        const querySnapshot = await usersRef.get();
        querySnapshot.forEach(doc => {
            const userId = doc.id;
            admin.firestore()
            .collection('timeline')
            .doc(userId)
            .collection('timelineAds')
            .doc(adId)
            .get().then(doc => {
                if(doc.exists){
                doc.ref.delete();
                }
            })

        })



})