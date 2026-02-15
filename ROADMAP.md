# Pixel Stepper — 4-Week Roadmap (Feb 12 – Mar 12, 2026)

> **North Star:** 10,000 premium subscribers
> **Current state:** v2.1.0 submitted, waiting for App Store review
> **Pricing:** $2.99/month · $19.99/year (1-week free trial)

---

## Where We Are (v2.1.0 — Submitted Feb 11)

### Already Built & Shipping
- Pixel avatar with 3 energy states + 4 evolution phases
- Live Activity (Lock Screen + Dynamic Island)
- Home Screen widget
- Cosmetic Shop: 30 items across 3 categories (backgrounds, hats, accessories)
- Step Coins economy (earned through walking, spent on cosmetics)
- 3 daily missions (free) / 5 (premium) with coin rewards
- Weekly challenges (premium)
- Streak tracking with 7,500-step daily goal
- Streak freeze (premium, once per week)
- 2x coin multiplier for premium users
- Rotating featured shop (3-day cycle, premium early access)
- 4 share card types (daily progress, evolution milestone, weekly summary, streak)
- Instagram story sharing integration
- Celebration overlays for milestones
- Step Moment (daily check-in prompt)
- Notification system (streak at risk, milestones, re-engagement)
- HealthKit step tracking with proper iPad handling

### Conversion Math
To reach 10K subscribers at 4% conversion:
- Need **250,000 total downloads**
- At 500 downloads/day = 500 days (too slow)
- At 2,000 downloads/day = 125 days (~4 months with aggressive growth)
- **Realistic target for Month 1:** 5,000-10,000 downloads → 200-400 subscribers

---

## Week 1: Approval & Launch Prep (Feb 12-18)

### Goal: Get approved, prepare launch assets, optimize ASO

#### App Store (blocking — wait for review)
- [ ] Monitor review status daily
- [ ] If rejected again: fix within 24 hours and resubmit
- [ ] Reply to Guideline 2.1 Information Needed with business model details (see AppStoreMetadata.md)

#### ASO Optimization (do while waiting for review)
- [ ] **Title:** Update to "Pixel Stepper - Walk & Evolve" (adds searchable keywords within 30-char limit)
- [ ] **Subtitle:** "Earn Coins, Customize Your Buddy" (highlights gamification, fits 30 chars)
- [ ] **Keywords field** (100 chars): `pedometer,walking,steps,fitness,tamagotchi,pet,widget,dynamic,island,streak,coins,avatar,pixel,health`
- [ ] **Description:** Rewrite first 3 lines to highlight v2.1 features (cosmetics, missions, coins) — these show before "Read More"
- [ ] **What's New text:** Already written in AppStoreMetadata.md

#### Screenshot Refresh (critical for conversion)
- [ ] Screenshot 1: Hero shot — avatar on Lock Screen + Dynamic Island with "Your Walking Companion"
- [ ] Screenshot 2: Home tab showing streak hero + missions with "Daily Missions & Streaks"
- [ ] Screenshot 3: Cosmetic shop grid with "Customize Your Avatar"
- [ ] Screenshot 4: Stats tab with phase progress bar "Track Your Evolution"
- [ ] Screenshot 5: Share card being shared to Instagram "Share Your Journey"
- [ ] Take on iPhone 16 Pro (6.9") and iPhone 8 Plus (5.5")

#### Content Prep (batch create for launch week)
- [ ] Film 5 TikTok/Reels videos:
  1. "I built an app where a pixel character lives on your Lock Screen" (indie dev hook)
  2. "POV: Your step tracker actually understands bad days" (emotional hook)
  3. "What 0 vs 5,000 vs 10,000 steps looks like" (show avatar states)
  4. "I added a cosmetic shop to my step tracking app" (new feature showcase)
  5. "Things that happen when you walk 10K steps in this app" (mission completion, evolution, celebrations)
- [ ] Create 6 Instagram carousel/static posts
- [ ] Prepare Product Hunt listing (tagline, screenshots, maker comment, first 10 upvoters)
- [ ] Draft Reddit posts for r/iphone, r/iosapps, r/pixelart, r/indiegaming

---

## Week 2: Launch Blitz (Feb 19-25)

### Goal: 1,000-2,000 downloads in the first week after approval

*Assuming v2.1 is approved by this point. If not, shift this week forward.*

#### Day 1 — Coordinated Launch (all channels within 2 hours)
- [ ] **Product Hunt** launch (submit night before, live 12:01 AM PT)
- [ ] **Reddit** — 4 posts across r/apple, r/iphone, r/iosapps, r/indiegaming
- [ ] **TikTok** — Post "I built this app" video
- [ ] **Instagram** — Launch Reel + Story with App Store link
- [ ] **X/Twitter** — Launch thread with #buildinpublic
- [ ] **Hacker News** — "Show HN: Pixel Stepper — A gamified step tracker with pixel art"

#### Day 2-7 — Ride the Wave
- [ ] Respond to every comment on every platform within 1 hour
- [ ] Post daily on TikTok (1 video/day)
- [ ] Post daily Instagram Stories
- [ ] Repost any UGC or screenshots users share
- [ ] Monitor App Store reviews — respond to every one
- [ ] Track: downloads, sources, retention, paywall views, conversions

#### Apple Search Ads Setup ($300 initial budget)
- [ ] Campaign 1 — Brand: "pixel stepper", "pixelstepper" (exact, 10% budget)
- [ ] Campaign 2 — Category: "step tracker", "pedometer", "walking app" (broad, 40% budget)
- [ ] Campaign 3 — Competitor: "stepz", "pacer", "step tracker app" (exact, 30% budget)
- [ ] Campaign 4 — Feature: "dynamic island fitness", "pixel fitness", "step game" (broad, 20% budget)

---

## Week 3: Retention & Conversion (Feb 26 – Mar 4)

### Goal: Optimize retention, push first 100 subscribers, start v2.2 development

#### Analyze Week 2 Data
- [ ] Check Day 1, Day 3, Day 7 retention in App Store Connect
- [ ] Check paywall conversion rate (views → trial starts → subscriptions)
- [ ] Check which marketing channel drove most downloads
- [ ] Identify top-performing content — double down

#### Retention Content (show the journey, create FOMO)
- [ ] "Day 1 vs Day 7 with Pixel Stepper" evolution Reel
- [ ] "Phase 3 & 4 character reveal" — tease premium phases
- [ ] "Free vs Premium — what you actually get" — honest comparison
- [ ] "My pixel pal just hit Legendary" — end-game aspiration
- [ ] Launch #PixelStepperChallenge — users share Lock Screen + step count

#### Micro-Influencer Outreach (20-30 DMs)
- [ ] Target: pixel art creators, walking challenge accounts, iPhone setup/aesthetic accounts
- [ ] Offer: free lifetime premium + promo code for followers
- [ ] Template in MARKETING_STRATEGY.md

#### Start v2.2 Development — Companions & Widget Themes
**Companions (new cosmetic category):**
- [ ] Design 6 companion pets (dog, cat, bird, fox, dragon, robot)
- [ ] Model: add `companion` slot to CosmeticLoadout
- [ ] Render: small sprite that follows the avatar with its own 2-frame animation
- [ ] 3 free companions, 3 premium-gated
- [ ] Price range: 200-2000 coins

**Widget Themes (premium feature):**
- [ ] Design 3 themes: Dark Cosmos (free default), Neon Pulse (premium), Nature Calm (premium)
- [ ] Add `WidgetTheme` enum + `SharedData` sync
- [ ] Theme picker in Profile tab
- [ ] Widget reads theme from App Group UserDefaults

---

## Week 4: Scale & v2.2 (Mar 5-12)

### Goal: 5,000+ total downloads, 200+ subscribers, ship v2.2

#### Growth Scaling
- [ ] Analyze Apple Search Ads — kill underperformers, scale winners
- [ ] Run first Instagram giveaway: "Win 1 year of Pixel Stepper Premium" (follow + tag 2 friends + share)
- [ ] Press outreach: email 9to5Mac, MacStories, Cult of Mac, iMore with press kit
- [ ] Submit for Apple App Store feature at developer.apple.com/contact/app-store/promote/
- [ ] Post "Week 2 numbers" transparency post on X (builds trust + indie dev community support)

#### Complete v2.2 Development
- [ ] Finish companions + widget themes
- [ ] Add review request prompt (trigger after 7-day streak or Phase 2 evolution, never on bad days)
- [ ] Add "Invite a Friend" share mechanic (deep link that gives both users 100 bonus coins)
- [ ] QA, build, submit v2.2

#### Localization Prep (high ROI, low effort)
- [ ] Research top markets from App Store Connect demographics
- [ ] Localize App Store listing (title, subtitle, description, keywords) for top 3 markets
- [ ] Priority languages: German, Spanish, Japanese (large Health & Fitness markets)

---

## v2.2+ Feature Pipeline (Beyond Month 1)

Prioritized by impact on subscriber growth:

| Priority | Feature | Impact | Effort | Target |
|----------|---------|--------|--------|--------|
| 1 | **Apple Watch app** | Huge differentiator — character on watch face, complication | High | v2.3 (Month 2) |
| 2 | **Social challenges** | Friend vs friend step battles, viral referral loop | High | v2.3 (Month 2) |
| 3 | **Seasonal events** | Monthly themed events with limited cosmetics (Valentine's, Spring, etc.) | Medium | v2.2+ ongoing |
| 4 | **Battle Pass** | 30-day tiered reward track (free + premium tiers), drives daily engagement | Medium | v2.4 (Month 3) |
| 5 | **Outfits** | Full-body cosmetic category, biggest visual impact | Medium | v2.4 (Month 3) |
| 6 | **Virtual journeys** | "Walk across Japan" — step milestones mapped to real-world routes | Medium | v2.5 (Month 4) |
| 7 | **Siri Shortcuts / App Intents** | "Hey Siri, how's my pixel buddy?" — unique, Apple loves this | Low | v2.3 |
| 8 | **iPad native layout** | Proper iPad UI (not just iPhone compat mode) | Medium | v2.4 |
| 9 | **Accessibility** | VoiceOver, Dynamic Type, Reduce Motion | Low | v2.3 |

---

## Key Metrics to Track Weekly

| Metric | Week 2 Target | Week 4 Target | Month 3 Target |
|--------|---------------|---------------|----------------|
| Total Downloads | 1,000 | 5,000 | 25,000 |
| DAU | 200 | 1,000 | 5,000 |
| Day 1 Retention | 40% | 45% | 50% |
| Day 7 Retention | 20% | 25% | 30% |
| Paywall View Rate | 15% | 20% | 25% |
| Trial Start Rate | 30% | 35% | 40% |
| Trial → Paid | 50% | 55% | 60% |
| Active Subscribers | 20 | 200 | 1,000 |
| MRR | $60 | $600 | $3,000 |
| App Store Rating | 4.5+ | 4.6+ | 4.7+ |

---

## Budget (Month 1)

| Item | Cost | Notes |
|------|------|-------|
| Apple Search Ads | $300-500 | Start conservative, scale if CPA < $2 |
| Canva Pro | $13 | Social content creation |
| Micro-influencer promo codes | Free | Give lifetime premium codes |
| Giveaway prize | Free | 1 year premium subscription |
| Apple Developer fee | Already paid | $99/year |
| **Total** | **~$315-515** | |

Zero-budget alternatives if needed: focus purely on Reddit + TikTok organic (both free, highest ROI for new apps).

---

## Decision Points

**After Week 2 (first data):**
- If Day 7 retention < 15% → prioritize onboarding improvements before more marketing
- If paywall conversion < 2% → A/B test paywall copy, pricing, or timing
- If Apple Search Ads CPA > $3 → pause ads, focus organic only

**After Week 4:**
- If subscribers > 200 → aggressive scaling, increase ad budget to $1K/month
- If subscribers < 50 → product-market fit investigation, user interviews, pivot features
- If one channel drives 80%+ downloads → go all-in on that channel

---

*Last updated: February 11, 2026*
*Version: 2.1.0 (submitted for review)*
