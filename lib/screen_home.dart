import 'dart:convert';

import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_details_model.dart';
import 'package:crypto_app/coin_graph_screen.dart';
import 'package:crypto_app/screen_update_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  late Future<List<CoinDetails>> coinDetailsFuture;

  List<CoinDetails> coinDetailsList = [];

  bool isFirstTimeDataAccess = true;

  String name = "";

  String email = "";

  String mobileNumber = "";

  bool isDarkMode = AppTheme.isDarkModeEnabled;

  @override
  void initState() {
    getUserData();
    coinDetailsFuture = getCoinDetails();
    super.initState();
  }

  void getUserData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      name = _pref.getString("name") ?? "";
      email = _pref.getString("email") ?? "";
      mobileNumber = _pref.getString("mobile") ?? "";
    });
  }

  Future<List<CoinDetails>> getCoinDetails() async {
    String url =
        "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=false";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List coinData = json.decode(response.body);
      List<CoinDetails> data =
          coinData.map((e) => CoinDetails.fromJson(e)).toList();

      return data;
    } else {
      return <CoinDetails>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor:
          isDarkMode ? const Color(0xff121212) : const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _globalKey.currentState!.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          "CryptoApp",
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      drawer: Drawer(
        backgroundColor:
            isDarkMode ? const Color(0xff121212) : const Color(0xffFFFFFF),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 70,
              ),
              accountName: Text(
                name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              accountEmail: Text(
                "$email\n$mobileNumber",
                style: const TextStyle(fontSize: 17),
              ),
            ),
            ListTile(
              title: Text(
                "Update Profile",
                style: TextStyle(
                    fontSize: 17,
                    color: isDarkMode ? Colors.white : Colors.black),
              ),
              leading: Icon(Icons.account_box,
                  color: isDarkMode ? Colors.white : Colors.black),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                isDarkMode ? "Light Mode" : "Dark Mode",
                style: TextStyle(
                    fontSize: 17,
                    color: isDarkMode ? Colors.white : Colors.black),
              ),
              leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: isDarkMode ? Colors.white : Colors.black),
              onTap: () async {
                SharedPreferences _pref = await SharedPreferences.getInstance();
                setState(() {
                  isDarkMode = !isDarkMode;
                });
                AppTheme.isDarkModeEnabled = isDarkMode;
                await _pref.setBool("isDarkMode", isDarkMode);
              },
            )
          ],
        ),
      ),
      body: FutureBuilder(
        future: coinDetailsFuture,
        builder: (context, AsyncSnapshot<List<CoinDetails>> snapshot) {
          if (snapshot.hasData) {
            if (isFirstTimeDataAccess) {
              coinDetailsList = snapshot.data!;
              isFirstTimeDataAccess = false;
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 15),
                  child: TextField(
                    onChanged: (value) {
                      List<CoinDetails> searchResult =
                          snapshot.data!.where((element) {
                        String? _coinName = element.name;
                        bool isItemFound = _coinName!.contains(value);
                        return isItemFound;
                      }).toList();

                      setState(() {
                        coinDetailsList = searchResult;
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      hintText: "Search Coin..",
                      hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? Colors.white : Colors.grey),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: coinDetailsList.isEmpty
                      ? Center(
                          child: Text(
                            "No Coin Found",
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                        )
                      : ListView.builder(
                          itemCount: coinDetailsList.length,
                          itemBuilder: (context, index) {
                            return coinsDetail(coinDetailsList[index]);
                          }),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget coinsDetail(CoinDetails model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoinGraphScreen(
                  coinDetails: model,
                ),
              ),
            );
          },
          leading: Image.network("${model.image}"),
          title: Text(
            "${model.name}\n ${model.symbol}",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              text: "${model.currentPrice}\n",
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: "${model.priceChangePercentage24h}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          )),
    );
  }
}
