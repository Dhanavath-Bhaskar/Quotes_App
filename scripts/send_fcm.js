const admin = require("firebase-admin");
const fs = require("fs");
const fetch = require("node-fetch");
const cron = require("node-cron");

// --- INIT ADMIN SDK ---
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Replace this with your device token from your Flutter app logs
const deviceToken = "eGY5Int8QHy0O67p4Hvw80:APA91bGOux9UsoLgjrUndpHIxjzVlNIcp5jFmCXtTB6PBAKKq_elqmIcrNYaWxbKNOouce0OzeJpP3nA0LNIHO-9zzpmx9BGrvSNT2bbLgOdAQPttLFaYoM";

// --- Quotes loaded from JSON file ---
const quotes = JSON.parse(fs.readFileSync("quotes_seed.json", "utf8"));

// --- Only valid quotes: non-empty kQuote, kAuthor, kCategory ---
function getValidQuotes() {
  return quotes.filter(
    (q) =>
      q &&
      typeof q === "object" &&
      typeof q.kQuote === "string" &&
      q.kQuote.trim().length > 0 &&
      typeof q.kAuthor === "string" &&
      q.kAuthor.trim().length > 0 &&
      typeof q.kCategory === "string" &&
      q.kCategory.trim().length > 0
  );
}

// --- Emoji map for categories ---
const _categoryEmoji = {
  All: "🌸",
  Action: "⚡️",
  Adventure: "🏔️",
  Art: "🖼️",
  Balance: "🤹",
  Belief: "🙌",
  Change: "🔄",
  Charity: "🎁",
  Childhood: "🧸",
  Community: "🏘️",
  Confidence: "😎",
  Courage: "🦁",
  "Creativity & Inspiration": "🎨",
  Culture: "🎭",
  Decision: "🔀",
  Determination: "⛰️",
  Discipline: "🥋",
  Diversity: "🌈",
  Dreams: "🌙",
  Education: "🎓",
  Empathy: "💗",
  Endings: "🌇",
  Equality: "🟰",
  Faith: "🕍",
  Family: "👨‍👩‍👧‍👦",
  Focus: "🧐",
  "Forging Ahead": "🚀",
  Forgiveness: "🫂",
  Freedom: "🗽",
  Friendship: "👫",
  Giving: "💝",
  Gratitude: "🙏",
  Growth: "🌿",
  "Hard Work": "💪",
  "Happiness & Joy": "😊",
  Health: "🍎",
  Hope: "🌅",
  Honesty: "🪞",
  Humility: "🪶",
  Humor: "😂",
  Imagination: "🦋",
  Inclusion: "🧑‍🤝‍🧑",
  Innovation: "💡",
  Integrity: "🦾",
  Justice: "⚖️",
  Kindness: "🤗",
  Leadership: "👑",
  Learning: "📖",
  Legacy: "🏛️",
  Life: "🌱",
  Listening: "👂",
  Love: "💖",
  Memories: "📷",
  Mindfulness: "🧘",
  "Mindfulness & Letting Go": "🍃",
  Mindset: "🧠",
  "Motivation & Achievement": "🏆",
  Music: "🎵",
  Natural: "🌳",
  "New Beginnings": "🥚",
  Opportunity: "🪟",
  "Overcoming Obstacles": "⛷️",
  Parenting: "🧑‍🍼",
  Passion: "🔥",
  Patience: "⏳",
  Peace: "🕊️",
  "Peace & Inner Calm": "☮️",
  Perseverance: "🛤️",
  Philosophy: "📜",
  Positivity: "🌞",
  Prosperity: "🪙",
  Purpose: "🎯",
  Reflection: "🔮",
  "Relationships & Connection": "💞",
  Resilience: "🌵",
  Responsibility: "🧑‍💼",
  Risk: "🎲",
  Sacrifice: "⚰️",
  "Self-Discovery": "🧭",
  "Self-Improvement": "🔝",
  "Self-Love": "💓",
  Service: "🧹",
  Silence: "🔇",
  Simplicity: "🔹",
  Sincerity: "🫶",
  Spirituality: "🕉️",
  Strength: "🦾",
  Success: "🏅",
  Teamwork: "🤼",
  Time: "⏰",
  Travel: "✈️",
  Trust: "🗝️",
  Unity: "🔗",
  Value: "💎",
  Vision: "🔭",
  Wealth: "💸",
  Wellness: "🥦",
  Wisdom: "🦉",
  "Wisdom of Age": "👵",
  "Worry & Anxiety": "😟",
  Youth: "🧑",
  Uncategorized: "✨",
};

// --- Pixabay Query Map ---
const _pixabayQueries = {
  All: "nature",
  Action: "action",
  Adventure: "adventure",
  Art: "art",
  Balance: "balance",
  Belief: "belief",
  Change: "change",
  Charity: "charity",
  Childhood: "childhood",
  Community: "community",
  Confidence: "confidence",
  Courage: "courage",
  "Creativity & Inspiration": "creative art",
  Culture: "culture",
  Decision: "decision",
  Determination: "determination",
  Discipline: "discipline",
  Diversity: "diversity",
  Dreams: "dreams",
  Education: "education",
  Empathy: "empathy",
  Endings: "endings",
  Equality: "equality",
  Faith: "faith",
  Family: "family",
  Focus: "focus",
  "Forging Ahead": "progress",
  Forgiveness: "forgiveness",
  Freedom: "freedom",
  Friendship: "friendship",
  Giving: "giving",
  Gratitude: "gratitude",
  Growth: "growth",
  "Hard Work": "hard work",
  "Happiness & Joy": "happy moments",
  Health: "health",
  Hope: "hope",
  Honesty: "honesty",
  Humility: "humility",
  Humor: "humor",
  Imagination: "imagination",
  Inclusion: "inclusion",
  Innovation: "innovation",
  Integrity: "integrity",
  Justice: "justice",
  Kindness: "kindness",
  Leadership: "leadership",
  Learning: "learning",
  Legacy: "legacy",
  Life: "life",
  Listening: "listening",
  Love: "love",
  Memories: "memories",
  Mindfulness: "mindfulness",
  "Mindfulness & Letting Go": "mindfulness meditation",
  Mindset: "mindset",
  "Motivation & Achievement": "motivation success",
  Music: "music",
  Natural: "natural",
  "New Beginnings": "new beginnings",
  Opportunity: "opportunity",
  "Overcoming Obstacles": "overcoming obstacles",
  Parenting: "parenting",
  Passion: "passion",
  Patience: "patience",
  Peace: "peace",
  "Peace & Inner Calm": "peaceful scenery",
  Perseverance: "perseverance",
  Philosophy: "philosophy books",
  Positivity: "positivity",
  Prosperity: "prosperity",
  Purpose: "purpose",
  Reflection: "reflection",
  "Relationships & Connection": "relationship love",
  Resilience: "resilience",
  Responsibility: "responsibility",
  Risk: "risk",
  Sacrifice: "sacrifice",
  "Self-Discovery": "self discovery",
  "Self-Improvement": "self improvement",
  "Self-Love": "self love",
  Service: "service",
  Silence: "silence",
  Simplicity: "simplicity",
  Sincerity: "sincerity",
  Spirituality: "spirituality",
  Strength: "strength",
  Success: "success",
  Teamwork: "teamwork",
  Time: "time",
  Travel: "travel",
  Trust: "trust",
  Unity: "unity",
  Value: "integrity",
  Vision: "vision",
  Wealth: "wealth",
  Wellness: "wellness",
  Wisdom: "wisdom",
  "Wisdom of Age": "wisdom age",
  "Worry & Anxiety": "anxiety relief",
  Youth: "youth",
  Uncategorized: "abstract art",
};


const kPixabayKey = "50180577-5f0d84f67bd57fb18ae937c93";

// --- Time labels for notification ---
const timeLabels = {
  morning: "🌅 Good Morning",
  afternoon: "🌞 Good Afternoon",
  evening: "🌇 Good Evening",
  night: "🌙 Good Night",
};

// --- Get random image from Pixabay for category ---
async function getPixabayImageUrl(category) {
  const query = _pixabayQueries[category] || _pixabayQueries["Uncategorized"];
  const url = `https://pixabay.com/api/?key=${kPixabayKey}&q=${encodeURIComponent(query)}&image_type=photo&per_page=50`;
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error("Pixabay fetch failed");
    const data = await res.json();
    if (data.hits && data.hits.length > 0) {
      const rand = Math.floor(Math.random() * data.hits.length);
      return data.hits[rand].largeImageURL;
    }
  } catch (_) {
    // ignore, fallback to default
  }
  return "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg";
}

// --- Pick a random valid quote ---
function getRandomValidQuote() {
  const validQuotes = getValidQuotes();
  if (validQuotes.length === 0) throw new Error("No valid quotes found!");
  return validQuotes[Math.floor(Math.random() * validQuotes.length)];
}

// --- Send push notification ---
async function sendQuoteNotification(timeOfDay) {
  const randomQuote = getRandomValidQuote();
  const category = randomQuote.kCategory || "Uncategorized";
  const emoji = _categoryEmoji[category] || "";
  const imageUrl = await getPixabayImageUrl(category);

  const message = {
    token: deviceToken,
    notification: {
      title: `${timeLabels[timeOfDay]} • ${emoji} ${category}`,
      body: `"${randomQuote.kQuote}"\n- ${randomQuote.kAuthor}`,
      image: imageUrl,
    },
    android: {
      notification: {
        icon: "ic_launcher",
        color: "#009688",
        image: imageUrl,
      },
      priority: "high",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`[${timeOfDay}] Notification sent:`, response);
  } catch (error) {
    console.error(`[${timeOfDay}] Error sending notification:`, error);
  }
}

// --- Schedule cron jobs ---
cron.schedule("30 2 * * *", () => sendQuoteNotification("morning"));    // 8:00 AM IST
cron.schedule("30 7 * * *", () => sendQuoteNotification("afternoon"));  // 1:00 PM IST
cron.schedule("30 12 * * *", () => sendQuoteNotification("evening"));   // 6:00 PM IST
cron.schedule("30 16 * * *", () => sendQuoteNotification("night"));     // 10:00 PM IST


// --- Test all four notifications now ---
(async () => {
  await sendQuoteNotification("morning");
  // await sendQuoteNotification("afternoon");
  // await sendQuoteNotification("evening");
  // await sendQuoteNotification("night");
  console.log("Push notification scheduler started (4 times/day)...");
})();
