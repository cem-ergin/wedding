import 'package:aycacem/pages/info_page/count_time.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatefulWidget {
  InfoPage({Key key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Bilgi"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 16),
          Text("KONUM"),
          Text(
            "Resmin üstüne tıklayarak konum alabilirsiniz",
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                _launchMapsUrl(40.8757508, 26.640345619);
                //https://www.google.com/maps/place/ilkim+d%C3%BC%C4%9F%C3%BCn+salonu/@40.8757508,26.6403456,19z/data=!3m1!4b1!4m5!3m4!1s0x14b3c7ee5c91875b:0xba472159d66f578!8m2!3d40.8757498!4d26.6408928?hl=tr
              },
              child: Container(
                height: _size.height * 0.3,
                width: _size.width,
                child: Image.asset("assets/images/salon.png"),
              ),
            ),
          ),
          Divider(),
          Text("KALAN ZAMAN"),
          CountTime(),
        ],
      ),
    );
  }

  void _launchMapsUrl(double lat, double lon) async {
    // final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    final url =
        "https://www.google.com/maps/place/ilkim+d%C3%BC%C4%9F%C3%BCn+salonu/@40.8757508,26.6403456,19z/data=!3m1!4b1!4m5!3m4!1s0x14b3c7ee5c91875b:0xba472159d66f578!8m2!3d40.8757498!4d26.6408928?hl=tr";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
