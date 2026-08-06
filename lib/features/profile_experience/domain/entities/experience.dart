import 'package:equatable/equatable.dart';

class Experience extends Equatable {
  const Experience({
    required this.title,
    required this.description,
    required this.jobTypeKey,
    required this.certificateImage,
  });

  final String title;
  final String description;
  final String jobTypeKey;
  final String certificateImage;

  Experience copyWith({
    String? title,
    String? description,
    String? jobTypeKey,
    String? certificateImage,
  }){
    return Experience(
      title: title ?? this.title,
      description: description ?? this.description,
      jobTypeKey: jobTypeKey ?? this.jobTypeKey,
      certificateImage: certificateImage ?? this.certificateImage,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    jobTypeKey,
    certificateImage,
  ];
}