import '../models/article.dart';

final List<DesiArticle> mockArticles = [
  DesiArticle(
    id: 'art_1',
    title: 'Sattu vs Whey: The Ultimate Indian Budget Protein Showdown',
    subtitle: 'Can a ₹10 glass of roasted chickpea flour (Sattu) compete with premium imported whey protein?',
    category: 'Gym Hacks',
    imageUrl: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    isFeatured: true,
    tags: ['Budget Fuel', 'Gym Hacks', 'Vegetarian'],
    sections: [
      const ArticleSection(
        heading: 'The Protein Cost Equation',
        text: 'Let\'s talk pure economics, Champ. A single scoop of branded imported whey protein costs anywhere between ₹90 to ₹140, yielding about 24g of protein. On the other hand, 100g of roasted gram flour (Sattu) costs around ₹10 to ₹15 and yields about 20g of protein. If you are a hostel student living on a strict pocket-money budget, the math is staring you in the face.',
      ),
      const ArticleSection(
        heading: 'But What About the Amino Acid Profile?',
        text: 'This is where WhatsApp University and fitness influencers clash. Whey is a complete protein, meaning it has all 9 essential amino acids in perfect ratios. Sattu, being plant-based, is low in the essential amino acid Lysine. However, here is the secret: if you mix Sattu with milk instead of water, or consume it alongside a grain like wheat roti or rice during the day, the amino acids combine to form a complete protein profile!',
      ),
      const ArticleSection(
        heading: 'Digestibility and Absorption',
        text: 'Whey protein is fast-digesting, making it ideal immediately post-workout. Sattu is packed with complex carbohydrates and dietary fiber, meaning it digests slowly. This makes Sattu an incredible meal-replacement shake or pre-workout energy fuel that keeps you full for 3-4 hours and prevents mid-lecture hunger pangs.',
      ),
    ],
    hostelHack: 'Hostel Kettle Shake: Mix 4 tablespoons of Sattu, 1 glass of cold milk, a pinch of cardamom (elaichi), and a teaspoon of honey or jaggery. Shake it in an empty peanut butter jar. No blender needed, no lumps, and costs under ₹15!',
    quiz: const ArticleQuiz(
      question: 'Why is Sattu not considered a "complete" protein on its own?',
      options: [
        'It has zero essential amino acids.',
        'It is limited in the essential amino acid Lysine.',
        'It cannot be digested by humans.',
        'It contains too much artificial fat.'
      ],
      correctAnswerIndex: 1,
      explanation: 'Sattu (roasted gram flour) is a legume-based protein, meaning it is naturally lower in Lysine. Combining it with grains or dairy (like milk) solves this completely!',
    ),
  ),
  DesiArticle(
    id: 'art_2',
    title: 'The Soya Chunks Estrogen Myth: Demolishing False Claims',
    subtitle: 'Does eating soya chunks give you man boobs? Here is what peer-reviewed human trials actually say.',
    category: 'Mythbusters',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['Mythbuster', 'Science-Backed', 'Budget Protein'],
    sections: [
      const ArticleSection(
        heading: 'Where Did the Myth Come From?',
        text: 'The panic started because soybeans contain "phytoestrogens" (isoflavones). Some internet experts assumed phytoestrogens act exactly like human estrogen, leading to hormonal imbalances in men, reduced testosterone, and gynecomastia (man boobs). This claim spread like wildfire in Indian gym circles.',
      ),
      const ArticleSection(
        heading: 'Phytoestrogens vs. Estrogen: The Science',
        text: 'Here is the truth: phytoestrogens are plant-derived compounds that bind to estrogen receptors, but their biological activity is 1,000 to 10,000 times weaker than human estrogen. Multiple meta-analyses of clinical studies in men have shown that even high intakes of soy (up to 100g daily) have absolutely no effect on free testosterone levels, sperm count, or estrogen levels.',
      ),
      const ArticleSection(
        heading: 'The Budget Protein Powerhouse',
        text: 'At roughly ₹10 for a 50g serving, soya chunks offer a mind-blowing 26g of complete protein. It is virtually fat-free and low-carb. For any vegetarian or budget fitness enthusiast, skipping soya chunks because of outdated myths is a massive loss.',
      ),
    ],
    hostelHack: 'Quick Kettle Soya Meal: Soak 50g soya chunks in hot water inside your electric kettle for 5 minutes. Drain the water, squeeze the chunks, and toss them with chat masala, lemon juice, and a pinch of black salt. High-protein snack in 6 minutes flat!',
    quiz: const ArticleQuiz(
      question: 'How do soy phytoestrogens compare to human estrogen in potency?',
      options: [
        'They are 10 times stronger.',
        'They are exactly identical in strength.',
        'They are 1,000 to 10,000 times weaker.',
        'They only activate during workouts.'
      ],
      correctAnswerIndex: 2,
      explanation: 'Phytoestrogens are plant-based and have a negligible hormonal effect on humans, being 1,000x to 10,000x weaker than actual human estrogen.',
    ),
  ),
  DesiArticle(
    id: 'art_3',
    title: 'Ashwagandha & Muscle Recovery: Science-Backed Ayurvedic Boosters',
    subtitle: 'How this ancient root helps reduce cortisol, boost strength, and the right way to consume it.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1611078489935-0cb964de46d6?auto=format&fit=crop&q=80&w=600',
    readTime: '6 min read',
    tags: ['Ayurveda', 'Recovery', 'Herbs', 'Science-Backed'],
    sections: [
      const ArticleSection(
        heading: 'What is Ashwagandha?',
        text: 'Withania somnifera, popularly known as Ashwagandha or Indian Ginseng, is a cornerstone of Ayurvedic medicine. It is classified as an "adaptogen," which means it helps your body manage physical and mental stress.',
      ),
      const ArticleSection(
        heading: 'The Cortisol Connection',
        text: 'When you train hard, your body produces cortisol—the stress hormone. High cortisol levels break down muscle tissue (catabolism) and inhibit testosterone production. Clinical trials show that taking a daily dose of standardized Ashwagandha root extract can reduce cortisol levels by up to 20% to 30%, keeping your body in an anabolic (muscle-building) state.',
      ),
      const ArticleSection(
        heading: 'Strength and Sleep Quality',
        text: 'A famous 8-week double-blind study showed that subjects taking Ashwagandha experienced significant increases in muscle strength on the bench press and leg extension, and doubled their muscle mass reduction in body fat percentage compared to the placebo group. It also dramatically improves deep sleep, which is when muscle recovery actually happens.',
      ),
    ],
    hostelHack: 'Recovery Nightcap: Add 1/2 teaspoon (approx 2-3g) of Ashwagandha powder (churna) to warm milk right before sleeping. Add a pinch of cinnamon for taste. It costs less than ₹2 per night and improves sleep depth significantly.',
    quiz: const ArticleQuiz(
      question: 'What is the primary hormone that Ashwagandha helps reduce to support recovery?',
      options: [
        'Insulin',
        'Estrogen',
        'Cortisol',
        'Adrenaline'
      ],
      correctAnswerIndex: 2,
      explanation: 'Ashwagandha primarily works by lowering cortisol, the body\'s main stress hormone, which prevents muscle breakdown and promotes rest.',
    ),
  ),
  DesiArticle(
    id: 'art_4',
    title: 'Hostel Room Calisthenics: Building Muscle with a Bucket & Bed',
    subtitle: 'No gym membership? No problem. Here is how to load your muscles progressively using everyday room objects.',
    category: 'Gym Hacks',
    imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['No Gym', 'Hostel Hacks', 'Calisthenics'],
    sections: [
      const ArticleSection(
        heading: 'Progressive Overload Without Weights',
        text: 'Muscle growth requires mechanical tension. Your muscle fibers don\'t know whether you are holding a fancy Swiss dumbbell or a plastic bucket filled with water and textbooks. They only respond to the load and proximity to failure.',
      ),
      const ArticleSection(
        heading: 'The Bucket Bicep Curl & Row',
        text: 'A standard 15-liter hostel bucket filled with water weighs exactly 15kg. Fill it with water, grab the handle (wrap a towel around it for grip comfort), and you have an instant adjustable dumbbell. Do curls, single-arm rows, or upright rows. Adjust the weight easily by adding or pouring out water.',
      ),
      const ArticleSection(
        heading: 'Incline, Flat, and Decline Pushups',
        text: 'Use your bed. Place your feet on the bed and hands on the floor (Decline Pushups) to target the upper chest. Place hands on the bed and feet on the floor (Incline Pushups) for the lower chest. Slow down the eccentric phase (lowering) to 3 seconds to maximize muscle micro-tears.',
      ),
    ],
    hostelHack: 'Adjustable Dumbbell Hack: Fill a sturdy backpack with heavy engineering textbooks, water bottles, and spare shoes. Tighten the straps. You now have a 10-25kg weighted vest/dumbbell for squats, pushups, and rows!',
    quiz: const ArticleQuiz(
      question: 'How much does a standard 15-liter hostel bucket filled to the brim with water weigh?',
      options: [
        '5 kg',
        '10 kg',
        '15 kg',
        '25 kg'
      ],
      correctAnswerIndex: 2,
      explanation: 'Water has a density of 1kg/liter, meaning a 15-liter bucket of water weighs exactly 15kg (plus the negligible weight of the plastic bucket).',
    ),
  ),
  DesiArticle(
    id: 'art_5',
    title: 'Golden Milk Reimagined: The Ultimate Post-Workout Joint Elixir',
    subtitle: 'Unlock curcumin absorption with black pepper and coconut fat for instant joint relief.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Joint Health', 'Hostel Kettle', 'Anti-inflammatory'],
    sections: [
      const ArticleSection(
        heading: 'The Anti-Inflammatory Power of Haldi',
        text: 'Traditional Haldi Doodh (Golden Milk) has been used for centuries to heal injuries and reduce fever. Modern research confirms its power: curcumin, the active compound in turmeric, is a potent anti-inflammatory agent that acts similarly to over-the-counter painkillers, reducing muscle soreness (DOMS) and joint pain.',
      ),
      const ArticleSection(
        heading: 'The Bioavailability Trap',
        text: 'Here is the catch: curcumin is poorly absorbed by the human body. If you just mix turmeric powder in water or skimmed milk, most of the curcumin passes right through you without being absorbed. You are wasting the benefits.',
      ),
      const ArticleSection(
        heading: 'The Curcumin Absorption Code',
        text: 'To unlock curcumin, you need two catalysts: Piperine (found in black pepper) and healthy fats. Piperine increases curcumin absorption in humans by a staggering 2,000%! Healthy fats (like ghee, coconut oil, or whole milk fat) dissolve the fat-soluble curcumin, enabling direct absorption into your bloodstream.',
      ),
    ],
    hostelHack: 'The 2000% Bioavailable Golden Milk: Heat 1 cup of whole milk in your kettle. Stir in 1/2 teaspoon of organic turmeric, a tiny pinch of freshly ground black pepper (kali mirch), and 1/4 teaspoon of ghee. Drink it warm after your heaviest workout.',
    quiz: const ArticleQuiz(
      question: 'By how much does black pepper (piperine) increase the absorption of turmeric (curcumin)?',
      options: [
        '50%',
        '200%',
        '1,000%',
        '2,000%'
      ],
      correctAnswerIndex: 3,
      explanation: 'Clinical studies show that combining a tiny amount of black pepper with turmeric boosts curcumin bioavailability by 2,000%!',
    ),
  ),
  DesiArticle(
    id: 'art_6',
    title: 'White Rice is Not Your Enemy: Carbohydrates Fueling Desi Athletes',
    subtitle: 'Why you do not need expensive brown quinoa to get fit. The science of simple carbs and muscle glycogen.',
    category: 'Mythbusters',
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Mythbuster', 'Carb Fuel', 'Diet Culture', 'Budget Fuel'],
    sections: [
      const ArticleSection(
        heading: 'The Brown Rice Fad',
        text: 'Fitness magazines and clean-eating influencers love to demonize white rice, claiming it causes insulin spikes and weight gain. They advocate for brown rice, quinoa, or imported wild oats. But if you are on a budget, paying 3x more for brown rice makes no sense.',
      ),
      const ArticleSection(
        heading: 'Glycemic Index in Context',
        text: 'It is true that white rice has a higher Glycemic Index (GI) than brown rice. However, you almost never eat white rice dry and plain. You eat it with Daal (fiber and protein), Paneer or Chicken (protein and fat), and Vegetables (fiber). Adding protein, fiber, and fat completely blunts the glycemic response, meaning white rice digests slowly and provides steady energy.',
      ),
      const ArticleSection(
        heading: 'Glycogen Replenishment',
        text: 'For someone who trains hard, simple carbs are your best friend post-workout. White rice is easily digestible and rapidly refills muscle glycogen stores, accelerating recovery so you can hit your next training session with maximum energy.',
      ),
    ],
    hostelHack: 'Post-Workout Carb Bomb: A plate of hot white rice from the mess paired with double daal or boiled eggs. Add a spoonful of curd (dahi) to aid digestion and gut health. Safe, cheap, and effective.',
    quiz: const ArticleQuiz(
      question: 'What happens to the Glycemic Index (GI) of white rice when eaten with protein and fiber (like Daal)?',
      options: [
        'It increases significantly.',
        'It remains exactly the same.',
        'It decreases, leading to slower digestion.',
        'It turns into fat immediately.'
      ],
      correctAnswerIndex: 2,
      explanation: 'Co-ingesting protein, fats, and dietary fiber with high-GI foods slows down gastric emptying, thereby lowering the overall glycemic index of the meal.',
    ),
  ),
  DesiArticle(
    id: 'art_7',
    title: 'Jeera Water: The ₹2 Fat-Loss Drink That Actually Works',
    subtitle: 'Cumin seeds steeped overnight. Ancient Ayurvedic remedy now backed by modern metabolic science.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Fat Loss', 'Ayurveda', 'Hostel Kettle', 'Morning Ritual'],
    sections: [
      const ArticleSection(
        heading: 'What Jeera Water Does to Your Body',
        text: 'Soaking one teaspoon of cumin seeds (jeera) in a glass of water overnight and drinking it on an empty stomach in the morning triggers a powerful chain reaction. Cumin contains thymoquinone, a bioactive compound that reduces inflammation and stimulates digestive enzymes in the pancreas, improving nutrient absorption by up to 30%.',
      ),
      const ArticleSection(
        heading: 'Metabolism and Fat Burning',
        text: 'A clinical study in the journal Complementary Therapies in Clinical Practice showed that women who consumed jeera water daily lost 3x more body fat than the control group over 8 weeks. The mechanism is linked to improved thermogenesis (heat production) and increased bile acid secretion, which helps emulsify and digest dietary fats.',
      ),
      const ArticleSection(
        heading: 'Blood Sugar Control',
        text: 'Jeera water helps moderate the post-meal glucose spike by slowing carbohydrate absorption in the small intestine. This is particularly useful if you eat a heavy carb-rich mess thali every day.',
      ),
    ],
    hostelHack: 'Night Prep: Drop 1 teaspoon of jeera into your steel water bottle before sleeping. In the morning, drink the strained water first thing on an empty stomach. Cost per day: ₹1.5. Results in 4 weeks: measurable.',
    quiz: const ArticleQuiz(
      question: 'What is the primary bioactive compound in cumin that aids fat metabolism?',
      options: [
        'Capsaicin',
        'Curcumin',
        'Thymoquinone',
        'Piperine',
      ],
      correctAnswerIndex: 2,
      explanation: 'Thymoquinone is the key phytochemical in cumin responsible for its anti-inflammatory and metabolic-boosting effects.',
    ),
  ),
  DesiArticle(
    id: 'art_8',
    title: 'Amla: The Vitamin C King That Beats Every Supplement',
    subtitle: 'One raw amla has more Vitamin C than 20 oranges. Here is how to use it for immunity and recovery.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Immunity', 'Ayurveda', 'Vitamin C', 'Free'],
    sections: [
      const ArticleSection(
        heading: 'The Vitamin C Powerhouse',
        text: 'Indian Gooseberry (Amla) contains approximately 600-700mg of Vitamin C per 100g — compared to an orange which has only about 53mg. What makes Amla even more impressive is that its Vitamin C is stabilised by naturally occurring tannins, meaning it does not degrade quickly when cooked or exposed to heat, unlike synthetic supplements.',
      ),
      const ArticleSection(
        heading: 'Collagen Synthesis and Muscle Recovery',
        text: 'Vitamin C is essential for collagen synthesis. Collagen forms the connective tissue in your muscles, tendons, and ligaments. Intense training causes micro-tears in these tissues. Adequate Vitamin C speeds up the repair cycle, reducing soreness and injury risk. Amla also contains powerful antioxidants that neutralise free radicals generated during hard training.',
      ),
      const ArticleSection(
        heading: 'Digestive and Liver Health',
        text: 'In Ayurveda, Amla is considered a Rasayana — a longevity herb. Modern research confirms it protects liver cells from oxidative damage, improves digestion, and promotes healthy gut flora, all of which are foundational to absorbing the nutrients from your food.',
      ),
    ],
    hostelHack: 'Amla Protein Shot: Mix 2 tablespoons of Amla powder (or juice from 1 raw amla) into your Sattu shake. The Vitamin C in Amla dramatically increases the bioavailability of plant-based iron in your diet. Cost: ₹3 per day from any local kirana shop.',
    quiz: const ArticleQuiz(
      question: 'How does Amla\'s Vitamin C differ from synthetic supplements?',
      options: [
        'It contains less Vitamin C per gram.',
        'It is stabilised by tannins and more heat-resistant.',
        'It only works when combined with dairy.',
        'It has no proven benefits.',
      ],
      correctAnswerIndex: 1,
      explanation: 'Amla\'s Vitamin C is bound with natural tannins which act as stabilisers, making it more resilient to heat degradation compared to isolated ascorbic acid supplements.',
    ),
  ),
  DesiArticle(
    id: 'art_9',
    title: 'Dahi (Curd) Power: Gut Health, Protein & Recovery in a Bowl',
    subtitle: 'The original probiotic that hostel students ignore every day at the mess. Stop being foolish.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Gut Health', 'Probiotic', 'Budget Protein', 'Recovery'],
    sections: [
      const ArticleSection(
        heading: 'Dahi is a Complete Probiotic Superfood',
        text: 'Dahi (Indian curd) is made by fermenting milk with live bacterial cultures — primarily Lactobacillus bulgaricus and Streptococcus thermophilus. These live bacteria colonise your gut and dramatically improve digestion, nutrient absorption, and immune function. One cup of full-fat dahi provides around 10-12g of protein and a massive dose of calcium.',
      ),
      const ArticleSection(
        heading: 'Post-Workout Casein Protocol',
        text: 'Dahi is rich in casein protein, which is slow-digesting (takes 5-7 hours to fully absorb). This makes it the perfect pre-sleep protein source. Eating a bowl of dahi before bed creates a slow trickle of amino acids throughout the night, feeding your muscles while you sleep — exactly when muscle protein synthesis peaks.',
      ),
      const ArticleSection(
        heading: 'The Hidden Anti-Bloating Agent',
        text: 'If you constantly feel bloated after the mess thali, start ending your meal with a small bowl of plain dahi. The live cultures break down lactose and complex food residue in your gut, significantly reducing gas, bloating, and indigestion.',
      ),
    ],
    hostelHack: 'Mess Thali Hack: Always grab the dahi at the end of your mess meal. If there is no dahi, pick up a small curd packet from the campus canteen (costs ₹10-15). It is the cheapest and most effective gut supplement on the planet.',
    quiz: const ArticleQuiz(
      question: 'Why is curd (dahi) a good pre-sleep protein source?',
      options: [
        'It contains fast-digesting whey only.',
        'It is rich in slow-digesting casein protein.',
        'It has zero carbohydrates.',
        'It accelerates digestion speed.',
      ],
      correctAnswerIndex: 1,
      explanation: 'Curd is rich in casein — a slow-release protein that takes 5-7 hours to digest, providing a steady supply of amino acids to muscles during sleep.',
    ),
  ),
  DesiArticle(
    id: 'art_10',
    title: 'Moringa Leaves: The Superfood Growing in Your Backyard',
    subtitle: 'Drumstick leaves have more calcium than milk, more iron than spinach. And they grow everywhere in India.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['Superfood', 'Free Food', 'Micronutrients', 'Ayurveda'],
    sections: [
      const ArticleSection(
        heading: 'Nature\'s Multivitamin',
        text: 'Moringa oleifera — the drumstick tree — grows freely across most of India. Its leaves are gram-for-gram one of the most nutritionally dense plant foods ever analysed. Dried Moringa leaves contain: 9x more protein than yogurt, 17x more calcium than milk, 25x more iron than spinach, 15x more potassium than bananas, and 10x more Vitamin A than carrots.',
      ),
      const ArticleSection(
        heading: 'Athletic Performance Benefits',
        text: 'Research shows Moringa leaf extract significantly reduces exercise-induced oxidative stress, improves post-workout recovery time, and enhances muscle endurance. Its high iron content is critical for oxygen transport in red blood cells — directly impacting your cardiovascular performance during running and HIIT.',
      ),
      const ArticleSection(
        heading: 'How to Use It',
        text: 'Fresh Moringa leaves can be added to any daal, sabzi, or parathas without significantly changing the taste. Dried Moringa powder is available at any Ayurvedic shop for ₹50-80 per 100g and can be mixed into your Sattu shake or morning water.',
      ),
    ],
    hostelHack: 'Free Food Hack: If you are near a village or suburban area, locate a Moringa (Sahjan) tree. Pick fresh young leaves, wash them thoroughly, sun-dry for 2 days, and crush into powder. Completely free, indefinitely renewable, and more nutritious than any imported supplement.',
    quiz: const ArticleQuiz(
      question: 'Compared to milk, how much more calcium do dried Moringa leaves contain?',
      options: [
        '2x more',
        '5x more',
        '17x more',
        'The same amount',
      ],
      correctAnswerIndex: 2,
      explanation: 'Dried Moringa leaves are an extraordinary calcium source — containing approximately 17 times more calcium per gram than dairy milk.',
    ),
  ),
  DesiArticle(
    id: 'art_11',
    title: 'Methi (Fenugreek) Seeds: Testosterone, Muscle & Blood Sugar Control',
    subtitle: 'The tiny golden seeds in your kitchen sabzi dabba are a clinical-grade testosterone and insulin sensitizer.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['Testosterone', 'Ayurveda', 'Blood Sugar', 'Muscle Building'],
    sections: [
      const ArticleSection(
        heading: 'Fenugreek and Testosterone',
        text: 'Multiple randomised controlled trials have demonstrated that fenugreek supplementation significantly raises free testosterone levels in men. The active compounds furostanolic saponins (steroidal saponins) inhibit the enzyme 5-alpha reductase, which converts testosterone to DHT. This means more free testosterone remains available for muscle building and libido.',
      ),
      const ArticleSection(
        heading: 'Insulin Sensitivity and Fat Loss',
        text: 'Fenugreek seeds are extremely high in soluble fibre, particularly galactomannan. This fibre slows down carbohydrate absorption in the intestine, blunting post-meal glucose spikes. Over time, regular consumption significantly improves insulin sensitivity — your body becomes better at utilising carbohydrates for energy rather than storing them as fat.',
      ),
      const ArticleSection(
        heading: 'Muscle Cramp Prevention',
        text: 'Fenugreek is a natural source of magnesium, potassium, and vitamin B6. These micronutrients are critical for electrolyte balance and muscle contraction. If you experience frequent muscle cramps during workouts, methi seed water in the morning may resolve this.',
      ),
    ],
    hostelHack: 'Methi Soak: Place 1 teaspoon of methi seeds in half a glass of water before sleeping. In the morning, chew and swallow the soaked seeds before breakfast. Costs ₹1 per day from your kitchen or kirana store.',
    quiz: const ArticleQuiz(
      question: 'How does fenugreek affect testosterone levels?',
      options: [
        'It directly produces testosterone.',
        'It inhibits enzymes that convert testosterone to DHT.',
        'It only works in women.',
        'It has no proven testosterone-related benefits.',
      ],
      correctAnswerIndex: 1,
      explanation: 'Furostanolic saponins in fenugreek inhibit 5-alpha reductase, preserving free testosterone by blocking its conversion to dihydrotestosterone (DHT).',
    ),
  ),
  DesiArticle(
    id: 'art_12',
    title: 'The Power of Ghee: Healthy Fat That Builds Hormones',
    subtitle: 'Stop fearing ghee. Clarified butter is nature\'s hormone precursor and the ultimate cooking fat.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Healthy Fats', 'Hormones', 'Ayurveda', 'Cooking'],
    sections: [
      const ArticleSection(
        heading: 'Why Fats Are Essential for Muscle Building',
        text: 'Every steroid hormone in your body — testosterone, cortisol, estrogen, DHEA — is synthesised from cholesterol. Cholesterol is made primarily from dietary saturated fats. When you aggressively cut fat from your diet, you literally reduce the raw material your body needs to make testosterone. Ghee is one of the most bioavailable sources of saturated fat and fat-soluble vitamins (A, D, E, K2).',
      ),
      const ArticleSection(
        heading: 'Butyric Acid: The Gut Healer',
        text: 'Ghee is extraordinarily rich in butyric acid (butyrate), a short-chain fatty acid that is the primary fuel source for colonocytes (cells lining your intestine). Adequate butyrate intake has been shown to reduce intestinal inflammation, heal leaky gut syndrome, and dramatically improve nutrient absorption — including protein absorption from every meal you eat.',
      ),
      const ArticleSection(
        heading: 'High Smoke Point Advantage',
        text: 'Ghee has a smoke point of 250°C, making it one of the safest fats to cook with at high temperatures. Unlike refined vegetable oils that oxidise and produce harmful aldehydes when overheated, ghee remains chemically stable and safe.',
      ),
    ],
    hostelHack: 'The ₹5 Mess Upgrade: Ask the mess staff to add one small spoon of ghee to your roti or rice. Most mess facilities will add it on request. If not, buy a small tin of ghee from the canteen and keep it in your room — just 1 teaspoon per meal is enough.',
    quiz: const ArticleQuiz(
      question: 'What unique fatty acid in ghee specifically feeds and heals intestinal cells?',
      options: [
        'Omega-3 fatty acid',
        'Linoleic acid',
        'Butyric acid (Butyrate)',
        'Stearic acid',
      ],
      correctAnswerIndex: 2,
      explanation: 'Butyrate is the preferred fuel for colonocytes and plays a critical role in maintaining intestinal integrity and reducing gut inflammation.',
    ),
  ),
  DesiArticle(
    id: 'art_13',
    title: 'Tulsi Kadha: Your Immunity Shield During Exam Season',
    subtitle: 'Five leaves from the plant on your balcony can rebuild your immune system in a week.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1585420847987-c2e9e5f62e58?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Immunity', 'Ayurveda', 'Free', 'Anti-Viral'],
    sections: [
      const ArticleSection(
        heading: 'Tulsi: The Queen of Herbs',
        text: 'Ocimum sanctum (Holy Basil / Tulsi) is classified in Ayurveda as an adaptogen and immunomodulator. Modern pharmacological research has confirmed it contains eugenol, rosmarinic acid, and ursolic acid — compounds with proven anti-bacterial, anti-viral, anti-fungal, and anti-inflammatory properties.',
      ),
      const ArticleSection(
        heading: 'The Science of Kadha',
        text: 'A traditional Tulsi Kadha combines Tulsi leaves, ginger, black pepper, and cloves. Each ingredient contributes: Tulsi provides immune-modulating phytochemicals, Ginger adds gingerols (potent anti-inflammatory agents), Black pepper adds piperine (bioavailability booster), and Cloves add eugenol (the most powerful natural anti-bacterial agent known).',
      ),
      const ArticleSection(
        heading: 'Exam Season Protocol',
        text: 'During high-stress exam periods, cortisol suppresses your immune system, making you vulnerable to infections. Daily Tulsi Kadha counteracts this effect by directly stimulating T-lymphocyte and B-lymphocyte production, strengthening your adaptive immunity.',
      ),
    ],
    hostelHack: 'Kettle Kadha: Boil 5-7 fresh Tulsi leaves, 1 small ginger piece, 4 black peppercorns, and 2 cloves in 1.5 cups of water in your hostel kettle for 10 minutes. Strain, add honey. Drink hot. Total cost: ₹5 or less if you have a Tulsi plant on the balcony.',
    quiz: const ArticleQuiz(
      question: 'Which bioactive compound in cloves makes Tulsi Kadha anti-bacterial?',
      options: [
        'Curcumin',
        'Gingerol',
        'Eugenol',
        'Thymoquinone',
      ],
      correctAnswerIndex: 2,
      explanation: 'Eugenol, found abundantly in cloves, is one of the most potent natural anti-bacterial and anti-fungal agents identified in scientific research.',
    ),
  ),
  DesiArticle(
    id: 'art_14',
    title: 'Peanuts: The Cheapest Complete Snack for Muscle Gainers',
    subtitle: '₹20 worth of moongfali gives you 30g of healthy fats, 13g of protein, and keeps you full for hours.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1567718379361-52e3f7e02f7b?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Budget Snack', 'Protein', 'Healthy Fats', 'Hostel Hacks'],
    sections: [
      const ArticleSection(
        heading: 'The Macro Profile of Peanuts',
        text: 'Per 100g, raw peanuts contain approximately 26g protein, 49g healthy fats (predominantly monounsaturated oleic acid — the same fat in olive oil), 16g carbohydrates, and 9g dietary fiber. They are also rich in magnesium, vitamin E, niacin, and folate. For less than ₹20, you get a nutrient bomb.',
      ),
      const ArticleSection(
        heading: 'Arginine and Blood Flow',
        text: 'Peanuts are the richest plant source of L-Arginine, an amino acid that is a direct precursor to Nitric Oxide (NO). Nitric Oxide dilates blood vessels, improving blood flow to muscles during workouts, creating better pumps and nutrient delivery. This is why most pre-workout supplements use L-Arginine as a key ingredient.',
      ),
      const ArticleSection(
        heading: 'Homemade Peanut Butter Protocol',
        text: 'Buying branded peanut butter at ₹400+ per jar is the biggest nutrition scam targeting Indian fitness enthusiasts. Raw peanuts cost ₹100/kg. You can blend them in any mixer or food processor for 5 minutes to make pure, additive-free peanut butter for a quarter of the cost.',
      ),
    ],
    hostelHack: 'Sattu-Peanut Pre-Workout: Mix 3 tablespoons of Sattu, 1 tablespoon of homemade peanut butter, 1 glass of cold milk, and a banana. This single drink contains 30g protein, 60g carbs, and 20g healthy fats — a complete pre-workout meal for under ₹30.',
    quiz: const ArticleQuiz(
      question: 'What compound in peanuts acts as a precursor to Nitric Oxide (NO)?',
      options: [
        'Glutamine',
        'Leucine',
        'L-Arginine',
        'Creatine',
      ],
      correctAnswerIndex: 2,
      explanation: 'L-Arginine is the direct precursor to Nitric Oxide in the human body. Peanuts are the richest plant-based source of this amino acid.',
    ),
  ),
  DesiArticle(
    id: 'art_15',
    title: 'Neem: The Ultimate Skin, Liver & Testosterone Protector',
    subtitle: 'Bitter neem leaves growing outside your hostel have been protecting Indian warriors for 4,000 years.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Ayurveda', 'Skin Health', 'Liver', 'Free'],
    sections: [
      const ArticleSection(
        heading: 'Nimbidin and Liver Protection',
        text: 'Neem leaves contain a compound called nimbidin, which has extraordinary hepatoprotective (liver-protecting) properties. For athletes who may consume protein supplements, creatine, or any processed foods, liver health is paramount. A stressed liver impairs fat metabolism, hormone synthesis, and nutrient detoxification. Daily neem consumption keeps liver enzymes (ALT, AST) in the healthy range.',
      ),
      const ArticleSection(
        heading: 'Skin and Acne Benefits During Cutting Phases',
        text: 'During caloric restriction phases (cutting), hormonal fluctuations often cause increased sebum production, leading to acne and skin breakouts. Neem\'s antibacterial and anti-inflammatory compounds directly inhibit the bacteria (Propionibacterium acnes) responsible for acne. Taking 5 neem leaves daily is more effective than most commercial face washes.',
      ),
      const ArticleSection(
        heading: 'Blood Sugar and Insulin Sensitivity',
        text: 'Compounds in neem leaves — particularly flavonoids like quercetin and catechins — have been shown to lower fasting blood glucose levels and improve insulin sensitivity, making your body more efficient at using carbohydrates for energy.',
      ),
    ],
    hostelHack: 'Morning Bitter Ritual: Eat 5-7 fresh neem leaves on an empty stomach every morning (rinse them first). It is intensely bitter for the first week, then you stop noticing. Neem trees grow across every hostel campus in India — this is completely free.',
    quiz: const ArticleQuiz(
      question: 'What is the primary compound in neem leaves responsible for liver protection?',
      options: [
        'Curcumin',
        'Nimbidin',
        'Piperine',
        'Quercetin',
      ],
      correctAnswerIndex: 1,
      explanation: 'Nimbidin is the primary bioactive compound in neem responsible for its powerful hepatoprotective (liver-protecting) effects.',
    ),
  ),
  DesiArticle(
    id: 'art_16',
    title: 'Besan (Gram Flour) Chilla: The 5-Minute Protein Pancake',
    subtitle: 'The best hostel breakfast you are not making. 25g protein, zero equipment, and costs ₹15.',
    category: 'Recipes',
    imageUrl: 'https://images.unsplash.com/photo-1484723091739-30990bf5d85c?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Recipes', 'High Protein', 'Breakfast', 'Budget Fuel'],
    sections: [
      const ArticleSection(
        heading: 'Besan: The Protein in Your Kitchen',
        text: 'Besan (Chickpea flour / Gram flour) contains approximately 20g protein per 100g. Unlike refined wheat flour (maida), besan is low glycemic, high fibre, and rich in folate, thiamine, and iron. Making besan chilla requires only a tawa (flat pan) and a gas stove — both available in most hostel kitchens and PG accommodations.',
      ),
      const ArticleSection(
        heading: 'The Macro-Stacked Chilla Recipe',
        text: 'Mix 100g besan with 1 egg (optional for extra protein), 1 chopped onion, 1 green chilli, 1 grated carrot, salt, cumin, and turmeric. Add water to form a thin batter. Pour onto a hot tawa with minimal oil. Cook for 2 minutes each side. You now have a complete meal with 25g+ protein and a full serving of vegetables.',
      ),
      const ArticleSection(
        heading: 'Customisation for Fitness Goals',
        text: 'Add paneer crumbles for bulking (extra protein and fat). Add sprouted moong for extra micronutrients. Eat with curd for probiotic benefits and complete amino acid profiling. The chilla base is infinitely customisable for your current fitness phase.',
      ),
    ],
    hostelHack: 'Batch Cook Hack: Make 6-8 chillas at once on a Sunday afternoon. Stack and wrap them in foil. Store in the hostel mini-fridge. Reheat on the tawa for 30 seconds each morning. Breakfast solved for the entire week at ₹80 total.',
    quiz: const ArticleQuiz(
      question: 'Compared to maida (refined wheat flour), how does besan differ nutritionally?',
      options: [
        'Lower protein, higher glycemic index',
        'Higher protein, lower glycemic index, higher fibre',
        'Exactly the same nutritional profile',
        'Lower protein but much richer in carbohydrates',
      ],
      correctAnswerIndex: 1,
      explanation: 'Besan has nearly double the protein of maida, a significantly lower glycemic index, and much higher dietary fibre content.',
    ),
  ),
  DesiArticle(
    id: 'art_17',
    title: 'Sprouted Moong: The Living Superfood You Can Grow in 2 Days',
    subtitle: 'When moong dal sprouts, its nutrition multiplies. Vitamin C increases 600%, protein bioavailability doubles.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Sprouts', 'Free Food', 'Micronutrients', 'Raw Nutrition'],
    sections: [
      const ArticleSection(
        heading: 'The Germination Transformation',
        text: 'When a seed sprouts, it undergoes a biochemical revolution. Enzymes activate that break down antinutrients (phytic acid, lectins, trypsin inhibitors) that would normally block mineral and protein absorption. Simultaneously, the sprouting process synthesises new vitamins — particularly Vitamin C (increases ~600%), Vitamin K, and B-vitamins.',
      ),
      const ArticleSection(
        heading: 'Protein Quality Upgrade',
        text: 'Sprouting increases the biological value (BV) of moong dal protein by deactivating protease inhibitors — substances in raw legumes that interfere with protein-digesting enzymes. This means your body absorbs nearly double the amino acids from sprouted moong compared to cooked dal, gram for gram.',
      ),
      const ArticleSection(
        heading: 'The Enzyme Benefit',
        text: 'Sprouts are living food teeming with active enzymes (amylases, proteases, lipases). Eating enzyme-rich living foods reduces your body\'s metabolic burden of producing digestive enzymes, freeing up biological energy for muscle repair and immunity.',
      ),
    ],
    hostelHack: 'The 2-Day Hostel Sprout Factory: Soak 1 cup of moong dal overnight in your steel glass. Drain the water, tie the wet moong in a moist cotton cloth, and hang it from your room door or keep it in a damp dark corner. After 48 hours, fresh sprouts emerge. Rinse and eat raw with lemon and salt. Free protein.',
    quiz: const ArticleQuiz(
      question: 'By approximately how much does Vitamin C content increase when moong dal sprouts?',
      options: [
        '50%',
        '200%',
        '600%',
        'It decreases during sprouting',
      ],
      correctAnswerIndex: 2,
      explanation: 'The sprouting process triggers Vitamin C biosynthesis from scratch. Studies show Vitamin C can increase by 500-600% compared to the unsprouted seed.',
    ),
  ),
  DesiArticle(
    id: 'art_18',
    title: 'Triphala: The Ayurvedic Gut Reset That Beats Probiotics',
    subtitle: 'Three dried fruits. Ancient formula. Now proven to modulate gut bacteria better than commercial probiotics.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1559181567-c3190958d3b8?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['Gut Health', 'Ayurveda', 'Detox', 'Recovery'],
    sections: [
      const ArticleSection(
        heading: 'What is Triphala?',
        text: 'Triphala is one of the oldest and most revered Ayurvedic formulations, composed of three dried fruits in equal proportions: Amalaki (Amla / Indian Gooseberry), Bibhitaki (Bahera / Belleric Myrobalan), and Haritaki (Harad / Chebulic Myrobalan). Together, they create a synergistic compound with prebiotic, antioxidant, anti-inflammatory, and mild laxative properties.',
      ),
      const ArticleSection(
        heading: 'Gut Microbiome Modulation',
        text: 'Recent research published in the Journal of Ethnopharmacology confirmed that Triphala actively promotes the growth of beneficial gut bacteria (Bifidobacterium, Lactobacillus) while inhibiting pathogenic bacteria. This prebiotic effect is comparable to commercial probiotic supplements, but with the additional benefit of a powerful antioxidant profile from gallic acid and ellagic acid.',
      ),
      const ArticleSection(
        heading: 'Athletic Recovery Benefits',
        text: 'A healthy gut microbiome directly impacts athletic performance. Gut bacteria synthesise B-vitamins, produce neurotransmitters (including serotonin), and regulate inflammatory responses. Athletes with diverse gut bacteria have been shown to have faster recovery times, better sleep quality, and higher VO2 max scores.',
      ),
    ],
    hostelHack: 'Nightly Reset: Mix 1/2 teaspoon of Triphala churna in warm water and drink 30 minutes before bed. Available at any Patanjali or Ayurvedic shop for ₹40-60 for a month\'s supply. Do not take with milk, as dairy binds to the tannins and reduces efficacy.',
    quiz: const ArticleQuiz(
      question: 'What are the three fruits that make up Triphala?',
      options: [
        'Amla, Neem, Ashwagandha',
        'Amalaki, Bibhitaki, Haritaki',
        'Ginger, Turmeric, Pepper',
        'Tulsi, Amla, Jeera',
      ],
      correctAnswerIndex: 1,
      explanation: 'Triphala literally means "three fruits" in Sanskrit: Amalaki (Amla), Bibhitaki (Bahera), and Haritaki (Harad).',
    ),
  ),
  DesiArticle(
    id: 'art_19',
    title: 'Sleep is the Original Steroid: Optimise Recovery Without Supplements',
    subtitle: 'Growth hormone production peaks at 11pm. If you are awake scrolling reels, you are losing gains.',
    category: 'Recovery',
    imageUrl: 'https://images.unsplash.com/photo-1541480601022-2308c0f02487?auto=format&fit=crop&q=80&w=600',
    readTime: '5 min read',
    tags: ['Sleep', 'Recovery', 'Hormones', 'Science-Backed'],
    sections: [
      const ArticleSection(
        heading: 'The Growth Hormone Window',
        text: 'Human Growth Hormone (HGH) — the primary anabolic hormone responsible for muscle repair and fat burning — is secreted in pulses during deep (slow-wave) sleep. The largest pulse occurs approximately 1-2 hours after falling asleep. If you sleep at 1am, this pulse shifts to 2-3am, but critically, the magnitude (amplitude) of the pulse is significantly reduced compared to sleeping at 10-11pm.',
      ),
      const ArticleSection(
        heading: 'Sleep Deprivation and Muscle Loss',
        text: 'A landmark study showed that cutting sleep from 8.5 to 5.5 hours per night — while on the same diet and workout program — reduced fat loss by 55% and caused muscle loss instead of gain. Sleep is not optional recovery; it is the primary recovery modality. No supplement can compensate for chronic sleep debt.',
      ),
      const ArticleSection(
        heading: 'The Hostel Sleep Protocol',
        text: 'Create a 30-minute pre-sleep routine: Dim your room lights, use yellow/warm-toned bulbs, stop using your phone 20 minutes before bed, drink warm Ashwagandha milk, and maintain a consistent sleep time (even on weekends). Your body\'s circadian rhythm responds to consistency above all else.',
      ),
    ],
    hostelHack: 'Phone Hack: Enable "Night Light" or "Blue Light Filter" on your Android/iOS phone after 9pm. Use the inbuilt sleep mode that auto-silences notifications. Put your charger across the room so you cannot use the phone in bed. These free hacks measurably improve sleep onset speed.',
    quiz: const ArticleQuiz(
      question: 'What happened to fat loss when sleep was restricted from 8.5 to 5.5 hours per night in a controlled study?',
      options: [
        'Fat loss increased by 20%',
        'Fat loss remained the same',
        'Fat loss decreased by 55%',
        'Subjects gained muscle and lost fat equally',
      ],
      correctAnswerIndex: 2,
      explanation: 'The landmark Spiegel et al. study found that sleep restriction cut fat loss by 55% and shifted the body into a muscle-catabolising state.',
    ),
  ),
  DesiArticle(
    id: 'art_20',
    title: 'Haldi-Ginger-Honey: The Desi Pre-Sleep Recovery Shot',
    subtitle: 'Three kitchen ingredients that together form a clinically validated anti-inflammatory, cortisol-lowering nightcap.',
    category: 'Recipes',
    imageUrl: 'https://images.unsplash.com/photo-1571091655789-405eb7a3a3a8?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Anti-inflammatory', 'Recovery', 'Ayurveda', 'Hostel Kettle'],
    sections: [
      const ArticleSection(
        heading: 'Why This Combination Works',
        text: 'Turmeric (Haldi), Ginger (Adrak), and Honey (Shehad) is not just a grandmother\'s home remedy — it is a clinically validated anti-inflammatory stack. Curcumin in turmeric inhibits the NF-κB inflammatory pathway. Gingerols and shogaols in ginger inhibit COX-2 enzymes (the same target as ibuprofen). Raw honey contains defensins — natural antimicrobial peptides — and acts as a glycogen topper for overnight muscle repair.',
      ),
      const ArticleSection(
        heading: 'The Cortisol-Lowering Effect',
        text: 'Taking this combination 30 minutes before sleep works synergistically with your body\'s nocturnal cortisol suppression cycle. Ginger has been shown to modulate the HPA (Hypothalamic-Pituitary-Adrenal) axis, reducing the evening cortisol spike that many stressed students experience, enabling a smoother transition into deep sleep.',
      ),
      const ArticleSection(
        heading: 'Honey for Night-Time Glycogen',
        text: 'Raw honey consists of approximately 40% fructose and 30% glucose. The fructose is preferentially stored in the liver as liver glycogen. A small amount of pre-sleep honey ensures your liver glycogen is topped off, preventing your body from producing cortisol during the night to maintain blood sugar — a common cause of waking up at 3am.',
      ),
    ],
    hostelHack: 'The 5-Minute Recovery Shot: In your hostel kettle, heat half a glass of water. Add 1/4 teaspoon of turmeric, grate in a small piece of fresh ginger (or add a pinch of dry ginger powder), and 1 teaspoon of raw honey. Stir. Drink 30 minutes before bed. Cost: under ₹5.',
    quiz: const ArticleQuiz(
      question: 'Why does raw honey before bed help prevent waking up at 3am?',
      options: [
        'It acts as a sleeping pill',
        'Its fructose tops off liver glycogen, preventing cortisol release to maintain blood sugar',
        'It increases melatonin directly',
        'It has no scientifically proven effect on sleep',
      ],
      correctAnswerIndex: 1,
      explanation: 'The liver glycogen stored from honey\'s fructose ensures stable blood sugar through the night, preventing the cortisol surge that often wakes people up in the early morning hours.',
    ),
  ),
  DesiArticle(
    id: 'art_21',
    title: 'Lauki (Bottle Gourd): The Most Underrated Recovery Vegetable in India',
    subtitle: 'The vegetable every student rejects at the mess is clinically proven to support kidney, heart and post-workout rehydration.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1626200419199-391ae4be7a41?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Recovery', 'Hydration', 'Budget Fuel', 'Micronutrients'],
    sections: [
      const ArticleSection(
        heading: 'Composition Breakdown',
        text: 'Bottle gourd (Lauki / Dudhi) is 96% water, making it one of the most hydrating vegetables available. Per 100g it provides: 15 kcal, 0.2g fat, 0.6g protein, essential electrolytes (sodium, potassium, magnesium), and Vitamin C. Its extremely low calorie density makes it the perfect high-volume food for anyone cutting calories.',
      ),
      const ArticleSection(
        heading: 'Post-Workout Electrolyte Replenishment',
        text: 'After intense workouts, your body loses significant sodium, potassium, and magnesium through sweat. The electrolyte profile of lauki juice (naturally containing all three) provides a free, natural electrolyte drink without the artificial colours and sugar of commercial sports drinks.',
      ),
      const ArticleSection(
        heading: 'Kidney and Liver Protection',
        text: 'Ayurvedic texts prescribe lauki juice for kidney and liver cooling. Modern research backs this — lauki contains flavonoids and antioxidants that reduce oxidative stress in kidney and liver cells. For athletes consuming high-protein diets, kidney support is critical for long-term health.',
      ),
    ],
    hostelHack: 'Lauki Juice Hack: Grate raw lauki, squeeze through a cloth to extract the juice. Add a pinch of black salt, jeera powder, and lemon. Drink post-workout. Do not heat lauki juice — it develops toxic compounds when heated. Always drink freshly extracted, raw juice.',
    quiz: const ArticleQuiz(
      question: 'What percentage of bottle gourd (lauki) is water?',
      options: [
        '70%',
        '82%',
        '96%',
        '100%',
      ],
      correctAnswerIndex: 2,
      explanation: 'Lauki is approximately 96% water content, making it one of the most hydrating vegetables and an excellent natural electrolyte source for athletes.',
    ),
  ),
  DesiArticle(
    id: 'art_22',
    title: 'Sun Exposure: Free Vitamin D and Testosterone Boost Before 10am',
    subtitle: 'Your hostel rooftop is a free testosterone therapy clinic. But only before 10am.',
    category: 'Lifestyle',
    imageUrl: 'https://images.unsplash.com/photo-1520716533752-9240bd5de94e?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Vitamin D', 'Testosterone', 'Free', 'Morning Ritual'],
    sections: [
      const ArticleSection(
        heading: 'The Vitamin D-Testosterone Link',
        text: 'Vitamin D is technically a hormone, not a vitamin. Leydig cells in the testes have Vitamin D receptors, and multiple studies confirm that men with optimal Vitamin D levels (40-60 ng/mL) have significantly higher testosterone levels than those who are deficient. India has a paradoxical vitamin D deficiency epidemic — despite tropical sunlight — because most Indians now spend daylight hours indoors.',
      ),
      const ArticleSection(
        heading: 'The 20-Minute Window',
        text: 'Before 10am, UVB rays hit Earth at an angle that enables your skin to synthesise cholecalciferol (Vitamin D3) from 7-dehydrocholesterol in your skin. Just 15-20 minutes of direct sun exposure on your arms, legs, and face before 10am can produce 10,000-20,000 IU of Vitamin D — far more than any supplement.',
      ),
      const ArticleSection(
        heading: 'Circadian Rhythm Reset',
        text: 'Morning sunlight also hits your retina and triggers a hormonal cascade: it suppresses melatonin, resets your circadian clock, boosts morning cortisol to appropriate levels (improving alertness), and triggers serotonin production. The first 30 minutes of sunlight exposure each morning is the most high-leverage free health tool available.',
      ),
    ],
    hostelHack: 'Rooftop Protocol: Take your morning Sattu shake or jeera water to the hostel rooftop. Spend 15-20 minutes in direct sunlight before 10am. Do your dynamic warm-up routine or mobility work in the sun simultaneously. Free Vitamin D + free circadian entrainment + free warm-up.',
    quiz: const ArticleQuiz(
      question: 'What is the ideal window for getting Vitamin D-synthesising UVB sun exposure in India?',
      options: [
        'Between 12pm and 2pm (peak sun)',
        'Before 10am',
        'After 4pm (when it is cooler)',
        'At any time of day, duration does not matter',
      ],
      correctAnswerIndex: 1,
      explanation: 'UVB rays at the correct angle for Vitamin D synthesis are available in the morning hours before 10am. After this, UVA rays predominate, which cause skin damage without Vitamin D production.',
    ),
  ),
  DesiArticle(
    id: 'art_23',
    title: 'Kokum: The Coastal Fat-Burner Nobody Outside Maharashtra Knows About',
    subtitle: 'Hydroxycitric acid (HCA) in kokum was used in Ayurveda long before it appeared in weight-loss supplements.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Fat Loss', 'Ayurveda', 'Coastal India', 'Metabolism'],
    sections: [
      const ArticleSection(
        heading: 'What is Kokum?',
        text: 'Garcinia indica (Kokum) is a fruit indigenous to the Western Ghats of India, widely used in Goan and Konkan cuisine. Its dried rind contains Hydroxycitric Acid (HCA), the same compound found in Garcinia cambogia supplements sold globally for weight loss — except kokum is the original, cheaper, and less processed source.',
      ),
      const ArticleSection(
        heading: 'HCA\'s Fat-Metabolism Mechanism',
        text: 'HCA inhibits an enzyme called ATP citrate lyase, which is responsible for converting excess carbohydrates into fatty acids for storage. By blocking this enzyme, HCA diverts carbohydrates toward glycogen storage in muscles instead of fat storage in adipose tissue. This makes kokum particularly effective when consumed alongside a high-carb Indian diet.',
      ),
      const ArticleSection(
        heading: 'Cooling and Digestive Benefits',
        text: 'Kokum sharbat (the traditional drink made by dissolving kokum in water with black salt) is one of the most effective natural antacids and digestive aids available. It reduces acidity, prevents heat stroke, and promotes bile secretion for fat digestion. Perfect for hot Indian summers.',
      ),
    ],
    hostelHack: 'Kokum Sharbat: Dissolve 2-3 pieces of dried kokum in a glass of water with a pinch of black salt, cumin powder, and a teaspoon of jaggery. Available at any Maharashtra or Goa-based grocery store for ₹40-80 per pack that lasts a month.',
    quiz: const ArticleQuiz(
      question: 'What enzyme does Hydroxycitric Acid (HCA) in kokum inhibit to reduce fat storage?',
      options: [
        'Lipase',
        'Amylase',
        'ATP citrate lyase',
        'Glucokinase',
      ],
      correctAnswerIndex: 2,
      explanation: 'HCA specifically inhibits ATP citrate lyase — the enzyme that converts excess acetyl-CoA (from carbohydrate metabolism) into fatty acids for storage in adipose tissue.',
    ),
  ),
  DesiArticle(
    id: 'art_24',
    title: 'Chana Dal Pre-Workout: The Sustained Energy Secret of Indian Wrestlers',
    subtitle: 'Traditional pehelwans fuelled epic training sessions with boiled chana, not banana gels or energy bars.',
    category: 'Nutrition',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=600',
    readTime: '4 min read',
    tags: ['Pre-Workout', 'Wrestling', 'Budget Fuel', 'Carb Fuel'],
    sections: [
      const ArticleSection(
        heading: 'The Glycemic Index Advantage',
        text: 'Whole black chana (kala chana) has one of the lowest glycemic indices of any carbohydrate-rich food (GI ≈ 28-33). This means it releases glucose into the bloodstream extremely slowly and consistently over 3-4 hours — the perfect sustained energy release for long training sessions, wrestling bouts, or athletic competitions.',
      ),
      const ArticleSection(
        heading: 'The Pehelwan Protocol',
        text: 'Traditional Indian wrestlers (pehelwans) in Varanasi and Kolhapur have been consuming boiled chana with ghee and jaggery as their primary pre-training fuel for centuries. The combination of slow carbs (chana) + healthy fat (ghee) + natural sugar (jaggery as a fast-acting initial glucose booster) creates a perfectly timed, multi-phase energy release.',
      ),
      const ArticleSection(
        heading: 'Nutritional Powerhouse',
        text: 'One cup of boiled black chana provides: 40g complex carbohydrates, 14g protein, 11g dietary fiber, high amounts of iron, folate, magnesium, and phosphorus. It also contains resistant starch which feeds your gut bacteria and improves insulin sensitivity over time.',
      ),
    ],
    hostelHack: 'Overnight Chana Soak: Soak 1/2 cup kala chana in water overnight. Boil the next day for 20 minutes in your hostel pressure cooker (if available) or kettle for 40 minutes. Add a pinch of salt, black pepper, lemon, and optionally a spoon of ghee. Eat 1.5-2 hours before your workout.',
    quiz: const ArticleQuiz(
      question: 'What is the approximate Glycemic Index (GI) of whole black chana?',
      options: [
        'GI ≈ 70 (high)',
        'GI ≈ 55 (medium)',
        'GI ≈ 28-33 (very low)',
        'GI ≈ 90 (very high)',
      ],
      correctAnswerIndex: 2,
      explanation: 'Black chana has a very low GI of approximately 28-33, making it one of the best slow-release carbohydrate sources for sustained athletic performance.',
    ),
  ),
  DesiArticle(
    id: 'art_25',
    title: 'Ajwain Water: The Instant Bloat and Cramp Remedy in Your Spice Box',
    subtitle: 'Carom seeds fix digestion, bloating, muscle cramps, and acidity within 15 minutes of drinking.',
    category: 'Ayurvedic',
    imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&q=80&w=600',
    readTime: '3 min read',
    tags: ['Digestion', 'Ayurveda', 'Cramps', 'Hostel Kettle'],
    sections: [
      const ArticleSection(
        heading: 'Thymol: The Active Compound',
        text: 'Ajwain (Carom seeds) contain thymol as their primary bioactive compound — the same antiseptic ingredient used in commercial mouthwashes. In the digestive system, thymol releases calcium from smooth muscle cells, causing them to relax. This is what provides almost instant relief from stomach cramps, bloating, and spasms.',
      ),
      const ArticleSection(
        heading: 'The Digestive Enzyme Stimulator',
        text: 'Thymol also stimulates the secretion of gastric juices and digestive enzymes, dramatically improving the breakdown and absorption of proteins and carbohydrates. Athletes with poor digestion and suboptimal protein absorption will see measurable improvements in energy and performance from simply improving gut enzyme function.',
      ),
      const ArticleSection(
        heading: 'Respiratory Benefits for Endurance Athletes',
        text: 'Ajwain has natural bronchodilatory properties. Drinking warm ajwain water before a run or cardio session can open the airways and reduce breathlessness, particularly beneficial during humid Indian summers or if you have mild exercise-induced asthma.',
      ),
    ],
    hostelHack: 'Instant Relief Drink: Add 1 teaspoon of ajwain seeds to 1.5 cups of water in your hostel kettle. Boil for 5 minutes. Strain. Drink warm. Works within 15 minutes for bloating, stomach cramps, and acidity. Add a pinch of black salt for taste. Total cost: ₹2 per use.',
    quiz: const ArticleQuiz(
      question: 'What mechanism makes ajwain water so effective at relieving stomach cramps?',
      options: [
        'It directly kills gut bacteria',
        'Thymol releases calcium from smooth muscle cells, causing them to relax',
        'It increases stomach acid production',
        'It works purely as a placebo effect',
      ],
      correctAnswerIndex: 1,
      explanation: 'Thymol in ajwain acts as a calcium-channel modulator in smooth muscle — releasing calcium causes muscle relaxation, providing rapid relief from spasms and cramps.',
    ),
  ),
];
