class CoinDetails {
  String? id;
  String? symbol;
  String? name;
  String? image;
  double? currentPrice;
  double? priceChangePercentage24h;

  CoinDetails(
      {this.id,
      this.symbol,
      this.name,
      this.image,
      this.currentPrice,
      this.priceChangePercentage24h});

  CoinDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    symbol = json['symbol'];
    name = json['name'];
    image = json['image'];
    currentPrice = json['current_price'];
    priceChangePercentage24h = json['price_change_percentage_24h'];
  }
}
