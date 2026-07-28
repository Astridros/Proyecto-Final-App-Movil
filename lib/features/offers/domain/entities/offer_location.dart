import 'package:equatable/equatable.dart';

class OfferLocation extends Equatable {
  const OfferLocation({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  List<Object?> get props => [lat, lng];
}
