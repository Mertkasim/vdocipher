import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'video_player_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _playVideo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VideoPlayerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _playVideo();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PaymentPage()),
                // );
              },
              child: const Text('Play Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PaymentPage extends StatefulWidget {
  //  final String otp;
  //  final String playbackInfo;
  const PaymentPage({
    super.key,
  }); // required this.otp, required this.playbackInfo

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  String? paymentHtml;

  String otp = "";
  String playbackInfo = '';
  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

    // OTP ve playbackInfo'yu al
    fetchOtp().then((res) {
      if (res != null && res["otp"] != null && res["playbackInfo"] != null) {
        final otp = res["otp"];
        final playbackInfo = res["playbackInfo"];
        log("OTP -> $otp / $playbackInfo");
        final html = """
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body { margin: 0; padding: 0; overflow: hidden; }
            </style>
          </head>
          <body>
            <iframe
              src="https://player.vdocipher.com/v2/?otp=$otp&playbackInfo=$playbackInfo"
              width="100%"
              height="100%"
              style="border:none;"
              allowfullscreen
              allow="encrypted-media"
            ></iframe>
          </body>
        </html>
        """;

        setState(() {
          paymentHtml = html;
          _controller.loadHtmlString(html);
        });
      } else {
        log("OTP veya playbackInfo eksik!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Get.toNamed(NavigationConstants.userHomePage);
          },
        ),
        backgroundColor: Colors.red,
        title: const Text(
          "Ödeme",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

Future<dynamic> fetchOtp() async {
  const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXN1bHQiOjY4NywiaWF0IjoxNzUwMTY0NDk5LCJleHAiOjE3NTAxNzE2OTl9.Ww-StMktq4El78BzKUjJOjb1S38jqsgXb8_sKekTnGo";
  const String baseUrl =
      'https://patiumut.com/api'; // ← {{prod}} adresini buraya yaz
  const String endpoint = '/user/get-otp/10766';

  final Uri url = Uri.parse('$baseUrl$endpoint');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  var res = jsonDecode(response.body);
  final String otp = res['otp'];
  final String playbackInfo = res['playbackInfo'];

  log('OTP: $otp');
  log('Playback Info: $playbackInfo');

  if (response.statusCode == 200) {
    log('Başarılı: ${response.body}');
    return res;
  } else {
    log('Hata: ${response.statusCode} - ${response.body}');
  }
  return "";
}


// class PaymentPage extends StatefulWidget {
//   const PaymentPage({
//     super.key,
//   });
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
// class _PaymentPageState extends State<PaymentPage> {
//   late final WebViewController _controller;
//   late String threeDSHtmlContent;
//   PaymentController paymentController = Get.put(PaymentController());
//   @override
//   void initState() {
//     //  final String paymentHtml=Get.arguments;
//     // paymentController.paymentService();
//     // final arguments = Get.arguments;
//     // paymentController.cardNumber = arguments["cardNumber"];
//     // paymentController.cardHolder = arguments["cardHolder"];
//     // paymentController.cvc = int.tryParse(arguments["cvc"] ?? 0) ?? 0;
//     // paymentController.expireMonth =
//     //     int.tryParse(arguments["expireMonth"] ?? 0) ?? 0;
//     // paymentController.expireYear =
//     //     int.tryParse(arguments["expireYear"] ?? 0) ?? 0;
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadHtmlString(paymentController.paymentHtml.value);
//     paymentController.paymentService().then((onValue) {});
//     super.initState();
//     // fetchPaymentData();
//     // _controller = WebViewController()
//     // ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     // ..setNavigationDelegate(
//     //   NavigationDelegate(
//     //     onPageStarted: (String url) {
//     //       print("PAYMENTT Sayfa yükleniyor: $url");
//     //     },
//     //     onPageFinished: (String url) {
//     //       print("PAYMENTT Sayfa tamamlandı: $url");
//     //       checkPaymentStatus(url);
//     //     },
//     //     onWebResourceError: (WebResourceError error) {
//     //       print("PAYMENTT Hata: ${error.description}");
//     //     },
//     //   ),
//     // );
//   }
//   // Future<void> fetchPaymentData() async {
//   //   try {
//   //     print(paymentController.cvc);
//   //     print(paymentController.expireYear);
//   //     print(paymentController.expireMonth);
//   //     print(paymentController.cardHolder);
//   //     print(paymentController.cardNumber);
//   //     if (paymentController.expireYear == 0 ||
//   //         paymentController.expireMonth == 0) {
//   //       return;
//   //     }
//   //     await paymentController.paymentService();
//   //     if (paymentController.paymentResponseModel!.success == 1) {
//   //       if (paymentController.paymentResponseModel!.data![0].result!.status ==
//   //           "success") {
//   //         setState(() {
//   //           threeDSHtmlContent = utf8.decode(base64.decode(paymentController
//   //               .paymentResponseModel!.data![0].result!.threeDsHtmlContent!));
//   //           isLoading = false;
//   //         });
//   //         loadHtmlContent();
//   //       } else {
//   //         print("PAYMENTT: 1");
//   //         //showError("PAYMENTT Ödeme bilgileri alınamadı.");
//   //       }
//   //     } else {
//   //       print("PAYMENTT: 2");
//   //       //showError("PAYMENTT API isteği başarısız oldu.");
//   //     }
//   //   } catch (e) {
//   //     print("PAYMENTT: 3");
//   //     //showError("PAYMENTT Bir hata oluştu: $e");
//   //   }
//   // }
//   // void loadHtmlContent() {
//   //   _controller.loadHtmlString(threeDSHtmlContent);
//   // }
//   // void showError(String message) {
//   //   ScaffoldMessenger.of(context)
//   //       .showSnackBar(SnackBar(content: Text(message)));
//   //   setState(() {
//   //     isLoading = false;
//   //   });
//   // }
//   // void checkPaymentStatus(String url) {
//   //   print("PAYMENTT STATUS -+ ${url}");
//   //   if (url.contains("success")) {
//   //     print("PAYMENTT: deneme");
//   //     Navigator.pop(context, "success");
//   //     MySubscriptionController subscriptionController =
//   //         Get.put(MySubscriptionController());
//   //     subscriptionController.getMyCurrentSubscription();
//   //     Get.toNamed(NavigationConstants.paymentResultPage, arguments: {
//   //       "result": "success",
//   //     });
//   //   } else if (url.contains("failure")) {
//   //     print("PAYMENTT başarısız");
//   //     Navigator.pop(context, "failure");
//   //     Get.toNamed(NavigationConstants.paymentResultPage, arguments: {
//   //       "result": "failure",
//   //     });
//   //   }
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(
      //       Icons.arrow_back,
      //       color: ColorConstants.whiteColor,
      //     ),
      //     onPressed: () {
      //       Get.back();
      //     },
      //   ),
      //   backgroundColor: ColorConstants.primaryDark,
      //   title: const Text(
      //     "Ödeme",
      //     textAlign: TextAlign.center,
      //     style: TextStyle(color: ColorConstants.whiteColor),
      //   ),
      // ),
//       body: Obx(() {
//         // _controller = WebViewController()
//         //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         //   ..loadHtmlString(paymentController.paymentHtml.value);
//         return paymentController.isLoading.value
//             ? const Center(child: CircularProgressIndicator())
//             : WebViewWidget(controller: _controller);
//       }),
//     );
//   }
// }



//*********** */

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:jukka/constants/endpoint_constants.dart';
// import 'package:jukka/constants/prefrences_keys.dart';
// import 'package:jukka/init/locale/locale_manager.dart';
// import 'package:jukka/services/dio_service_helper.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class PaymentPage extends StatefulWidget {
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }
// class _PaymentPageState extends State<PaymentPage> {
//   late WebViewController controller;
//   late String threeDSHtmlContent;
//   bool isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     fetchPaymentData();
//     controller = WebViewController()
//       ..loadRequest(
//         Uri.parse('https://flutter.dev'),
//       );
//   }
//   Future<void> fetchPaymentData() async {
// String token = LocaleManager.instance.getString(PreferencesKeys.token)!;
//  final response = await DioServiceHelper().makeGetReq(
//     endPoint: EndpointConstants.paymentService,
//     getHeaders: {
//       'Authorization': 'Bearer $token',
//       },
//   );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == 1) {
//         setState(() {
//           threeDSHtmlContent = utf8.decode(
//               base64.decode(data['data'][0]['Result']['threeDSHtmlContent']));
//           isLoading = false;
//         });
//       } else {
//         showError("Ödeme bilgileri alınamadı.");
//       }
//     } else {
//       showError("API isteği başarısız oldu.");
//     }
//   }
//   void showError(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//     setState(() {
//       isLoading = false;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ödeme"),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           :WebViewWidget(controller: controller)
//            WebView(
//               initialUrl: Uri.dataFromString(
//                 threeDSHtmlContent,
//                 mimeType: 'text/html',
//                 encoding: Encoding.getByName('utf-8'),
//               ).toString(),
//               javascriptMode: JavascriptMode.unrestricted,
//               onPageFinished: (url) {
//                 print("WebView yükleme tamamlandı: $url");
//               },
//             ),
//     );
//   }
// }
