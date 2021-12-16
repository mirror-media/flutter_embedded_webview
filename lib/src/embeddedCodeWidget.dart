import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/src/platform/dcardEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/embeddedCodeType.dart';
import 'package:flutter_embedded_webview/src/platform/facebookEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/generalEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleFormsEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleMapEmbeddedWidget.dart';
import 'package:flutter_embedded_webview/src/platform/instagramEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/tiktokEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/twitterEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/ytEmbeddedCodeWidget.dart';

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
  late final EmbeddedCodeType? _embeddedCodeType;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _embeddedCodeType = EmbeddedCode.findEmbeddedCodeType(widget.embeddedCode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
    } else if(_embeddedCodeType == EmbeddedCodeType.tiktok) {
      return TiktokEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    } else if(_embeddedCodeType == EmbeddedCodeType.googleMap) {
      return GoogleMapEmbeddedCodeWidget(
        embeddedCode: widget.embeddedCode,
      );
    } 

    return GeneralEmbeddedCodeWidget(embeddedCode: widget.embeddedCode);
  }
}
