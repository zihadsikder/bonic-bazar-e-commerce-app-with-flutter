import 'package:eClassify/data/model/category_model.dart';

import '../CustomField/custom_field_model.dart';

class ItemModel {
  int? id;
  String? name;
  String? description;
  int? price;
  String? image;
  dynamic watermarkimage;
  double? latitude;
  double? longitude;
  String? address;
  String? contact;
  int? totalLikes;
  int? views;
  String? type;
  String? status;
  bool? active;
  String? videoLink;
  User? user;
  List<GalleryImages>? galleryImages;
  List<ItemOffers>? itemOffers;
  CategoryModel? category;
  List<CustomFieldModel>? customFields;
  bool? isLike;
  bool? isFeature;
  String? created;
  String? itemType;
  int? userId;
  int? categoryId;
  bool? isAlreadyOffered;
  String? allCategoryIds;

  ItemModel(
      {this.id,
      this.name,
      this.category,
      this.description,
      this.price,
      this.image,
      this.watermarkimage,
      this.latitude,
      this.longitude,
      this.address,
      this.contact,
      this.type,
      this.status,
      this.active,
      this.totalLikes,
      this.views,
      this.videoLink,
      this.user,
      this.galleryImages,
      this.itemOffers,
      this.customFields,
      this.isLike,
      this.isFeature,
      this.created,
      this.itemType,
      this.userId,
      this.categoryId,
      this.isAlreadyOffered,
      this.allCategoryIds});

  ItemModel copyWith(
      {int? id,
      String? name,
      String? description,
      int? price,
      String? image,
      dynamic watermarkimage,
      double? latitude,
      double? longitude,
      String? address,
      String? contact,
      int? totalLikes,
      int? views,
      String? type,
      String? status,
      bool? active,
      String? videoLink,
      User? user,
      List<GalleryImages>? galleryImages,
      List<ItemOffers>? itemOffers,
      CategoryModel? category,
      List<CustomFieldModel>? customFields,
      bool? isLike,
      bool? isFeature,
      String? created,
      String? itemType,
      int? userId,
      bool? isAlreadyOffered,
      String? allCategoryId,
      int? categoryId}) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      watermarkimage: watermarkimage ?? this.watermarkimage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      type: type ?? this.type,
      status: status ?? this.status,
      active: active ?? this.active,
      totalLikes: totalLikes ?? this.totalLikes,
      views: views ?? this.views,
      videoLink: videoLink ?? this.videoLink,
      user: user ?? this.user,
      galleryImages: galleryImages ?? this.galleryImages,
      itemOffers: itemOffers ?? this.itemOffers,
      customFields: customFields ?? this.customFields,
      isLike: isLike ?? this.isLike,
      isFeature: isFeature ?? this.isFeature,
      created: created ?? this.created,
      itemType: itemType ?? this.itemType,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      isAlreadyOffered: isAlreadyOffered ?? this.isAlreadyOffered,
      allCategoryIds: allCategoryIds ?? this.allCategoryIds,
    );
  }

  ItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'] != null
        ? CategoryModel.fromJson(json['category'])
        : null;
    totalLikes = json['total_likes'];
    views = json['clicks'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
    watermarkimage = json['watermarkimage'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    contact = json['contact'];
    type = json['type'];
    status = json['status'];
    active = json['active'] == 0 ? false : true;
    videoLink = json['video_link'];
    isLike = json['is_liked'];
    isFeature = json['is_feature'];
    created = json['created_at'];
    itemType = json['item_type'];
    userId = json['user_id'];
    categoryId = json['category_id'];
    isAlreadyOffered = json['is_already_offered'];
    allCategoryIds = json['all_category_ids'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['gallery_images'] != null) {
      galleryImages = <GalleryImages>[];
      json['gallery_images'].forEach((v) {
        galleryImages!.add(GalleryImages.fromJson(v));
      });
    }
    if (json['item_offers'] != null) {
      itemOffers = <ItemOffers>[];
      json['item_offers'].forEach((v) {
        itemOffers!.add(ItemOffers.fromJson(v));
      });
    }
    if (json['custom_fields'] != null) {
      customFields = <CustomFieldModel>[];
      json['custom_fields'].forEach((v) {
        customFields!.add(CustomFieldModel.fromMap(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['total_likes'] = totalLikes;
    data['clicks'] = views;
    data['image'] = image;
    data['watermarkimage'] = watermarkimage;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;
    data['contact'] = contact;
    data['type'] = type;
    data['status'] = status;
    data['active'] = active;
    data['video_link'] = videoLink;
    data['is_liked'] = isLike;
    data['is_feature'] = isFeature;
    data['created_at'] = created;
    data['item_type'] = itemType;
    data['user_id'] = userId;
    data['category_id'] = categoryId;
    data['is_already_offered'] = isAlreadyOffered;
    data['all_category_ids'] = allCategoryIds;
    data['category'] = category!.toJson();
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (galleryImages != null) {
      data['gallery_images'] = galleryImages!.map((v) => v.toJson()).toList();
    }
    if (itemOffers != null) {
      data['item_offers'] = itemOffers!.map((v) => v.toJson()).toList();
    }
    if (customFields != null) {
      data['custom_fields'] = customFields!.map((v) => v.toMap()).toList();
    }
    return data;
  }

  @override
  String toString() {
    return 'ItemModel{id: $id, name: $name, description: $description, price: $price, image: $image, watermarkimage: $watermarkimage, latitude: $latitude, longitude: $longitude, address: $address, contact: $contact, total_likes: $totalLikes,isLiked: $isLike, isFeature: $isFeature,views: $views, type: $type, status: $status, active: $active, videoLink: $videoLink, user: $user, galleryImages: $galleryImages,itemOffers:$itemOffers, category: $category, customFields: $customFields,createdAt:$created,itemType:$itemType,userId:$userId,categoryId:$categoryId,isAlreadyOffered:$isAlreadyOffered,allCategoryId:$allCategoryIds}';
  }
}

class User {
  int? id;
  String? name;
  String? mobile;
  String? email;
  String? type;
  String? profile;
  String? fcmId;
  String? firebaseId;
  int? status;
  String? apiToken;
  dynamic address;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.name,
      this.mobile,
      this.email,
      this.type,
      this.profile,
      this.fcmId,
      this.firebaseId,
      this.status,
      this.apiToken,
      this.address,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
    email = json['email'];
    type = json['type'];
    profile = json['profile'];
    fcmId = json['fcm_id'];
    firebaseId = json['firebase_id'];
    status = json['status'];
    apiToken = json['api_token'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;
    data['email'] = email;
    data['type'] = type;
    data['profile'] = profile;
    data['fcm_id'] = fcmId;
    data['firebase_id'] = firebaseId;
    data['status'] = status;
    data['api_token'] = apiToken;
    data['address'] = address;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class GalleryImages {
  int? id;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? itemId;

  GalleryImages(
      {this.id, this.image, this.createdAt, this.updatedAt, this.itemId});

  GalleryImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemId = json['item_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_id'] = itemId;
    return data;
  }
}

class ItemOffers {
  int? id;
  int? sellerId;
  int? buyerId;
  String? createdAt;
  String? updatedAt;
  int? amount;

  ItemOffers(
      {this.id,
      this.sellerId,
      this.createdAt,
      this.updatedAt,
      this.buyerId,
      this.amount});

  ItemOffers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buyerId = json['buyer_id'];
    sellerId = json['seller_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['buyer_id'] = buyerId;
    data['seller_id'] = sellerId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['amount'] = amount;
    return data;
  }
}

/*class ItemCategory {
  int? id;
  int? sequence;
  String? name;
  String? image;
  int? parentCategoryId;
  String? description;
  int? status;
  String? createdAt;
  String? updatedAt;

  ItemCategory(
      {this.id,
      this.sequence,
      this.name,
      this.image,
      this.parentCategoryId,
      this.description,
      this.status,
      this.createdAt,
      this.updatedAt});

  ItemCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequence = json['sequence'];
    name = json['name'];
    image = json['image'];
    parentCategoryId = json['parent_category_id'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sequence'] = sequence;
    data['name'] = name;
    data['image'] = image;
    data['parent_category_id'] = parentCategoryId;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}*/
