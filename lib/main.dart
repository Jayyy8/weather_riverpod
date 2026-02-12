import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("database");

  runApp(const CupertinoApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(),
  ));
}

/* ===================== AUTH GATE ===================== */

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box("database");

    if (box.get("username") == null) {
      return const Signup();
    }
    return const Login();
  }
}

/* ===================== LOGIN PAGE ===================== */

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> biometrics() async{
    final LocalAuthentication auth = LocalAuthentication();
   try{
     final bool didAuthenticate = await auth.authenticate(
       localizedReason: 'Please authenticate Biometrics',
       biometricOnly: true,
     );

     if (didAuthenticate){
       setState(() {
         _username.text = box.get("username");
         _password.text = box.get("password");
       });
     }
   } catch (e) {
     showCupertinoDialog(context: context, builder: (context){
       return CupertinoAlertDialog(
         title: Text("Biometrics Unsupported"),
         content: Text(e.toString()),
         actions: [
           CupertinoButton(child: Text("Close"), onPressed: (){
             Navigator.pop(context);
           })
         ],
       );
     });
   }
  }

  Future<void> getCurrentLocation() async{
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    print(position.latitude);
    print(position.longitude);
  }
  bool hidePassword = true;
  String msg = "";
  final box = Hive.box("database");

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Login",
                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 35)),
            const SizedBox(height: 10),
            CupertinoTextField(
              padding: const EdgeInsets.all(9),
              controller: _username,
              prefix: const Icon(CupertinoIcons.person),
              placeholder: "Username",
            ),
            CupertinoTextField(
              controller: _password,
              prefix: const Icon(CupertinoIcons.padlock),
              placeholder: "Password",
              obscureText: hidePassword,
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(hidePassword
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash),
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Login'),
                    onPressed: () {
                      if (_username.text.trim() == box.get("username") &&
                          _password.text.trim() == box.get("password")) {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const MyApp(),
                          ),
                        );
                      } else {
                        setState(() {
                          msg = "Invalid username or password";
                        });
                      }
                    },
                  ),
                  (box.get("biometrics", defaultValue: false)) ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(Icons.fingerprint, size: 30,), onPressed: (){
                        biometrics();
                  }) : SizedBox(height: 30,),
                  CupertinoButton(
                      child: const Text("Reset Data"),
                      onPressed: () {
                        box.delete("username");
                        box.delete("theme_color");
                        box.delete("theme_color_name");
                        box.delete("saved_city");
                        box.delete("biometrics");
                        Navigator.pushReplacement(context, CupertinoPageRoute(builder: (_) => const Signup()));
                      }
                  ),
                  Text(msg,
                      style: const TextStyle(
                          color: CupertinoColors.destructiveRed)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ===================== SIGNUP PAGE ===================== */

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final box = Hive.box("database");
  bool hidePassword = true;
  String msg = "";

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create your local account",
                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 35)),
            const SizedBox(height: 10),
            CupertinoTextField(
              padding: const EdgeInsets.all(9),
              controller: _username,
              prefix: const Icon(CupertinoIcons.person),
              placeholder: "Username",
            ),
            CupertinoTextField(
              controller: _password,
              prefix: const Icon(CupertinoIcons.padlock),
              placeholder: "Password",
              obscureText: hidePassword,
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(hidePassword
                    ? CupertinoIcons.eye
                    : CupertinoIcons.eye_slash),
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Sign Up'),
                    onPressed: () {
                      if (_username.text.isEmpty || _password.text.isEmpty) {
                        setState(() {
                          msg = "Input text fields are empty";
                        });
                      } else {
                        box.put("username", _username.text.trim());
                        box.put("password", _password.text.trim());

                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const Login(),
                          ),
                        );
                      }
                    },
                  ),
                  Text(msg,
                      style: const TextStyle(
                          color: CupertinoColors.destructiveRed)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ===================== MAIN APP ===================== */

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // LOAD SAVED THEME COLOR
    final savedColorValue = box.get("theme_color");
    final savedColorName = box.get("theme_color_name");

    if (savedColorValue != null && savedColorName != null) {
      primaryColor = Color(savedColorValue);
      themeColorName = savedColorName;
    }

    _initializeLocation();
  }
  final box = Hive.box("database");
  Map<String, dynamic> weatherData = {};
  String api = "4a702b6d783570a69a84b7d6ac2f3a44";

  bool darkMode = true;
  bool isMetric = true;

  String city = "";
  String temperature = "";
  String weatherCondition = "";
  IconData weatherIcon = CupertinoIcons.sun_max;
  String humidity = "";
  String windSpeed = "";

  Color primaryColor = CupertinoColors.activeBlue;
  String themeColorName = "Blue";

  Future<void> _initializeLocation() async {
    final savedCity = box.get("saved_city");

    // If user already selected a city before, use it
    if (savedCity != null && savedCity.toString().isNotEmpty) {
      setState(() {
        city = savedCity;
      });
      await getWeatherData();
      return;
    }

    // Otherwise use Geolocator (FIRST TIME ONLY)
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          city = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              "";
        });

        await getWeatherData();
      }
    } catch (e) {
      print("Location error: $e");
    }
  }

  Future<void> getWeatherData() async {
    if (city.isEmpty) return;

    final link =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$api";

    try {
      final response = await http.get(Uri.parse(link));
      weatherData = jsonDecode(response.body);

      if (weatherData["cod"] != 200) throw Exception("Invalid city");

      double tempKelvin = weatherData["main"]["temp"];
      String tempConverted = isMetric
          ? (tempKelvin - 273.15).toStringAsFixed(0)
          : ((tempKelvin - 273.15) * 9 / 5 + 32).toStringAsFixed(0);

      setState(() {
        city = weatherData["name"];
        temperature = tempConverted;
        weatherCondition = weatherData["weather"][0]["main"];

        if (weatherCondition == "Clouds") {
          weatherIcon = CupertinoIcons.cloud;
        } else if (weatherCondition == "Rain") {
          weatherIcon = CupertinoIcons.cloud_bolt_rain;
        } else if (weatherCondition == "Clear") {
          weatherIcon = CupertinoIcons.sun_max;
        }

        humidity = weatherData["main"]["humidity"].toString();
        windSpeed = weatherData["wind"]["speed"].toString();
      });
    } catch (_) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Error"),
          content:
          const Text("Invalid city or something went wrong. Try again."),
          actions: [
            CupertinoButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: darkMode ? Brightness.dark : Brightness.light,
        primaryColor: primaryColor,
      ),
      home: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: "Settings",
            ),
          ],
        ),
        tabBuilder: (context, index) {
          if (index == 0) {
            return CupertinoPageScaffold(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      "$temperature°${isMetric ? 'C' : 'F'}",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      weatherCondition,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                    Icon(weatherIcon, size: 100),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Humidity: $humidity%"),
                        Text("Wind: $windSpeed km/h"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return CupertinoPageScaffold(
            child: ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: _iconBox(
                        Icons.fingerprint,
                        CupertinoColors.systemOrange,
                      ),
                      title: const Text("Biometrics"),
                      trailing: CupertinoSwitch(
                        value: box.get("biometrics", defaultValue: false),
                        onChanged: (value) {
                          setState(() {
                            box.put("biometrics",
                                !box.get("biometrics", defaultValue: false));
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: _iconBox(
                        CupertinoIcons.moon_fill,
                        CupertinoColors.systemBlue,
                      ),
                      title: const Text("Dark Mode"),
                      trailing: CupertinoSwitch(
                        value: darkMode,
                        onChanged: (value) {
                          setState(() => darkMode = value);
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: _iconBox(
                        CupertinoIcons.thermometer,
                        CupertinoColors.systemPurple,
                      ),
                      title: const Text("Metric"),
                      trailing: CupertinoSwitch(
                        value: isMetric,
                        onChanged: (value) {
                          setState(() => isMetric = value);
                          getWeatherData();
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _showLocationDialog,
                      child: CupertinoListTile(
                        leading: _iconBox(
                          CupertinoIcons.location_fill,
                          CupertinoColors.systemGreen,
                        ),
                        title: const Text("Location"),
                        trailing: const Icon(CupertinoIcons.chevron_forward),
                        additionalInfo: Text(city),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showThemeDialog,
                      child: CupertinoListTile(
                        leading: _iconBox(
                          CupertinoIcons.paintbrush_fill,
                          primaryColor,
                        ),
                        title: const Text("Theme Color"),
                        trailing: const Icon(CupertinoIcons.chevron_forward),
                        additionalInfo: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.circle_fill,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(themeColorName),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAboutDialog,
                      child: CupertinoListTile(
                        leading: _iconBox(
                          CupertinoIcons.group,
                          CupertinoColors.systemGrey,
                        ),
                        title: const Text("About"),
                        trailing: const Icon(CupertinoIcons.chevron_forward),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text("Logout"),
                            content: const Text("Return to login page?"),
                            actions: [
                              CupertinoButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              CupertinoButton(
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: CupertinoColors.destructiveRed),
                                ),
                                onPressed: () {
                                  // Close the dialog and go to Login, clearing all previous routes
                                  Navigator.of(context).pushAndRemoveUntil(
                                    CupertinoPageRoute(builder: (_) => const Login()),
                                        (route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      child: CupertinoListTile(
                        leading: _iconBox(
                          Icons.logout,
                          CupertinoColors.systemYellow,
                        ),
                        title: const Text("Logout"),
                        trailing: const Icon(CupertinoIcons.chevron_forward),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(icon, size: 18, color: CupertinoColors.white),
    );
  }

  void _showThemeDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Theme Color"),
        content: Wrap(
          spacing: 12,
          children: [
            _colorDot("Red", CupertinoColors.destructiveRed),
            _colorDot("Orange", CupertinoColors.systemOrange),
            _colorDot("Yellow", CupertinoColors.systemYellow),
            _colorDot("Green", CupertinoColors.systemGreen),
            _colorDot("Blue", CupertinoColors.activeBlue),
            _colorDot("Indigo", CupertinoColors.systemIndigo),
            _colorDot("Purple", CupertinoColors.systemPurple),
          ],
        ),
        actions: [
          CupertinoButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(String name, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          primaryColor = color;
          themeColorName = name;
        });
        box.put("theme_color", color.value);
        box.put("theme_color_name", name);

        Navigator.pop(context);
      },
      child: Icon(
        CupertinoIcons.circle_fill,
        color: color,
        size: 30,
      ),
    );
  }

  void _showLocationDialog() {
    final controller = TextEditingController(text: city);

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("City"),
        content: CupertinoTextField(controller: controller),
        actions: [
          CupertinoButton(
            child: const Text("Save"),
            onPressed: () {
              setState(() {
                city = controller.text.trim();
              });

              box.put("saved_city", city);

              getWeatherData();
              Navigator.pop(context);
            },
          ),
          CupertinoButton(
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Members"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Delos Santos, Jhanelle N."),
            Text("Enriquez, Tijano Tj P."),
            Text("Maniago, Jairus Legor C."),
          ],
        ),
        actions: [
          CupertinoButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
