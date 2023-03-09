import 'dart:convert';

import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_details_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoinGraphScreen extends StatefulWidget {
  final CoinDetails coinDetails;

  const CoinGraphScreen({
    super.key,
    required this.coinDetails,
  });

  @override
  State<CoinGraphScreen> createState() => _CoinGraphScreenState();
}

class _CoinGraphScreenState extends State<CoinGraphScreen> {
  bool isLoading = true,
      isFirstTime = true,
      isDarkMode = AppTheme.isDarkModeEnabled;

  List<FlSpot> flSpotList = [];

  double minX = 0.0, minY = 0.0, maxY = 0.0, maxX = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChartData("1");
  }

  void getChartData(String days) async {
    if (isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }
    String url =
        "https://api.coingecko.com/api/v3/coins/${widget.coinDetails.id}/market_chart?vs_currency=inr&days=$days";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> result = json.decode(response.body);
      List rawList = result['prices'];
      List<List> chartData = rawList.map((e) => e as List).toList();
      List<PriceAndTime> priceAndTimeList = chartData
          .map(
            (e) => PriceAndTime(time: e[0] as int, price: e[1] as double),
          )
          .toList();

      flSpotList = [];

      for (var element in priceAndTimeList) {
        flSpotList.add(
          FlSpot(element.time.toDouble(), element.price),
        );
      }

      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      priceAndTimeList.sort(((a, b) => a.price.compareTo(b.price)));

      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xff121212) : Colors.white,
        title: Text(
          "${widget.coinDetails.name}",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: isLoading == false
          ? SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text:
                              "${widget.coinDetails.name} (${widget.coinDetails.symbol}) Price\n",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(
                              text: "${widget.coinDetails.currentPrice}",
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text:
                                  "${widget.coinDetails.priceChangePercentage24h}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                            TextSpan(
                              text: "Rs.$maxY",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 200,
                  ),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: LineChart(
                      LineChartData(
                        maxX: maxX,
                        maxY: maxY,
                        minY: minY,
                        minX: minX,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(
                          getDrawingHorizontalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(strokeWidth: 0);
                          },
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: flSpotList,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            getChartData("1");
                          },
                          child: const Text("1d"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("15");
                          },
                          child: const Text("15d"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getChartData("15");
                          },
                          child: const Text("30d"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class PriceAndTime {
  late int time;
  late double price;
  PriceAndTime({required this.time, required this.price});
}
