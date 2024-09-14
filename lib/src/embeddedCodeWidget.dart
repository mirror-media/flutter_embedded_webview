import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/src/platform/dcardEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/embeddedCodeType.dart';
import 'package:flutter_embedded_webview/src/platform/facebookEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/generalEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleDocsEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleFormsEmbeddedCodeWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleMapEmbeddedWidget.dart';
import 'package:flutter_embedded_webview/src/platform/googleSpreadsheetsEmbeddedCodeWidget.dart';
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

class _EmbeddedCodeWidgetState extends State<EmbeddedCodeWidget>
    with AutomaticKeepAliveClientMixin {
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

    switch (_embeddedCodeType) {
      case EmbeddedCodeType.facebook:
        return Container();
        return FacebookEmbeddedCodeWidget(embeddedCode: widget.embeddedCode);
      case EmbeddedCodeType.instagram:
        return InstagramEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.twitter:
        return TwitterEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.tiktok:
        return TiktokEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.dcard:
        return DcardEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleForms:
        return GoogleFormsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleMap:
        return GoogleMapEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.youtube:
        return YtEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
          aspectRatio: widget.aspectRatio,
        );
      case EmbeddedCodeType.googleDocs:
        return GoogleDocsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      case EmbeddedCodeType.googleSpreadsheets:
        return GoogleSpreadsheetsEmbeddedCodeWidget(
          embeddedCode: widget.embeddedCode,
        );
      default:
        return GeneralEmbeddedCodeWidget(embeddedCode: widget.embeddedCode);
    }
  }
}
