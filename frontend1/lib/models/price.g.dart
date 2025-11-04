// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Price _$PriceFromJson(Map<String, dynamic> json) => Price(
  date: json['date'] as String,
  state: json['state'] as String,
  district: json['district'] as String,
  market: json['market'] as String,
  commodity: json['commodity'] as String,
  minPrice: (json['min_price'] as num?)?.toDouble(),
  maxPrice: (json['max_price'] as num?)?.toDouble(),
  modalPrice: (json['modal_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PriceToJson(Price instance) => <String, dynamic>{
  'date': instance.date,
  'state': instance.state,
  'district': instance.district,
  'market': instance.market,
  'commodity': instance.commodity,
  'min_price': instance.minPrice,
  'max_price': instance.maxPrice,
  'modal_price': instance.modalPrice,
};
