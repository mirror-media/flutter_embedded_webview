import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreadsEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;

  const ThreadsEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  State<ThreadsEmbeddedCodeWidget> createState() =>
      _ThreadsEmbeddedCodeWidgetState();
}

class _ThreadsEmbeddedCodeWidgetState extends State<ThreadsEmbeddedCodeWidget> {
  late final WebViewController _webViewController;
  double _height = 400;

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'EmbedHeight',
        onMessageReceived: (message) {
          final nextHeight = double.tryParse(message.message);
          if (nextHeight == null ||
              !nextHeight.isFinite ||
              nextHeight < 120 ||
              (nextHeight - _height).abs() < 1) {
            return;
          }
          if (mounted) {
            setState(() {
              _height = nextHeight;
            });
          }
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: _height,
        child: WebViewWidget(controller: _webViewController),
      ),
    );
  }

  String _getHtml(String embeddedCode) {
    final normalizedCode = embeddedCode.contains('threads.net/embed.js')
        ? embeddedCode
        : '$embeddedCode<script async src="https://www.threads.net/embed.js"></script>';
    return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        overflow-x: hidden;
        background: transparent;
      }
      #widget {
        width: 100%;
      }
    </style>
    <script type="text/javascript">
      function getHeight() {
        var body = document.body;
        var html = document.documentElement;
        return Math.max(
          body ? body.scrollHeight : 0,
          body ? body.offsetHeight : 0,
          html ? html.clientHeight : 0,
          html ? html.scrollHeight : 0,
          html ? html.offsetHeight : 0
        );
      }

      function notifyHeight() {
        var h = getHeight();
        if (h > 0 && window.EmbedHeight) {
          window.EmbedHeight.postMessage(String(h));
        }
      }

      window.addEventListener('load', function() {
        notifyHeight();
        setTimeout(notifyHeight, 300);
        setTimeout(notifyHeight, 1000);
        setTimeout(notifyHeight, 2500);
      });
    </script>
  </head>
  <body>
    <div id="widget">$normalizedCode</div>
  </body>
</html>
''';
  }
}
