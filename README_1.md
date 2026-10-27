# HelpNearby

**Free and low-cost community help, in one place, in under 30 seconds.**

People who need help with food, healthcare, housing or school often don't know what exists nearby, and the information that does exist is scattered across flyers, agency websites and word of mouth. HelpNearby puts local resources on one shared, searchable map with the answers people need first: *Is it open right now? How far is it? Is it free? Do I need an appointment? Do they speak my language?*

Community members can suggest places they know, and **every suggestion is verified by a volunteer before anyone else sees it.**

Built for **NextSpark Hacks 2026**.

> ⚠️ **Prototype notice:** listings marked "Sample" are **fictional demo data**. The hotlines shown (988, 211, 911) are real US services.

## Features

- **Shared database** – everyone sees the same listings (Supabase / Postgres).
- **Community suggestions with verification** – anyone can suggest a place; it's saved as *pending* and stays hidden until a volunteer approves it. The submitter sees their own suggestion marked "Waiting for verification", and it switches to live once approved. Approved listings show a "Verified" date.
- **Map view** – color-coded pins (green = open now, grey = closed), popups with call and directions links.
- **Distance sorting** – "Use my location" or type a ZIP/address; results show miles away and sort nearest first.
- **Plain-language search** – "hungry" finds food, "rent" finds housing, "laptop" finds device programs.
- **Filters** – category, open now, free only, no appointment, language.
- **Save & print** a personal list for people without reliable internet.
- **Crisis bar** – 988, 211 and 911 always visible.
- **Accessible & mobile-first** – keyboard navigable, screen-reader labels, dark mode.
- **Works without the database** – if no database is configured (or it's unreachable) the app falls back to demo mode with sample data.

## Run it locally (demo mode, 10 seconds)

Open `index.html` in any modern browser. No install, no build step.

## Connect the shared database (about 10 minutes)

1. Create a free project at [supabase.com](https://supabase.com).
2. In the project, open **SQL Editor → New query**, paste all of `setup.sql`, and click **Run**. This creates the table, the security rules and the sample listings.
3. Open **Connect** (or **Project Settings → API Keys**) and copy the **Project URL** and the **anon / publishable key**.
4. In `index.html`, find `CONFIG` near the top of the `<script>` and paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
5. Reload the page. The badge at the top should say **● Live shared database**.

> The anon key is designed to be public. **Never** put the `service_role` / secret key in the page.

### How verification works

| Who | Can do |
|---|---|
| The public (anon key) | Read **approved** listings; submit **new pending** suggestions. Cannot approve, edit or delete anything. |
| You (Supabase dashboard) | Review pending suggestions and set `status` to `approved` or `rejected`. |

These rules are enforced by Postgres row-level security in `setup.sql`, not just by the website, so they can't be bypassed from the browser.

**To verify a suggestion:** Supabase → **Table Editor → resources** → filter `status = pending` → check the details (call them, check their website) → change `status` to `approved`. The `verified_at` date is filled in automatically, and the listing appears for everyone on their next refresh (pages also refresh every 2 minutes).

## Deploy a live demo (GitHub Pages)

1. Push this repo to GitHub (**public**).
2. **Settings → Pages** → Source: *Deploy from a branch* → `main`, `/ (root)` → **Save**.
3. Your site is live at `https://<username>.github.io/<repo-name>/` within a minute.

## How it's built

- **Front end:** a single `index.html` – HTML, CSS and vanilla JavaScript.
- **Database:** Supabase (hosted Postgres) via `supabase-js`. Row-level security policies allow public reads of approved rows and public inserts of pending rows only; a trigger stamps `verified_at` on approval.
- **Map:** Leaflet with OpenStreetMap data; tiles from OpenStreetMap, Esri or Humanitarian OSM, with automatic fallback.
- **Location:** browser Geolocation API, or address/ZIP lookup with OpenStreetMap Nominatim. Distances use the haversine formula.
- **"Open now":** compares the current day and time with each listing's schedule, refreshed every minute.
- **Saved list, your pending suggestions and theme** are kept in the browser's `localStorage`.
- **Spam protection:** database length/format checks and a hidden honeypot field.

## Planned / not yet built

- Real, verified listings for a specific city (e.g. imported from a 211 data feed or city open-data portal)
- An in-app reviewer page with volunteer login (reviewing currently happens in the Supabase dashboard)
- Reporting outdated information on a listing
- Translated interface (Spanish first)
- Rate limiting for submissions

## Tools and credits

- **Languages:** HTML, CSS, JavaScript
- **Database:** [Supabase](https://supabase.com) (Postgres, row-level security) and `@supabase/supabase-js`
- **Map:** [Leaflet](https://leafletjs.com) · map data © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors · tiles from OpenStreetMap, [Esri](https://www.esri.com) and [Humanitarian OSM Team](https://www.hotosm.org)
- **Geocoding:** [Nominatim](https://nominatim.org) (OpenStreetMap)
- **Directions links:** Google Maps URLs (no API key)
- **Hosting:** GitHub Pages
- **AI assistance:** Claude (Anthropic) was used to help write the code, the database setup and this README. *(Edit this line to describe exactly what you did yourself, e.g. chose the problem, defined features and the verification rules, set up the database, tested, recorded the demo.)*

## License

MIT
