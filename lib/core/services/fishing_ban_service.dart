class FishingBanService {
  static bool isBanActive() {
    DateTime startDate = DateTime(DateTime.now().year, 4, 15);
    DateTime endDate = DateTime(DateTime.now().year, 7, 15);
    DateTime now = DateTime.now();

    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  static BanStatus getBanStatus() {
    DateTime startDate = DateTime(DateTime.now().year, 4, 15);
    DateTime endDate = DateTime(DateTime.now().year, 5, 15);
    DateTime now = DateTime.now();

    int remainingDays = 0;
    int totalDays = endDate.difference(startDate).inDays;
    double progress = 0.0;
    bool isBanActive = false;

    if (now.isBefore(startDate)) {
      remainingDays = startDate.difference(now).inDays;
      progress = 0.0;
      isBanActive = false;
    } else if (now.isAfter(endDate)) {
      remainingDays = 0;
      progress = 1.0;
      isBanActive = false;
    } else {
      remainingDays = endDate.difference(now).inDays;
      progress = (totalDays - remainingDays) / totalDays;
      isBanActive = true;
    }

    return BanStatus(
      isActive: isBanActive,
      remainingDays: remainingDays,
      totalDays: totalDays,
      progress: progress,
    );
  }
}

class BanStatus {
  final bool isActive;
  final int remainingDays;
  final int totalDays;
  final double progress;

  const BanStatus({
    required this.isActive,
    required this.remainingDays,
    required this.totalDays,
    required this.progress,
  });
}
