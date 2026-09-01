export const EmotionType = Object.freeze({
  angry: 'angry',
  happy: 'happy',
  sad: 'sad',
  neutral: 'neutral',
});

export class EmotionData {
  constructor({
    type,
    labelArabic,
    labelEnglish,
    subtitleArabic,
    emoji,
    apiTag,
    color,
    darkColor,
    accentColor,
    prompts,
  }) {
    this.type = type;
    this.labelArabic = labelArabic;
    this.labelEnglish = labelEnglish;
    this.subtitleArabic = subtitleArabic;
    this.emoji = emoji;
    this.apiTag = apiTag;
    this.color = color;
    this.darkColor = darkColor;
    this.accentColor = accentColor;
    this.prompts = prompts;
  }

  promptFor(index) {
    return this.prompts[index % this.prompts.length];
  }

  static all = Object.freeze({
    [EmotionType.angry]: new EmotionData({
      type: EmotionType.angry,
      labelArabic: 'معصب',
      labelEnglish: 'Angry',
      subtitleArabic: 'نبرة حادة وغاضبة',
      emoji: '😡',
      apiTag: 'angry',
      color: '#E63946',
      darkColor: '#9D0208',
      accentColor: '#FF758F',
      prompts: [
        'والله زهقت منك، كم مرة لازم أعيد عليك نفس الحكي؟!',
        'ما بصدق حالي، رجعوا أخروا الطلب بعد ما وعدوني ألف مرة!',
        'هاي مش طريقة، ليش ما حدا رد عليي وأنا مستني من الصبح؟',
        'بجنن والله، كل مرة نفس المشكلة وما حدا بيحلها!',
        'ولا كلمة زيادة! أنا حكيت اللي عندي وخلاص!',
        'إنت ليش دايماً بتعمل عكس اللي بنتفق عليه بالضبط؟!',
      ],
    }),
    [EmotionType.happy]: new EmotionData({
      type: EmotionType.happy,
      labelArabic: 'فرحان',
      labelEnglish: 'Happy',
      subtitleArabic: 'طاقة وبهجة وضحكة',
      emoji: '😁',
      apiTag: 'happy',
      color: '#FFB703',
      darkColor: '#FB8500',
      accentColor: '#FFE3A8',
      prompts: [
        'يا زلمة مبروك عليك النجاح، والله بتستاهل هالفرحة كلها!',
        'ما بصدق إني أخيراً حجزت تذكرة السفر، فرحان مش طبيعي!',
        'اليوم أحلى يوم بحياتي، خطبت حبيبتي وكل الأهل مبسوطين!',
        'يا سلام عليك، جبت العلامة الكاملة، الله يبارك فيك!',
        'يسعد قلبك يا خوي، ما قصرت وبيضت وجوهنا!',
        'أخيراً خلصنا المشروع وسلمناه على أحسن وجه، الحمد لله!',
      ],
    }),
    [EmotionType.sad]: new EmotionData({
      type: EmotionType.sad,
      labelArabic: 'زعلان',
      labelEnglish: 'Sad',
      subtitleArabic: 'حزن وشوق ونبرة هادية',
      emoji: '😢',
      apiTag: 'sad',
      color: '#4361EE',
      darkColor: '#1E2E7B',
      accentColor: '#A5C4D4',
      prompts: [
        'ما بعرف ليش بس اليوم قلبي تعبان وحاسس إني وحيد كتير.',
        'اشتقتلك كتير، من يوم ما سافرت البيت مش هو البيت.',
        'تعبت من كل شي، حاسس إني بحاول وما حدا شايف تعبي.',
        'خسارة والله، فاتنا القطار وضاع تعبنا كله من غير فايدة.',
        'ياريت لو الأيام بترجع لورا ونصلح اللي صار بيناتنا.',
      ],
    }),
    [EmotionType.neutral]: new EmotionData({
      type: EmotionType.neutral,
      labelArabic: 'طبيعي',
      labelEnglish: 'Neutral',
      subtitleArabic: 'كلام يومي هادئ وعادي',
      emoji: '😐',
      apiTag: 'neutral',
      color: '#4A6572',
      darkColor: '#232F34',
      accentColor: '#90A4AE',
      prompts: [
        'الجو اليوم معتدل شوي، بكرة إن شاء الله بصير أحسن.',
        'رايح عالدوام الساعة تمانية وبرجع البيت بعد الظهر.',
        'الاجتماع بيبدأ الساعة عشرة وبده يوخذ حوالي ساعة.',
        'لازم أَمُرّ عالسوبرماركت وأجيب شوية غراض للبيت.',
        'شغلت السيارة وهيني طالع عالطريق، بشوفك هناك.',
      ],
    }),
  });
}
