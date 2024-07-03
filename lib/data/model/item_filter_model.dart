// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ItemFilterModel {
  final String maxPrice;
  final String minPrice;
  final String categoryId;
  final String postedSince;
  final String city;
  final String state;
  final String country;

  ItemFilterModel(
      {required this.maxPrice,
      required this.minPrice,
      required this.categoryId,
      required this.postedSince,
      required this.city,
      required this.state,
      required this.country,
      });

  ItemFilterModel copyWith(
      {String? maxPrice,
      String? minPrice,
      String? categoryId,
      String? postedSince,
      String? city,
      String? state,
      String? country,
      }) {
    return ItemFilterModel(
        maxPrice: maxPrice ?? this.maxPrice,
        minPrice: minPrice ?? this.minPrice,
        categoryId: categoryId ?? this.categoryId,
        postedSince: postedSince ?? this.postedSince,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'max_price': maxPrice,
      'min_price': minPrice,
      'category_id': categoryId,
      'posted_since': postedSince,
      "city": city,
      "state": state,
      "country": country,
    };
  }

  @override
  String toString() {
    return 'ItemFilterModel(maxPrice: $maxPrice, minPrice: $minPrice, categoryId: $categoryId, postedSince: $postedSince, city: $city,state: $state,country: $country)';
  }

  factory ItemFilterModel.createEmpty() {
    return ItemFilterModel(
        maxPrice: "",
        minPrice: "",
        categoryId: "",
        postedSince: "",
        city: '',
        country: '',
        state: '',
        );
  }

  factory ItemFilterModel.fromMap(Map<String, dynamic> map) {
    return ItemFilterModel(
      city: map['city'].toString(),
      state: map['state'].toString(),
      country: map['country'].toString(),
      maxPrice: map['max_price'].toString(),
      minPrice: map['min_price'].toString(),
      categoryId: map['category_id'].toString(),
      postedSince: map['posted_since'].toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemFilterModel.fromJson(String source) =>
      ItemFilterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant ItemFilterModel other) {
    if (identical(this, other)) return true;

    return other.maxPrice == maxPrice &&
        other.minPrice == minPrice &&
        other.categoryId == categoryId &&
        other.postedSince == postedSince;
  }

  @override
  int get hashCode {
    return maxPrice.hashCode ^
        minPrice.hashCode ^
        categoryId.hashCode ^
        postedSince.hashCode;
  }
}
