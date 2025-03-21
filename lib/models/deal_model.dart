class DealModel {
  final bool addtocart;
  final String dealAmount;
  final String dealImage;
  final String dealPercentage;
  final int dealRating;
  final String dealTitle;
  final String name;
  final String totalprice;

  DealModel({
    required this.addtocart,
    required this.dealAmount,
    required this.dealImage,
    required this.dealPercentage,
    required this.dealRating,
    required this.dealTitle,
    required this.name,
    required this.totalprice,
  });

  Map<String, dynamic> toMap() {
    return {
      'dealAmount': dealAmount,
      'dealImage': dealImage,
      'dealPercentage': dealPercentage,
      'dealRating': dealRating,
      'dealTitle': dealTitle,
      'name': name,
      'totalprice': totalprice,
    };
  }
}
