import 'package:equatable/equatable.dart';

class OfferLikeResult extends Equatable {
  const OfferLikeResult({required this.liked, required this.likesCount});

  final bool liked;
  final int likesCount;

  @override
  List<Object?> get props => [liked, likesCount];
}
