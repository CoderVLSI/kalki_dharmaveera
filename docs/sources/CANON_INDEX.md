# Canon index: Kalki in the Puranas (working draft v0.1)

**Status:** first pass. Primary-text sites (Wikipedia, vedabase.io, sacred-texts.com, GRETIL, archive.org) are blocked from the build sandbox, so this was assembled from search-result snippets and recall. Every row carries a confidence tag and **nothing marked UNVERIFIED may be quoted in-game** until it is checked against the Sanskrit or a public-domain translation.

Confidence tags: **SEEN** = appeared in a search snippet this session (still not checked against the primary text) · **RECALL** = from memory, UNVERIFIED.

## 1. Texts

| Text | Class | Kalki content | Ref | Confidence |
|---|---|---|---|---|
| **Kalki Purana** | Upapurana (not one of the 18), late (commonly placed in Bengal, 15th-18th c.; other dates proposed) | Full life: Brahma and the gods ask Vishnu for protection from Kali; birth in Shambhala to Vishnuyasha and Sumati; training under Parashurama; worship of Shiva, who grants a white horse, sword and parrot; marriage to Padmavati of Simhala (and Rama, daughter of Shashidhvaja); wars; Koka and Vikoka; Kali's defeat; Satya Yuga | Three parts, usually 7 + 7 + 21 chapters | SEEN (structure and outline) |
| **Bhagavata Purana** | Mahapurana | Kalki born in the house of the Shambhala village head Vishnuyasha; rides the horse Devadatta, sword in hand, and destroys kings who act as thieves; then Satya Yuga returns | 12.2 (about verses 18-24); also in the avatar lists (1.3, 2.7, 11.4) | RECALL, partly SEEN (a vedabase page for 12.2.19-20 appeared in results) |
| **Vishnu Purana** | Mahapurana | Kali Yuga description (Book 6, ch. 1); Kalki's coming at the yuga's end (Book 4, ch. 24) | 4.24, 6.1 | RECALL |
| **Agni Purana** | Mahapurana | Kalki as son of Vishnuyasha, with Yajnavalkya as priest, who destroys the non-Aryans (a mleccha-type term) and re-establishes order among the four varnas | ch. 16, vv. 8-9 | SEEN (two pages quote the same passage) |
| **Garuda Purana** | Mahapurana | Lists ten avatars; Kalki is the tenth | Pūrva-khaṇḍa ch. 1 **[VERIFY]** | SEEN (that it lists Kalki 10th) |
| **Matsya Purana** | Mahapurana | Kalki among the avatars | - | SEEN (that it mentions Kalki); ref RECALL |
| **Vayu Purana** | Mahapurana | Kalki Vishnuyasha / Pramiti in the account of the future | ch. 98 | RECALL |
| **Brahmanda Purana** | Mahapurana | Parallel to Vayu (Pramiti) | - | RECALL |
| **Devi Bhagavata Purana** | Upapurana or Mahapurana by tradition | The gods ask Vishnu to return as Kalki when wicked kings oppress people | ch. 5 **[VERIFY]** | SEEN |
| **Mahabharata, Vana Parva** | Itihasa | The earliest Kalki passage: Vishnuyasha Kalki; he restores dharma but does not end the cycle | 3.188.85-3.189.6 | SEEN |
| Linga, Padma, Skanda, Brahma Vaivarta, Kurma, Varaha, Vamana, Markandeya, Narada, Shiva, Brahma, Bhavishya, Brahma | Mahapuranas | Not yet checked | - | NOT DONE |

Note: the numbering of the avatar list differs between texts (for example the Bhagavata lists Kalki as the 22nd of 25 in one enumeration but as the tenth of the standard ten elsewhere). The game uses the standard ten.

## 2. Story beats we can use (Kalki Purana outline, SEEN in summaries)

1. **The gods petition Vishnu** about Kali Yuga: prologue and Narayana cameo.
2. **Birth at Shambhala** to Vishnuyasha and Sumati; brothers Kavi, Prajna and Sumantra (RECALL).
3. **Parashurama trains him** in the Vedas and arms.
4. **Shiva's boons:** a white horse (Devadatta, described as a manifestation of Garuda), a jewel-hilted sword, and the parrot **Shuka**, who knows past, present and future.
5. **Padmavati of Simhala** (daughter of Brihadratha and Kaumudi), later a second wife, Rama (daughter of Shashidhvaja).
6. **Campaign:** begins against the "Sunyavadis" who misled the people (a sensitive passage; see below).
7. **Koka and Vikoka**, twin generals of Kali, who revive each other; Brahma advises that they die only if separated and struck **at the same time**. Kalki strikes both temples at once.
8. **Kali defeated**, his line destroyed; Dharma restored; Satya Yuga begins; Kalki returns to Shambhala; his parents go to Badrikashrama; Kalki departs to Vaikuntha.

## 3. Design implications

- **Koka/Vikoka boss mechanic is canon:** two linked bosses that resurrect each other unless hit within the same moment. Implement as a paired boss; the player must separate them and land simultaneous hits (rear-up Astra + slash window).
- **Devadatta = Garuda's manifestation** supports the mounted-first design and a "Garuda surge" dash.
- **Shuka as scout** is canon (knows past, present and future): good basis for hint and foresight mechanics.
- **Sensitive passages:** the Kalki Purana's war includes enemies defined by religious or ethnic labels (and the Agni Purana line uses a "non-Aryan" term). Per PLAN.md 2.2 the game defines the enemy by **conduct** (tyranny, deceit, plunder) and uses **fictional** looks and banners. We do not depict real communities as enemies.
- **Dharma's four legs** (tapas, shaucha, daya, satya) are used for the progression pillars (Bhagavata 1.17, RECALL).

## 4. To do (needs primary-text access)

Ask for these hosts to be added to the sandbox allowlist, then do a real verification pass: `vedabase.io`, `en.wikipedia.org`, `www.sacred-texts.com`, `gretil.sub.uni-goettingen.de`, `archive.org`. Then:
1. Verify every ref above against the Sanskrit or Wilson (public domain) Vishnu Purana translation.
2. Sweep the remaining 11 Mahapuranas (and Kalki Purana chapter by chapter) and replace NOT DONE rows.
3. Pull verse text for the narration lines in `data/dialogue.json` and set their `ref` fields.

## 5. Searches used

Web searches on 8 Oct 2026 for Kalki references across the Mahapuranas and for a Kalki Purana summary. Pages surfaced include the Kalki Purana and Koka and Vikoka Wikipedia articles, vyasaonline.com, indianetzone.com and a vedabase.io page for SB 12.2.19-20. They were not fetchable from the sandbox, so details come from the search summaries only.
