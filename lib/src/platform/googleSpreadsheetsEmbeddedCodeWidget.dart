import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleSpreadsheetsEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleSpreadsheetsEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleSpreadsheetsEmbeddedCodeWidgetState createState() =>
      _GoogleSpreadsheetsEmbeddedCodeWidgetState();
}

class _GoogleSpreadsheetsEmbeddedCodeWidgetState
    extends State<GoogleSpreadsheetsEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _aspectRatio = _setAspectRatioByIframe(widget.embeddedCode);
  }

  double _setAspectRatioByIframe(String embeddedCode) {
    RegExp widthRegExp = RegExp(
      r'width="(.[0-9]*)"',
      caseSensitive: false,
    );
    RegExp heightRegExp = RegExp(
      r'height="(.[0-9]*)"',
      caseSensitive: false,
    );
    double? iframeWidth = double.tryParse(
        widthRegExp.firstMatch(widget.embeddedCode)?.group(1) ?? '');
    double? iframeHeight = double.tryParse(
        heightRegExp.firstMatch(widget.embeddedCode)?.group(1) ?? '');
    if (iframeWidth == null || iframeHeight == null) {
      return 16 / 9;
    }

    return iframeWidth / iframeHeight;
  }

  String _getHtml(String embeddedCode) {
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=0.85">
    
    <style>
      *{box-sizing: border-box;margin:0px; padding:0px;}
        #widget {
                  display: flex;
                  justify-content: center;
                  margin: 0 auto;
                  max-width:100%;
              }
        iframe{
          margin:0;
          width:100%;
          padding:0px;
        }      
    </style>
  </head>
  <body>
    <div id="widget">$embeddedCode</div>
    $dynamicAspectRatioScriptSetup
    $dynamicAspectRatioScriptCheck
  </body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / _aspectRatio,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(
                  Uri.dataFromString(
                    _getHtml(widget.embeddedCode),
                    mimeType: 'text/html',
                    encoding: Encoding.getByName('utf-8'),
                  ),
                )
            ),
          );
        });
  }

  static const String dynamicAspectRatioScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendAspectRatio = () => PageAspectRatio.postMessage(widget.clientWidth/widget.clientHeight);
    </script>
  """;

  static const String dynamicAspectRatioScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => sendAspectRatio();
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;
}