import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

import '../../../../core/helper/helper.dart';
import '../../../../core/ui/theme/colors.dart';
import '../../../../core/ui/theme/text_styles.dart';

class ImageViewScreen extends StatefulWidget {
  static const String routeName = "image_view_screen";

  const ImageViewScreen({
    Key? key,
    required this.arg,
  }) : super(key: key);

  final ImageViewScreenParams arg;

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  final ValueNotifier<bool> isShow = ValueNotifier(true);
  final int _progress = 0;

  @override
  void initState() {
    super.initState();
    // ImageDownloader.callback(onProgressUpdate: (_, progress) {
    //   setState(() {
    //     _progress = progress;
    //   });
    // }); TODO:
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onVerticalDragEnd: (val) {
                if (val.primaryVelocity! > 0) {
                  Navigator.of(context).pop();
                }
              },
              onTap: () {
                isShow.value = !isShow.value;
                // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinearProgressIndicator(
                    value: _progress / 100,
                    color: AppColors.orange,
                    backgroundColor: Colors.grey,
                  ),
                  Expanded(
                    child: PhotoView.customChild(
                      // enableRotation: true,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: widget.arg.imageProvider,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
            ),
            Positioned(
              top: 0,
              width: size.width,
              child: ValueListenableBuilder<bool>(
                valueListenable: isShow,
                builder: (context, value, _) {
                  return _Hidable(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.arg.topRightCornerText ?? "",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.styleWeight600(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.arg.topLeftCornerText ?? "",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.styleWeight600(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 0,
              width: size.width,
              child: ValueListenableBuilder<bool>(
                valueListenable: isShow,
                builder: (context, value, _) {
                  return _Hidable(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () async {
                              try {
                                Helper.downloadImage(
                                  widget.arg.imageUrl,
                                  outputMimeType: 'image/${widget.arg.imageUrl.split('.').last}',
                                );

                                // String? i = await ImageDownloader.downloadImage(
                                //   widget.arg.imageUrl,
                                //   outputMimeType:
                                //       'image/${widget.arg.imageUrl.split('.').last}',
                                // ).timeout(const Duration(seconds: 5));

                                // if (i == null) {
                                //   BotToast.showText(text: 'error!');
                                //   return;
                                // } else {
                                //   BotToast.showText(
                                //     text: 'Downloaded Successfully',
                                //   );
                                // }
                              } on PlatformException catch (error) {
                                log(error.message.toString());
                              }
                            },
                            icon: const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.arg.bottomLeftCornerText ?? "",
                            style: AppTextStyles.styleWeight600(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageViewScreenParams {
  final ImageProvider imageProvider;
  final String imageUrl;

  final String? topRightCornerText;
  final String? topLeftCornerText;
  final String? bottomLeftCornerText;

  ImageViewScreenParams({
    required this.imageProvider,
    required this.imageUrl,
    this.topRightCornerText,
    this.topLeftCornerText,
    this.bottomLeftCornerText,
  });
}

class _Hidable extends StatelessWidget {
  const _Hidable({
    Key? key,
    required this.value,
    required this.child,
  }) : super(key: key);

  final bool value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeIn,
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeIn,
        duration: const Duration(milliseconds: 150),
        child: value ? child : const SizedBox(),
      ),
    );
  }
}
