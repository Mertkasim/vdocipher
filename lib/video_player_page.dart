import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VdoPlayerController? _controller;
  final double aspectRatio = 16 / 9;
  String? _errorMessage;
  bool _isLoading = true;
  String otp = "";
  String playbackInfo = "";

  @override
  void initState() {
    log("LODVİDEOOTP");
    fetchOtp().then((res) {
      if (res != null) {
        setState(() {
          otp = res["otp"];
          playbackInfo = res["playbackInfo"];
          _isLoading = false;
        });
        _controller = VdoPlayerController();
      } else {
        setState(() {
          log("OTP veya playbackInfo alınamadı !!!!!!!!!!!!!");
          _errorMessage = "OTP veya playbackInfo alınamadı";
          _isLoading = false;
        });
      }
    });
    super.initState();
  }

  Future<void> _initializePlayer() async {
    try {
      log("OTPİTİLİA -> $otp // $playbackInfo");
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _controller = VdoPlayerController();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      log('VdoPlayer initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('VdoCipher Video')),
        body: Container(
          alignment: Alignment.center,
          child: const Text('Yükleniyor...'),
        ),
      );
    }

    // if (_errorMessage != null) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('VdoCipher Video')),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text('Hata: $_errorMessage'),
    //           const SizedBox(height: 20),
    //           ElevatedButton(
    //             onPressed: _initializePlayer,
    //             child: const Text('Tekrar Dene'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    log("AÇILACAKOTP -> ${otp} / $playbackInfo");
    return Scaffold(
      appBar: AppBar(title: const Text('VdoCipher Video')),
      body: VdoPlayer(
        embedInfo: EmbedInfo.streaming(
          otp: otp,
          playbackInfo: playbackInfo,
          embedInfoOptions: EmbedInfoOptions(autoplay: true),
        ),
        onPlayerCreated: (controller) => _onPlayerCreated(controller),
        onError: _onVdoError,
        controls: true,
      ),
      // otp.isNotEmpty && playbackInfo.isNotEmpty
      //     ? VdoPlayer(
      //       embedInfo: EmbedInfo.streaming(
      //         otp: otp,
      //         playbackInfo: playbackInfo,
      //         embedInfoOptions: EmbedInfoOptions(
      //           autoplay: false,
      //           customPlayerId: "default",
      //         ),
      //       ),
      //       onPlayerCreated: _onPlayerCreated,
      //       onError: (vdoError) {
      //         print('VdoPlayer error: ${vdoError.message}');
      //         setState(() {
      //           _errorMessage = vdoError.message;
      //         });
      //       },
      //     )
      //     : const Center(child: Text("Video yüklenemedi.")),
    );
  }

  void _onPlayerCreated(VdoPlayerController? controller) {
    if (controller == null) return;
    setState(() {
      _controller = controller;
      _onEventChange(_controller);
    });
  }

  void _onEventChange(VdoPlayerController? controller) {
    if (controller == null) return;
    controller.addListener(() {
      if (!mounted) return;
      VdoPlayerValue value = controller.value;
      debugPrint(
        "Player State: "
        "\nloading: ${value.isLoading} "
        "\nplaying: ${value.isPlaying} "
        "\nbuffering: ${value.isBuffering} "
        "\nended: ${value.isEnded}",
      );
    });
  }

  Future<Map<String, dynamic>?> fetchOtp() async {
    const String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXN1bHQiOjY4NywiaWF0IjoxNzUwMjQ3Mjg2LCJleHAiOjE3NTAyNTQ0ODZ9.yaF14MTg-S-A8h6TYqzJfK8qNnZbZ1ieSSQgYIO5nVg";
    const String baseUrl = 'https://patiumut.com/api';
    const String endpoint = '/user/get-otp/10766';

    final Uri url = Uri.parse('$baseUrl$endpoint');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      log('OTP: ${res["otp"]}');
      log('Playback Info: ${res["playbackInfo"]}');
      return {"otp": res["otp"], "playbackInfo": res["playbackInfo"]};
    } else {
      log('Hata: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}

_onVdoError(VdoError vdoError) {
  print("Oops, the system encountered a problem: " + vdoError.message);
}
