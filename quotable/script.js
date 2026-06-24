const loadingEl  = document.getElementById('loading');
const contentEl  = document.getElementById('content');
const quoteMark  = document.getElementById('quote-mark');
const quoteText  = document.getElementById('quote-text');
const quoteAuth  = document.getElementById('quote-author');
const toast      = document.getElementById('toast');

/* ── Toast ── */
let toastTimer;
function showToast(msg) {
  toast.textContent = msg;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 3000);
}

/* ── Curated Stoic fallbacks (shuffled randomly for the click button) ── */
const FALLBACKS = [
  { quote: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius" },
  { quote: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius" },
  { quote: "Waste no more time arguing what a good man should be. Be one.", author: "Marcus Aurelius" },
  { quote: "The soul becomes dyed with the color of its thoughts.", author: "Marcus Aurelius" },
  { quote: "Accept the things to which fate binds you, and love the people with whom fate brings you together.", author: "Marcus Aurelius" },
  { quote: "Very little is needed to make a happy life; it is all within yourself, in your way of thinking.", author: "Marcus Aurelius" },
  { quote: "We suffer more often in imagination than in reality.", author: "Seneca" },
  { quote: "Begin at once to live, and count each separate day as a separate life.", author: "Seneca" },
  { quote: "Difficulties strengthen the mind, as labor does the body.", author: "Seneca" },
  { quote: "Luck is what happens when preparation meets opportunity.", author: "Seneca" },
  { quote: "If it is not right, do not do it; if it is not true, do not say it.", author: "Marcus Aurelius" },
  { quote: "He who fears death will never do anything worthy of a man who is alive.", author: "Seneca" },
  { quote: "Man is not disturbed by events, but by the opinions about events.", author: "Epictetus" },
  { quote: "Make the best use of what is in your power, and take the rest as it happens.", author: "Epictetus" },
  { quote: "He is a wise man who does not grieve for the things which he has not, but rejoices for those which he has.", author: "Epictetus" },
  { quote: "First say to yourself what you would be; and then do what you have to do.", author: "Epictetus" },
  { quote: "No man is free who is not master of himself.", author: "Epictetus" },
  { quote: "Seek not the good in external things; seek it in yourself.", author: "Epictetus" },
];

let fallbackIndex = Math.floor(Math.random() * FALLBACKS.length);
function nextFallback() {
  const q = FALLBACKS[fallbackIndex % FALLBACKS.length];
  fallbackIndex++;
  return q;
}
function todayFallback() {
  const seed = parseInt(new Date().toISOString().slice(0, 10).replace(/-/g, ''), 10);
  return FALLBACKS[seed % FALLBACKS.length];
}

/* ── API helpers ── */
async function apiFetch(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(res.status);
  return res.json();
}

async function fetchTodayQuote() {
  const data = await apiFetch('https://zenquotes.io/api/today');
  return { quote: data[0].q, author: data[0].a };
}

async function fetchRandomQuote() {
  const data = await apiFetch('https://zenquotes.io/api/random');
  return { quote: data[0].q, author: data[0].a };
}

/* ── Render ── */
function render({ quote, author }) {
  quoteText.textContent = quote;
  quoteAuth.textContent = '— ' + author;
  loadingEl.classList.add('hidden');
  contentEl.classList.remove('hidden');
}

/* ── Initial load — try API, always fall back silently ── */
async function loadDaily() {
  try {
    render(await fetchTodayQuote());
  } catch {
    render(todayFallback());
  }
}

/* ── Click " for a new quote ── */
quoteMark.addEventListener('click', async () => {
  quoteMark.classList.add('spinning');
  contentEl.classList.add('fading');
  try {
    render(await fetchRandomQuote());
  } catch {
    // API unavailable (e.g. CORS in dev) — cycle through curated quotes silently
    render(nextFallback());
  }
  quoteMark.classList.remove('spinning');
  contentEl.classList.remove('fading');
});

loadDaily();
