import 'package:equatable/equatable.dart';

class ApplyOfferResult extends Equatable {
  const ApplyOfferResult({required this.id, required this.status});

  final String id;
  final String status;

  @override
  List<Object?> get props => [id, status];
}
