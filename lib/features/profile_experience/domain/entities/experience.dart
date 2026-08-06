class Experience {
  final String id;
  final String title;
  final String description;
  final String jobTypeKey;
  final String certificateImage;

  const Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.jobTypeKey,
    required this.certificateImage,
  });

  Experience copyWith({
    String? id,
    String? title,
    String? description,
    String? jobTypeKey,
    String? certificateImage,
  }) {
    return Experience(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      jobTypeKey: jobTypeKey ?? this.jobTypeKey,
      certificateImage: certificateImage ?? this.certificateImage,
    );
  }
}