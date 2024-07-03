// ignore_for_file: public_member_api_docs, sort_constructors_first
class HomeSlider {
  int? id;
  String? sequence;
  String? thirdPartyLink;
  int? itemId;
  String? image;

  HomeSlider(
      {this.id, this.sequence, this.thirdPartyLink, this.itemId, this.image});

  HomeSlider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequence = json['sequence'];
    thirdPartyLink = json['third_party_link'];
    itemId = json['item_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sequence'] = sequence;
    data['third_party_link'] = thirdPartyLink;
    data['item_id'] = itemId;
    data['image'] = image;
    return data;
  }
}
