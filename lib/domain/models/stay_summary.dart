class AnnualStaySummary {
  const AnnualStaySummary({
    required this.year,
    required this.estimatedStayDays,
    required this.monthlyCounts,
  });

  final int year;
  final int estimatedStayDays;
  final Map<int, int> monthlyCounts;
}
