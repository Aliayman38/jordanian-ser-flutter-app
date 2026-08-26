import 'package:flutter/material.dart';

/// Represents a single emotion category used in the SER data-collection flow.
enum EmotionType { angry, happy, sad, neutral }

/// Static metadata + authentic Jordanian-dialect prompts for each [EmotionType].
class EmotionData {
  final EmotionType type;
  final String labelArabic;
  final String labelEnglish;
  final String subtitleArabic;
  final String emoji;
  final String apiTag;
  final Color color;
  final Color darkColor;
  final Color accentColor;
  final List<String> prompts;

  const EmotionData({
    required this.type,
    required this.labelArabic,
    required this.labelEnglish,
    required this.subtitleArabic,
    required this.emoji,
    required this.apiTag,
    required this.color,
    required this.darkColor,
    required this.accentColor,
    required this.prompts,
  });

  /// Picks a prompt for a recording session (rotates through the list).
  String promptFor(int index) => prompts[index % prompts.length];

  static const Map<EmotionType, EmotionData> all = {
    EmotionType.angry: EmotionData(
      type: EmotionType.angry,
      labelArabic: 'معصب',
      labelEnglish: 'Angry',
      subtitleArabic: 'نبرة حادة وغاضبة',
      emoji: '😡',
      apiTag: 'angry',
      color: Color(0xFFE63946),
      darkColor: Color(0xFF9D0208),
      accentColor: Color(0xFFFF758F),
      prompts: [
        'والله زهقت منك، كم مرة لازم أعيد عليك نفس الحكي؟!',
        'ما بصدق حالي، رجعوا أخروا الطلب بعد ما وعدوني ألف مرة!',
        'هاي مش طريقة، ليش ما حدا رد عليي وأنا مستني من الصبح؟',
        'بجنن والله، كل مرة نفس المشكلة وما حدا بيحلها!',
        'ولا كلمة زيادة! أنا حكيت اللي عندي وخلاص!',
        'إنت ليش دايماً بتعمل عكس اللي بنتفق عليه بالضبط؟!',
      ],
    ),
    EmotionType.happy: EmotionData(
      type: EmotionType.happy,
      labelArabic: 'فرحان',
      labelEnglish: 'Happy',
      subtitleArabic: 'طاقة وبهجة وضحكة',
      emoji: '😁',
      apiTag: 'happy',
      color: Color(0xFFFFB703),
      darkColor: Color(0xFFFB8500),
      accentColor: Color(0xFFFFE3A8),
      prompts: [
        'يا زلمة مبروك عليك النجاح، والله بتستاهل هالفرحة كلها!',
        'ما بصدق إني أخيراً حجزت تذكرة السفر، فرحان مش طبيعي!',
        'اليوم أحلى يوم بحياتي، خطبت حبيبتي وكل الأهل مبسوطين!',
        'يا سلام عليك، جبت العلامة الكاملة، الله يبارك فيك!',
        'يسعد قلبك يا خوي، ما قصرت وبيضت وجوهنا!',
        'أخيراً خلصنا المشروع وسلمناه على أحسن وجه، الحمد لله!',
      ],
    ),
    EmotionType.sad: EmotionData(
      type: EmotionType.sad,
      labelArabic: 'زعلان',
      labelEnglish: 'Sad',
      subtitleArabic: 'حزن وشوق ونبرة هادية',
      emoji: '😢',
      apiTag: 'sad',
      color: Color(0xFF4361EE),
      darkColor: Color(0xFF1E2E7B),
      accentColor: Color(0xFFA5C4D4),
      prompts: [
        'ما بعرف ليش بس اليوم قلبي تعبان وحاسس إني وحيد كتير.',
        'اشتقتلك كتير، من يوم ما سافرت البيت مش هو البيت.',
        'تعبت من كل شي، حاسس إني بحاول وما حدا شايف تعبي.',
        'خسارة والله، فاتنا القطار وضاع تعبنا كله من غير فايدة.',
        'ياريت لو الأيام بترجع لورا ونصلح اللي صار بيناتنا.',
      ],
    ),
    EmotionType.neutral: EmotionData(
      type: EmotionType.neutral,
      labelArabic: 'طبيعي',
      labelEnglish: 'Neutral',
      subtitleArabic: 'كلام يومي هادئ وعادي',
      emoji: '😐',
      apiTag: 'neutral',
      color: Color(0xFF4A6572),
      darkColor: Color(0xFF232F34),
      accentColor: Color(0xFF90A4AE),
      prompts: [
        'الجو اليوم معتدل شوي، بكرة إن شاء الله بصير أحسن.',
        'رايح عالدوام الساعة تمانية وبرجع البيت بعد الظهر.',
        'الاجتماع بيبدأ الساعة عشرة وبده يوخذ حوالي ساعة.',
        'لازم أَمُرّ عالسوبرماركت وأجيب شوية غراض للبيت.',
        'شغلت السيارة وهيني طالع عالطريق، بشوفك هناك.',
      ],
    ),
  };
}
