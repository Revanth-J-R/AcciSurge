const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


exports.sendNotification = functions.https.onRequest(async (req, res) => {
  const tokens = req.body.tokens;
  const title = req.body.title;
  const body = req.body.body;

  const message = {
    notification: {
      title: title,
      body: body,
    },
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    res.status(200).send(`Successfully sent message: ${response}`);
  } catch (error) {
    res.status(500).send(`Error sending message: ${error}`);
  }
});
