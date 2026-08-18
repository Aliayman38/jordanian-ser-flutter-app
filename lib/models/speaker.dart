/// Speaker gender, used to build the `speaker_id` sent to the backend.
enum Gender { male, female }

extension GenderX on Gender {
  String get label => this == Gender.male ? 'ذكر' : 'أنثى';
  String get apiValue => this == Gender.male ? 'male' : 'female';
}
