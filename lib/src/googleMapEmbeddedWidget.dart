import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleMapEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleMapEmbeddedCodeWidgetState createState() => _GoogleMapEmbeddedCodeWidgetState();
}

class _GoogleMapEmbeddedCodeWidgetState extends State<GoogleMapEmbeddedCodeWidget> {
  final double _aspectRatio = 8/7;
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
                  justify-content: left;
                  margin: 0 auto;
                  max-width:100%;
              }      
    </style>
  </head>
  <body>
    <div id="widget">$embeddedCode</div>
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
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: null,
            navigationDelegate: (navigation) async {
              final url = navigation.url;
              if(navigation.isForMainFrame ||
                url.startsWith('https://maps.google.com/maps?q=') ||
                url.startsWith('https://www.google.com/maps/embed')) {
                return NavigationDecision.navigate;
              } else if(await canLaunch(url)) {
                launch(url);
                return NavigationDecision.prevent;
              }
              
              return NavigationDecision.prevent;
            }
          ),
        );
      }
    );
  }
}