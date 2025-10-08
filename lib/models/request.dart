class Request {
  final String key;
  final String title;
  final String description;
  final DateTime dateTime;
  final String email;
  final String status;

  Request({
    required this.key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.email,
    required this.status,
  });
}
