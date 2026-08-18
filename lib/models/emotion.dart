import 'package:flutter/material.dart';

/// Represents a single emotion category used in the SER data-collection flow.
enum EmotionType { angry, happy, sad, neutral }

/// Static metadata + Jordanian-dialect prompts for each [EmotionType].
class EmotionData {
  final EmotionType type;
  final String labelArabic;
  final String labelEnglish;
  final String emoji;
  final String apiTag;
  final Color color;
  final Color darkColor;
  final List<String> prompts;

  const EmotionData({
    required this.type,
    required this.labelArabic,
    required this.labelEnglish,
    required this.emoji,
    required this.apiTag,
    required this.color,
    required this.darkColor,
    required this.prompts,
  });

  /// Picks a prompt for a recording session (rotates through the list).
  String promptFor(int index) => prompts[index % prompts.length];

  static const Map<EmotionType, EmotionData> all = {
    EmotionType.angry: EmotionData(
      type: EmotionType.angry,
      labelArabic: 'معصب',
      labelEnglish: 'Angry',
      emoji: '😡',
      apiTag: 'angry',
      color: Color(0xFFEF5350),
      darkColor: Color(0xFFB71C1C),
      prompts: [
        'والله زهقت منك، كم مرة لازم أعيد عليك نفس الحكي؟!',
        'ما بصدق حالي، رجعوا أخروا الطلب بعد ما وعدوني ألف مرة!',
        'هاي مش طريقة، ليش ما حدا رد عليي وأنا مستني من الصبح؟',
        'بجنن والله، كل مرة نفس المشكلة وما حدا بيحلها!',
      ],
    ),
    EmotionType.happy: EmotionData(
      type: EmotionType.happy,
      labelArabic: 'فرحان',
      labelEnglish: 'Happy',
      emoji: '😁',
      apiTag: 'happy',
      color: Color(0xFFFFCA28),
      darkColor: Color(0xFFEF6C00),
      prompts: [
        'يا زلمة مبروك عليك النجاح، والله يستاهل هالفرحة كلها!',
        'ما بصدق إني أخيراً حجزت تذكرة السفر، فرحان مش طبيعي!',
        'اليوم أحلى يوم بحياتي، خطبت حبيبتي وكل الأهل مبسوطين!',
        'يا سلام عليك، جبت العلامة الكاملة، الله يبارك فيك!',
      ],
    ),
    EmotionType.sad: EmotionData(
      type: EmotionType.sad,
      labelArabic: 'زعلان',
      labelEnglish: 'Sad',
      emoji: '😢',
      apiTag: 'sad',
      color: Color(0xFF5C6BC0),
      darkColor: Color(0xFF283593),
      prompts: [
        'ما بعرف ليش بس اليوم قلبي تعبان وحاسس إني وحيد كتير.',
        'اشتقتلك كتير، من يوم ما سافرت البيت مش هو البيت.',
        'تعبت من كل شي، حاسس إني بحاول وما حدا شايف تعبي.',
        'خساره والله، فاتنا القطار وضاع تعبنا كله من غير فايدة.',
      ],
    ),
    EmotionType.neutral: EmotionData(
      type: EmotionType.neutral,
      labelArabic: 'طبيعي',
      labelEnglish: 'Neutral',
      emoji: '😐',
      apiTag: 'neutral',
      color: Color(0xFF78909C),
      darkColor: Color(0xFF37474F),
      prompts: [
        'الجو اليوم معتدل شوي، بكرة إن شاء الله بصير أحسن.',
        'رايح عالدوام الساعة تمانية وبرجع البيت بعد الظهر.',
        'الاجتماع بيبدأ الساعة عشرة وبده يوخذ حوالي ساعة.',
        'لازم أمر عالسوبرماركت وأجيب شوية غراض للبيت.',
      ],
    ),
  };
}
