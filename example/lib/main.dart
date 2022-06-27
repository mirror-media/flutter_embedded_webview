import 'package:flutter/material.dart';
import 'package:flutter_embedded_webview/flutter_embedded_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Embedded Webview Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String fbEmbeddedCode =
      '<iframe src="https://www.facebook.com/plugins/video.php?height=476&href=https%3A%2F%2Fwww.facebook.com%2F100000380083001%2Fvideos%2F724999198620696%2F&show_text=true&width=267&t=0" width="267" height="591" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowfullscreen="true" allow="autoplay; clipboard-write; encrypted-media; picture-in-picture; web-share" allowFullScreen="true"></iframe>';

  final String tiktokEmbeddedCode =
      '<blockquote class="tiktok-embed" cite="https://www.tiktok.com/@liuruixue0105/video/7106408699614219521" data-video-id="7106408699614219521" style="max-width: 605px;min-width: 325px;" > <section> <a target="_blank" title="@liuruixue0105" href="https://www.tiktok.com/@liuruixue0105">@liuruixue0105</a> <p></p> <a target="_blank" title="♬ 原聲  - 0105" href="https://www.tiktok.com/music/原聲-0105-7106408721009429250">♬ 原聲  - 0105</a> </section> </blockquote> <script async src="https://www.tiktok.com/embed.js"></script>';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Embedded Webview Demo'),
      ),
      backgroundColor: Colors.yellow,
      body: ListView(
        children: [
          EmbeddedCodeWidget(
            embeddedCode: fbEmbeddedCode,
          ),
          EmbeddedCodeWidget(
            embeddedCode: tiktokEmbeddedCode,
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}