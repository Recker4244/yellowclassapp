import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:video_player/video_player.dart';
import 'package:yellowclass/model/teaching_class.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init = initialise();
  }

  Future<bool> initialise() async {
    await read();
    return true;
  }

  VideoPlayerController? controller;
  List<TeachingClass> classes = [];
  read() async {
    final String response = await rootBundle.loadString('assets/dataset.json');
    Iterable l = json.decode(response);

    classes = List<TeachingClass>.from(
        l.map((model) => TeachingClass.fromJson(model)));

    controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  Future<bool>? init;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yellow Class"),
        backgroundColor: Colors.amberAccent,
      ),
      body: FutureBuilder(
        future: init,
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return InViewNotifierList(
              isInViewPortCondition:
                  (double deltaTop, double deltaBottom, double vpHeight) {
                return deltaTop < (0.2 * vpHeight) &&
                    deltaBottom > (0.2 * vpHeight);
              },
              itemCount: classes.length,
              builder: (BuildContext context, int index) {
                return InViewNotifierWidget(
                  id: '$index',
                  builder:
                      (BuildContext context, bool? isInView, Widget? child) {
                    if (isInView!) {
                      controller = VideoPlayerController.network(
                          classes[index].videoUrl!,
                          videoPlayerOptions: VideoPlayerOptions());
                      controller!.initialize();
                      controller!.setVolume(0);
                      controller!.play();
                    }

                    return Container(
                        decoration: const BoxDecoration(),
                        height: 250.0,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                isInView
                                    ? AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: VideoPlayer(controller!))
                                    : Image.network(
                                        classes[index].coverPicture!),
                                isInView && !controller!.value.isPlaying
                                    ? Container(
                                        //height: 250,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: Colors.grey[600]!
                                                          .withOpacity(0.5)),
                                                  child: Text(
                                                    "${controller!.value.position.inMicroseconds}:${controller!.value.position.inSeconds}",
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            controller!.value.volume == 0
                                                ? Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.volume_off),
                                                      onPressed: () {
                                                        controller!
                                                            .setVolume(1.0);
                                                      },
                                                    ),
                                                  )
                                                : Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: IconButton(
                                                      icon: const Icon(Icons
                                                          .volume_up_rounded),
                                                      onPressed: () {
                                                        controller!
                                                            .setVolume(0.0);
                                                        // setState(() {

                                                        // });
                                                      },
                                                    ),
                                                  )
                                          ],
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                            Text(classes[index].title!)
                          ],
                        ));
                  },
                );
              },
            );
          }

          return const Scaffold();
        },
      ),
    );
  }
}
