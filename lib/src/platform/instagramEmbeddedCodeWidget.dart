import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InstagramEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const InstagramEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _InstagramEmbeddedCodeWidgetState createState() => _InstagramEmbeddedCodeWidgetState();
}

class _InstagramEmbeddedCodeWidgetState extends State<InstagramEmbeddedCodeWidget> {
  double _aspectRatio = 16/9;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  String _getHtml(String embeddedCode) {
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
    </style>
  </head>
  <script src="https://www.instagram.com/embed.js"></script>
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
    if(aspectRatio != 0) {
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
          height: constraints.maxWidth/_aspectRatio,
          child: WebView(
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              _webViewController.loadUrl(Uri.dataFromString(
                _getHtml(widget.embeddedCode),
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ).toString());
            },
            javascriptChannels:
                <JavascriptChannel> {
                  _getAspectRatioJavascriptChannel(),
                },
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: null,
            onPageFinished: (e) async{
              await _webViewController.runJavascript('instgrm.Embeds.process();');

              _webViewController.runJavascript('setTimeout(() => PageAspectRatio(), 0)');
            },
            navigationDelegate: (navigation) async {
              final url = navigation.url;
              if (navigation.isForMainFrame && await canLaunch(url)) {
                launch(url);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }
          ),
        );
      }
    );
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