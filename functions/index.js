
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { log } = require('firebase-functions/lib/logger');
admin.initializeApp();

exports.myfunction=functions.firestore.document("chat/{twouserchat}/messages/{message}").onCreate((snapshot,context)=>{
    console.log("contexttoken-------"+context.params.message);
    console.log("token-------"+snapshot.data());
    console.log("token-------"+snapshot.data().aotherdevicetoken);
   
    return admin.messaging().sendToDevice(snapshot.data().aotherdevicetoken,{notification:{title:snapshot.data().senderusername,body:snapshot.data().message,clickAction:"FLUTTER_NOTIFICATION_CLICK",},});
    
    
});
