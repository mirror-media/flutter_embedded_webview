import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FacebookEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const FacebookEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _FacebookEmbeddedCodeWidgetState createState() =>
      _FacebookEmbeddedCodeWidgetState();
}

class _FacebookEmbeddedCodeWidgetState
    extends State<FacebookEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  bool _isVertical = false;
  late WebViewController _webViewController;

  @override
  void initState() {
    _aspectRatio = _setAspectRatioByIframe(widget.embeddedCode);
    super.initState();
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
    double? facebookIframeWidth = double.tryParse(
        widthRegExp.firstMatch(widget.embeddedCode)?.group(1) ?? '');
    double? facebookIframeHeight = double.tryParse(
        heightRegExp.firstMatch(widget.embeddedCode)?.group(1) ?? '');
    if (facebookIframeWidth == null || facebookIframeHeight == null) {
      return 16 / 9;
    }

    if ((facebookIframeWidth / facebookIframeHeight) < 16 / 9) {
      _isVertical = true;
    }

    return facebookIframeWidth / facebookIframeHeight;
  }

  String _getHtml(String embeddedCode, double width) {
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
    <style>
      *{box-sizing: border-box;margin:0px; padding:0px;}
        #widget {
                  display: flex;
                  justify-content: center;
                  margin: 0 auto;
                  max-width:100%;
              }    
        iframe{margin:0;width:100%}  
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

  void _setAspectRatio(double aspectRatio) {
    if (aspectRatio != 0 && _isVertical) {
      setState(() {
        _aspectRatio = aspectRatio;
      });
    }
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
                ..addJavaScriptChannel(
                  'PageAspectRatio',
                  onMessageReceived: (message) {
                    _setAspectRatio(double.parse(message.message));
                  },
                )
                ..loadRequest(Uri.dataFromString(
                  _getHtml(widget.embeddedCode, constraints.maxWidth),
                  mimeType: 'text/html',
                  encoding: Encoding.getByName('utf-8'),
                )),
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