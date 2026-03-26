DateTime toEthiopian(DateTime dateTime) {
  return dateTime.toUtc().add(const Duration(hours: 3));
}
