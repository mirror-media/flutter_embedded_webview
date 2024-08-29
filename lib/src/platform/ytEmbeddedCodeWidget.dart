import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YtEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  final double? aspectRatio;

  const YtEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<YtEmbeddedCodeWidget> createState() => _YtEmbeddedCodeWidgetState();
}

class _YtEmbeddedCodeWidgetState extends State<YtEmbeddedCodeWidget> {
  late double _aspectRatio;
  late String? _initialUrl;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // 设置初始URL
    _initialUrl = _getWebviewInitialUrl();

    // 设置纵横比
    if (widget.aspectRatio == null) {
      _aspectRatio = _getWebviewAspectRatio();
    } else {
      _aspectRatio = widget.aspectRatio!;
    }

    // 初始化WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(_initialUrl!));

  }

  String? _getWebviewInitialUrl() {
    try {
      RegExp initialUrlRegExp = RegExp(
        r'src="(https:\/\/www\.youtube\.com\/embed\/\w+)"',
        caseSensitive: false,
      );
      String initialUrl = initialUrlRegExp.firstMatch(widget.embeddedCode)!.group(1)!;
      return initialUrl;
    } catch (e) {
      return null;
    }
  }

  double _getWebviewAspectRatio() {
    try {
      RegExp widthRegExp = RegExp(
        r'width="(.[0-9]*)"',
        caseSensitive: false,
      );
      RegExp heightRegExp = RegExp(
        r'height="(.[0-9]*)"',
        caseSensitive: false,
      );
      double w = double.parse(widthRegExp.firstMatch(widget.embeddedCode)!.group(1)!);
      double h = double.parse(heightRegExp.firstMatch(widget.embeddedCode)!.group(1)!);
      return w / h;
    } catch (e) {
      return 16 / 9;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialUrl == null) {
      return Container();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth / _aspectRatio,
          child: WebViewWidget(
            controller: _controller,
          ),
        );
      },
    );
  }
}