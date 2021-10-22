import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YtEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const YtEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  State<YtEmbeddedCodeWidget> createState() => _YtEmbeddedCodeWidgetState();
}

class _YtEmbeddedCodeWidgetState extends State<YtEmbeddedCodeWidget> {
  double _ratio = 16/9;
  late String _initialUrl;

  Future<bool> _setWebviewInitialUrlAndRatio() async{
    try {
      RegExp initialUrlRegExp = RegExp(
        r'src="(https:\/\/www\.youtube\.com\/embed\/\w+)"',
        caseSensitive: false,
      );
      _initialUrl = initialUrlRegExp.firstMatch(widget.embeddedCode)!.group(1)!;
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
      _ratio = w/h;
      return true;
    } catch(e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _setWebviewInitialUrlAndRatio(),
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (snapshot.connectionState == ConnectionState.done) {
              if(snapshot.data!) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth/_ratio,
                  child: WebView(
                    initialUrl: _initialUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (e) {},
                  ),
                );
              }
              
              return Container();
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth/_ratio,
              child: const Center(child: CircularProgressIndicator())
            );
          }
        );
      }
    );
  }
}