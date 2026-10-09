# Kalki Purana Game Reference: working notes

Source of truth: `docs/sources/Kalki_Purana_Game_Reference.pdf` (research edition 1.0, 9 Oct 2026; supplied by the user). This file is the short agent-facing digest plus how the current game reconciles with it. Machine-readable forms: `data/missions.json` (M00-M17), `data/characters.json` (asset IDs, regions, equipment). The PDF mentions a companion `Kalki_Game_Agent_Data.json` that was **not** supplied; ask the user for it if exact records are needed (the two data files above were rebuilt from the PDF text).

## Rules to obey (PDF sections 0, 10, 11)
- Tiers: **A** Bhagavata/Vishnu/Agni (verified), **B** Kalki Purana expanded account, **C** epic parallel, **G** game adaptation (never presented as scripture), **U** unverified. Only Bhagavata, Vishnu and Agni passages are verified; the other 15 Mahapuranas are NOT VERIFIED, so do not invent verses for them.
- Every cutscene/lore claim carries source tier + locator. Newly composed dialogue is `DRAMATIZED_ADAPTATION` and is shown as **ADAPTED DIALOGUE - NOT A VERSE** (done in `Game.tier_label`). Sanskrit lines are only voiced after manual proofreading against the chosen edition (none used yet).
- Enemies are identified by **deeds**, never by religion, ethnicity, caste, nationality, language or dress. No present-day people, dates or politicians. Kali (the personified age) is not the goddess Kali. Parashurama is the guru, Mahadeva the revered giver of the gifts, and Vishnu/Narayana the Lord himself; they appear only in those roles, always with reverence.
- Finale must show **renewal** (dharma restored, Krita/Satya Yuga beginning), not only defeated enemies. Do not assign a Gregorian date to the end of the age.
- Devadatta is "swift"; white is traditional, not stated in Bhagavata 12.2.19-20. Four companions vs three elder brothers (Kavi, Prajna, Sumantra) is an edition tension in the text.

## Verified anchors worth knowing (locators only; text and Devanagari are in the PDF)
Bhagavata 1.3.25 (Kalki born to Vishnuyashas), 12.2.1 (virtues decline: dharma, satya, shaucha, kshama, daya), 12.2.18 (birth in Shambhala), 12.2.19-20 (Devadatta, sword, robber-kings), 12.2.21-23 (hearts cleansed, Krita begins), 12.2.24 (astronomical sign), 12.2.37-39 (Maru and Devapi restore dharma), Vishnu Purana 4.24, Agni Purana 16.8-10, Kalki Purana I.2.4/I.2.5/I.2.15 (promise of manifestation, companions, birth on Madhava shukla dvadashi).

## Reconciliation with the current game (v0.5.1)
| Item | Status |
|---|---|
| Prologue (devatas petition Narayana, vow, birth) | Matches M01/M02 (K1 I.1-I.2, B3 12.2.18). Brahma as the petitioner is in the roster (CHAR_BRAHMA). Lines relabelled B + adapted-dialogue mark. Voiced text says "Vishnuyasha"; the PDF uses IAST "Vishnuyashas" (changing the audio would cost about 70 credits; text could follow when re-recorded). |
| Pillars Tapas/Shaucha/Daya/Satya | Device is **G**. Bhagavata 12.2.1 lists the declining virtues (dharma, satya, shaucha, kshama, daya), so the names are grounded but the "four legs / pillars" mechanic is adaptation. Relabelled. |
| Koka and Vikoka twin-revive rule | PDF: source supports the characters and the war (K1 III.6-8), not boss phases. Rule is **G**; `data/enemies.json` ref updated. |
| Raiders/archers/banner-bearers | Invented (G); defined by conduct. Keep out of identity targeting. The older word "Mlechha" appears only in design docs, never as an in-game label. |
| Shuka appears at game start | Canon order has Shuka granted by Shiva in M04 (K1 I.3). The arena prototype is not in canon order; resolve when M03/M04 exist. |
| "Astra" rear-up shockwave | **G** ability. Brahmastra is only for Vikanja (M10, late). |
| Rodin models the user is generating | Brahma, Shiva, baby/child/teen Kalki map to slots `brahma`, `shiva`, `kalki_baby`, `kalki_child`, `kalki_teen` (`scripts/props.gd`). |

## Build order requested by the PDF (section 15)
Vertical slice first: **M03 (Parashurama's gurukula) + M04 (Shiva's three gifts) + M10 (Giantess of the North: Kuthodari/Vikanja)**, then all 18 missions with working objectives, cutscenes, UI and save state. Acceptance tests (PDF section 12) are a release gate: all 18 missions implemented (no empty placeholders), every cutscene tagged with tier and locator, no identity-based enemy logic, Sanskrit proofread, finale shows renewal. Current status per mission is in `data/missions.json`.
