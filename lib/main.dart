import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;
const List<String> coolColorNames = <String>[
  'Sarcoline', 'Coquelicot', 'Smaragdine', 'Mikado', 'Glaucous', 'Wenge',
  'Fulvous', 'Xanadu', 'Falu', 'Eburnean', 'Amaranth', 'Australien',
  'Banan', 'Falu', 'Gingerline', 'Incarnadine', 'Labrador', 'Nattier',
  'Pervenche', 'Sinoper', 'Verditer', 'Watchet', 'Zaffre',
];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inflation Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
//      darkTheme: ThemeData(
//        brightness: Brightness.dark,
//      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedColorIndex = 0;


  Widget _buildMenu(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () { },
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: _selectedColorIndex);

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor: CupertinoColors.white,
                onSelectedItemChanged: (int index) {
                  setState(() => _selectedColorIndex = index);
                },
                children: List<Widget>.generate(coolColorNames.length, (int index) {
                  return Center(
                    child: Text(coolColorNames[index]),
                  );
                }),
              ),
            );
          },
        );
      },
      child: _buildMenu(
        <Widget>[
          const Text('Favorite Color'),
          Text(
            coolColorNames[_selectedColorIndex],
            style: const TextStyle(
                color: CupertinoColors.inactiveGray
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //statusbar color https://stackoverflow.com/questions/52489458/how-to-change-status-bar-color-in-flutter
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: CupertinoTheme.of(context).brightness == Brightness.light
            ?  Color(0xfff5f5f5)
            :  Color(0xff1e1e1e),
    ));


    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Inflation Calculator'),
        // We're specifying a back label here because the previous page is a
        // Material page. CupertinoPageRoutes could auto-populate these back
        // labels.
      ),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).brightness == Brightness.light
                ? CupertinoColors.extraLightBackgroundGray
                : CupertinoColors.darkBackgroundGray,
          ),
          child: ListView(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 32.0)),
              _buildColorPicker(context),
            ],
          ),
        ),
      ),
    );
  }
}
