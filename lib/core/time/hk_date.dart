DateTime hkToday() {
  // Hong Kong does not observe daylight saving time and uses UTC+8.
  return normalizeDate(DateTime.now().toUtc().add(const Duration(hours: 8)));
}

DateTime normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

List<DateTime> enumerateInclusiveDates(DateTime start, DateTime end) {
  final normalizedStart = normalizeDate(start);
  final normalizedEnd = normalizeDate(end);
  if (normalizedEnd.isBefore(normalizedStart)) {
    return const [];
  }

  final dates = <DateTime>[];
  var current = normalizedStart;
  while (!current.isAfter(normalizedEnd)) {
    dates.add(current);
    current = current.add(const Duration(days: 1));
  }
  return dates;
}

String dateKey(DateTime date) {
  final normalized = normalizeDate(date);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

int inclusiveDateCount(DateTime start, DateTime end) {
  return enumerateInclusiveDates(start, end).length;
}
