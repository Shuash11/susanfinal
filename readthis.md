# 🔐 Secrets Setup Guide (Flutter + Backend)

## ⚠️ CORE RULE

👉 **Secrets (API keys) MUST ONLY exist in the backend**

Flutter (frontend) must NEVER store or access secrets directly.

---

# 🧠 How It Works

```text
Flutter App → Backend Server → AI API (DeepSeek / Gemini)
```

* Flutter = public (unsafe for secrets)
* Backend = private (safe for secrets)

---

# ❌ WRONG APPROACH

Do NOT do any of the following in Flutter:

```dart
const apiKey = "YOUR_API_KEY"; // ❌ NEVER
```

```yaml
assets:
  - .env  # ❌ WRONG
```

* `.env` in Flutter will NOT be secure
* It will either break your build or expose your key

---

# ✅ CORRECT APPROACH

## 🔹 Step 1 — Store Secret in Backend

Create a `.env` file in your backend project:

```env
API_KEY=your_real_api_key_here
```

---

## 🔹 Step 2 — Install dotenv

```bash
npm install dotenv
```

---

## 🔹 Step 3 — Load Secret in Backend

```javascript
import dotenv from "dotenv";

dotenv.config();

const apiKey = process.env.API_KEY;
```

---

## 🔹 Step 4 — Use Secret in API Request

```javascript
headers: {
  "Authorization": `Bearer ${process.env.API_KEY}`
}
```

---

## 🔹 Step 5 — Protect `.env`

In `.gitignore`:

```text
.env
```

👉 This prevents GitHub from uploading your secret

---

# 📱 Flutter Side (Important)

Flutter should ONLY call your backend:

```dart
final response = await http.post(
  Uri.parse("https://your-backend-url/chat"),
);
```

---

# 🔐 Why This Is Secure

* API key is hidden in backend ✅
* Not visible in app code ✅
* Not exposed to users ✅
* Not uploaded to GitHub ✅

---

# 🚨 Common Mistakes

### ❌ “I added secret in Flutter”

→ Not secure, easily exposed

### ❌ “I used .env in Flutter”

→ Breaks build OR exposes key

### ❌ “I used GitHub secrets for Flutter”

→ Only works for backend, not apps

---

# ✅ Checklist

* [ ] `.env` exists in backend only
* [ ] `.env` is in `.gitignore`
* [ ] Backend reads API key using dotenv
* [ ] Flutter does NOT contain API key
* [ ] Flutter calls backend endpoint

---

# 🎯 Final Goal

👉 Keep your API key:

* Hidden 🔒
* Safe 🛡️
* Server-side only 🖥️

---

# 🤖 Notes for Replit Agent / Developers

When setting up backend:

DO:

* Use `.env` for API keys
* Load using dotenv
* Create secure API endpoints

DO NOT:

* Store secrets in Flutter
* Add `.env` to frontend
* Expose API keys anywhere public
