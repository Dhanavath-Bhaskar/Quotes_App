const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Dynamic import of node-fetch for CommonJS
const fetch = (...args) =>
  import('node-fetch').then(({ default: fetch }) => fetch(...args));

const PIXABAY_KEY = '50180577-5f0d84f67bd57fb18ae937c93';
const PER_PAGE = 200;

const CATEGORIES = [
  "Health",
  "Forging Ahead",
  "Resilience",
  "Perseverance",
  "Charity",
  "Wisdom",
  "Natural",
  "Humor",
  "Nature",
  "Dreams",
  "Positivity",
  "Discipline",
  "Music",
  "Memories",
  "Change",
  "Mindset",
  "Learning",
  "Kindness",
  "Patience",
  "Mindfulness",
  "Culture",
  "Overcoming Obstacles",
  "Trust",
  "Justice",
  "Peace",
  "Prosperity",
  "Wealth",
  "Authenticity",
  "Reflection",
  "Listening",
  "Responsibility",
  "Growth",
  "Hope",
  "Leadership",
  "Teamwork",
  "Education",
  "Opportunity",
  "Self-Improvement",
  "Vision",
  "Wellness",
  "Time",
  "Freedom",
  "Simplicity",
  "Honesty",
  "Integrity",
  "Adventure",
  "Travel",
  "Art",
  "Innovation",
  "Imagination",
  "Determination",
  "Action",
  "Risk",
  "Confidence",
  "Humility",
  "Inclusion",
  "Family",
  "Childhood",
  "Sacrifice",
  "Youth",
  "Endings",
  "Self-Discovery",
  "Silence",
  "Decision",
  "Service",
  "Value",
  "Spirituality",
  "Passion",
  "Parenting",
  "Wisdom of Age",
  "New Beginnings",
  "Happiness & Joy",
  "Life",
  "Gratitude",
  "Diversity",
  "Equality",
  "Purpose",
  "Community",
  "Self-Love",
  "Philosophy",
  "Peace & Inner Calm",
  "Courage",
  "Belief",
  "Giving",
  "Worry & Anxiety",
  "Motivation & Achievement",
  "Failure",
  "Faith",
  "Love",
  "Creativity & Inspiration",
  "Success",
  "Balance",
  "Friendship",
  "Mindfulness & Letting Go",
  "Hard Work",
  "Relationships & Connection",
  "Forgiveness",
  "Focus",
  "Strength",
  "Empathy"
];


const CATEGORY_SEARCH_MAP = {
  "Health": "health",
  "Forging Ahead": "progress",
  "Resilience": "resilience",
  "Perseverance": "perseverance",
  "Charity": "charity",
  "Wisdom": "wisdom",
  "Natural": "nature",
  "Humor": "humor",
  "Nature": "nature",
  "Dreams": "dream",
  "Positivity": "positive",
  "Discipline": "discipline",
  "Music": "music",
  "Memories": "memory",
  "Change": "change",
  "Mindset": "mindset",
  "Learning": "learning",
  "Kindness": "kindness",
  "Patience": "patience",
  "Mindfulness": "mindfulness",
  "Culture": "culture",
  "Overcoming Obstacles": "overcome",
  "Trust": "trust",
  "Justice": "justice",
  "Peace": "peace",
  "Prosperity": "prosperity",
  "Wealth": "wealth",
  "Authenticity": "authentic",
  "Reflection": "reflection",
  "Listening": "listen",
  "Responsibility": "responsibility",
  "Growth": "growth",
  "Hope": "hope",
  "Leadership": "leadership",
  "Teamwork": "teamwork",
  "Education": "education",
  "Opportunity": "opportunity",
  "Self-Improvement": "improvement",
  "Vision": "vision",
  "Wellness": "wellness",
  "Time": "time",
  "Freedom": "freedom",
  "Simplicity": "simplicity",
  "Honesty": "honest",
  "Integrity": "integrity",
  "Adventure": "adventure",
  "Travel": "travel",
  "Art": "art",
  "Innovation": "innovation",
  "Imagination": "imagination",
  "Determination": "determination",
  "Action": "action",
  "Risk": "risk",
  "Confidence": "confidence",
  "Humility": "humility",
  "Inclusion": "inclusion",
  "Family": "family",
  "Childhood": "childhood",
  "Sacrifice": "sacrifice",
  "Youth": "youth",
  "Endings": "ending",
  "Self-Discovery": "discovery",
  "Silence": "silence",
  "Decision": "decision",
  "Service": "service",
  "Value": "value",
  "Spirituality": "spiritual",
  "Passion": "passion",
  "Parenting": "parenting",
  "Wisdom of Age": "elderly",
  "New Beginnings": "beginning",
  "Happiness & Joy": "happiness",
  "Life": "life",
  "Gratitude": "gratitude",
  "Diversity": "diversity",
  "Equality": "equality",
  "Purpose": "purpose",
  "Community": "community",
  "Self-Love": "selflove",
  "Philosophy": "philosophy",
  "Peace & Inner Calm": "calm",
  "Courage": "courage",
  "Belief": "belief",
  "Giving": "giving",
  "Worry & Anxiety": "anxiety",
  "Motivation & Achievement": "motivation",
  "Failure": "failure",
  "Faith": "faith",
  "Love": "love",
  "Creativity & Inspiration": "creativity",
  "Success": "success",
  "Balance": "balance",
  "Friendship": "friendship",
  "Mindfulness & Letting Go": "mindfulness",
  "Hard Work": "work",
  "Relationships & Connection": "relationship",
  "Forgiveness": "forgiveness",
  "Focus": "focus",
  "Strength": "strength",
  "Empathy": "empathy"
};

const DEFAULT_FALLBACK = "inspiration"; // As a last resort

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function fetchImagesForTerm(term, neededCount = 200) {
  let urls = [];
  let page = 1;
  while (urls.length < neededCount) {
    const apiUrl =
      `https://pixabay.com/api/?key=${PIXABAY_KEY}` +
      `&q=${encodeURIComponent(term)}` +
      `&image_type=photo` +
      `&per_page=${PER_PAGE}` +
      `&page=${page}`;
    const res = await fetch(apiUrl);
    const data = await res.json();
    if (!data.hits || data.hits.length === 0) break;
    const newUrls = data.hits.map(hit => hit.largeImageURL);
    // Stop if no new images found (to avoid infinite loop)
    if (newUrls.length === 0) break;
    urls = urls.concat(newUrls);
    if (data.hits.length < PER_PAGE) break; // No more pages
    page++;
  }
  // Return unique URLs, up to neededCount
  return Array.from(new Set(urls)).slice(0, neededCount);
}

async function fillAllCategories() {
  for (const CATEGORY of CATEGORIES) {
    let allImages = [];
    // 1. Try original category
    allImages = await fetchImagesForTerm(CATEGORY);
    // 2. If not enough, try mapped synonym
    if (allImages.length < PER_PAGE && CATEGORY_SEARCH_MAP[CATEGORY]) {
      const synonymImages = await fetchImagesForTerm(CATEGORY_SEARCH_MAP[CATEGORY]);
      allImages = Array.from(new Set(allImages.concat(synonymImages)));
    }
    // 3. If still not enough, try fallback
    if (allImages.length < PER_PAGE) {
      const fallbackImages = await fetchImagesForTerm(DEFAULT_FALLBACK);
      allImages = Array.from(new Set(allImages.concat(fallbackImages)));
    }
    allImages = allImages.slice(0, PER_PAGE);

    if (allImages.length === 0) {
      console.error(`❌ No images found for "${CATEGORY}" (even after fallbacks)!`);
      continue;
    }
    console.log(`✅ Got ${allImages.length} images for "${CATEGORY}"`);

    // Find quotes for this category missing imageUrl
    const snapshot = await db
      .collection('quotes')
      .where('kCategory', '==', CATEGORY)
      .where('imageUrl', '==', '')
      .get();

    if (snapshot.size === 0) {
      console.log(`Nothing to update for "${CATEGORY}".\n`);
      continue;
    }

    // Batch update
    const batch = db.batch();
    snapshot.docs.forEach((doc, idx) => {
      // Cycle through images if fewer images than quotes
      const imageUrl = allImages[idx % allImages.length];
      batch.update(doc.ref, { imageUrl });
      console.log(`→ ${doc.id} (${CATEGORY}) will get ${imageUrl}`);
    });

    await batch.commit();
    console.log(`🎉 "${CATEGORY}" missing imageUrl fields filled!\n`);
  }

  process.exit(0);
}

fillAllCategories().catch(err => {
  console.error('🛑 Fatal error:', err);
  process.exit(1);
});
