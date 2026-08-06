import '../../domain/entities/experience.dart';

class ExperienceModel extends Experience{
  const ExperienceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.jobTypeKey,
    required super.certificateImage,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobTypeKey: json['jobTypeKey'] ?? '',
      certificateImage: json['certificateImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "title": title,
      "description": description,
      "jobTypeKey": jobTypeKey,
      "certificateImage": certificateImage,
    };
  }

  factory ExperienceModel.fromEntity(Experience experience){
    return ExperienceModel(
      id: experience.id,
      title: experience.title,
      description: experience.description,
      jobTypeKey: experience.jobTypeKey,
      certificateImage: experience.certificateImage,
    );
  }
}