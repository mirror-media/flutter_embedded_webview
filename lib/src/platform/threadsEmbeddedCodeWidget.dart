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

  void _log(String message) {
    debugPrint('[ThreadsEmbed] $message');
  }

  @override
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            _log('web_error code=${error.errorCode} type=${error.errorType} desc=${error.description}');
          },
          onPageFinished: (url) {
            _log('page_finished url=$url');
          },
        ),
      )
      ..addJavaScriptChannel(
        'EmbedHeight',
        onMessageReceived: (message) {
          final nextHeight = double.tryParse(message.message);
          if (nextHeight == null ||
              !nextHeight.isFinite ||
              nextHeight < 120 ||
              (nextHeight - _height).abs() < 1) {
            _log('height_ignored raw=${message.message}');
            return;
          }
          if (mounted) {
            setState(() {
              _height = nextHeight;
            });
            _log('height_updated value=$_height');
          }
        },
      )
      ..addJavaScriptChannel(
        'ThreadsDebug',
        onMessageReceived: (message) {
          _log('js ${message.message}');
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
      #widget iframe {
        width: 100% !important;
        min-height: 420px;
        border: 0;
      }
    </style>
    <script type="text/javascript">
      function extractThreadsPermalink() {
        var permalinkFromData = document.querySelector('[data-text-post-permalink]')?.getAttribute('data-text-post-permalink');
        if (permalinkFromData && window.ThreadsDebug) ThreadsDebug.postMessage('permalink:data=' + permalinkFromData);
        if (permalinkFromData) return permalinkFromData;
        var cite = document.querySelector('blockquote[cite]')?.getAttribute('cite');
        if (cite && window.ThreadsDebug) ThreadsDebug.postMessage('permalink:cite=' + cite);
        if (cite) return cite;
        var direct = document.querySelector('a[href*="threads.net/"]')?.getAttribute('href');
        if (direct && window.ThreadsDebug) ThreadsDebug.postMessage('permalink:anchor=' + direct);
        if (direct) return direct;
        if (window.ThreadsDebug) ThreadsDebug.postMessage('permalink:none');
        return null;
      }

      function buildFallbackIframe() {
        var permalink = extractThreadsPermalink();
        if (!permalink) return;
        var normalized = permalink;
        while (normalized.endsWith('/')) {
          normalized = normalized.slice(0, -1);
        }
        var src = normalized.endsWith('/embed') ? normalized : normalized + '/embed';
        var root = document.getElementById('widget');
        if (!root) return;
        if (root.querySelector('iframe')) return;
        root.innerHTML = '';
        var iframe = document.createElement('iframe');
        iframe.src = src;
        iframe.loading = 'lazy';
        iframe.referrerPolicy = 'no-referrer';
        iframe.allow = 'autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share';
        root.appendChild(iframe);
        if (window.ThreadsDebug) ThreadsDebug.postMessage('fallback_iframe=' + src);
      }

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
        if (window.ThreadsDebug) ThreadsDebug.postMessage('height=' + h);
        if (h > 0 && window.EmbedHeight) {
          window.EmbedHeight.postMessage(String(h));
        }
      }

      window.addEventListener('load', function() {
        notifyHeight();
        setTimeout(notifyHeight, 300);
        setTimeout(notifyHeight, 1000);
        setTimeout(function() {
          if (!document.querySelector('#widget iframe')) {
            buildFallbackIframe();
          }
          notifyHeight();
        }, 1600);
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
