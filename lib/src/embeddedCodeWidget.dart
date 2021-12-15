import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/src/dcardEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/embeddedCodeType.dart';
import 'package:flutter_embedded_webview/src/facebookEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/googleFormsEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/instagramEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/twitterEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/ytEmbeddedCodeWidget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

@immutable
class EmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  final double? aspectRatio;
  
  const EmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
    this.aspectRatio,
  }) : super(key: key);

  @override
  _EmbeddedCodeWidgetState createState() => _EmbeddedCodeWidgetState();
}

class _EmbeddedCodeWidgetState extends State<EmbeddedCodeWidget> with AutomaticKeepAliveClientMixin {
  bool _screenIsReseted = false;
  
  late final EmbeddedCodeType? _embeddedCodeType;
  WebViewController? _webViewController;

  double? _webViewWidth;
  double? _webViewHeight;
  late double _webViewAspectRatio;
  late double _webViewBottomPadding;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _embeddedCodeType = EmbeddedCode.findEmbeddedCodeType(widget.embeddedCode);
    _webViewAspectRatio = widget.aspectRatio ?? 16 / 9;
    _webViewBottomPadding = 16;
    super.initState();
  }

  _loadHtmlFromAssets(String embeddedCode, double width) {
    if(_embeddedCodeType == EmbeddedCodeType.tiktok) {
      RegExp videoIdRegExp = RegExp(
        r'data-video-id="(.[0-9]*)"',
        caseSensitive: false,
      );

      String? videoId = videoIdRegExp.firstMatch(widget.embeddedCode)!.group(1);

      _webViewController!.loadUrl(
        'https://www.tiktok.com/embed/v2/$videoId',
      );
    } else {
      String html = _getHtml(embeddedCode, width);
      _webViewController!.loadUrl(
        Uri.dataFromString(
          html,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString()
      );
    }
  }

  String _getHtml(String embeddedCode, double width) {
    double scale = 1.0001;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=$width, user-scalable=no, initial-scale=$scale, maximum-scale=$scale, minimum-scale=$scale, shrink-to-fit=no">
  <meta http-equiv="X-UA-Compatible" content="chrome=1">

  <title>Document</title>
  <style>
    body {
      margin: 0;
      padding: 0; 
      background: #F5F5F5;
    }
    div.iframe-width {
      width: 100%;
    }
  </style>
</head>
  <body>
    <center>
      <div class="iframe-width">
        $embeddedCode
      </div>
    </center>
  </body>
</html>
        ''';
  }

  // refer to the link(https://github.com/flutter/flutter/issues/2897)
  // webview will cause the device to crash in some physical android device, 
  // when the webview height is higher than the physical device screen height.
  // --------------------------------------------------
  // width : device screen width - 32(padding) 
  // height : device screen height
  // ratio : webview aspect ratio
  // width / ratio + bottomPadding : webview height + bottomPadding(padding)
  bool _isHigherThanScreenHeight(double width, double height, double ratio, double bottomPadding) {
    double webviewHeight = width / ratio;
    return (webviewHeight + bottomPadding) >  height;
  }

  double _getIframeHeight(double width, double height, double ratio, double bottomPadding) {
    if(Platform.isIOS) {
      return width / ratio + bottomPadding;
    }

    return _isHigherThanScreenHeight(width, height, ratio, bottomPadding) 
      ? height 
      : width / ratio + bottomPadding;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 32;
    var height = MediaQuery.of(context).size.height;

    super.build(context);

    if(_embeddedCodeType == EmbeddedCodeType.facebook) {
      return FacebookEmbeddedCodeWidget(embeddedCode: widget.embeddedCode);
    } else if(_embeddedCodeType == EmbeddedCodeType.youtube) {
      return YtEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
        aspectRatio: widget.aspectRatio,
      );
    } else if(_embeddedCodeType == EmbeddedCodeType.dcard) {
      return DcardEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    } else if(_embeddedCodeType == EmbeddedCodeType.googleForms) {
      return GoogleFormsEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    } else if(_embeddedCodeType == EmbeddedCodeType.instagram) {
      return InstagramEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    } else if(_embeddedCodeType == EmbeddedCodeType.twitter) {
      return TwitterEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    }

    return Stack(
      children: [
        // display iframe
        SizedBox(
          width: width,
          height: _getIframeHeight(
            width, 
            height, 
            _webViewAspectRatio, 
            _webViewBottomPadding,
          ),
          child: WebView(
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
              _loadHtmlFromAssets(widget.embeddedCode, width);
            },
            javascriptMode: JavascriptMode.unrestricted,
            gestureRecognizers: null,
            onPageFinished: (e) async{
              _webViewWidth = double.tryParse(
                await _webViewController!
                    .runJavascriptReturningResult("document.documentElement.scrollWidth;"),
              );
              _webViewHeight = double.tryParse(
                await _webViewController!
                    .runJavascriptReturningResult("document.documentElement.scrollHeight;"),
              );
              // reset the webview size
              if(mounted && !_screenIsReseted) {
                setState(() {
                  _screenIsReseted = true;
                  if(_webViewWidth != null && _webViewHeight != null) {
                    _webViewAspectRatio = _webViewWidth!/_webViewHeight!;
                  }
                });
              }
            },
          ),
        ),
        // display watching more widget when meeting some conditions.
        if(_isHigherThanScreenHeight(
              width, height, 
              _webViewAspectRatio, _webViewBottomPadding
            ) && 
            Platform.isAndroid)
          Positioned(
            bottom: 0.0,
            child: _buildWatchingMoreWidget(width),
          ),
        // cover a launching url widget over the iframe 
        // when the iframe is not google map.
        if(_embeddedCodeType != EmbeddedCodeType.googleMap)
          InkWell(
            onTap: (){
              _launchUrl(
                _embeddedCodeType,
                widget.embeddedCode
              );
            },
            child: Container(
              width: width,
              height: _getIframeHeight(
                width, 
                height, 
                _webViewAspectRatio, 
                _webViewBottomPadding
              ),
              color: Colors.transparent,
            ),
          ),
      ],
    );
  }

  Widget _buildWatchingMoreWidget(double width) {
    return Container(
      width: width,
      height: width / 16 * 9 / 3,
      color: Colors.black.withOpacity(0.6),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Center(
          child: Text(
            '點擊觀看更多',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(EmbeddedCodeType? embeddedCodeType, String embeddedCode) async{
    RegExp? regExp = EmbeddedCode.getLaunchUrlRegExpByType(embeddedCodeType);

    if(regExp != null) {
      String url = regExp.firstMatch(embeddedCode)!.group(1)!;
      url = Uri.decodeFull(url);

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
