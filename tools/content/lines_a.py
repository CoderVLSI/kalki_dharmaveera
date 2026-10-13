# Dialogue for M00-M06. L(id, speaker, en, hi, te, tier, source, speech_type)
# tier A = verified principal text (Bhagavata/Vishnu/Agni), B = Kalki Purana expanded account, G = game adaptation.
# DRAMATIZED_ADAPTATION lines are newly composed (shown as ADAPTED DIALOGUE - NOT A VERSE);
# ENGLISH_PARAPHRASE lines paraphrase the cited passage.
LINES = []
D, P = "DRAMATIZED_ADAPTATION", "ENGLISH_PARAPHRASE"


def L(i, sp, en, hi, te, tier="B", src="", st=D):
    LINES.append(dict(id=i, speaker=sp, en=en, hi=hi, te=te, tier=tier, src=src, st=st))


# ---------------------------------------------------------------- M00 The Age Fractures
L("m00_1", "Narrator",
  "Day by day, through the force of time, righteousness, truth, purity, patience, compassion, lifespan, strength and memory decline.",
  "समय के प्रभाव से दिन-प्रतिदिन धर्म, सत्य, शौच, क्षमा, दया, आयु, बल और स्मृति घटते जाते हैं।",
  "కాల ప్రభావంతో రోజురోజుకూ ధర్మం, సత్యం, శౌచం, క్షమ, దయ, ఆయుష్షు, బలం, స్మృతి క్షీణిస్తాయి.",
  "A", "Bhagavata Purana 12.2.1", P)
L("m00_2", "Narrator",
  "Kalki beholds the age as it will be: rulers who rob like thieves, and people who have forgotten what they are.",
  "कल्कि उस युग को वैसा ही देखते हैं जैसा वह होगा: चोरों की तरह लूटने वाले शासक, और अपना स्वरूप भूल चुके लोग।",
  "కల్కి ఆ యుగాన్ని అది ఉండబోయే రూపంలో చూస్తాడు: దొంగల్లా దోచుకునే పాలకులు, తమ నిజస్వరూపాన్ని మరచిన ప్రజలు.",
  "B", "Bhagavata 1.3.25; 12.2.20 (the yuga-sandhi vision)")
L("m00_3", "Refugee",
  "Lord, they take our grain and call it a tax. The road is unsafe, and fear has poisoned even our well.",
  "प्रभु, वे हमारा अनाज छीनकर उसे कर कहते हैं। सड़क असुरक्षित है, और भय ने हमारे कुएँ तक को विषैला कर दिया है।",
  "ప్రభూ, వారు మా ధాన్యం లాక్కొని దాన్ని పన్ను అంటారు. దారి సురక్షితం కాదు, భయం మా బావిని కూడా విషపూరితం చేసింది.",
  "G", "")
L("m00_4", "Kalki",
  "Stay close to me. I will not strike anyone for who they are, only for what they do.",
  "मेरे पास रहो। मैं किसी पर उसके स्वरूप के लिए नहीं, केवल उसके कर्म के लिए प्रहार करूँगा।",
  "నా దగ్గరే ఉండండి. నేను ఎవరినీ వారు ఎవరన్నదానికి కాదు, వారు చేసే పనికి మాత్రమే శిక్షిస్తాను.",
  "G", "")
L("m00_5", "Refugee",
  "The toll-keepers wear the king's colours, but they behave like robbers. Will you stop them?",
  "चुंगी वाले राजा के रंग पहनते हैं, पर व्यवहार लुटेरों जैसा करते हैं। क्या आप उन्हें रोकेंगे?",
  "సుంకం వసూలు చేసేవారు రాజు రంగులు ధరిస్తారు, కానీ దొంగల్లా ప్రవర్తిస్తారు. మీరు వారిని ఆపుతారా?",
  "G", "")
L("m00_6", "Narrator",
  "Radiant and riding at speed, he confronts masses of robbers masquerading as kings.",
  "तेजस्वी और वेग से दौड़ते हुए, वे राजा का वेश धरे लुटेरों के दलों का सामना करते हैं।",
  "తేజస్సుతో, వేగంగా స్వారీ చేస్తూ, రాజు వేషం వేసిన దొంగల గుంపులను ఎదుర్కొంటాడు.",
  "A", "Bhagavata Purana 12.2.20", P)
L("m00_7", "Narrator",
  "The road is open again, and the people breathe. Dharma still stands on one leg, but the first step toward the age's end has been taken.",
  "सड़क फिर खुल गई है और लोग साँस ले रहे हैं। धर्म अभी एक पैर पर ही खड़ा है, पर युग के अंत की ओर पहला कदम उठ चुका है।",
  "దారి మళ్ళీ తెరుచుకుంది, ప్రజలు ఊపిరి పీల్చుకున్నారు. ధర్మం ఇంకా ఒంటి కాలిపైనే ఉంది, కానీ యుగాంతం వైపు మొదటి అడుగు పడింది.",
  "G", "")

# ---------------------------------------------------------------- M02 The House in Shambhala
L("m02_1", "Narrator",
  "In the village of Shambhala, in the house of the eminent Brahmin Vishnuyashas, Kalki will appear.",
  "शम्भल ग्राम में, श्रेष्ठ ब्राह्मण विष्णुयश के घर में कल्कि प्रकट होंगे।",
  "శంభల గ్రామంలో, ప్రముఖ బ్రాహ్మణుడు విష్ణుయశుని ఇంట్లో కల్కి అవతరిస్తాడు.",
  "A", "Bhagavata Purana 12.2.18", P)
L("m02_2", "Vishnuyashas",
  "My son, a household is the first temple. A truth spoken at this hearth is worth more than gold.",
  "पुत्र, घर पहला मंदिर है। इस चूल्हे के पास बोला गया सत्य सोने से अधिक मूल्यवान है।",
  "నాయనా, ఇల్లే మొదటి గుడి. ఈ పొయ్యి దగ్గర పలికిన సత్యం బంగారం కన్నా విలువైనది.",
  "B", "Kalki Purana I.2 (household of Vishnuyashas)")
L("m02_3", "Kalki",
  "Father, why do the elders say the age is growing dark?",
  "पिताजी, बड़े क्यों कहते हैं कि युग अँधेरा होता जा रहा है?",
  "నాన్నా, యుగం చీకటిగా మారుతోందని పెద్దలు ఎందుకు అంటారు?",
  "G", "")
L("m02_4", "Vishnuyashas",
  "Because people forget their duties, child. But one who remembers can relight a whole village.",
  "क्योंकि लोग अपने कर्तव्य भूल जाते हैं, बच्चे। पर जो याद रखता है, वह पूरे गाँव को फिर से प्रकाशित कर सकता है।",
  "ఎందుకంటే ప్రజలు తమ కర్తవ్యాలను మరచిపోతారు, బిడ్డా. కానీ గుర్తుంచుకున్నవాడు ఊరు మొత్తాన్ని మళ్ళీ వెలిగించగలడు.",
  "G", "")
L("m02_5", "Sumati",
  "Your elder brothers Kavi, Prajna and Sumantra are at their lessons. Learn beside them, and be as kind as you are strong.",
  "तुम्हारे बड़े भाई कवि, प्रज्ञ और सुमन्त्र पाठ पढ़ रहे हैं। उनके साथ सीखो, और जितने बलवान हो उतने ही दयालु भी बनो।",
  "నీ అన్నలు కవి, ప్రజ్ఞుడు, సుమంత్రుడు పాఠాల్లో ఉన్నారు. వారితో కలిసి నేర్చుకో, బలం ఉన్నంత దయ కూడా కలిగి ఉండు.",
  "B", "Kalki Purana I.2 (parents; brothers Kavi, Prajna, Sumantra)")
L("m02_6", "Sumati",
  "On the twelfth day of the bright half of Madhava you were born. We saw a light in this house that was not the lamp's.",
  "माधव मास के शुक्ल पक्ष की द्वादशी को तुम्हारा जन्म हुआ। हमने इस घर में ऐसा प्रकाश देखा जो दीपक का नहीं था।",
  "మాధవ మాసం శుక్లపక్ష ద్వాదశి నాడు నీవు జన్మించావు. ఈ ఇంట్లో దీపానిది కాని ఒక వెలుగు మాకు కనిపించింది.",
  "B", "Kalki Purana I.2.15 (birth tithi; calendar-sensitive)")
L("m02_7", "Vishnuyashas",
  "Come to the sacred fire. Today your name is spoken before the household.",
  "पवित्र अग्नि के पास आओ। आज घर के सामने तुम्हारा नाम लिया जाएगा।",
  "పవిత్ర అగ్ని దగ్గరకు రా. ఈ రోజు ఇంటి ముందు నీ పేరు పలుకబడుతుంది.",
  "G", "")
L("m02_8", "Vishnuyashas",
  "We call you Kalki. May you be the one who ends the age of strife.",
  "हम तुम्हें कल्कि कहते हैं। तुम ही कलह के इस युग का अंत करने वाले बनो।",
  "నిన్ను కల్కి అని పిలుస్తున్నాము. కలహ యుగాన్ని అంతం చేసేవాడివి నీవే కావాలి.",
  "B", "Kalki Purana I.2 (naming)")
L("m02_9", "Narrator",
  "The house in Shambhala taught him three things: truth, compassion, and duty.",
  "शम्भल के उस घर ने उन्हें तीन बातें सिखाईं: सत्य, करुणा और कर्तव्य।",
  "శంభలలోని ఆ ఇల్లు అతనికి మూడు విషయాలు నేర్పింది: సత్యం, కరుణ, కర్తవ్యం.",
  "G", "")

# ---------------------------------------------------------------- M03 Parashurama's Gurukula
L("m03_1", "Narrator",
  "Kalki climbs Mahendra mountain to study the Vedas, the arts and the science of arms with Parashurama.",
  "कल्कि महेन्द्र पर्वत पर परशुराम से वेद, कलाएँ और शस्त्रविद्या सीखने जाते हैं।",
  "కల్కి మహేంద్ర పర్వతంపై పరశురాముని వద్ద వేదాలు, కళలు, శస్త్రవిద్య నేర్చుకోవడానికి వెళ్తాడు.",
  "B", "Kalki Purana I.3")
L("m03_2", "Parashurama",
  "You have come a long way, Kalki. Here nothing is taught for show. Every lesson is for the protection of others.",
  "कल्कि, तुम बहुत दूर से आए हो। यहाँ कुछ भी दिखावे के लिए नहीं सिखाया जाता। हर शिक्षा दूसरों की रक्षा के लिए है।",
  "కల్కీ, నీవు చాలా దూరం నుండి వచ్చావు. ఇక్కడ ఏదీ ప్రదర్శన కోసం నేర్పబడదు. ప్రతి పాఠం ఇతరులను కాపాడడానికే.",
  "B", "Kalki Purana I.3 (guru Parashurama)")
L("m03_3", "Parashurama",
  "Begin with the training pillars. They do not strike back, so learn to see before you strike.",
  "पहले प्रशिक्षण-स्तंभों से आरंभ करो। वे पलटकर वार नहीं करते, इसलिए प्रहार से पहले देखना सीखो।",
  "ముందుగా శిక్షణ స్తంభాలతో మొదలుపెట్టు. అవి తిరిగి కొట్టవు, కాబట్టి కొట్టే ముందు చూడడం నేర్చుకో.",
  "G", "")
L("m03_4", "Parashurama",
  "Now the archery lesson: strike three distant targets with your Astra, the wave of focused will.",
  "अब धनुर्विद्या का पाठ: अपने अस्त्र, एकाग्र संकल्प की तरंग, से तीन दूर के लक्ष्य भेदो।",
  "ఇప్పుడు విలువిద్య పాఠం: ఏకాగ్ర సంకల్ప తరంగమైన నీ అస్త్రంతో దూరంగా ఉన్న మూడు లక్ష్యాలను కొట్టు.",
  "G", "")
L("m03_5", "Parashurama",
  "Well done. Now stand against me. This is practice, not a duel to the death. I will tell you when you have shown enough.",
  "बहुत अच्छा। अब मेरे सामने खड़े हो। यह अभ्यास है, प्राणघातक द्वंद्व नहीं। जब तुमने पर्याप्त दिखा दिया, मैं बता दूँगा।",
  "బాగుంది. ఇప్పుడు నా ఎదుట నిలబడు. ఇది అభ్యాసం, ప్రాణాంతక ద్వంద్వం కాదు. నీవు చాలినంత చూపించినప్పుడు నేను చెబుతాను.",
  "G", "")
L("m03_6", "Parashurama",
  "Enough. Skill has worth only when joined with discernment.",
  "बस। कौशल का मूल्य तभी है जब उसके साथ विवेक हो।",
  "చాలు. నైపుణ్యానికి విలువ వివేకంతో కలిసినప్పుడే.",
  "G", "")
L("m03_7", "Parashurama",
  "Go to Mahadeva's shrine. A weapon given by the gods must be received with devotion, not pride.",
  "महादेव के मंदिर जाओ। देवताओं द्वारा दिया गया शस्त्र भक्ति से ग्रहण करना चाहिए, अभिमान से नहीं।",
  "మహాదేవుని ఆలయానికి వెళ్ళు. దేవతలు ఇచ్చిన ఆయుధాన్ని భక్తితో స్వీకరించాలి, గర్వంతో కాదు.",
  "B", "Kalki Purana I.3 (pilgrimage to Shiva after training)")
L("m03_8", "Kalki",
  "I carry your lesson with me, Gurudeva. I will strike only to protect.",
  "गुरुदेव, मैं आपकी शिक्षा अपने साथ ले जाता हूँ। मैं केवल रक्षा के लिए प्रहार करूँगा।",
  "గురుదేవా, మీ పాఠాన్ని నాతో తీసుకువెళ్తున్నాను. కేవలం రక్షణ కోసమే కొడతాను.",
  "G", "")

# ---------------------------------------------------------------- M04 Three Gifts of Mahadeva
L("m04_1", "Narrator",
  "At the shrine of Bilvodakeshvara, Kalki bows before Shiva and Parvati and asks for nothing for himself.",
  "बिल्वोदकेश्वर के मंदिर में कल्कि शिव और पार्वती को प्रणाम करते हैं और अपने लिए कुछ नहीं माँगते।",
  "బిల్వోదకేశ్వర ఆలయంలో కల్కి శివ పార్వతులకు నమస్కరిస్తాడు, తన కోసం ఏమీ కోరడు.",
  "B", "Kalki Purana I.3 (worship of Shiva)")
L("m04_2", "Kalki",
  "Mahadeva, I seek no kingdom, only the strength to restore what has been lost.",
  "महादेव, मुझे राज्य नहीं चाहिए, केवल वह शक्ति जिससे जो खो गया है उसे लौटा सकूँ।",
  "మహాదేవా, నాకు రాజ్యం వద్దు, పోగొట్టుకున్నదాన్ని తిరిగి నిలబెట్టే శక్తి మాత్రమే కావాలి.",
  "G", "")
L("m04_3", "Shiva",
  "Your devotion is heard, Kalki. Receive a swift horse, a parrot who knows all times, and a jewel-hilted sword.",
  "कल्कि, तुम्हारी भक्ति सुनी गई। एक द्रुतगामी अश्व, एक त्रिकालज्ञ शुक और रत्नजटित मूठ वाला खड्ग स्वीकार करो।",
  "కల్కీ, నీ భక్తి వినబడింది. వేగవంతమైన గుర్రం, అన్ని కాలాలూ తెలిసిన చిలుక, రత్నాలు పొదిగిన పిడి గల ఖడ్గం స్వీకరించు.",
  "B", "Kalki Purana I.3 (horse, Shuka, sword)")
L("m04_4", "Shiva",
  "May these gifts serve the restoration of dharma.",
  "ये उपहार धर्म की पुनःस्थापना के काम आएँ।",
  "ఈ బహుమతులు ధర్మ పునఃస్థాపనకు ఉపయోగపడాలి.",
  "B", "Kalki Purana I.3")
L("m04_5", "Parvati",
  "Ride with truth beside you, and the sword will never be heavy in your hand.",
  "सत्य को साथ लेकर चलो, तो खड्ग तुम्हारे हाथ में कभी भारी नहीं लगेगा।",
  "సత్యాన్ని తోడుగా తీసుకొని సాగిపో, ఖడ్గం నీ చేతిలో ఎప్పుడూ బరువు కాదు.",
  "B", "Kalki Purana I.3 (Parvati beside Shiva)")
L("m04_6", "Shuka",
  "I am Shuka, my Lord. I know what was, what is, and what will be.",
  "प्रभु, मैं शुक हूँ। मैं जानता हूँ जो था, जो है और जो होगा।",
  "ప్రభూ, నేను శుకుడిని. జరిగినది, జరుగుతున్నది, జరగబోయేది నాకు తెలుసు.",
  "B", "Kalki Purana I.3 (the parrot Shuka)")
L("m04_7", "Narrator",
  "The Lord mounts the swift horse Devadatta and bears a sword. The verse names the horse; its colour it does not give.",
  "प्रभु द्रुतगामी अश्व देवदत्त पर आरूढ़ होते हैं और खड्ग धारण करते हैं। श्लोक घोड़े का नाम बताता है, उसका रंग नहीं।",
  "ప్రభువు వేగవంతమైన గుర్రం దేవదత్తుపై ఎక్కి ఖడ్గం ధరిస్తాడు. శ్లోకం గుర్రం పేరు చెబుతుంది, రంగు చెప్పదు.",
  "A", "Bhagavata Purana 12.2.19", P)
L("m04_8", "Shuka",
  "Ride through the rings, my Lord. Let Devadatta learn your hand.",
  "प्रभु, इन वलयों में से निकलिए। देवदत्त आपके हाथ को पहचान ले।",
  "ప్రభూ, ఈ వలయాల గుండా స్వారీ చేయండి. దేవదత్తుడు మీ చేతిని తెలుసుకోవాలి.",
  "G", "")

# ---------------------------------------------------------------- M05 The Parrot of Simhala
L("m05_1", "Narrator",
  "In Mahishmati, King Vishakhayupa receives the young avatar with honour and counsel.",
  "माहिष्मती में राजा विशाखयूप युवा अवतार का सम्मान और परामर्श के साथ स्वागत करते हैं।",
  "మాహిష్మతిలో రాజు విశాఖయూపుడు యువ అవతారాన్ని గౌరవంతో, సలహాతో స్వాగతిస్తాడు.",
  "B", "Kalki Purana I.4")
L("m05_2", "Vishakhayupa",
  "Lord Kalki, a righteous ruler stands beside you. Beyond the sea lies Simhala, where a princess named Padma worships Vishnu alone.",
  "प्रभु कल्कि, एक धर्मनिष्ठ शासक आपके साथ खड़ा है। समुद्र के पार सिंहल है, जहाँ पद्मा नाम की राजकुमारी केवल विष्णु की उपासना करती है।",
  "ప్రభూ కల్కీ, ధర్మనిష్ఠ గల పాలకుడు మీ పక్కన ఉన్నాడు. సముద్రం అవతల సింహళం ఉంది, అక్కడ పద్మ అనే రాకుమారి విష్ణువును మాత్రమే ఆరాధిస్తుంది.",
  "B", "Kalki Purana I.4 (Vishakhayupa reveals Padma of Simhala)")
L("m05_3", "Shuka",
  "Let me fly ahead, my Lord. A bird crosses the sea without asking leave of any king.",
  "प्रभु, मुझे आगे उड़ने दीजिए। पक्षी किसी राजा से अनुमति लिए बिना समुद्र पार कर जाता है।",
  "ప్రభూ, నన్ను ముందుగా ఎగరనివ్వండి. పక్షి ఏ రాజు అనుమతీ లేకుండా సముద్రం దాటుతుంది.",
  "B", "Kalki Purana I.4-I.6 (Shuka as messenger)")
L("m05_4", "Shuka",
  "I have seen her. Padma prays at dawn and dusk, and no suitor has moved her heart.",
  "मैंने उसे देखा है। पद्मा प्रातः और संध्या प्रार्थना करती है, और किसी भी वर ने उसका हृदय नहीं जीता।",
  "ఆమెను చూశాను. పద్మ ఉదయం, సాయంత్రం ప్రార్థిస్తుంది, ఏ వరుడూ ఆమె హృదయాన్ని కదిలించలేదు.",
  "B", "Kalki Purana I.5-I.6 (Padma's svayamvara; the suitors transformed by Shiva's boon)")
L("m05_5", "Shuka",
  "She has sent word: she waits for Vishnu's own. I told her he is already on the road.",
  "उसने संदेश भेजा है: वह स्वयं विष्णु के अंश की प्रतीक्षा करती है। मैंने उससे कहा कि वे पहले से ही मार्ग पर हैं।",
  "ఆమె సందేశం పంపింది: ఆమె విష్ణువు స్వరూపం కోసం వేచి ఉంది. ఆయన అప్పటికే దారిలో ఉన్నారని చెప్పాను.",
  "B", "Kalki Purana I.6")
L("m05_6", "Vishakhayupa",
  "Then go, Lord. Mahishmati will stand with you. The scout's tale is an adaptation; the road beyond is the story.",
  "तो जाइए, प्रभु। माहिष्मती आपके साथ खड़ी है। शुक की टोह इस खेल का रूपांतरण है; आगे का मार्ग ही कथा है।",
  "అయితే వెళ్ళండి ప్రభూ. మాహిష్మతి మీతో నిలుస్తుంది. శుకుని వేగు ఈ ఆట చేసిన అనుసృజన; ముందున్న దారే కథ.",
  "G", "Scout mode is an adaptation, not in the Purana (PDF M05 gate)")

# ---------------------------------------------------------------- M06 The Lotus of Simhala
L("m06_1", "Narrator",
  "Kalki crosses to Simhala. The palace garden is quiet, and lotus ponds mirror the sky.",
  "कल्कि सिंहल पहुँचते हैं। महल का उद्यान शांत है, और कमल-सरोवर आकाश को प्रतिबिंबित करते हैं।",
  "కల్కి సింహళానికి చేరుతాడు. రాజభవన ఉద్యానవనం ప్రశాంతంగా ఉంది, కమల సరస్సులు ఆకాశాన్ని ప్రతిబింబిస్తున్నాయి.",
  "B", "Kalki Purana II.1-II.3")
L("m06_2", "Padmavati",
  "You have come. The parrot told me the truth. I have chosen no one, because I was waiting for you.",
  "आप आ गए। शुक ने मुझे सच बताया था। मैंने किसी को नहीं चुना, क्योंकि मैं आपकी प्रतीक्षा कर रही थी।",
  "మీరు వచ్చారు. చిలుక నాకు నిజం చెప్పింది. నేను ఎవరినీ ఎన్నుకోలేదు, ఎందుకంటే మీ కోసం వేచి ఉన్నాను.",
  "B", "Kalki Purana II.1-II.3 (Padma and Kalki)")
L("m06_3", "Kalki",
  "Padma, the choice is yours alone. Say what you wish.",
  "पद्मा, चुनाव केवल तुम्हारा है। जो चाहो वह कहो।",
  "పద్మా, ఎంపిక నీది మాత్రమే. నీకు ఏది కావాలో చెప్పు.",
  "G", "Respect Padma's agency (PDF M06 gate)")
L("m06_4", "Padmavati",
  "Then I choose. Gather the lotuses from the three ponds; they are offered at the fire.",
  "तो मैं चुनती हूँ। तीनों सरोवरों से कमल एकत्र कीजिए; वे अग्नि में अर्पित होंगे।",
  "అయితే నేను ఎన్నుకుంటున్నాను. మూడు సరస్సుల నుండి కమలాలు తీసుకురండి; వాటిని అగ్నికి అర్పిస్తారు.",
  "G", "")
L("m06_5", "Brhadratha",
  "King of Simhala, I give my daughter freely. The old curse that changed her suitors ends in your presence.",
  "सिंहल का राजा होकर मैं अपनी पुत्री को स्वेच्छा से देता हूँ। जिस प्राचीन शाप ने उसके वरों को बदल दिया था, वह आपकी उपस्थिति में समाप्त होता है।",
  "సింహళ రాజుగా నా కుమార్తెను స్వచ్ఛందంగా ఇస్తున్నాను. ఆమె వరులను మార్చిన పాత శాపం మీ సన్నిధిలో అంతమవుతుంది.",
  "B", "Kalki Purana II.1-II.3 (transformed kings restored)")
L("m06_6", "Narrator",
  "The kings who had been changed are restored to themselves. Walk around the fire four times, and the vow is made.",
  "जो राजा बदल दिए गए थे, वे अपने स्वरूप में लौट आते हैं। अग्नि की चार परिक्रमा कीजिए, और संकल्प पूर्ण होता है।",
  "మార్చబడిన రాజులు తమ నిజరూపంలోకి వస్తారు. అగ్ని చుట్టూ నాలుగు ప్రదక్షిణలు చేయండి, ప్రతిజ్ఞ పూర్తవుతుంది.",
  "B", "Kalki Purana II.3")
L("m06_7", "Padmavati",
  "Wherever the road goes, Lord, I walk with you. Let us go home to Shambhala.",
  "प्रभु, मार्ग जहाँ भी जाए, मैं आपके साथ चलती हूँ। चलिए, शम्भल लौट चलें।",
  "ప్రభూ, దారి ఎక్కడికి వెళ్ళినా నేను మీతో నడుస్తాను. శంభలకు తిరిగి వెళ్దాం.",
  "B", "Kalki Purana II.3, II.6 (return to Shambhala)")
