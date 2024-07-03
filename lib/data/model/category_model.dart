// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:eClassify/Utils/api.dart';

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String url;
  final List<CategoryModel> children;
  final String description;
  final int? subcategoriesCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.children,
    this.subcategoriesCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> childData = json['subcategories'] ?? [];
      List<CategoryModel> children =
          childData.map((child) => CategoryModel.fromJson(child)).toList();

      return CategoryModel(
          id: json['id'],
          name: json['name'],
          url: json['image'],
          subcategoriesCount: json['subcategories_count'],
          children: children,
          description: json['description'] ?? "");
    } catch (e, st) {

      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'image': url,
      'subcategories_count': subcategoriesCount,
      "description": description,
      'subcategories': children.map((child) => child.toJson()).toList(),
    };
    return data;
  }

  @override
  String toString() {
    return 'CategoryModel( id: $id, name: $name, url: $url, descrtiption:$description, children: $children,subcategories_count:$subcategoriesCount)';
  }
}
