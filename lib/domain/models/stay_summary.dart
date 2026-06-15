class AbsenceAlert {
  const AbsenceAlert({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int days;
}

class AnnualStaySummary {
  const AnnualStaySummary({
    required this.year,
    required this.estimatedStayDays,
    required this.monthlyCounts,
    required this.absenceAlerts,
  });

  final int year;
  final int estimatedStayDays;
  final Map<int, int> monthlyCounts;
  final List<AbsenceAlert> absenceAlerts;
}
