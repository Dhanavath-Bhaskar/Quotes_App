const { onSchedule } = require("firebase-functions/v2/scheduler");
const { getFirestore } = require("firebase-admin/firestore");
const { initializeApp } = require("firebase-admin/app");
const admin = require("firebase-admin"); // only for messaging

initializeApp();

exports.sendDailyQuoteNotifications = onSchedule("every 5 minutes", async (event) => {
  const db = getFirestore();
  const usersSnap = await db.collection("users").get();
  const now = new Date();
  const nowMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();

  for (const userDoc of usersSnap.docs) {
    const prefsRef = userDoc.ref.collection("settings").doc("prefs");
    const prefs = (await prefsRef.get()).data() || {};
    if (!prefs.notificationsEnabled) continue;
    const [h, m] = (prefs.notificationTime || "8:00").split(":").map(Number);
    const notifMinutes = h * 60 + m;
    if (nowMinutes !== notifMinutes) continue;
    const fcmToken = prefs.fcmToken;
    if (!fcmToken) continue;

    const quote = "Be yourself; everyone else is already taken.";
    const author = "Oscar Wilde";
    const imageUrl = "https://images.unsplash.com/photo-xxx";

    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "🌸 Daily Q",
        body: `"${quote}" — ${author}`,
      },
      data: {
        quote,
        author,
        imageUrl,
      },
    });
  }
  return null;
});
