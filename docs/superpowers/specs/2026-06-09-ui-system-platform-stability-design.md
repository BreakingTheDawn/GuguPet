# GuguPet UI System and Platform Stability Design

Date: 2026-06-09

## Background

GuguPet currently has a clear product direction: a pet companion that helps users continue their job search. The strongest current screen is the confide room, where the pet character, soft background, and input area create emotional value. Other modules are useful, but the visual language is fragmented across tool-style job cards, a large green park scene, a brown archive-style column page, and a profile page with separate card styling.

This design defines a single UI system before page-level implementation. It also includes the platform fixes needed to verify the UI reliably on Windows and Web.

## Confirmed Scope

The implementation will use the "system first, pages second" approach.

Included:

- Build a unified design token layer for color, surface, text, icon, border, and status usage.
- Add a shared responsive app frame for mobile-first layout and basic desktop polish.
- Normalize bottom navigation, page backgrounds, surfaces, cards, pills, buttons, icon badges, search fields, and empty states.
- Optimize all five main tabs: Confide, Jobs, Park, Columns, and Profile.
- Keep the visual direction as "companion plus workbench".
- Keep mobile portrait as the primary experience.
- Use progressive desktop support: centered app container and branded outer background now, with room for a future full desktop layout.
- Fix only the platform issues that block UI verification.
- Systematically organize database migrations within the bounded migration scope.
- Add a discoverable technical debt record at `docs/技术债务记录.md`.

Not included:

- Full Web productization.
- Full two-column desktop workbench.
- Historical technical debt consolidation.
- Rebuilding the main pet asset set.
- Large business-flow or navigation architecture rewrites.
- Unrelated data-layer refactors outside migration stability.

## Visual Direction

The selected direction is a balanced "companion plus workbench" model.

- Confide remains the emotional companion center.
- Jobs and Profile lean toward a clear workbench experience.
- Park and Columns keep light module-specific themes, but share the same base skeleton, token system, surfaces, icon rules, and text hierarchy.
- The main pet remains a memorable character. Smaller repeated UI marks use a simplified penguin badge system.

## Design Tokens

The following values are the first locked token set for this work:

| Type | Token | Value | Purpose |
| --- | --- | --- | --- |
| Background | `backgroundDefault` | `#F8F7FC` | Default page background |
| Background | `backgroundSubtle` | `#F1F3FA` | Section and weak-state background |
| Text | `textDefault` | `#202136` | Main titles and primary body text |
| Text | `textSecondary` | `#71758A` | Descriptions, timestamps, metadata |
| Text | `textTertiary` | `#A1A4B5` | Placeholder and disabled text |
| Text | `textInverse` | `#FFFFFF` | Text on dark or brand-filled surfaces |
| Text Fill | `textFill` | `#EEF1FF` | Light label and selected text containers |
| Icon | `iconDefault` | `#5F6FEB` | Active icons and primary actions |
| Icon | `iconSecondary` | `#7B7E91` | Inactive and supporting icons |
| Icon Fill | `iconFill` | `#EEF1FF` | Icon badge backgrounds |
| Surface | `surfaceDefault` | `#FFFFFF` | Cards, dialogs, and navigation |
| Surface | `surfaceSecondary` | `#F4F5FB` | Secondary cards and list rows |
| Surface Fill | `surfaceFill` | `#FFFFFFCC` | Translucent overlays and soft containers |
| Brand | `brandPrimary` | `#5F6FEB` | Primary buttons, active state, key links |
| Brand | `brandSoft` | `#DDE3FF` | Soft brand fills |
| Accent | `accentWarm` | `#F5B84B` | Pet levels, rewards, warm feedback |
| Accent | `accentGrowth` | `#59C783` | Growth, completion, online state |
| Border | `borderDefault` | `#E4E6EF` | Card and input borders |
| Divider | `dividerDefault` | `#ECEEF5` | List and navigation dividers |

Token usage rules:

- Indigo is the brand and action color.
- Warm yellow represents pet rewards, level, encouragement, and positive emotional feedback.
- Green represents growth, completion, and online state.
- Module themes must be derived from these tokens instead of adding unrelated palettes.
- Page backgrounds should avoid pure white as the dominant full-screen background.

## Base UI Framework

### Responsive App Frame

Add a shared app frame around the main content.

Mobile:

- Keep the current full-screen mobile app experience.
- Preserve the five-tab bottom navigation pattern.

Wide Web and Windows:

- Center the app in a constrained container.
- Use a branded outer background.
- Keep bottom navigation inside the app container, not stretched across the full desktop window.
- Reserve breakpoint constants so a future two-column desktop layout can be added without replacing the frame.

### Bottom Navigation

Keep five tabs:

- Confide
- Jobs
- Park
- Columns
- Profile

Navigation styling:

- Active icon and label use `brandPrimary`.
- Inactive icon and label use `iconSecondary`.
- Navigation surface uses `surfaceFill` with a light top divider.
- Icon choice stays Material Icons for normal actions.
- Pet-specific or emotional states may use the simplified penguin badge system.

### Shared Components

Create or normalize these shared components first:

- `ResponsiveAppFrame`
- `AppSurfaceCard`
- `AppSectionHeader`
- `AppPill`
- `AppIconBadge`
- `AppEmptyState`
- `AppPrimaryButton`
- `AppSearchField`

The goal is to reduce visual fragmentation across the five tabs. This is not a mandate to abstract every widget in one pass.

## Page Strategies

### Confide

Role: emotional companion center.

Changes:

- Keep the pet as the main visual anchor.
- Normalize the top status bar, interaction buttons, and input area to the token system.
- Make the input area feel like a clear "today's confide entry" rather than an isolated floating control.
- Represent pet status, level, and maturity with brand, warm, and growth accents.
- Reduce mixed emoji, icon, and character styles.

### Jobs

Role: action workbench.

Changes:

- Keep search, categories, job cards, and detail entry.
- Strengthen the information hierarchy around today's new jobs, recommendations, filters, and notifications.
- Use `AppSurfaceCard` for job cards.
- Normalize score, location, experience, education, and detail buttons through shared pills and button rules.
- Keep job business logic unchanged.

### Park

Role: light social extension of companionship.

Changes:

- Replace the large empty green area with a more structured section.
- Keep the "coder forest" idea as a light theme, not a separate full palette.
- Use unified icon badges for friends, posts, notifications, and social actions.
- Use simplified penguin badges for users or pet avatars where appropriate.
- Add visible guidance, social cards, or task entry points so empty space does not read as a loading failure.

### Columns

Role: paid content and archive.

Changes:

- Preserve the archive concept and content commerce role.
- Reduce brown-gold from a dominant page-wide palette to a module accent.
- Normalize cards, preview buttons, category pills, and bottom CTA with the shared token system.
- Keep prices and trial-reading actions clear.

### Profile

Role: personal job-search workbench.

Changes:

- Keep user identity, job status stats, VIP entry, and feature list.
- Normalize avatar, role tags, stat cards, and VIP surfaces.
- Make stat numbers and labels easier to scan.
- Use warm accent for VIP and benefits, but keep the card inside the global visual language.

## Platform Stability

### Web UI Verification

Goal: Web can open and browse the five main tabs for UI verification.

Scope:

- Wrap or replace startup-time platform calls that are unsupported on Web, including direct `Platform.isWindows` or equivalent `Platform._operatingSystem` access paths.
- Degrade unsupported Web services so they do not block main-page rendering.
- Local database, notifications, file paths, device information, and security checks may use mock, empty, or disabled states on Web.
- Web is not treated as a production platform in this work.

### Windows Startup

Goal: Windows can launch into the main page for UI verification.

Scope:

- Organize database migration version handling.
- Make repeated table creation idempotent or guarded by explicit existence checks.
- Fix the observed repeated `wish_envelopes` table creation failure.
- Preserve existing local data by default.
- If a development database is unrecoverably inconsistent, surface a clear error and recovery guidance instead of silently deleting data.

### Database Migration

Migration work is intentionally bounded:

- Clarify the current database version path.
- Ensure table creation and upgrade steps are repeatable where needed.
- Avoid re-running already completed migration steps.
- Add tests for key migration paths, including existing-table scenarios.
- Do not change business model meaning.
- Do not perform broad data-layer refactoring outside migration stability.

## Verification

Use screenshot verification plus automated tests.

Required checks:

- Windows launches to the main page.
- Web opens and can browse the five main tabs.
- Screenshots for all five main tabs show consistent navigation, surfaces, text hierarchy, and no obvious overflow or abnormal blank space.
- Database migration tests cover repeated table or existing-table scenarios.
- Web startup has a smoke test or equivalent verification.
- Key main pages have smoke or widget tests for loadability.

If existing historical tests fail outside this scope, record the failure and separate it from this work unless it blocks the UI verification path.

## Documentation

Add `docs/技术债务记录.md` as the discoverable long-term debt entry for this project.

This work records only UI and platform verification debt discovered during this design. It explicitly does not consolidate historical debt from earlier plans, including `docs/plans/2026-03-24-technical-debt-resolution.md`.

The design document links to the debt document. If README is touched later, only a short pointer should be added.

## Debt Summary

Detailed tracking belongs in `docs/技术债务记录.md`.

Known deferred items:

- Web is only supported for UI browsing and verification, not production release.
- Desktop gets a centered mobile-first container now, not a full two-column desktop interface.
- Historical technical debt remains unconsolidated.
- Some old database migration paths may remain outside the covered key-path tests.
- Main pet assets are reused; only small badge/icon consistency is addressed.

## Approval State

The following decisions were confirmed before writing this design:

- Scope: UI optimization plus platform verification blockers.
- Visual direction: companion plus workbench.
- Primary platform: mobile-first.
- Page scope: all five main tabs.
- Pet strategy: keep main pet, add simplified penguin badges.
- Icon strategy: Material Icons plus branded pet badges.
- Design token set: approved.
- Desktop approach: progressive, centered container first.
- Platform repair scope: fix UI verification blockers and record remaining debt.
- Debt document: `docs/技术债务记录.md`.
- Database migration: systematic bounded organization.
- Data handling: preserve data by default, with explicit recovery guidance for unrecoverable dirty development databases.
- Web depth: browse main pages for UI verification, not production Web.
- Verification: screenshots plus automated tests.
