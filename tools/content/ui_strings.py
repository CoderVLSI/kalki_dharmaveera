# UI / objective strings: S(key, en, hi, te)
STRINGS = {}


def S(k, en, hi, te):
    STRINGS[k] = {"en": en, "hi": hi, "te": te}


S("game_title", "KALKI DHARMAVEERA", "कल्कि धर्मवीर", "కల్కి ధర్మవీర")
S("missions", "Missions", "अभियान", "మిషన్లు")
S("btn_continue", "Continue", "जारी रखें", "కొనసాగించు")
S("btn_begin", "Begin the campaign", "अभियान आरंभ करें", "ప్రచారం ప్రారంభించు")
S("btn_newgame", "New campaign", "नया अभियान", "కొత్త ప్రచారం")
S("btn_codex", "Codex", "कोडेक्स", "కోడెక్స్")
S("btn_freeride", "Free ride (arena)", "मुक्त सवारी (अखाड़ा)", "స్వేచ్ఛా స్వారీ (అరేనా)")
S("btn_next", "Next mission", "अगला अभियान", "తదుపరి మిషన్")
S("btn_replay", "Replay", "फिर खेलें", "మళ్ళీ ఆడు")
S("btn_retry", "Try again", "फिर प्रयास करें", "మళ్ళీ ప్రయత్నించు")
S("btn_menu", "Menu", "मेनू", "మెనూ")
S("btn_resume", "Resume", "जारी रखें", "కొనసాగించు")
S("btn_close", "Close", "बंद करें", "మూసివేయి")
S("btn_talk", "TALK", "बात", "మాట")
S("mission_complete", "Mission complete", "अभियान पूर्ण", "మిషన్ పూర్తయింది")
S("mission_failed", "Kalki has fallen. The age is not yet lost.", "कल्कि गिर गए। युग अभी खोया नहीं है।", "కల్కి పడిపోయాడు. యుగం ఇంకా కోల్పోలేదు.")
S("paused", "Paused", "विराम", "విరామం")
S("prompt_talk", "[G] Talk to %s", "[G] %s से बात करें", "[G] %s తో మాట్లాడండి")
S("codex", "Codex", "कोडेक्स", "కోడెక్స్")
S("codex_empty", "No entries yet. Entries appear as you meet them in the story.", "अभी कोई प्रविष्टि नहीं। कथा में मिलते ही प्रविष्टियाँ जुड़ेंगी।", "ఇంకా ఎంట్రీలు లేవు. కథలో ఎదురైనప్పుడు ఎంట్రీలు చేరుతాయి.")
S("adapted_note", "Source tier and citation as in the reference PDF; game text is adapted.", "स्रोत-स्तर और संदर्भ संदर्भ-पीडीएफ के अनुसार; खेल का पाठ रूपांतरित है।", "మూల స్థాయి, ఉదహరింపు రిఫరెన్స్ PDF ప్రకారం; ఆట పాఠ్యం అనుసృజన.")
S("paraphrase", "PARAPHRASE OF THE TEXT", "पाठ का सार", "పాఠ్య సారాంశం")
S("satya_dawn", "SATYA YUGA DAWNS", "सत्ययुग का उदय", "సత్య యుగోదయం")
S("yields", "yields with honour", "सम्मान सहित हार मानता है", "గౌరవంగా లొంగాడు")

# speakers / names
for k, en, hi, te in [
    ("Kalki", "Kalki", "कल्कि", "కల్కి"), ("Vishnuyashas", "Vishnuyashas", "विष्णुयश", "విష్ణుయశుడు"),
    ("Sumati", "Sumati", "सुमति", "సుమతి"), ("Parashurama", "Parashurama", "परशुराम", "పరశురాముడు"),
    ("Shiva", "Shiva", "शिव", "శివుడు"), ("Parvati", "Parvati", "पार्वती", "పార్వతి"),
    ("Padmavati", "Padmavati", "पद्मावती", "పద్మావతి"), ("Ramadevi", "Ramadevi", "रमादेवी", "రమాదేవి"),
    ("Yajnavalkya", "Yajnavalkya", "याज्ञवल्क्य", "యాజ్ఞవల్క్యుడు"), ("Ananta", "Sage Ananta", "ऋषि अनन्त", "ఋషి అనంతుడు"),
    ("Vishakhayupa", "King Vishakhayupa", "राजा विशाखयूप", "రాజు విశాఖయూపుడు"), ("Brhadratha", "King Brhadratha", "राजा बृहद्रथ", "రాజు బృహద్రథుడు"),
    ("Maru", "Maru", "मरु", "మరువు"), ("Devapi", "Devapi", "देवापि", "దేవాపి"),
    ("Dharma", "Dharma", "धर्म", "ధర్మం"), ("Krita", "Krita Yuga", "कृतयुग", "కృత యుగం"),
    ("Kali", "Kali, the age", "कलि, युग-पुरुष", "కలి, యుగ పురుషుడు"), ("Kuthodari", "Kuthodari", "कुथोदरी", "కుథోదరి"),
    ("Vikanja", "Vikanja", "विकंज", "వికంజుడు"), ("Koka", "Koka", "कोक", "కోకుడు"),
    ("Shashidhvaja", "King Shashidhvaja", "राजा शशिध्वज", "రాజు శశిధ్వజుడు"), ("Shushanta", "Queen Shushanta", "रानी सुशान्ता", "రాణి సుశాంత"),
    ("Sulocana", "Sulocana", "सुलोचना", "సులోచన"), ("Refugee", "Refugee", "शरणार्थी", "శరణార్థి"),
    ("Surya", "Surya Deva", "सूर्यदेव", "సూర్యదేవుడు"),
]:
    S("speaker_" + k, en, hi, te)
    S("npc_" + k.lower(), en, hi, te)
S("npc_toll", "Toll-keeper", "चुंगी अधिकारी", "సుంకం అధికారి")

# enemies
S("enemy_construct", "Training pillar", "प्रशिक्षण-स्तंभ", "శిక్షణ స్తంభం")
S("enemy_android", "Iron soldier of Kali", "कलि का लौह सैनिक", "కలి ఇనుప సైనికుడు")
S("enemy_guru", "Parashurama (practice)", "परशुराम (अभ्यास)", "పరశురాముడు (అభ్యాసం)")
S("enemy_king", "King Shashidhvaja", "राजा शशिध्वज", "రాజు శశిధ్వజుడు")
S("enemy_kuthodari", "Kuthodari", "कुथोदरी", "కుథోదరి")
S("enemy_vikanja", "Vikanja", "विकंज", "వికంజుడు")
S("enemy_kali", "Kali", "कलि", "కలి")

# objectives
OBJ = [
    ("obj_talk_refugee", "Speak with the refugee elder", "शरणार्थी बुज़ुर्ग से बात करें", "శరణార్థి పెద్దతో మాట్లాడండి"),
    ("obj_protect", "Protect the refugees: stop the robbers", "शरणार्थियों की रक्षा करें: लुटेरों को रोकें", "శరణార్థులను కాపాడండి: దొంగలను ఆపండి"),
    ("obj_toll", "Reach the toll post", "चुंगी चौकी तक पहुँचें", "సుంకం కేంద్రానికి చేరండి"),
    ("obj_tollkeepers", "Stop the toll-keepers who rob by deed", "कर्म से लूटने वाले चुंगी अधिकारियों को रोकें", "చేతల్లో దోచే సుంకం అధికారులను ఆపండి"),
    ("obj_talk_father", "Speak with your father, Vishnuyashas", "अपने पिता विष्णुयश से बात करें", "మీ తండ్రి విష్ణుయశునితో మాట్లాడండి"),
    ("obj_talk_mother", "Speak with your mother, Sumati", "अपनी माता सुमति से बात करें", "మీ తల్లి సుమతితో మాట్లాడండి"),
    ("obj_naming", "Go to the sacred fire for your naming", "नामकरण के लिए पवित्र अग्नि के पास जाएँ", "నామకరణం కోసం పవిత్ర అగ్ని దగ్గరకు వెళ్ళండి"),
    ("obj_talk_guru", "Speak with Parashurama", "परशुराम से बात करें", "పరశురాముడితో మాట్లాడండి"),
    ("obj_pillars", "Strike the training pillars", "प्रशिक्षण-स्तंभों पर प्रहार करें", "శిక్షణ స్తంభాలను కొట్టండి"),
    ("obj_astra", "Strike the distant targets with your Astra (F)", "अपने अस्त्र (F) से दूर के लक्ष्यों को भेदें", "మీ అస్త్రంతో (F) దూరపు లక్ష్యాలను కొట్టండి"),
    ("obj_spar", "Spar with Parashurama (practice only)", "परशुराम के साथ अभ्यास-युद्ध करें", "పరశురాముడితో అభ్యాస పోరు చేయండి"),
    ("obj_shrine", "Walk to Mahadeva's shrine", "महादेव के मंदिर तक चलें", "మహాదేవుని ఆలయం వరకు నడవండి"),
    ("obj_approach", "Approach the shrine of Bilvodakeshvara", "बिल्वोदकेश्वर के मंदिर के पास जाएँ", "బిల్వోదకేశ్వర ఆలయానికి చేరండి"),
    ("obj_talk_shiva", "Worship and speak with Mahadeva", "महादेव की आराधना कर बात करें", "మహాదేవుని ఆరాధించి మాట్లాడండి"),
    ("obj_mount", "Mount Devadatta", "देवदत्त पर आरूढ़ हों", "దేవదత్తుడిపై ఎక్కండి"),
    ("obj_rings", "Ride through the rings (Devadatta trial)", "वलयों में से सवारी करें (देवदत्त परीक्षा)", "వలయాల గుండా స్వారీ చేయండి (దేవదత్త పరీక్ష)"),
    ("obj_gate_mahishmati", "Ride to the gate of Mahishmati", "माहिष्मती के द्वार तक सवारी करें", "మాహిష్మతి ద్వారం వరకు స్వారీ చేయండి"),
    ("obj_talk_vish", "Speak with King Vishakhayupa", "राजा विशाखयूप से बात करें", "రాజు విశాఖయూపుడితో మాట్లాడండి"),
    ("obj_scout", "Shuka scouts Simhala", "शुक सिंहल की टोह लेता है", "శుకుడు సింహళాన్ని వేగు చూస్తాడు"),
    ("obj_gate_simhala", "Walk to the palace of Simhala", "सिंहल के महल तक चलें", "సింహళ రాజభవనం వరకు నడవండి"),
    ("obj_talk_padma", "Speak with Padmavati", "पद्मावती से बात करें", "పద్మావతితో మాట్లాడండి"),
    ("obj_lotus", "Gather lotuses from the three ponds", "तीनों सरोवरों से कमल एकत्र करें", "మూడు సరస్సుల నుండి కమలాలు సేకరించండి"),
    ("obj_fire", "Walk around the sacred fire four times", "पवित्र अग्नि की चार परिक्रमा करें", "పవిత్ర అగ్ని చుట్టూ నాలుగు ప్రదక్షిణలు చేయండి"),
    ("obj_talk_ananta", "Listen to the sage Ananta", "ऋषि अनन्त को सुनें", "ఋషి అనంతుని వినండి"),
    ("obj_choice", "Answer the sage", "ऋषि को उत्तर दें", "ఋషికి జవాబు చెప్పండి"),
    ("obj_lotus_white", "Walk to the white lotus", "श्वेत कमल तक चलें", "తెల్ల కమలం వరకు నడవండి"),
    ("obj_talk_family", "Receive blessings from your family", "परिवार से आशीर्वाद लें", "కుటుంబం నుండి ఆశీర్వాదాలు పొందండి"),
    ("obj_council", "Gather at the council fire", "सभा की अग्नि पर एकत्र हों", "సభా అగ్ని వద్ద చేరండి"),
    ("obj_codex", "Read the codex entry", "कोडेक्स की प्रविष्टि पढ़ें", "కోడెక్స్ ఎంట్రీ చదవండి"),
    ("obj_pilgrims", "Defend the pilgrims from armed raiders", "सशस्त्र लुटेरों से तीर्थयात्रियों की रक्षा करें", "సాయుధ దోపిడీదారుల నుండి యాత్రికులను కాపాడండి"),
    ("obj_talk_rishi", "Speak with the rishi", "ऋषि से बात करें", "ఋషితో మాట్లాడండి"),
    ("obj_ascend", "Ride up the white mountain", "श्वेत पर्वत पर सवारी करें", "తెల్ల పర్వతం పైకి స్వారీ చేయండి"),
    ("obj_kuthodari", "Defeat Kuthodari and Vikanja", "कुथोदरी और विकंज को पराजित करें", "కుథోదరి, వికంజుడిని ఓడించండి"),
    ("obj_reach_kalapa", "Ride to Kalapa village", "कलाप ग्राम तक सवारी करें", "కలాప గ్రామం వరకు స్వారీ చేయండి"),
    ("obj_talk_devapi", "Speak with Devapi", "देवापि से बात करें", "దేవాపితో మాట్లాడండి"),
    ("obj_talk_maru", "Speak with Maru", "मरु से बात करें", "మరువుతో మాట్లాడండి"),
    ("obj_defend_road", "Drive off the raiders at the pass", "दर्रे पर लुटेरों को भगाएँ", "కనుమ దగ్గర దోపిడీదారులను తరిమేయండి"),
    ("obj_talk_dharma", "Speak with Dharma", "धर्म से बात करें", "ధర్మంతో మాట్లాడండి"),
    ("obj_talk_krita", "Speak with Krita Yuga", "कृतयुग से बात करें", "కృత యుగంతో మాట్లాడండి"),
    ("obj_march", "March toward Visasana", "विसासन की ओर कूच करें", "విసాసనం వైపు సాగండి"),
    ("obj_patrol", "Break the iron patrol", "लौह गश्ती दल को तोड़ें", "ఇనుప గస్తీని ఛేదించండి"),
    ("obj_gate_guards", "Break the gate guard", "द्वार रक्षकों को तोड़ें", "ద్వార రక్షకులను ఛేదించండి"),
    ("obj_twins", "Strike Koka and Vikoka together", "कोक और विकोक पर एक साथ प्रहार करें", "కోకుడు, వికోకుడిపై ఒకేసారి కొట్టండి"),
    ("obj_kali", "Defeat Kali", "कलि को पराजित करें", "కలిని ఓడించండి"),
    ("obj_gate_bhallata", "Walk to the court of Bhallata", "भल्लाट के दरबार तक चलें", "భల్లాట సభ వరకు నడవండి"),
    ("obj_talk_shashidhvaja", "Speak with King Shashidhvaja", "राजा शशिध्वज से बात करें", "రాజు శశిధ్వజుడితో మాట్లాడండి"),
    ("obj_duel", "Honourable duel: yield nothing, kill no one", "सम्मानपूर्ण द्वंद्व: न झुकें, किसी को न मारें", "గౌరవ ద్వంద్వం: లొంగకండి, ఎవరినీ చంపకండి"),
    ("obj_talk_ramadevi", "Speak with Ramadevi", "रमादेवी से बात करें", "రమాదేవితో మాట్లాడండి"),
    ("obj_lotus_shrines", "Light the lotus shrines (avoid the poison mist)", "कमल-मंदिरों को जलाएँ (विषैले कोहरे से बचें)", "కమల మందిరాలను వెలిగించండి (విష పొగమంచును తప్పించండి)"),
    ("obj_talk_sulocana", "Speak with Sulocana", "सुलोचना से बात करें", "సులోచనతో మాట్లాడండి"),
    ("obj_restore", "Restore the towns", "नगरों को पुनः स्थापित करें", "పట్టణాలను పునఃస్థాపించండి"),
    ("obj_predators", "Stop the last predatory rulers' men", "अंतिम शिकारी शासकों के सैनिकों को रोकें", "చివరి దోపిడీ పాలకుల మనుషులను ఆపండి"),
    ("obj_ganga", "Walk to the sacred confluence", "पवित्र संगम तक चलें", "పవిత్ర సంగమం వరకు నడవండి"),
    ("obj_farewell", "Speak with your companions", "अपने साथियों से बात करें", "మీ సహచరులతో మాట్లాడండి"),
    ("obj_talk_narayana", "Speak with the Lord", "प्रभु से बात करें", "ప్రభువుతో మాట్లాడండి"),
    ("opt_m07_a", "Hold harder to what the world gives.", "संसार जो देता है उसे और कसकर पकड़ो।", "లోకం ఇచ్చినదాన్ని మరింత గట్టిగా పట్టుకో."),
    ("opt_m07_b", "Remember the Lord within, and act without clinging.", "भीतर के प्रभु को स्मरण करो और आसक्ति रहित कर्म करो।", "లోపల ఉన్న ప్రభువును స్మరించి అంటిపెట్టుకోకుండా కర్మ చేయి."),
    ("opt_m07_c", "Run away from the world.", "संसार से भाग जाओ।", "లోకం నుండి పారిపో."),
]
for k, en, hi, te in OBJ:
    S(k, en, hi, te)
