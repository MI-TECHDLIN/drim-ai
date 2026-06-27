> [!IMPORTANT]
> Drim AI was built for **Hackathon Track 04 — "What Do I Even Do With My Life? (AI Can Help)"**,
> sponsored by **Apexon**.
>
> Built solo in **4–6 days** by a first-year Software Engineering student from Akure, Ondo State, Nigeria.
> The Android APK is available now. iOS is fully built and simulator-tested — pending Apple Developer License.

<p align="left">
<img width="1920" height="1080" alt="coverpage" src="https://github.com/user-attachments/assets/ca92a03d-9a23-4c2e-b523-73324cd02ac4" />
</p>

<h2>Drim AI — Career Guidance for the 99%</h2>
<h4>An AI-powered career operating system for students who've never had a career counsellor.</h4>


> *"Fewer than 1% of students end up in the career they originally intended."*
> **Drim AI was built for the other 99%.**

---

## What Drim AI Does

Drim AI guides students through a **research-backed three-stage journey** — self-awareness, exploration, and confidence — in about five minutes.

The confidence measurement is grounded in **CDMSE (Career Decision-Making Self-Efficacy)** — a validated psychological construct from peer-reviewed research. When a student's score goes from 4 to 8, that's a measurable outcome, not a cosmetic one.

### Core Features

- **Confidence Pre-Check** — Rate your career clarity 1–10 before anything starts
- **8-Question Self-Discovery Quiz** — Covers interests, values, strengths, work style, and vision
- **AI Career Roadmap** — 3 personalised career matches with fit scores, honest outlook, and a 10–15 step roadmap with real course links per step (Coursera, YouTube, Kaggle, freeCodeCamp)
- **Career Detail Explorer** — Expandable roadmap steps, skill chips, and live job listings via Adzuna
- **Skills Tracker** — Tap to cycle NOT STARTED → LEARNING → DONE
- **Confidence Post-Check + Delta Screen** — "YOU GREW. 4 → 8." — live, measurable proof
- **Home Dashboard** — YOUR PATH card, NEXT STEP prompt, and confidence summary

### Phase 7–9 Features

- **Dream Company Pathfinder** — Type any company (Google, GTBank, McKinsey, any startup) and get an AI gap analysis + company-specific roadmap
- **Momentum Map** — Real GitHub-style activity heatmap powered by actual database activity
- **Goal Timeline** — Set a 3-month, 6-month, or 1-year deadline with daily pace tracking
- **Celebration System** — Skill completion and streak milestone screens with permanent badges
- **Activity Screen** — Weekly score, average intensity, streak tracking with STREAK AT RISK alerts

---

## Download

<p align="left">
  <a href="https://github.com/MI-TECHDLIN/drim-ai/releases/latest">
    <img src="https://img.shields.io/github/v/release/MI-TECHDLIN/drim-ai?label=Latest%20Release&style=for-the-badge&color=2E6171" alt="Latest Release" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/iOS-Simulator%20Only-lightgrey?style=for-the-badge&logo=apple&logoColor=white" alt="iOS" />
</p>

| Platform | Status | Notes |
|----------|--------|-------|
| Android | Available | Download APK from [Releases](https://github.com/MI-TECHDLIN/drim-ai/releases/tag/v1.0.0) |
| iOS | Simulator Only | Fully built and tested — pending Apple Developer License ($99/yr) |

> [!NOTE]
> The Flutter codebase is **fully cross-platform**. iOS support is complete at the code level.
> Physical iPhone installation requires an Apple Developer account which was not available during the hackathon.

---

## Building from Source

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart 3.0+
- Android Studio or VS Code with Flutter extension
- A Supabase project (free tier is fine)
- Groq API key (free at [console.groq.com](https://console.groq.com))
- Adzuna API credentials (free at [developer.adzuna.com](https://developer.adzuna.com)) — optional, fallback listings built in

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/drim-ai.git
cd drim-ai
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Set up Supabase

Run the following SQL in your Supabase SQL Editor to create all required tables:

```sql
-- profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  display_name text, age_band text, education_stage text,
  created_at timestamptz default now(), updated_at timestamptz default now()
);

-- Additional tables: quiz_responses, career_matches, skill_progress,
-- confidence_scores, dream_company_goals, user_goals,
-- user_activity, user_badges
-- See /supabase/schema.sql for the full schema
```

Enable RLS and disable email confirmation in Supabase Auth settings.

### 4. Deploy Edge Functions

```bash
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set GROQ_API_KEY=gsk_your_key_here
supabase secrets set ADZUNA_APP_ID=your_id
supabase secrets set ADZUNA_APP_KEY=your_key
supabase functions deploy generate-roadmap --no-verify-jwt
supabase functions deploy analyze-gap --no-verify-jwt
```

### 5. Run the app

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

> [!TIP]
> Run `flutter run` without dart-define flags to test the UI in offline/demo mode.
> Every screen has a built-in fallback — the app never crashes without a backend.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod 2.5 |
| Navigation | go_router 14 |
| Backend | Supabase (Auth + PostgreSQL + Edge Functions) |
| Primary AI | Groq — Llama 3.3-70B (free tier) |
| AI Fallback | OpenAI GPT-4o-mini |
| Job Listings | Adzuna API |
| Fonts | Google Fonts (Poppins + Inter) |
| Design System | Custom Neo-Brutalism |

---
## Architecture

```
drim_ai/
├── lib/
│   ├── core/                  # Supabase client, app config
│   ├── data/                  # Repositories (auth, profile, quiz, roadmap...)
│   ├── features/              # Screen files by feature
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── confidence/
│   │   ├── quiz/
│   │   ├── roadmap/
│   │   ├── career_detail/
│   │   ├── skills/
│   │   ├── jobs/
│   │   ├── home/
│   │   ├── profile/
│   │   ├── activity/
│   │   ├── dream_job/
│   │   ├── goal/
│   │   └── celebration/
│   ├── models/                # Data models
│   ├── router/                # go_router config + refresh stream
│   ├── state/                 # Riverpod providers
│   ├── theme/                 # Colors, spacing, radii, shadows, typography
│   └── widgets/               # Shared widgets (DrimShimmer, DrimErrorState...)
├── supabase/
│   └── functions/
│       ├── generate-roadmap/  # Career match AI Edge Function
│       └── analyze-gap/       # Dream Company gap analysis Edge Function
└── README.md
```
---

## Design System

Drim AI uses a custom **neo-brutalism** design language — bold, warm, and anxiety-reducing by design.

| Token | Value | Use |
|-------|-------|-----|
| Anchor | `#2E6171` | Primary brand, headers, buttons |
| Sage | `#9CC5A1` | Progress, growth, completion |
| Apricot | `#E9A178` | Warmth, next steps, celebrations |
| Sand | `#F5F1EA` | App background |
| Error | `#C2705A` | Errors (warm terracotta — never alarm red) |

**Rules:** 2px black borders on everything · Hard 4px offset shadows (zero blur) · No gradients · No soft shadows · Poppins ExtraBold headings · Inter body text

---

## Screens (22 total)

| Phase | Screens |
|-------|---------|
| 1–2 | Splash, Onboarding Carousel, Auth, Profile Setup |
| 3–4 | Confidence Pre-Check, Quiz (8 questions), Roadmap Loading, Roadmap Results |
| 5–6 | Career Detail, Skills Tracker, Job Listings, Confidence Post-Check, Delta Screen, Home Dashboard |
| 7 | Dream Job Search, Gap Analysis, Company Roadmap |
| 8 | Goal Setup, Activity (Momentum Map) |
| 9 | Skill Celebration, Streak Celebration, Profile |

---

## Research Foundation

Drim AI is evidence-based, not vibes-based.

- **CDMSE (Career Decision-Making Self-Efficacy)** — the validated psychological construct the confidence meter is based on
- **The STUDIA mobile app study** — demonstrated measurable CDMSE gains from short, structured self-assessment apps
- **PIC Model** (Prescreening, In-depth exploration, Choice) — drives the three-stage journey architecture
- **Social Cognitive Career Theory (SCCT)** — informs the self-awareness-first sequencing

The evidence-based sequencing isn't a tagline. It's the product architecture.

---

## Hackathon Context

- **Event:** YouthCode Foundation X AI Hackathon 2026
- **Track:** Track 04 — *"What Do I Even Do With My Life? (AI Can Help)"*
- **Build Time:** 4–6 days, 9 phases, 22 screens

---

## What's Next

- [ ] Apple Developer License → proper iOS release
- [ ] RIASEC / Holland codes psychometric assessment
- [ ] Longitudinal tracking (return in 3 months, see your growth)
- [ ] Counsellor and mentor marketplace
- [ ] Multi-language support (Yoruba, Igbo, Hausa, French for Francophone Africa)
- [ ] Home screen widget (daily streak + next skill)
- [ ] School and university institutional dashboards
- [ ] Freemium model — core journey stays permanently free

---

## License

This project is open source and available under the [MIT License](LICENSE).

---

<p align="center">
  <sub>Built with 🔥 by a student, for students. For the 99%.</sub>
</p>
