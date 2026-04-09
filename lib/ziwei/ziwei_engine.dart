import 'package:dart_iztro/crape_myrtle/translations/types/mutagen.dart';
import 'package:dart_iztro/dart_iztro.dart';
import 'package:get/get.dart';
import 'package:lunar/calendar/LunarMonth.dart';
import 'package:lunar/calendar/LunarYear.dart';

import 'ziwei_models.dart';

class ZiweiEngine {
  static const int minSupportedYear = 1900;
  static const int maxSupportedYear = 2100;
  static const int defaultVisibleYear = 2000;
  static const List<String> _mutagenLabels = ['禄', '权', '科', '忌'];

  static const List<ZiweiTimeOption> timeOptions = [
    ZiweiTimeOption(index: 0, label: '早子时', range: '00:00-01:00'),
    ZiweiTimeOption(index: 1, label: '丑时', range: '01:00-03:00'),
    ZiweiTimeOption(index: 2, label: '寅时', range: '03:00-05:00'),
    ZiweiTimeOption(index: 3, label: '卯时', range: '05:00-07:00'),
    ZiweiTimeOption(index: 4, label: '辰时', range: '07:00-09:00'),
    ZiweiTimeOption(index: 5, label: '巳时', range: '09:00-11:00'),
    ZiweiTimeOption(index: 6, label: '午时', range: '11:00-13:00'),
    ZiweiTimeOption(index: 7, label: '未时', range: '13:00-15:00'),
    ZiweiTimeOption(index: 8, label: '申时', range: '15:00-17:00'),
    ZiweiTimeOption(index: 9, label: '酉时', range: '17:00-19:00'),
    ZiweiTimeOption(index: 10, label: '戌时', range: '19:00-21:00'),
    ZiweiTimeOption(index: 11, label: '亥时', range: '21:00-23:00'),
    ZiweiTimeOption(index: 12, label: '晚子时', range: '23:00-00:00'),
  ];

  static bool _translationsReady = false;

  static void ensureInitialized() {
    if (_translationsReady) {
      return;
    }
    IztroTranslationService.init(initialLocale: 'zh_CN');
    Get.addTranslations(IztroTranslationService.withAppTranslations().keys);
    _translationsReady = true;
  }

  static ZiweiBirthInput defaultInput() {
    ensureInitialized();
    final now = DateTime.now();
    final lunar = solar2Lunar(_formatDate(now));
    return ZiweiBirthInput(
      lunarYear: lunar.lunarYear,
      lunarMonth: lunar.lunarMonth,
      lunarDay: lunar.lunarDay,
      timeIndex: timeToIndex(now.hour),
      gender: ZiweiGender.male,
      isLeapMonth: lunar.isLeap,
    );
  }

  static List<int> yearOptions() {
    return List<int>.generate(
      maxSupportedYear - minSupportedYear + 1,
      (index) => minSupportedYear + index,
    );
  }

  static int leapMonthOfYear(int lunarYear) {
    return LunarYear.fromYear(lunarYear).getLeapMonth();
  }

  static bool canUseLeapMonth(int lunarYear, int lunarMonth) {
    return leapMonthOfYear(lunarYear) == lunarMonth;
  }

  static int daysInMonth({
    required int lunarYear,
    required int lunarMonth,
    required bool isLeapMonth,
  }) {
    final actualMonth = isLeapMonth ? -lunarMonth : lunarMonth;
    final month = LunarMonth.fromYm(lunarYear, actualMonth);
    return month?.getDayCount() ?? 29;
  }

  static ZiweiBirthInput normalizeInput(ZiweiBirthInput input) {
    final leapEnabled = canUseLeapMonth(input.lunarYear, input.lunarMonth)
        ? input.isLeapMonth
        : false;
    final maxDay = daysInMonth(
      lunarYear: input.lunarYear,
      lunarMonth: input.lunarMonth,
      isLeapMonth: leapEnabled,
    );
    return input.copyWith(
      isLeapMonth: leapEnabled,
      lunarDay: input.lunarDay.clamp(1, maxDay),
    );
  }

  static FunctionalAstrolabe buildChart(ZiweiBirthInput input) {
    ensureInitialized();
    final normalized = normalizeInput(input);
    return byLunar(
      '${normalized.lunarYear}-${normalized.lunarMonth.toString().padLeft(2, '0')}-${normalized.lunarDay.toString().padLeft(2, '0')}',
      normalized.timeIndex,
      normalized.gender == ZiweiGender.male
          ? GenderName.male
          : GenderName.female,
      normalized.isLeapMonth,
    );
  }

  static IFunctionalHoroscpoe buildHoroscope(
    FunctionalAstrolabe chart,
    DateTime referenceDateTime,
  ) {
    ensureInitialized();
    return chart.horoscope(
      date: _formatDate(referenceDateTime),
      timeIndex: timeToIndex(referenceDateTime.hour),
    );
  }

  static SolarDate solarDateFrom(ZiweiBirthInput input) {
    final normalized = normalizeInput(input);
    return lunar2Solar(
      '${normalized.lunarYear}-${normalized.lunarMonth.toString().padLeft(2, '0')}-${normalized.lunarDay.toString().padLeft(2, '0')}',
      normalized.isLeapMonth,
    );
  }

  static String formatSolarDate(SolarDate solarDate) => solarDate.toString();

  static String formatReferenceDate(DateTime dateTime) => _formatDate(dateTime);

  static String formatReferenceTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String stemBranchOf(IFunctionalPalace palace) {
    return '${palace.heavenlySten.title}${palace.earthlyBranch.title}';
  }

  static String timeLabelOf(int timeIndex) {
    return timeOptions.firstWhere((item) => item.index == timeIndex).label;
  }

  static String timeRangeOf(int timeIndex) {
    return timeOptions.firstWhere((item) => item.index == timeIndex).range;
  }

  static String starLabel(
    IFunctionalStar star, {
    bool includeBrightness = false,
    bool includeMutagen = true,
  }) {
    final buffer = StringBuffer(star.name.title);
    if (includeMutagen && star.mutagen != null) {
      buffer.write('[${mutagenTitle(star.mutagen)}]');
    }
    if (includeBrightness && star.brightness != null) {
      buffer.write('(${star.brightness!.title})');
    }
    return buffer.toString();
  }

  static List<String> starLabels(
    Iterable<IFunctionalStar> stars, {
    bool includeBrightness = false,
    bool includeMutagen = true,
  }) {
    return stars
        .map(
          (star) => starLabel(
            star,
            includeBrightness: includeBrightness,
            includeMutagen: includeMutagen,
          ),
        )
        .toList(growable: false);
  }

  static List<IFunctionalStar> allStars(IFunctionalPalace palace) {
    return [
      ...palace.majorStars,
      ...palace.minorStars,
      ...palace.adjectiveStars,
    ];
  }

  static List<IFunctionalStar> mutagenStars(IFunctionalPalace palace) {
    return allStars(palace).where((star) => star.mutagen != null).toList();
  }

  static List<int> surroundedIndexes(
    FunctionalAstrolabe chart,
    int palaceIndex,
  ) {
    final surrounded = chart.surroundedPalaces(palaceIndex);
    return [
      surrounded.target.index,
      surrounded.opposite.index,
      surrounded.wealth.index,
      surrounded.career.index,
    ];
  }

  static List<ZiweiFlyTarget> flyTargetsOf(IFunctionalPalace palace) {
    final targets = palace.mutagedPalaces() ?? const [];
    return List<ZiweiFlyTarget>.generate(_mutagenLabels.length, (index) {
      final target = index < targets.length ? targets[index] : null;
      return ZiweiFlyTarget(
        label: _mutagenLabels[index],
        targetIndex: target?.index,
        targetName: target?.name.title ?? '未落宫',
        isSelf: target?.index == palace.index,
      );
    });
  }

  static List<ZiweiMutagenSummary> collectMutagenSummaries(
    FunctionalAstrolabe chart,
  ) {
    final result = <ZiweiMutagenSummary>[];
    for (final palace in chart.palaces) {
      for (final star in mutagenStars(palace)) {
        final mutagen = star.mutagen;
        if (mutagen == null) {
          continue;
        }
        result.add(
          ZiweiMutagenSummary(
            label: _mutagenLabel(mutagen),
            starName: star.name.title,
            palaceName: palace.name.title,
            palaceIndex: palace.index,
          ),
        );
      }
    }
    result.sort((left, right) {
      return _mutagenLabels
          .indexOf(left.label)
          .compareTo(_mutagenLabels.indexOf(right.label));
    });
    return result;
  }

  static Map<int, List<String>> flyTargetLabels(IFunctionalPalace palace) {
    final result = <int, List<String>>{};
    for (final item in flyTargetsOf(palace)) {
      final targetIndex = item.targetIndex;
      if (targetIndex == null) {
        continue;
      }
      result.putIfAbsent(targetIndex, () => <String>[]).add(item.label);
    }
    return result;
  }

  static List<IFunctionalStar> horoscopeStarsAt(
    HoroscopeItem item,
    int palaceIndex,
  ) {
    final stars = item.stars;
    if (stars == null || palaceIndex < 0 || palaceIndex >= stars.length) {
      return const [];
    }
    return stars[palaceIndex];
  }

  static IFunctionalPalace? agePalaceFor(
    IFunctionalHoroscpoe horoscope,
    PalaceName palaceName,
  ) {
    final palaceIndex = horoscope.age.palaceNames.indexOf(palaceName);
    if (palaceIndex < 0) {
      return null;
    }
    return horoscope.astrolabe.palace(palaceIndex);
  }

  static String scopePalaceTitleAt(
    ZiweiDisplayScope scope,
    IFunctionalHoroscpoe horoscope,
    int palaceIndex,
  ) {
    switch (scope) {
      case ZiweiDisplayScope.origin:
        return horoscope.astrolabe.palace(palaceIndex)?.name.title ?? '-';
      case ZiweiDisplayScope.decadal:
        return horoscope.decadal.palaceNames[palaceIndex].title;
      case ZiweiDisplayScope.age:
        return horoscope.age.palaceNames[palaceIndex].title;
      case ZiweiDisplayScope.yearly:
        return horoscope.yearly.palaceNames[palaceIndex].title;
      case ZiweiDisplayScope.monthly:
        return horoscope.monthly.palaceNames[palaceIndex].title;
      case ZiweiDisplayScope.daily:
        return horoscope.daily.palaceNames[palaceIndex].title;
      case ZiweiDisplayScope.hourly:
        return horoscope.hourly.palaceNames[palaceIndex].title;
    }
  }

  static IFunctionalPalace? mappedPalaceForScope(
    ZiweiDisplayScope scope,
    IFunctionalHoroscpoe horoscope,
    PalaceName palaceName,
  ) {
    switch (scope) {
      case ZiweiDisplayScope.origin:
        return horoscope.astrolabe.palace(palaceName);
      case ZiweiDisplayScope.decadal:
        return horoscope.palace(palaceName, Scope.decadal);
      case ZiweiDisplayScope.age:
        return agePalaceFor(horoscope, palaceName);
      case ZiweiDisplayScope.yearly:
        return horoscope.palace(palaceName, Scope.yearly);
      case ZiweiDisplayScope.monthly:
        return horoscope.palace(palaceName, Scope.monthly);
      case ZiweiDisplayScope.daily:
        return horoscope.palace(palaceName, Scope.daily);
      case ZiweiDisplayScope.hourly:
        return horoscope.palace(palaceName, Scope.hourly);
    }
  }

  static List<String> flowStarLabelsAt(
    ZiweiDisplayScope scope,
    IFunctionalHoroscpoe horoscope,
    int palaceIndex,
  ) {
    switch (scope) {
      case ZiweiDisplayScope.origin:
      case ZiweiDisplayScope.age:
        return const [];
      case ZiweiDisplayScope.decadal:
        return starLabels(horoscopeStarsAt(horoscope.decadal, palaceIndex));
      case ZiweiDisplayScope.yearly:
        return starLabels(horoscopeStarsAt(horoscope.yearly, palaceIndex));
      case ZiweiDisplayScope.monthly:
        return starLabels(horoscopeStarsAt(horoscope.monthly, palaceIndex));
      case ZiweiDisplayScope.daily:
        return starLabels(horoscopeStarsAt(horoscope.daily, palaceIndex));
      case ZiweiDisplayScope.hourly:
        return starLabels(horoscopeStarsAt(horoscope.hourly, palaceIndex));
    }
  }

  static String scopeMutagenText(
    ZiweiDisplayScope scope,
    IFunctionalHoroscpoe horoscope,
  ) {
    switch (scope) {
      case ZiweiDisplayScope.origin:
        return '本命以生年四化为主';
      case ZiweiDisplayScope.age:
        return mutagenAssignmentText(horoscope.age.mutagen);
      case ZiweiDisplayScope.decadal:
        return mutagenAssignmentText(horoscope.decadal.mutagen);
      case ZiweiDisplayScope.yearly:
        return mutagenAssignmentText(horoscope.yearly.mutagen);
      case ZiweiDisplayScope.monthly:
        return mutagenAssignmentText(horoscope.monthly.mutagen);
      case ZiweiDisplayScope.daily:
        return mutagenAssignmentText(horoscope.daily.mutagen);
      case ZiweiDisplayScope.hourly:
        return mutagenAssignmentText(horoscope.hourly.mutagen);
    }
  }

  static String mutagenAssignmentText(List<StarName> stars) {
    if (stars.isEmpty) {
      return '无四化';
    }
    final labels = <String>[];
    for (
      var index = 0;
      index < stars.length && index < _mutagenLabels.length;
      index++
    ) {
      labels.add('化${_mutagenLabels[index]} ${stars[index].title}');
    }
    return labels.join(' · ');
  }

  static String palaceFlagsText(IFunctionalPalace palace) {
    final flags = <String>[];
    if (palace.isBodyPalace) {
      flags.add('身宫');
    }
    if (palace.isOriginalPalace) {
      flags.add('来因宫');
    }
    flags.addAll(palaceShenshaLabels(palace));
    return flags.join(' · ');
  }

  static String majorStarsText(IFunctionalPalace palace) {
    if (palace.majorStars.isEmpty) {
      return '空宫';
    }
    return palace.majorStars.map((star) => star.name.title).join(' · ');
  }

  static String supportStarsText(IFunctionalPalace palace) {
    final minor = palace.minorStars.map((star) => star.name.title);
    final adjective = palace.adjectiveStars.map((star) => star.name.title);
    final items = [...minor, ...adjective].take(6).toList();
    return items.isEmpty ? '无辅杂曜摘要' : items.join(' · ');
  }

  static String denseSupportStarsText(IFunctionalPalace palace) {
    final items = [
      ...palace.minorStars.map((star) => star.name.title),
      ...palace.adjectiveStars.map((star) => star.name.title),
    ];
    return items.isEmpty ? '无辅杂曜' : items.join(' · ');
  }

  static List<String> palaceShenshaLabels(IFunctionalPalace palace) {
    final labels = <String>[];
    for (final item in [
      palace.changShen12.title,
      palace.boShi12.title,
      palace.jiangQian12.title,
      palace.suiQian12.title,
    ]) {
      if (item.isNotEmpty && !labels.contains(item)) {
        labels.add(item);
      }
    }
    return labels;
  }

  static String palaceShenshaText(IFunctionalPalace palace) {
    final labels = palaceShenshaLabels(palace);
    return labels.isEmpty ? '无神煞摘要' : labels.join(' · ');
  }

  static String inlineMajorStarsText(IFunctionalPalace palace) {
    if (palace.majorStars.isEmpty) {
      return '空宫';
    }
    return _inlineJoin(palace.majorStars.map((star) => star.name.title));
  }

  static String inlineMajorBrightnessText(IFunctionalPalace palace) {
    return _inlineJoin(
      palace.majorStars.map((star) => star.brightness?.title ?? ''),
    );
  }

  static String inlineSupportStarsText(IFunctionalPalace palace) {
    return _inlineJoin([
      ...palace.minorStars.map((star) => star.name.title),
      ...palace.adjectiveStars.map((star) => star.name.title),
    ]);
  }

  static String inlineShenshaText(IFunctionalPalace palace) {
    return _inlineJoin([
      palace.boShi12.title,
      palace.jiangQian12.title,
      palace.suiQian12.title,
    ]);
  }

  static String decadalRangeText(IFunctionalPalace palace) {
    final range = palace.decadal.range;
    if (range.isEmpty) {
      return '-';
    }
    return '${range.first}~${range.last}';
  }

  static String yearlySequenceText(
    IFunctionalPalace palace, {
    int maxItems = 6,
  }) {
    return _sequenceText(palace.yearlies, maxItems: maxItems);
  }

  static String ageSequenceText(IFunctionalPalace palace, {int maxItems = 6}) {
    return _sequenceText(palace.ages, maxItems: maxItems);
  }

  static String fullStarsText(IFunctionalPalace palace) {
    return starLabels(
      allStars(palace),
      includeBrightness: true,
      includeMutagen: true,
    ).join('、');
  }

  static String mutagenTitle(Mutagen? mutagen) {
    switch (mutagen) {
      case Mutagen.siHuaLu:
        return '禄';
      case Mutagen.siHuaQuan:
        return '权';
      case Mutagen.siHuaKe:
        return '科';
      case Mutagen.siHuaJi:
        return '忌';
      case null:
        return '';
    }
  }

  static String _mutagenLabel(Mutagen mutagen) {
    switch (mutagen) {
      case Mutagen.siHuaLu:
        return '禄';
      case Mutagen.siHuaQuan:
        return '权';
      case Mutagen.siHuaKe:
        return '科';
      case Mutagen.siHuaJi:
        return '忌';
    }
  }

  static String _formatDate(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _sequenceText(Iterable<int> items, {required int maxItems}) {
    return items.take(maxItems).join(',');
  }

  static String _inlineJoin(Iterable<String> items) {
    final labels = items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    return labels.isEmpty ? '' : labels.join(' ');
  }
}
