import 'package:flutter/material.dart';

/// Speaker gender, used to build the `speaker_id` sent to the backend.
enum Gender { male, female }

extension GenderX on Gender {
  String get label => this == Gender.male ? 'شاب' : 'صبية';
  String get formalLabel => this == Gender.male ? 'ذكر' : 'أنثى';
  String get description => this == Gender.male ? 'صوت رجالي' : 'صوت نسائي';
  IconData get icon => this == Gender.male ? Icons.male_rounded : Icons.female_rounded;
  String get apiValue => this == Gender.male ? 'male' : 'female';
}
