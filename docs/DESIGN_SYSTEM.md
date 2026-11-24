# RITMA — UX & Brand Design System Direction

**Brand Positioning:** RITMA — *Contemporary Performance*  
**Qualities:** Premium, modern, refined, trustworthy, clean, operationally efficient, accessible.

---

## 1. Evaluation of Candidate Palette

Initial candidate tokens evaluated for WCAG 2.1 AA compliance and operational ergonomics:

| Token | Hex | Evaluation & Accessibility Verdict |
|---|---|---|
| **Graphite** | `#202421` | **Strong Primary Ink & Anchor.** ~14.7:1 contrast against Porcelain (`#FFFFFF`) and ~13.4:1 against Warm Ivory (`#F6F4ED`). Conveys architectural calm and precision. |
| **Warm Ivory** | `#F6F4ED` | **Strong Light Canvas.** Softer and more premium than sterile pure grey (`#F5F5F5`); avoids harsh screen glare during long front-desk shifts. |
| **Porcelain** | `#FFFFFF` | **Strong Elevated Card Surface.** Pairs cleanly on Warm Ivory with subtle 1px borders (`#D8D4C8`) rather than heavy drop shadows. |
| **Sage** | `#A7B7A0` | **Use for Subtle Surfaces & Dark-Mode Secondary.** Contrast on white is only ~2.1:1—MUST NOT be used for body text or small icons on light surfaces. Pair with a darkened **Deep Sage (`#4E624A`)** (~6.5:1 on white) for light-mode text/icons. |
| **Electric Lime** | `#C7F36B` | **High-Energy Kinetic Accent (Use with Discipline).** Contrast on Porcelain is ~1.25:1—NEVER use as text or thin outline on light backgrounds. Shines as a solid CTA/pill container with **Graphite (`#202421`) text** (~11.8:1 contrast!) and as the primary highlight on **Dark Theme** surfaces. |
| **Muted Coral** | `#D98276` | **Warm Alert/Waitlist/Danger Accent.** Contrast on white is ~2.9:1—use as dark-mode error/alert foreground or light-mode badge surface; pair with **Deep Coral (`#B34C3E`)** (~5.2:1 on white) for light-mode error text. |

**Key Engineering Takeaway:** Never hardcode hex values in widgets. Bind all UI to Material 3 `ColorScheme` semantic roles (`primary`, `primaryContainer`, `surface`, `onSurfaceVariant`, `error`) so the approved visual direction can be refined centrally in `lib/core/theme/`.

---

## 2. Three Proposed Visual Directions

### Direction A — Editorial Kinetic *(Recommended Baseline — Active in Initial Theme)*
- **Visual Mood:** Architectural hospitality meets modern athletic club (inspired by Equinox, Aesop, and precision Swiss instruments).
- **Palette Application:** Warm Ivory (`#F6F4ED`) canvas, Porcelain (`#FFFFFF`) hairline-bordered cards, Graphite (`#202421`) primary buttons and typography, Electric Lime (`#C7F36B`) reserved strictly for kinetic micro-moments (active pass indicator, booking confirmation pill, dark-mode CTA), Deep Sage for positive/confirmed states, Deep/Muted Coral for full/late-cancel alerts.
- **Typography:** Clean geometric grotesque display headings (`Plus Jakarta Sans` or `Inter Tight` when bundled) + crisp tabular numerals (`Inter` / system sans with `fontFeatures: [FontFeature.tabularFigures()]`) for schedules, capacities, and credit counts.
- **Best Fit:** Bridges luxury Pilates/Yoga boutiques and high-end traditional gyms effortlessly.

### Direction B — Precision Obsidian *(Dark-First Performance)*
- **Visual Mood:** High-contrast athletic telemetry (inspired by Whoop, Barry's, and Strava Pro).
- **Palette Application:** Obsidian (`#141715`) and Graphite (`#202421`) primary surfaces across Member Experience, Electric Lime (`#C7F36B`) primary actions, Porcelain/Warm Ivory typography, Sage secondary indicators. Operations web/tablet defaults to crisp Light Mode for bright lobby lighting with optional Dark Mode toggle.
- **Trade-Off:** Looks bold and sporty for CrossFit/HIIT gyms, though slightly intense for serene Yoga/Pilates studios unless Light Mode remains equally polished.

### Direction C — Mineral Studio *(Calm Botanical Minimal)*
- **Visual Mood:** Soft studio wellness and calm clarity (inspired by Alo, Reformer studios, and Notion).
- **Palette Application:** Porcelain (`#FFFFFF`) & Warm Ivory (`#F6F4ED`) primary canvas, Deep Sage (`#4E624A`) primary actions instead of Graphite, Sage (`#A7B7A0`) soft tinted containers, Muted Coral accents, Electric Lime minimized or replaced with warm brass/olive highlights.
- **Trade-Off:** Very welcoming for boutique wellness studios, slightly less assertive for high-volume multi-branch traditional gyms.

---

## 3. Dual UX Architecture: Member vs Operations

RITMA refuses to force a member and a front-desk receptionist into the same navigation chrome or screen density.

| Dimension | Member Experience (`/member/*`) | Operations Experience (`/ops/*`) |
|---|---|---|
| **Primary Goal** | Book a class in < 10 seconds, pull up QR pass instantly, track remaining credits & visits | Process check-ins in < 2 seconds, manage schedules/rosters, monitor branch KPIs accurately |
| **Visual Density** | `RitmaDensity.member` — generous whitespace, 16px–24px rhythm, card-led visual hierarchy | `RitmaDensity.operations` — compact density (`VisualDensity.compact`), high scannability, tabular numbers, clear status badges |
| **Navigation Pattern** | Bottom navigation bar (4 clear tabs: **Home / Pass**, **Schedule**, **Bookings**, **Profile**) | Adaptive shell: Mobile bottom bar (Check-In Scanner, Roster, Members, Dashboard) + Tablet/Web **NavigationRail** with persistent **Org/Branch Context Switcher** |
| **Key Components** | Rotating Digital QR Pass card, horizontal date strip, remaining credit pills, 1-tap booking bottom sheet | Full-bleed QR scanner overlay with instant green/coral audio-haptic feedback, searchable member table, roster quick-toggle attendance list, live metric tiles |

---

## 4. Accessibility, Scaling & Responsive Standards

1. **Contrast Compliance:** Minimum 4.5:1 for normal text and 3:1 for large text/UI controls in both Light and Dark themes.
2. **Dynamic Text Scaling:** Layouts must not clip or overflow at up to `2.0x` system font scale—use flexible `Wrap`, scrollable containers, and avoid fixed-height text boxes.
3. **Touch Targets:** Minimum `48x48dp` interactive targets on mobile (`44x44dp` minimum on compact Operations controls).
4. **Responsive Breakpoints:**
   - Compact (Phone): `< 600dp`
   - Medium (Tablet / Large Phone): `600dp – 1023dp`
   - Expanded (Desktop / Web Ops): `>= 1024dp`
5. **Color-Blind Safety:** Never convey check-in status (`ALLOWED` / `DENIED`), booking state (`Confirmed` / `Waitlist`), or seat availability using color alone—always pair with explicit iconography and concise labels.
6. **Honest States:** Every data surface uses `AsyncStateView` (or equivalent) to handle Loading, Empty, Error (with retry), Offline, and Success states cleanly.
