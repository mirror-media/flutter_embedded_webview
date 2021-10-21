enum EmbeddedCodeType {
  facebook,
  instagram,
  twitter,
  tiktok,
  dcard,
  googleMap
}

class EmbeddedCode {
  static EmbeddedCodeType? checkEmbeddedCodeType(String embeddedCode) {
    if(embeddedCode.contains('www.facebook.com/plugins')) {
      return EmbeddedCodeType.facebook;
    } else if(embeddedCode.contains('instagram-media')) {
      return EmbeddedCodeType.instagram;
    } else if(embeddedCode.contains('twitter-tweet')) {
      return EmbeddedCodeType.twitter;
    } else if(embeddedCode.contains('class="tiktok-embed"')) {
      return EmbeddedCodeType.tiktok;
    } else if(embeddedCode.contains('embed.dcard.tw/v1/posts')) {
      return EmbeddedCodeType.dcard;
    } else if(embeddedCode.contains('www.google.com/maps/embed')) {
      return EmbeddedCodeType.googleMap;
    }

    return null;
  }

  static RegExp? getLaunchUrlRegExpByType(EmbeddedCodeType? type) {
    switch(type) {
      case EmbeddedCodeType.facebook:
        // username refer to https://www.facebook.com/help/105399436216001
        // facebook url ex.
        // https://www.facebook.com/ facebookapp              / posts                                / 10160138384851729
        // https://www.facebook.com/ 563994370665617          / videos                               / 397668314698045
        // https://www.facebook.com/ DonDonDonkiTW            / photos           /a.3857266087638216 / 3902755526422605
        // https://www.facebook.com/ permalink.php?story_fbid = 229021587215556  &id                 = 11239244970
        return RegExp(
          r'src="https:\/\/www\.facebook\.com\/plugins\/(?:post|video)\.php\?(?:.*)href=(https?(?:%3A%2F%2F|\:\/\/)www\.facebook\.com(?:%2F|\/)(?:permalink\.php(?:%3F|\?)story_fbid|[a-zA-Z0-9.]+)(?:%2F|\/|=|%3D)(?:posts|videos|photos|[0-9]+)(?:%2F[a-z].[0-9]+|\/[a-z].[0-9]+|\&id|%26id)?(?:%2F|\/|=|%3D)[0-9]+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.instagram:
        return RegExp(
          r'permalink="(https:\/\/www\.instagram\.com\/p\/\w+\/)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.twitter:
        return RegExp(
          r'(https?:\/\/twitter\.com\/\w{1,15}\/status\/\d+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.tiktok:
        return RegExp(
          r'cite="(https:\/\/www.tiktok.com\/.*)" data-video-id="',
          caseSensitive: false,
        );
      case EmbeddedCodeType.dcard:
        return RegExp(
          r'(https:\/\/embed.dcard.tw\/v1\/posts\/[0-9]+)',
          caseSensitive: false,
        );
      case EmbeddedCodeType.googleMap:
        return null;
      default: 
        return null;
    }
  }
}