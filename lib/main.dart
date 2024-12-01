import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageWordsWithDynamicBackground(),
    );
  }
}

class ImageWordsWithDynamicBackground extends StatefulWidget {
  @override
  _ImageWordsWithDynamicBackgroundState createState() =>
      _ImageWordsWithDynamicBackgroundState();
}

class _ImageWordsWithDynamicBackgroundState
    extends State<ImageWordsWithDynamicBackground> {
  List<Map<String, String>> items = [];
  int currentIndex = 0;
  Color backgroundColor = Colors.black; // 기본 배경 색상
  Color textColor = Colors.white; // 기본 글귀 색상
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 초기 색 추출
    _loadData();

    // ScrollController에 리스너 추가
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadData();  // 스크롤이 끝에 도달하면 추가 데이터를 로드
      }
    });
  }

  // API 호출을 통해 데이터 로드
  Future<void> _loadData() async {
    if (isLoading) return;  // 이미 로딩 중이면 추가 요청을 하지 않음
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://yourapiurl.com/getItems'));

      if (response.statusCode == 200) {
        List<Map<String, String>> newItems = List<Map<String, String>>.from(
            json.decode(response.body).map((item) => {
              "image": item['image'],
              "words": item['words'],
            }));
        setState(() {
          items.addAll(newItems);  // 새 데이터를 리스트에 추가
          currentIndex = items.length - 1;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateColors(String imagePath) async {
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      AssetImage(imagePath),
    );

    final dominantColor = palette.dominantColor?.color ?? Colors.black;
    setState(() {
      backgroundColor = dominantColor;
      textColor = _getContrastingColor(dominantColor);
    });
  }

  Color _getContrastingColor(Color color) {
    double brightness = (0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue) / 255;
    return brightness < 0.5 ? Colors.white : Colors.black;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = items.isNotEmpty ? items[currentIndex] : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView.builder(
        controller: _scrollController,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Column(
            children: [
              // 이미지
              Image.network(
                item['image']!,  // 서버에서 받아온 이미지 URL 사용
                fit: BoxFit.cover,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
              ),
              // 글귀
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: backgroundColor,
                child: Text(
                  item['words']!,
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
