class JobApplication {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final String jobLink;
  final DateTime createdAt;
  final String applicationStatus;

  JobApplication({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.jobLink,
    required this.createdAt,
    required this.applicationStatus,
});

}