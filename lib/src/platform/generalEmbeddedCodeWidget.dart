import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GeneralEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;

  const GeneralEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GeneralEmbeddedCodeWidgetState createState() =>
      _GeneralEmbeddedCodeWidgetState();
}

class _GeneralEmbeddedCodeWidgetState extends State<GeneralEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  late WebViewController _webViewController;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PageAspectRatio',
        onMessageReceived: (JavaScriptMessage message) {
          final nextAspectRatio = double.tryParse(message.message);
          if (nextAspectRatio == null) {
            return;
          }
          _setAspectRatio(nextAspectRatio);
        },
      )
      ..loadHtmlString(
        _getHtml(widget.embeddedCode),
        baseUrl: Uri.dataFromString(
          '',
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString(),
      );
    super.initState();
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
  <body>
    <div id="widget">$embeddedCode</div>
    $dynamicAspectRatioScriptSetup
    $dynamicAspectRatioScriptCheck
  </body>
</html>
''';
  }

  void _setAspectRatio(double aspectRatio) {
    if (aspectRatio.isFinite &&
        aspectRatio > 0 &&
        (aspectRatio - _aspectRatio).abs() > 0.01) {
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
        child: WebViewWidget(controller: _webViewController),
      );
    });
  }

  static const String dynamicAspectRatioScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendAspectRatio = () => {
        if (widget.clientHeight > 0) {
          PageAspectRatio.postMessage((widget.clientWidth/widget.clientHeight).toString())
        }
      };
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
