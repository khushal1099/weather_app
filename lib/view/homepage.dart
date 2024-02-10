import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/controller/themeprovider.dart';
import 'package:weather_app/model/api_helper.dart';
import '../controller/search_provider.dart';
import '../model/wether_model.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    var sp = Provider.of<SearchProvider>(context, listen: false);
    sp.fetchDataFromPrefs();
    super.initState();
  }

  http.Response? res;
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var sp = Provider.of<SearchProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          sp.loc ?? "",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        actions: [
          Consumer<ThemeProvider>(builder: (context, tp, child) {
            return IconButton(
              onPressed: () {
                tp.setTheme();
              },
              icon: tp.isDark == false
                  ? Icon(Icons.dark_mode)
                  : Icon(Icons.light_mode_outlined),
            );
          })
        ],
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
        future: ApiHelper().getApiData(sp.loc ?? ""),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error : ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            Wether? detail = snapshot.data;
            String inputString = detail!.location!.localtime!;
            // Parse the input string to DateTime with a specific format
            DateFormat inputFormat = DateFormat("yyyy-MM-dd H:mm");
            DateTime dateTime = inputFormat.parse(inputString);

            // Format the date in the desired output format with month name
            DateFormat outputFormat = DateFormat("MMMM dd, yyyy", 'en_US');
            String formattedDate = outputFormat.format(dateTime);

            DateTime now = DateTime.now();
            double hour = now.hour.toDouble();

            return Consumer<SearchProvider>(builder: (context, sp, child) {
              return Stack(
                children: [
                  Container(
                      height: MediaQuery.sizeOf(context).height * 1,
                      width: MediaQuery.sizeOf(context).width * 1,
                      child: Provider.of<ThemeProvider>(context, listen: false)
                                  .isDark ==
                              false
                          ? Image.asset(
                              "assets/images/wetherbg.jpg",
                              fit: BoxFit.fitHeight,
                            )
                          : Image.asset(
                              "assets/images/bg_night.webp",
                              fit: BoxFit.fitHeight,
                            )),
                  Container(
                    margin: EdgeInsets.only(top: 80, left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey),
                    child: TextFormField(
                      controller: search,
                      decoration: InputDecoration(
                        hintText: "Search city",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              search.clear();
                            },
                            icon: Icon(Icons.close_outlined)),
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onFieldSubmitted: (value) async {
                        sp.searchloc(value);
                        String baseUrl =
                            "https://api.weatherapi.com/v1/forecast.json?key=e09f03988e1048d2966132426232205&q=";
                        String endUrl = "$value&aqi=no";
                        String api = baseUrl + endUrl;
                        res = await http.get(Uri.parse(api));
                      },
                    ),
                  ),
                  res?.statusCode == 400
                      ? Center(
                          child: Text(
                              "\t\t\t\t\t\t\t\t\t\tNo matching location found\n(you can search only search city weather)"),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 150),
                                height:
                                    MediaQuery.sizeOf(context).height * 0.35,
                                width: MediaQuery.sizeOf(context).width * 0.948,
                                color: Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .isDark
                                    ? Colors.black26
                                    : Colors.white30,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "${detail.current!.tempC}°",
                                            style: TextStyle(
                                              fontSize: 60,
                                              fontWeight: FontWeight.w700,
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            child: Text(
                                              "C",
                                              style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Provider.of<ThemeProvider>(
                                                                context,
                                                                listen: false)
                                                            .isDark
                                                        ? Colors.white54
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 18, left: 10),
                                            child: Text(
                                              "${detail.current?.condition?.text}",
                                              style: TextStyle(
                                                fontSize:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.03,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    Provider.of<ThemeProvider>(
                                                                context,
                                                                listen: false)
                                                            .isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 60,
                                        ),
                                        child: Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Provider.of<ThemeProvider>(
                                                        context,
                                                        listen: false)
                                                    .isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Container(
                                color: Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .isDark
                                    ? Colors.black26
                                    : Colors.white30,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      detail.forecast!.forecastday![0].hour!
                                          .length,
                                      (index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 28),
                                          child: Column(
                                            children: [
                                              (detail
                                                              .forecast!
                                                              .forecastday![0]
                                                              .hour![
                                                                  DateTime.now()
                                                                      .hour]
                                                              .time!
                                                              .split(
                                                                  "${DateTime.now().day}")[
                                                          1] ==
                                                      detail
                                                          .forecast!
                                                          .forecastday![0]
                                                          .hour![index]
                                                          .time!
                                                          .split(
                                                              "${DateTime.now().day}")[1])
                                                  ? Text(
                                                      "Now",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    )
                                                  : Text(
                                                      detail
                                                          .forecast!
                                                          .forecastday![0]
                                                          .hour![index]
                                                          .time!
                                                          .split(
                                                              "${DateTime.now().day}")[1],
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Image.network(
                                                "http:${detail.forecast!.forecastday![0].hour![index].condition!.icon}",
                                                height: 50,
                                                width: 50,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                "${detail.forecast!.forecastday![0].hour![index].tempC}°",
                                                style: TextStyle(fontSize: 15),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                height:
                                    MediaQuery.sizeOf(context).height * 0.32,
                                width: MediaQuery.sizeOf(context).width * 0.948,
                                color: Provider.of<ThemeProvider>(context,
                                            listen: false)
                                        .isDark
                                    ? Colors.black26
                                    : Colors.white30,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Icon(
                                                    Icons.thermostat,
                                                    size: 30,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "Feels Like",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.feelslikeC}°",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child:
                                                      Icon(Icons.air, size: 30),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "SW wind",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.windKph} km/h",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Icon(Icons.water_drop,
                                                      size: 30),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "Humidity",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.humidity}%",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Icon(
                                                      Icons.light_mode_outlined,
                                                      size: 30),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "UV",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.uv}",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Icon(Icons.visibility,
                                                      size: 30),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "Visibility",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.visKm}km",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.14,
                                            width: MediaQuery.sizeOf(context)
                                                    .width *
                                                0.3,
                                            decoration: BoxDecoration(
                                              color: Provider.of<ThemeProvider>(
                                                          context,
                                                          listen: false)
                                                      .isDark
                                                  ? Colors.grey
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Icon(Icons.wind_power,
                                                      size: 30),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "Air pressure",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Center(
                                                  child: Text(
                                                    "${detail.current!.pressureMb} km/h",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              );
            });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
