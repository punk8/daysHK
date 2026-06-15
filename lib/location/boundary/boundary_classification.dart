enum BoundaryClassification {
  insideHk('在香港'),
  outsideHk('不在香港'),
  nearBoundaryNeedsConfirmation('边界附近，需确认'),
  unknown('无法判断');

  const BoundaryClassification(this.label);

  final String label;
}

class BoundaryResult {
  const BoundaryResult({
    required this.classification,
    this.distanceToBoundaryMeters,
  });

  final BoundaryClassification classification;
  final double? distanceToBoundaryMeters;

  bool get needsConfirmation =>
      classification == BoundaryClassification.nearBoundaryNeedsConfirmation;
}
