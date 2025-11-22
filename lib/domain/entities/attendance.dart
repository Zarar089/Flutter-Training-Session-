class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final double totalHours;
  final String status;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.totalHours,
    required this.status,
  });
}

