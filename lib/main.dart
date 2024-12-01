import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageQuoteWithDynamicBackground(),
    );
  }
}

class ImageQuoteWithDynamicBackground extends StatefulWidget {
  @override
  _ImageQuoteWithDynamicBackgroundState createState() =>
      _ImageQuoteWithDynamicBackgroundState();
}

class _ImageQuoteWithDynamicBackgroundState
    extends State<ImageQuoteWithDynamicBackground> {
  final List<Map<String, String>> items = [
    {
      "image": "assets/KakaoTalk_Photo_2024-12-01-17-49-23.jpeg", // 로컬 이미지 경로
      "quote": "This is a sample quote for this image. This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.This is a sample quote for this image.",
    },
    {
      "image": "assets/KakaoTalk_Photo_2024-12-01-18-03-15.jpeg", // 다른 로컬 이미지
      "quote": "Another sample quote for another image.",
    },
  ];

  int currentIndex = 0;
  Color backgroundColor = Colors.black; // 기본 배경 색상
  Color textColor = Colors.white; // 기본 글귀 색상
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 색 추출
    _updateColors(items[currentIndex]['image']!);

    // ScrollController에 리스너 추가
    _scrollController.addListener(() {
      // 스크롤이 끝에 도달했을 때
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        showNextItem();
      }
    });
  }

  void showNextItem() {
    setState(() {
      currentIndex = (currentIndex + 1) % items.length;
    });
    _updateColors(items[currentIndex]['image']!);
  }

  Future<void> _updateColors(String imagePath) async {
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      AssetImage(imagePath),
    );

    // 주요 색 추출 (예시: 이미지에서 가장 우세한 색)
    final dominantColor = palette.dominantColor?.color ?? Colors.black;

    // 배경색을 주요 색으로 설정
    setState(() {
      backgroundColor = dominantColor;

      // 배경색에 맞춰 글귀 색상 결정 (배경이 어두우면 글귀는 밝게, 그 반대)
      textColor = _getContrastingColor(dominantColor);
    });
  }

  Color _getContrastingColor(Color color) {
    // 배경색이 어두운지 밝은지 체크하고 대비되는 색 반환
    double brightness = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue) / 255;
    return brightness < 0.5 ? Colors.white : Colors.black;
  }

  @override
  void dispose() {
    // ScrollController 해제
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = items[currentIndex];

    return Scaffold(
      // 전체 화면 배경 설정
      backgroundColor: backgroundColor, // Scaffold의 배경색을 전체적으로 설정
      body: ListView(
        controller: _scrollController, // ScrollController 추가
        children: [
          // 배경 이미지
          Image.asset(
            currentItem['image']!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          // 텍스트가 포함된 배경 영역
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: backgroundColor, // 배경 색상
            child: Column(
              children: [
                // 글귀 텍스트
                Text(
                  currentItem['quote']!,
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor, // 글귀 색상
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
