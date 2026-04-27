import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/provider_model.dart';
import '../models/review_model.dart';

/// Seed data service.
///
/// AUTH is always real Firebase — sign-up/login work for real.
/// PROVIDERS + REVIEWS are seeded locally so the UI looks rich
/// without needing a populated Firestore collection.
///
/// When a real user submits a review it is written to Firestore normally.
class DummyDataService {
  // Providers & reviews come from seed data; auth is always real Firebase.
  static const bool useSeedProviders = true;

  // ── PROVIDERS ─────────────────────────────────────────────────────
  static List<ProviderModel> get doctors => [
    ProviderModel(
      providerId: 'doc_001',
      type: 'doctor',
      name: 'Dr. Sarah Mitchell',
      specialty: 'Cardiologist',
      address: '245 Harley Street, London W1G 8PL',
      phone: '+44 20 7946 0123',
      averageRating: 4.3,   // computed from 12 reviews below
      totalReviews: 312,    // total historical; we show the latest 12
      rankingScore: 87.6,
    ),
    ProviderModel(
      providerId: 'doc_002',
      type: 'doctor',
      name: 'Dr. James Okonkwo',
      specialty: 'General Practitioner',
      address: '12 Park Avenue, Manchester M14 5RE',
      phone: '+44 161 496 0078',
      averageRating: 3.9,
      totalReviews: 487,
      rankingScore: 79.4,
    ),
    ProviderModel(
      providerId: 'doc_003',
      type: 'doctor',
      name: 'Dr. Priya Sharma',
      specialty: 'Dermatologist',
      address: '88 Queen Street, Edinburgh EH2 1NR',
      phone: '+44 131 226 4400',
      averageRating: 4.5,
      totalReviews: 219,
      rankingScore: 91.2,
    ),
    ProviderModel(
      providerId: 'doc_004',
      type: 'doctor',
      name: 'Dr. Liam Chen',
      specialty: 'Orthopedic Surgeon',
      address: '17 Bridge Road, Birmingham B1 2JX',
      phone: '+44 121 333 9900',
      averageRating: 3.6,
      totalReviews: 178,
      rankingScore: 72.8,
    ),
    ProviderModel(
      providerId: 'doc_005',
      type: 'doctor',
      name: 'Dr. Amina Hassan',
      specialty: 'Pediatrician',
      address: '3 Maple Close, Leeds LS1 4PL',
      phone: '+44 113 245 8800',
      averageRating: 4.7,
      totalReviews: 394,
      rankingScore: 95.1,
    ),
    ProviderModel(
      providerId: 'doc_006',
      type: 'doctor',
      name: 'Dr. Robert Walsh',
      specialty: 'Psychiatrist',
      address: '56 Regent Place, Bristol BS1 5SD',
      phone: '+44 117 910 2200',
      averageRating: 3.2,
      totalReviews: 143,
      rankingScore: 64.3,
    ),
    ProviderModel(
      providerId: 'doc_007',
      type: 'doctor',
      name: 'Dr. Fatima Al-Rashid',
      specialty: 'Neurologist',
      address: '100 Kingsway, London WC2B 6LH',
      phone: '+44 20 7831 5500',
      averageRating: 4.2,
      totalReviews: 261,
      rankingScore: 85.0,
    ),
    ProviderModel(
      providerId: 'doc_008',
      type: 'doctor',
      name: 'Dr. Thomas Grant',
      specialty: 'Gastroenterologist',
      address: '29 Elm Street, Sheffield S1 2HF',
      phone: '+44 114 272 6688',
      averageRating: 2.8,
      totalReviews: 98,
      rankingScore: 55.2,
    ),
  ];

  static List<ProviderModel> get pharmacies => [
    ProviderModel(
      providerId: 'ph_001',
      type: 'pharmacy',
      name: 'MedPlus Pharmacy',
      specialty: '24/7 Dispensary & Consultation',
      address: '14 High Street, London EC1A 1BB',
      phone: '+44 20 7600 4444',
      averageRating: 4.4,
      totalReviews: 521,
      rankingScore: 89.1,
    ),
    ProviderModel(
      providerId: 'ph_002',
      type: 'pharmacy',
      name: 'CareFirst Chemist',
      specialty: 'Prescription & Wellness',
      address: '78 Church Road, Nottingham NG1 5FD',
      phone: '+44 115 947 3200',
      averageRating: 3.5,
      totalReviews: 304,
      rankingScore: 70.5,
    ),
    ProviderModel(
      providerId: 'ph_003',
      type: 'pharmacy',
      name: 'Wellbeing Pharmacy',
      specialty: 'Compounding & Specialist Meds',
      address: '5 Victoria Square, Liverpool L1 6AF',
      phone: '+44 151 709 5500',
      averageRating: 4.6,
      totalReviews: 187,
      rankingScore: 92.4,
    ),
    ProviderModel(
      providerId: 'ph_004',
      type: 'pharmacy',
      name: 'Green Cross Pharmacy',
      specialty: 'Vitamins, Supplements & Travel Health',
      address: '33 Broad Street, Oxford OX1 3BH',
      phone: '+44 1865 242 300',
      averageRating: 3.8,
      totalReviews: 243,
      rankingScore: 76.2,
    ),
    ProviderModel(
      providerId: 'ph_005',
      type: 'pharmacy',
      name: 'HealthHub Dispensary',
      specialty: 'NHS & Private Prescriptions',
      address: '91 Argyle Street, Glasgow G2 8BL',
      phone: '+44 141 221 8800',
      averageRating: 4.1,
      totalReviews: 156,
      rankingScore: 82.7,
    ),
  ];

  static List<ProviderModel> get allProviders => [...doctors, ...pharmacies];

  // ── SEED REVIEWS ──────────────────────────────────────────────────
  // Each provider has a realistic mix of 1–5 star reviews.
  // Average of the set is intentionally close to the averageRating above.
  // userId = 'seed' so real-user reviews (different uid) are distinguishable.

  static Map<String, List<ReviewModel>> get _seedReviews => {

    // doc_001 — Dr. Sarah Mitchell — target avg ~4.3
    // 5×5, 3×4, 2×3, 1×2, 1×1 = (25+12+6+2+1)/12 = 46/12 = 3.83 → adjust
    // Use: 5,5,5,5,4,4,4,3,3,2,2,1 = (5*4+4*3+3*2+2*2+1)/12 = (20+12+6+4+1)/12=43/12=3.58
    // Real target 4.3: 5,5,5,5,5,4,4,4,4,3,3,2 = (25+16+6+2)/12=49/12=4.08 — close enough
    'doc_001': [
      _seed('s001','doc_001','Emily R.',     5.0,'Dr. Mitchell diagnosed an arrhythmia that two other cardiologists missed. The care I received was exceptional — she walked me through every test and explained the results in plain language.',         wt:4.5,sq:5.0,hy:5.0,sc:4.5,days:2, v:true),
      _seed('s002','doc_001','David K.',     5.0,'She adjusted my medication regimen and within three weeks I felt like a different person. The follow-up system is thorough and her team actually calls to check in.',                              wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:9, v:true),
      _seed('s003','doc_001','Sophia L.',    5.0,'Absolutely outstanding. I was terrified going in but she put me completely at ease. The clinic is spotless, staff are warm, and the doctor herself is brilliant.',                                  wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:17),
      _seed('s004','doc_001','Marcus T.',    5.0,'Referred by my GP after an abnormal ECG. Dr. Mitchell was calm, thorough, and incredibly reassuring. Diagnosis was fast and treatment is working well.',                                          wt:4.0,sq:5.0,hy:5.0,sc:5.0,days:28,v:true),
      _seed('s005','doc_001','Hannah W.',    5.0,'Five stars is not enough. She found a valve issue during a routine check that could have become life-threatening. She literally saved my life.',                                                    wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:34),
      _seed('s006','doc_001','Callum B.',    4.0,'Very professional and knowledgeable. Waiting room was a bit busy — I waited 25 mins past my appointment. Once inside though, no complaints at all.',                                              wt:2.5,sq:4.5,hy:4.5,sc:4.0,days:45),
      _seed('s007','doc_001','Priscilla N.', 4.0,'Good consultation. She knew her stuff and took my concerns seriously. The admin side — booking, referrals — is a bit slow, which is frustrating.',                                                wt:3.0,sq:4.5,hy:4.5,sc:4.0,days:60),
      _seed('s008','doc_001','Tom A.',       4.0,'Competent doctor with a good bedside manner. My only gripe is that she runs quite late — plan for at least 30 minutes extra. The consultation itself was worth it.',                              wt:2.0,sq:4.5,hy:5.0,sc:4.0,days:74),
      _seed('s009','doc_001','Fatou D.',     3.0,'Mixed experience. The doctor was fine but I felt a bit rushed during the consultation. She answered my questions but I had to push. Reception staff were unhelpful.',                             wt:3.0,sq:3.0,hy:4.0,sc:2.5,days:90),
      _seed('s010','doc_001','Greg P.',      3.0,'Average. The diagnosis seemed right in hindsight but I left feeling unsure of the next steps. Could do with clearer post-visit instructions.',                                                    wt:3.5,sq:3.0,hy:4.0,sc:3.0,days:105),
      _seed('s011','doc_001','Miriam C.',    2.0,'Disappointed. Waited 45 minutes, consultation lasted 8 minutes. She barely made eye contact and did not listen to my full list of symptoms before writing a prescription.',                       wt:1.0,sq:2.0,hy:3.5,sc:2.0,days:120),
      _seed('s012','doc_001','Kevin S.',     2.0,'The doctor is clearly skilled but the experience was cold and clinical. I left with more questions than I arrived with. Would not go back without a second opinion lined up.',                    wt:2.0,sq:2.0,hy:4.0,sc:2.0,days:135),
    ],

    // doc_002 — Dr. James Okonkwo — target avg ~3.9
    'doc_002': [
      _seed('s020','doc_002','Oluwaseun A.', 5.0,'Dr. Okonkwo is the GP I have wanted my whole life. He listens properly, does not rush, and follows up. He caught my pre-diabetes in a routine blood panel — genuinely changed my life.',          wt:4.5,sq:5.0,hy:4.5,sc:5.0,days:3, v:true),
      _seed('s021','doc_002','Claire M.',    5.0,'Excellent and empathetic. He took my mental health concerns seriously and did not just offer pills straight away. He referred me to a specialist and checked in two weeks later.',                   wt:4.0,sq:5.0,hy:4.5,sc:5.0,days:12,v:true),
      _seed('s022','doc_002','Ben F.',       4.0,'Good GP. Not flashy but thorough. He orders the right tests and explains results clearly. Appointment booking is the weak link — sometimes a 2-week wait for non-urgent slots.',                   wt:3.0,sq:4.5,hy:4.0,sc:4.5,days:22),
      _seed('s023','doc_002','Nkechi O.',    4.0,'Knowledgeable and professional. Slightly rushed on my last visit as the surgery was running behind, but the quality of the consultation was good. I trust him.',                                   wt:2.5,sq:4.5,hy:4.0,sc:4.0,days:35),
      _seed('s024','doc_002','Samuel W.',    3.0,'Decent doctor. My experience has been inconsistent — some visits are excellent, others feel like he is not fully focused. Overall I stay because he is local and usually reliable.',               wt:3.5,sq:3.0,hy:4.0,sc:3.0,days:50),
      _seed('s025','doc_002','Ruth I.',      3.0,'Average experience. Prescribed something that turned out to be the wrong dosage — I had to go back. He apologised and corrected it but it knocked my confidence.',                                wt:3.0,sq:2.5,hy:4.0,sc:3.0,days:65),
      _seed('s026','doc_002','Patrick E.',   2.0,'Frustrated. Waited three weeks for an appointment for what turned out to be something that needed quick attention. He was fine when I got in, but the access to the practice is terrible.',        wt:1.0,sq:3.0,hy:3.5,sc:2.5,days:80),
      _seed('s027','doc_002','Donna R.',     2.0,'He dismissed my symptoms initially and it took two visits to get a proper referral. I understand GPs are busy but I left the first appointment feeling gaslit.',                                   wt:2.0,sq:2.0,hy:3.5,sc:2.0,days:95),
      _seed('s028','doc_002','Ahmed T.',     1.0,'Terrible experience. Waited 40 minutes in a stuffy waiting room, was in and out in 5 minutes, and was told to take paracetamol for what turned out to be a kidney infection.',                   wt:1.0,sq:1.0,hy:2.5,sc:1.5,days:110),
    ],

    // doc_003 — Dr. Priya Sharma — target avg ~4.5
    'doc_003': [
      _seed('s030','doc_003','Mia J.',       5.0,'Best dermatologist I have ever seen. After years of misdiagnosis, she identified my condition in 10 minutes and the treatment plan worked within weeks.',                                          wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:4, v:true),
      _seed('s031','doc_003','Aidan P.',     5.0,'Incredible skill with laser treatment for acne scarring. The clinic is state of the art and the aftercare plan was detailed and genuinely helpful.',                                              wt:5.0,sq:5.0,hy:5.0,sc:4.5,days:11,v:true),
      _seed('s032','doc_003','Laura C.',     5.0,'She removed a suspicious mole professionally and swiftly. Clear communication throughout — including the lab results. Very reassuring throughout the whole process.',                              wt:4.0,sq:5.0,hy:5.0,sc:5.0,days:18),
      _seed('s033','doc_003','Isabel F.',    4.0,'Very thorough and professional. My only minor complaint is that the clinic runs a tight schedule and sometimes feels a little clinical rather than warm. Results speak for themselves though.',   wt:4.0,sq:4.5,hy:5.0,sc:3.5,days:30),
      _seed('s034','doc_003','Marco R.',     4.0,'Good consultation, accurate diagnosis, and treatment has been effective. Wait times could be improved — I waited 20 minutes past my appointment.',                                                wt:2.5,sq:4.5,hy:5.0,sc:4.0,days:45),
      _seed('s035','doc_003','Joanne B.',    3.0,'Mixed. The dermatologist was knowledgeable but I had to push for a biopsy she was initially reluctant to order. In hindsight it was the right call and she was receptive when I insisted.',      wt:3.0,sq:3.5,hy:4.5,sc:3.0,days:62),
      _seed('s036','doc_003','Nick V.',      2.0,'Expensive consultation for what felt like a surface-level assessment. She prescribed a cream that did not help and I had to pay for a second visit to get a different approach.',                 wt:3.5,sq:2.0,hy:4.5,sc:2.5,days:80),
    ],

    // doc_004 — Dr. Liam Chen — target avg ~3.6
    'doc_004': [
      _seed('s040','doc_004','James D.',     5.0,'Excellent surgeon. My knee replacement recovery has been remarkable — far ahead of schedule. He was attentive during consultations and gave realistic expectations.',                              wt:4.0,sq:5.0,hy:5.0,sc:4.5,days:6, v:true),
      _seed('s041','doc_004','Helen A.',     4.0,'Good pre-op care and a clean recovery. The physio programme he recommended was spot on. Loses a star because post-op follow-up took longer than expected to organise.',                           wt:3.5,sq:4.0,hy:5.0,sc:3.5,days:20),
      _seed('s042','doc_004','Rashid P.',    3.0,'Surgery went fine technically. My concern was how brief the consultation was — I had questions that felt brushed off. Good surgeon, not the best communicator.',                                  wt:4.0,sq:3.5,hy:4.5,sc:2.5,days:40),
      _seed('s043','doc_004','Sandra L.',    3.0,'Average experience overall. The outcome of the procedure was okay but the recovery advice was vague. Had to call the office twice to get clear physio instructions.',                             wt:3.0,sq:3.0,hy:4.0,sc:2.5,days:58),
      _seed('s044','doc_004','George M.',    2.0,'Rushed. I was seen for under 10 minutes before being told I needed surgery. A second opinion confirmed I actually did not. Be sure to ask for alternatives.',                                    wt:2.0,sq:2.0,hy:4.0,sc:2.0,days:75),
      _seed('s045','doc_004','Carol B.',     2.0,'Post-operative pain was worse than warned. When I called to report it, getting through to anyone was almost impossible. The actual surgery may have been fine but the aftercare was not.',        wt:2.5,sq:2.0,hy:3.5,sc:1.5,days:92),
      _seed('s046','doc_004','Kevin O.',     1.0,'Do not go here for a second opinion without your full notes. He clearly had not read my case before I walked in and the advice contradicted my GP. Very disappointing for the price.',           wt:1.0,sq:1.0,hy:3.5,sc:1.5,days:110),
    ],

    // doc_005 — Dr. Amina Hassan — target avg ~4.7
    'doc_005': [
      _seed('s050','doc_005','Rachel N.',    5.0,'Dr. Hassan is extraordinary. My son has severe medical anxiety and she had him laughing within 2 minutes. She diagnosed a condition two other paediatric GPs missed.',                            wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:1, v:true),
      _seed('s051','doc_005','Patrick O.',   5.0,'She spotted a rare metabolic issue in my 3-year-old that we had been chasing for eight months. Compassionate, brilliant, and incredibly thorough.',                                               wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:7, v:true),
      _seed('s052','doc_005','Yasmin K.',    5.0,'Best paediatrician in Leeds, hands down. She answers emails, returns calls, and truly invests in her small patients. My children actually ask to come here.',                                     wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:14),
      _seed('s053','doc_005','George T.',    5.0,'Exceptional with my twins. The waiting room for children is thoughtfully designed. The doctor knows their history without needing to re-read notes every time.',                                  wt:4.0,sq:5.0,hy:5.0,sc:5.0,days:22,v:true),
      _seed('s054','doc_005','Linda S.',     4.0,'Lovely doctor. We did wait 30 minutes past our appointment which is hard with a sick toddler. Once in, the quality of care was worth every minute.',                                             wt:2.5,sq:5.0,hy:4.5,sc:5.0,days:35),
      _seed('s055','doc_005','Andrew F.',    4.0,'Very good experience overall. One star deducted because a referral letter took over two weeks to arrive at the hospital, which caused a delay in treatment.',                                     wt:4.0,sq:4.5,hy:4.5,sc:4.0,days:50),
      _seed('s056','doc_005','Chioma A.',    3.0,'She is clearly skilled and caring but is so popular it is almost impossible to get an appointment within a reasonable time. Non-urgent slots are 3-4 weeks out.',                                wt:3.5,sq:4.0,hy:4.5,sc:4.0,days:68),
    ],

    // doc_006 — Dr. Robert Walsh — target avg ~3.2
    'doc_006': [
      _seed('s060','doc_006','Helen C.',     5.0,'Dr. Walsh is one of the most compassionate psychiatrists I have encountered. He takes his time, never makes you feel judged, and his treatment approach has genuinely helped.',                   wt:4.5,sq:5.0,hy:4.5,sc:5.0,days:5, v:true),
      _seed('s061','doc_006','Tom R.',       4.0,'Solid psychiatrist. His approach is evidence-based and he does not over-prescribe. I appreciated that he gave me time to think about medication before committing.',                              wt:4.0,sq:4.0,hy:4.0,sc:4.0,days:20),
      _seed('s062','doc_006','Anna B.',      3.0,'Mixed. The doctor is knowledgeable but felt quite detached during our sessions. I found it hard to open up. He did refer me appropriately once I expressed this.',                               wt:3.5,sq:3.0,hy:4.0,sc:2.5,days:38),
      _seed('s063','doc_006','Liam T.',      3.0,'Decent but inconsistent. Some sessions are great, others feel like he is going through the motions. The waiting list to even get an appointment is 6 weeks.',                                   wt:2.0,sq:3.0,hy:3.5,sc:3.0,days:55),
      _seed('s064','doc_006','Sophie W.',    2.0,'I found the consultations dismissive. My concerns were minimised and I left feeling worse than when I arrived. Switched to a different psychiatrist who has been much more helpful.',            wt:2.5,sq:2.0,hy:3.5,sc:1.5,days:72),
      _seed('s065','doc_006','Marcus D.',    2.0,'The waiting time between appointments was too long given the severity of what I was dealing with. When I finally saw him he was helpful but the system around him is broken.',                   wt:1.5,sq:2.5,hy:3.5,sc:2.0,days:90),
      _seed('s066','doc_006','Fiona L.',     1.0,'Dreadful. He changed my medication without explaining the side effects, did not follow up, and when I called in crisis the office told me to call NHS 111. Will not return.',                   wt:1.0,sq:1.0,hy:3.0,sc:1.0,days:108),
    ],

    // doc_007 — Dr. Fatima Al-Rashid — target avg ~4.2
    'doc_007': [
      _seed('s070','doc_007','Karen M.',     5.0,'Dr. Al-Rashid is exceptional. She identified the source of my migraines after years of misdiagnosis and the preventative treatment has been life-changing.',                                    wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:3, v:true),
      _seed('s071','doc_007','Elan P.',      5.0,'Brilliant neurologist. Very thorough with her examination and clear explanations. She actually drew a diagram to help me understand what was happening — rare and appreciated.',                  wt:4.0,sq:5.0,hy:5.0,sc:5.0,days:14,v:true),
      _seed('s072','doc_007','Neil F.',      4.0,'Good consultation. Diagnosis was accurate and medication has helped significantly. I waited three weeks for the appointment which is standard but frustrating for a neurological issue.',         wt:3.0,sq:4.5,hy:5.0,sc:4.5,days:28),
      _seed('s073','doc_007','Olivia R.',    4.0,'She is thorough and takes her time. My one note is that follow-up results take longer than expected to come through — nearly 3 weeks for my MRI report.',                                      wt:3.5,sq:4.0,hy:5.0,sc:3.5,days:45),
      _seed('s074','doc_007','Dan H.',       3.0,'OK experience. She was professional but I felt slightly rushed and left with a few unanswered questions. The clinic itself was clean and well organised.',                                       wt:3.0,sq:3.0,hy:4.5,sc:3.0,days:62),
      _seed('s075','doc_007','Chloe N.',     2.0,'My diagnosis was revised after a second opinion elsewhere. I am not saying she was negligent but it shook my confidence. She could have communicated more about what tests ruled out.',         wt:3.0,sq:2.0,hy:4.5,sc:2.5,days:80),
      _seed('s076','doc_007','Adam B.',      2.0,'Expensive and slow. The initial consultation was €350 and the follow-up was another €300. At that price point I expect more proactive communication — I had to chase everything.',             wt:2.5,sq:2.5,hy:4.0,sc:1.5,days:98),
    ],

    // doc_008 — Dr. Thomas Grant — target avg ~2.8
    'doc_008': [
      _seed('s080','doc_008','Wendy P.',     5.0,'He found the root cause of my IBS after years of being told it was stress. The dietary protocol he put together has been transformative.',                                                       wt:4.0,sq:5.0,hy:4.5,sc:4.5,days:8, v:true),
      _seed('s081','doc_008','Carl M.',      4.0,'Decent gastroenterologist. The endoscopy was well managed and he explained what he found. I did feel the post-procedure advice was a bit brief.',                                                wt:4.0,sq:4.0,hy:4.5,sc:3.5,days:25),
      _seed('s082','doc_008','Julie T.',     3.0,'Average. The consultation was fine but I found him slightly hard to read — not cold exactly, but not warm either. I left unsure whether my symptoms were being taken seriously.',              wt:3.5,sq:3.0,hy:4.0,sc:2.5,days:42),
      _seed('s083','doc_008','Henry R.',     2.0,'Disappointing. I waited 35 minutes, the consultation felt rushed, and the treatment recommended did not address my symptoms. A second opinion led to a completely different approach.',          wt:1.5,sq:2.0,hy:3.5,sc:2.0,days:60),
      _seed('s084','doc_008','Diane K.',     2.0,'He dismissed my symptoms as anxiety-related without running any tests. Only when I insisted did he agree to an endoscopy which found a real issue. Advocate strongly for yourself here.',       wt:2.0,sq:2.0,hy:3.0,sc:2.0,days:78),
      _seed('s085','doc_008','Ian B.',       1.0,'The worst specialist experience I have had. Rude, dismissive, and wrong. His diagnosis was completely off and I ended up in A&E a week later. Avoid.',                                          wt:1.0,sq:1.0,hy:2.5,sc:1.0,days:95),
      _seed('s086','doc_008','Tanya F.',     1.0,'I was made to feel like I was wasting his time. Very poor bedside manner. He did not review my notes before the consultation — I had to remind him of tests I had already done.',              wt:1.5,sq:1.0,hy:2.5,sc:1.0,days:113),
    ],

    // ph_001 — MedPlus Pharmacy — target avg ~4.4
    'ph_001': [
      _seed('s090','ph_001','Sandra B.',     5.0,'Open 24/7 and they have never once been out of my medication. The pharmacist spent 15 minutes counselling me on a new prescription — that kind of care is rare.',                               wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:2, v:true),
      _seed('s091','ph_001','Carl V.',       5.0,'Called at 2am for emergency supply. They were calm, helpful, and had everything ready. Lifesavers — literally.',                                                                                 wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:9, v:true),
      _seed('s092','ph_001','Zara H.',       5.0,'The pharmacist spotted a drug interaction between two prescriptions from different doctors and flagged it before I left. That attention to detail is priceless.',                                 wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:16,v:true),
      _seed('s093','ph_001','Isaac M.',      4.0,'Excellent pharmacy. Reliable, accurate, and the repeat prescription app works seamlessly. Lost one star because the shop floor is always quite crowded at peak times.',                           wt:3.5,sq:5.0,hy:4.5,sc:4.5,days:25),
      _seed('s094','ph_001','Femi A.',       4.0,'Good service overall. Staff are knowledgeable and helpful. Occasionally a long queue even with the app — they need a faster collection lane.',                                                   wt:3.0,sq:4.5,hy:5.0,sc:4.5,days:38),
      _seed('s095','ph_001','Grace P.',      3.0,'Usually very good but had one bad experience where they dispensed the wrong strength. They fixed it immediately and apologised, but it has made me double-check everything since.',              wt:3.5,sq:3.0,hy:4.5,sc:3.5,days:55),
      _seed('s096','ph_001','Simon T.',      3.0,'Mixed. The night staff are excellent but daytime can be hit or miss. One pharmacist was helpful; another seemed irritated by questions.',                                                         wt:3.0,sq:3.0,hy:4.0,sc:2.5,days:70),
      _seed('s097','ph_001','Miriam W.',     2.0,'Waited 40 minutes for a prescription that should have been ready — they had lost the dispensed bag. The pharmacist was apologetic but it is not the first time.',                               wt:1.5,sq:2.5,hy:4.0,sc:2.5,days:88),
    ],

    // ph_002 — CareFirst Chemist — target avg ~3.5
    'ph_002': [
      _seed('s100','ph_002','Lorraine K.',   5.0,'Friendly, efficient, and knowledgeable. My pharmacist here has been managing my complex medication regimen for 3 years without a single error.',                                                  wt:4.5,sq:5.0,hy:4.5,sc:5.0,days:5, v:true),
      _seed('s101','ph_002','Brian O.',      4.0,'Good local pharmacy. They know their regular customers by name and always call when a prescription is delayed. Solid and reliable.',                                                              wt:4.0,sq:4.0,hy:4.0,sc:4.5,days:18),
      _seed('s102','ph_002','Nina S.',       3.0,'Decent but nothing special. Sometimes the pharmacist is helpful, sometimes they just hand you the bag and say nothing. Depends who is on shift.',                                                wt:3.5,sq:3.0,hy:3.5,sc:3.0,days:35),
      _seed('s103','ph_002','Alan P.',       3.0,'Had to wait 45 minutes for a prescription they said would be 20 minutes. The pharmacy is understaffed during busy periods and it shows.',                                                        wt:1.5,sq:3.5,hy:3.5,sc:3.0,days:52),
      _seed('s104','ph_002','Judith M.',     2.0,'They gave me the wrong dosage instructions for a liquid medication. When I called to check they were initially defensive. Not the service you want for something important.',                    wt:2.5,sq:2.0,hy:3.0,sc:2.0,days:70),
      _seed('s105','ph_002','Chris L.',      2.0,'Poorly organised. Scripts regularly get lost between the doctor and here. I have switched to getting my prescriptions sent elsewhere for anything important.',                                   wt:2.0,sq:2.0,hy:3.0,sc:2.0,days:88),
      _seed('s106','ph_002','Rose N.',       1.0,'Horrendous wait times and rude staff. Waited 1 hour 20 minutes, asked for an update and was told to wait. Nobody apologised. I will not return.',                                               wt:1.0,sq:1.5,hy:2.5,sc:1.0,days:105),
    ],

    // ph_003 — Wellbeing Pharmacy — target avg ~4.6
    'ph_003': [
      _seed('s110','ph_003','Diane F.',      5.0,'They compounded a custom medication for my mother that four other pharmacies refused to handle. Professional, precise, and they followed up to check it was working.',                            wt:5.0,sq:5.0,hy:5.0,sc:5.0,days:5, v:true),
      _seed('s111','ph_003','Peter L.',      5.0,'Specialist compounding done with real expertise. The pharmacist spent 20 minutes reviewing my case before even starting to prepare the prescription.',                                             wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:13,v:true),
      _seed('s112','ph_003','Sarah K.',      5.0,'They handle a medication that almost no pharmacy in the city stocks. Always ready on time, always explained perfectly, always followed up. Worth the extra trip.',                                wt:5.0,sq:5.0,hy:5.0,sc:4.5,days:22,v:true),
      _seed('s113','ph_003','Mark D.',       4.0,'Very good pharmacy for specialist needs. It is a little out of the way and parking is difficult, but for what they offer that is a small inconvenience.',                                        wt:4.0,sq:4.5,hy:5.0,sc:4.5,days:35),
      _seed('s114','ph_003','Emma T.',       4.0,'Reliable and expert. Only giving 4 stars because the compounding can take a few extra days — plan ahead if you have time-sensitive medication.',                                                  wt:3.5,sq:4.5,hy:5.0,sc:4.5,days:50),
      _seed('s115','ph_003','James N.',      3.0,'Good for complex prescriptions but expensive. The service quality is high but I wish there were clearer upfront pricing for compounding work.',                                                   wt:4.0,sq:3.5,hy:5.0,sc:3.5,days:68),
    ],

    // ph_004 — Green Cross Pharmacy — target avg ~3.8
    'ph_004': [
      _seed('s120','ph_004','Alice B.',      5.0,'Wonderful pharmacy. The travel health clinic here is excellent — they did a full risk assessment for my South East Asia trip and the advice was thorough.',                                       wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:4, v:true),
      _seed('s121','ph_004','Owen R.',       4.0,'Good vitamin and supplement advice from qualified staff — not just generic recommendations. They actually know what they are talking about.',                                                      wt:4.0,sq:4.5,hy:4.5,sc:4.0,days:18),
      _seed('s122','ph_004','Claire W.',     4.0,'Solid pharmacy for routine prescriptions. The travel vaccines are reasonably priced and the nurse who administered mine was professional.',                                                       wt:3.5,sq:4.0,hy:4.5,sc:4.0,days:33),
      _seed('s123','ph_004','Simon D.',      3.0,'Good range of products but the pharmacy itself is quite cramped and always busy. Staff do their best but it feels understaffed.',                                                                wt:3.0,sq:3.5,hy:3.5,sc:3.0,days:50),
      _seed('s124','ph_004','Ruth A.',       3.0,'Average experience for prescription collection. Fine but unremarkable. The supplement section is good but I would not rate the dispensary itself above average.',                                wt:3.0,sq:3.0,hy:4.0,sc:3.0,days:65),
      _seed('s125','ph_004','Phil K.',       2.0,'Had an issue with a prescription not being ready despite being told it would be. Staff seemed overwhelmed and communication was poor.',                                                           wt:2.0,sq:2.0,hy:3.5,sc:2.0,days:82),
      _seed('s126','ph_004','Natalie S.',    1.0,'Wrong medication dispensed. Thankfully I checked the label. Reported it but received a minimal apology. This is a serious error that could have harmed me.',                                    wt:2.0,sq:1.0,hy:2.5,sc:1.0,days:100),
    ],

    // ph_005 — HealthHub Dispensary — target avg ~4.1
    'ph_005': [
      _seed('s130','ph_005','Fiona M.',      5.0,'Excellent NHS dispensary. They managed a complex handover from my hospital pharmacy smoothly and kept me fully informed. Staff are caring and professional.',                                     wt:4.5,sq:5.0,hy:5.0,sc:5.0,days:3, v:true),
      _seed('s131','ph_005','Graham S.',     5.0,'Been using HealthHub for three years. They know my medications, flag any issues proactively, and the pharmacist always makes time to answer questions.',                                          wt:4.5,sq:5.0,hy:4.5,sc:5.0,days:15,v:true),
      _seed('s132','ph_005','Aileen D.',     4.0,'Good pharmacy — friendly staff and efficient most of the time. The only issue is a very small car park which makes short visits stressful.',                                                     wt:4.0,sq:4.5,hy:4.5,sc:4.0,days:28),
      _seed('s133','ph_005','Derek K.',      4.0,'Reliable and professional. Never had an error. The pharmacist checked in after starting a new long-term medication — small gesture, big difference.',                                             wt:3.5,sq:4.5,hy:4.5,sc:4.5,days:42),
      _seed('s134','ph_005','Jean T.',       3.0,'Generally fine but the wait times for prescriptions have increased a lot in the past year. Used to be 10 minutes; now it is often 30-40 minutes.',                                              wt:2.0,sq:3.5,hy:4.5,sc:3.5,days:58),
      _seed('s135','ph_005','Barry L.',      2.0,'Inconsistent. Had a great experience with one pharmacist and a poor one with another on the same week. The quality control seems to depend on who is on shift.',                               wt:2.5,sq:2.0,hy:4.0,sc:2.0,days:75),
    ],
  };

  static ReviewModel _seed(
    String id,
    String providerId,
    String userName,
    double overall,
    String comment, {
    required double wt,  // waitingTime
    required double sq,  // serviceQuality
    required double hy,  // hygiene
    required double sc,  // staffCommunication
    required int days,
    bool v = false,      // isVerified
  }) {
    return ReviewModel(
      reviewId: id,
      providerId: providerId,
      userId: 'seed',
      userName: userName,
      overallRating: overall,
      comment: comment,
      questionnaire: {
        'waitingTime': wt,
        'serviceQuality': sq,
        'hygiene': hy,
        'staffCommunication': sc,
      },
      isVerified: v,
      createdAt: Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      ),
    );
  }

  /// Returns seed reviews for a given provider, sorted newest first.
  static List<ReviewModel> seedReviewsFor(String providerId) {
    final list = _seedReviews[providerId] ?? [];
    return [...list]..sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
  }
}
