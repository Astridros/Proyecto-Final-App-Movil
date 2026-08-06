import '../../domain/entities/experience.dart';

class ExperienceModel extends Experience{
  const ExperienceModel({
    required super.title,
    required super.description,
    required super.jobTypeKey,
    required super.certificateImage,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json){
    return ExperienceModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      jobTypeKey: json['jobTypeKey'] as String? ?? '',
      certificateImage: json['certificateImage'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'title': title,
      'description': description,
      'jobTypeKey': jobTypeKey,
      'certificateImage': certificateImage,
    };
  }

  factory ExperienceModel.fromEntity(Experience experience){
    return ExperienceModel(
      title: experience.title,
      description: experience.description,
      jobTypeKey: experience.jobTypeKey,
      certificateImage: experience.certificateImage,
    );
  }
}