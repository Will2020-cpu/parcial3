import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

import '../config/auth_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _auth = AuthService();

  final List<String> videos = [
    'assets/videos/video1.mp4',
    'assets/videos/video2.mp4',
    'assets/videos/video3.mp4',
    'assets/videos/video4.mp4',
  ];

  final List<String> descriptions = [
    'video #1',
    'video #2',
    'video #3',
    'video #4',
  ];

  final List<VideoPlayerController> controllers = [];

  int currentIndex = 0;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    initializeVideos();
  }

  Future<void> initializeVideos() async {
    try {
      for (final video in videos) {
        final controller = VideoPlayerController.asset(video);

        controllers.add(controller);

        await controller.initialize();
        await controller.setLooping(true);
      }

      if (!mounted) return;

      setState(() => initialized = true);
      await controllers[0].play();
    } catch (e) {
      debugPrint('Error cargando videos: $e');
    }
  }

  void changeVideo(int index) {
    if (index == currentIndex || !initialized) return;

    controllers[currentIndex].pause();
    currentIndex = index;
    controllers[currentIndex].play();

    setState(() {});
  }

  void toggleVideo() {
    if (!initialized) return;

    final controller = controllers[currentIndex];

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (!initialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        onPageChanged: changeVideo,
        itemBuilder: (context, index) {
          final controller = controllers[index];

          return GestureDetector(
            onTap: () {
              if (index == currentIndex) toggleVideo();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),

                if (index == currentIndex && !controller.value.isPlaying)
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 85,
                    ),
                  ),

                Positioned(
                  left: 18,
                  bottom: 35,
                  right: 85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${user?.displayName ?? user?.email ?? "usuario"}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        descriptions[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  right: 15,
                  bottom: 90,
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 35),
                      const Text(
                        'Me gusta',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      const Icon(Icons.comment, color: Colors.white, size: 35),
                      const Text(
                        'Comentarios',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      const Icon(Icons.share, color: Colors.white, size: 35),
                      const Text(
                        'Compartir',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 45,
                  right: 15,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                    onSelected: (value) {
                      if (value == 'logout') logout();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'logout',
                        child: Text(
                          'Cerrar sesión (${user?.displayName ?? user?.email ?? "Usuario"})',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
