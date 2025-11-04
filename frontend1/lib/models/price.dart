import 'package:json_annotation/json_annotation.dart';

part 'price.g.dart';

@JsonSerializable()
class Price {
  final String date;
  final String state;
  final String district;
  final String market;
  final String commodity;
  @JsonKey(name: 'min_price')
  final double? minPrice;
  @JsonKey(name: 'max_price')
  final double? maxPrice;
  @JsonKey(name: 'modal_price')
  final double? modalPrice;

  const Price({
    required this.date,
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    this.minPrice,
    this.maxPrice,
    this.modalPrice,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
  Map<String, dynamic> toJson() => _$PriceToJson(this);
}
