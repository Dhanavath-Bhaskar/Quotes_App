const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendDailyQuoteNotifications = functions.pubsub
    .schedule("every 5 minutes")
    .onRun(async (context) => {
      const usersSnap = await admin.firestore().collection("users").get();
      const now = new Date();
      const nowMinutes = now.getUTCHours() * 60 + now.getUTCMinutes();

      for (const userDoc of usersSnap.docs) {
        const prefsRef = userDoc.ref.collection("settings").doc("prefs");
        const prefs = (await prefsRef.get()).data() || {};
        if (!prefs.notificationsEnabled) continue;

        // Parse notificationTime ("9:00" → 9*60 = 540)
        const [h, m] = (prefs.notificationTime || "8:00")
            .split(":")
            .map(Number);
        const notifMinutes = h * 60 + m;
        if (nowMinutes !== notifMinutes) continue;

        // Get the user’s FCM token (you should save this in your mobile app)
        const fcmToken = prefs.fcmToken;
        if (!fcmToken) continue;

        // Pick a quote (your logic: random, by category, by language, etc.)
        // For demo: just a dummy quote.
        const quote = "Be yourself; everyone else is already taken.";
        const author = "Oscar Wilde";
        const imageUrl = "https://images.unsplash.com/photo-xxx";

        // Send FCM notification (broken up for max-len)
        await admin.messaging()
            .send({
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
