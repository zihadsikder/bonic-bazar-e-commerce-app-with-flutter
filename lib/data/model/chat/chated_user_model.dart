
//import 'package:eClassify/data/model/item/item_model.dart';

class ChatedUser {

  int? id;
  int? sellerId;
  int? buyerId;
  int? itemId;
  String? createdAt;
  String? updatedAt;
  int? amount;
  Seller? seller;
  Buyer? buyer;
  Item? item;

  ChatedUser(
      {this.id,
      this.sellerId,
      this.buyerId,
      this.itemId,
      this.createdAt,
      this.updatedAt,
      this.amount,
      this.seller,
      this.buyer,
      this.item});

  ChatedUser.fromJson(Map<String, dynamic> json/*, {BuildContext? context}*/) {
    id = json['id'];
    sellerId = json['seller_id'];
    buyerId = json['buyer_id'];
    itemId = json['item_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    amount = json['amount'];
    seller =
        json['seller'] != null ?  Seller.fromJson(json['seller']) : null;
    buyer = json['buyer'] != null ?  Buyer.fromJson(json['buyer']) : null;
    item = json['item'] != null ?  Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = id;
    data['seller_id'] = sellerId;
    data['buyer_id'] = buyerId;
    data['item_id'] = itemId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['amount'] = amount;
    if (seller != null) {
      data['seller'] = seller!.toJson();
    }
    if (buyer != null) {
      data['buyer'] = this.buyer!.toJson();
    }
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}

class Seller {
  int? id;
  String? name;
  String? profile;

  Seller({this.id, this.name, this.profile});

  Seller.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}

class Buyer {
  int? id;
  String? name;
  String? profile;

  Buyer({this.id, this.name, this.profile});

  Buyer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}

class Item {
  int? id;
  String? name;
  String? description;
  int? price;
  String? image;

  Item({this.id, this.name, this.description, this.price, this.image});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['image'] = this.image;
    return data;
  }
}
