import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/src/embeddedCodeType.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DcardEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const DcardEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _DcardEmbeddedCodeWidgetState createState() => _DcardEmbeddedCodeWidgetState();
}

class _DcardEmbeddedCodeWidgetState extends State<DcardEmbeddedCodeWidget> {
  double _aspectRatio = 1;
  late WebViewController _webViewController;

  void _loadHtmlFromAssets(embeddedCode) {
    String html = _getHtml(embeddedCode);
    _webViewController.loadUrl(
      Uri.dataFromString(
        html,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString()
    );
  }

  String _getHtml(String embeddedCode) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=358.0, user-scalable=no, initial-scale=1.0001, maximum-scale=1.0001, minimum-scale=1.0001, shrink-to-fit=no">
  <meta http-equiv="X-UA-Compatible" content="chrome=1">

  <title>Document</title>
  <style>
    body {
      margin: 0;
      padding: 0; 
      background: #F5F5F5;
    }
  </style>
</head>
  <body>
    $embeddedCode
  </body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth/_aspectRatio,
              child: WebView(
                onWebViewCreated: (WebViewController webViewController) {
                  _webViewController = webViewController;
                  _loadHtmlFromAssets(widget.embeddedCode);
                },
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (e) async{
                  await Future.delayed(const Duration(seconds: 1));
                  double? w = double.tryParse(
                    await _webViewController
                        .evaluateJavascript('document.querySelector("body").getBoundingClientRect().width'),
                  );
                  double? h = double.tryParse(
                    await _webViewController
                        .evaluateJavascript('document.querySelector("body").getBoundingClientRect().height'),
                  );

                  if(w != null && h != null) {
                    if(w == 0.0) {
                      w = constraints.maxWidth;
                    }
                    double ratio = w/h;
                    if(ratio != _aspectRatio) {
                      if(mounted) {
                        setState(() {
                          _aspectRatio = ratio;
                        });
                      }
                    }
                  }
                },
              ),
            ),
            InkWell(
              onTap: () async{
                RegExp regExp = EmbeddedCode.getLaunchUrlRegExpByType(EmbeddedCodeType.dcard)!;
                String url = regExp.firstMatch(widget.embeddedCode)!.group(1)!;
                url = Uri.decodeFull(url);

                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Container(
                width: constraints.maxWidth,
                height: constraints.maxWidth/_aspectRatio,
                color: Colors.transparent,
              ),
            ),
          ],
        );
      }
    );
  }
}