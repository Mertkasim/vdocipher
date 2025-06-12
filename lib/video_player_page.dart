import 'package:flutter/material.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VdoPlayerController? _controller;
  final double aspectRatio = 16/9;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
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
      print('VdoPlayer initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('VdoCipher Video')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hata: $_errorMessage'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializePlayer,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('VdoCipher Video')),
      body: SafeArea(
        child: VdoPlayer(
          embedInfo: EmbedInfo.streaming(
            otp: '20160313versASE323OLbh11WtsHB1NpeileVyP0jNCpgNk5Hi6RQIpjsw8gvd8Q',
            playbackInfo: 'eyJ2aWRlb0lkIjoiNDk5ZTQyYWZhMzAzNDdkZjkyOTM5OTJkY2ZlNTE3ZGYifQ==',
            embedInfoOptions: EmbedInfoOptions(
              autoplay: false,
              customPlayerId: "default",
            )
          ),
          onPlayerCreated: (controller) => _onPlayerCreated(controller),
          onError: (vdoError) {
            print('VdoPlayer error: ${vdoError.message}');
            setState(() {
              _errorMessage = vdoError.message;
            });
          },
        ),
      ),
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
      debugPrint("Player State: "
        "\nloading: ${value.isLoading} "
        "\nplaying: ${value.isPlaying} "
        "\nbuffering: ${value.isBuffering} "
        "\nended: ${value.isEnded}"
      );
    });
  }
}
