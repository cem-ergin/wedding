import 'package:aycacem/blocs/images/images_bloc.dart';
import 'package:aycacem/blocs/is_loading/is_loading_bloc.dart';
import 'package:aycacem/pages/home_page/home_page.dart';
import 'package:aycacem/pages/info_page/info_page.dart';
import 'package:aycacem/providers/camera_provider.dart';
import 'package:aycacem/providers/user_provider.dart';
import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:splashy_bottom_app_bar/splashy_bottom_app_bar.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CameraProvider(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ImagesBloc(),
          ),
          BlocProvider(
            create: (_) => IsLoadingBloc(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Eralp.builder(
      context: context,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ayca Cem',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List pageStrings = ["Galeri", "Bilgi"];
  final List pages = [
    GalleryPage(),
    InfoPage(),
  ];
  final List<BarItem> barItems = [
    BarItem(
      text: "Galeri",
      iconData: Icons.photo,
      color: Colors.blue,
    ),
    BarItem(
      text: "Bilgi",
      iconData: Icons.info,
      color: Colors.pinkAccent,
    ),
  ];
  @override
  void initState() {
    super.initState();
    timeDilation = 1.25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: SplashyBottomAppBar(
        currentIndex: _currentIndex,
        items: barItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
