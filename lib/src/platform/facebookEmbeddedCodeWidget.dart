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
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  String _getHtml(String embeddedCode, double width) {
    double scale = 1.0001;
    RegExp widthRegExp = RegExp(
      r'width="(.[0-9]*)"',
      caseSensitive: false,
    );
    double facebookIframeWidth =
        double.parse(widthRegExp.firstMatch(widget.embeddedCode)!.group(1)!);
    scale = width / facebookIframeWidth;
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=$scale">
    
    <style>
      *{box-sizing: border-box;margin:0px; padding:0px;}
        #widget {
                  display: flex;
                  justify-content: center;
                  margin: 0 auto;
                  max-width:100%;
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

  JavascriptChannel _getAspectRatioJavascriptChannel() {
    return JavascriptChannel(
        name: 'PageAspectRatio',
        onMessageReceived: (JavascriptMessage message) {
          _setAspectRatio(double.parse(message.message));
        });
  }

  void _setAspectRatio(double aspectRatio) {
    if (aspectRatio != 0) {
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
        child: WebView(
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              _webViewController.loadUrl(Uri.dataFromString(
                _getHtml(widget.embeddedCode, constraints.maxWidth),
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ).toString());
            },
            javascriptChannels: <JavascriptChannel>{
              _getAspectRatioJavascriptChannel(),
            },
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: null,
            onPageFinished: (e) async {
              _webViewController
                  .runJavascript('setTimeout(() => PageAspectRatio(), 0)');
            },
            navigationDelegate: (navigation) async {
              final url = navigation.url;
              if (navigation.isForMainFrame && await canLaunchUrlString(url)) {
                launchUrlString(url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }),
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
