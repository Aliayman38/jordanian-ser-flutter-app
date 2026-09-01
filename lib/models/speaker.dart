export const Gender = Object.freeze({
  male: 'male',
  female: 'female',
});

export const GenderX = {
  label(gender) {
    return gender === Gender.male ? 'شاب' : 'صبية';
  },
  formalLabel(gender) {
    return gender === Gender.male ? 'ذكر' : 'أنثى';
  },
  description(gender) {
    return gender === Gender.male ? 'صوت رجالي' : 'صوت نسائي';
  },
  icon(gender) {
    return gender === Gender.male ? 'male' : 'female';
  },
  apiValue(gender) {
    return gender === Gender.male ? 'male' : 'female';
  },
};
