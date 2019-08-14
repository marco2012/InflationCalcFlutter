import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'converionHelper.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

const double _kPickerSheetHeight = 216.0;
const double _kPickerItemHeight = 32.0;
const double cellHeight = 50.0;

const List<String> currencies = <String>[
  '\$ United States Dollar',
  '£ British pound sterling',
  '₤ Italian Lira'
];

class _MoneyData {
  double amount = 0.0;
  int currentValueStart = 1950;
  int currentValueEnd = new DateTime.now().year;
  int currency = 0;
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: 'Inflation Calculator',
//      theme: ThemeData(
//        brightness: Brightness.light,
//      ),
//      darkTheme: ThemeData(
//        brightness: Brightness.dark,
//      ),
//      home: MyHomePage(title: 'Flutter Demo Home Page'),
//    );
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.indigo,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Inflation Calculator',
            theme: theme,
            home: new MyHomePage(title: 'Inflation Calc'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static range(int a, [int stop, int step]) {
    int start;

    if (stop == null) {
      start = 0;
      stop = a;
    } else {
      start = a;
    }

    if (step == 0) throw Exception("Step cannot be 0");

    if (step == null)
      start < stop
          ? step = 1 // walk forwards
          : step = -1; // walk backwards

    // return [] if step is in wrong direction
    return start < stop == step > 0
        ? List<int>.generate(
            ((start - stop) / step).abs().ceil(), (int i) => start + (i * step))
        : [];
  }

  static int startYear = 1775;
  static int lastYear = 2019;
  List<int> years = range(startYear, lastYear + 1);
  int _selectedCurrencyIndex = 0;
  int _selectedStartIndex = 0;
  int _selectedEndIndex = (lastYear) - startYear;

  _MoneyData moneyData = new _MoneyData();

  TextEditingController textFieldController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: '');

  Widget _buildMenu(List<Widget> children, double height) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      height: height,
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
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: _selectedCurrencyIndex);

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor:
                    CupertinoTheme.of(context).scaffoldBackgroundColor,
                onSelectedItemChanged: (int index) {
                  setState(() => _selectedCurrencyIndex = index);
                  moneyData.currency = index;
                  switch (index) {
                    case 0:
                      startYear = 1774;
                      break;
                    case 1:
                      startYear = 1751;
                      break;
                    case 2:
                      startYear = 1861;
                      break;
                  }
                  years = range(startYear, lastYear + 1);
                  _selectedStartIndex = 0;
                  _selectedEndIndex = (lastYear) - startYear;
                },
                children: List<Widget>.generate(currencies.length, (int index) {
                  return Center(
                    child: Text(currencies[index]),
                  );
                }),
              ),
            );
          },
        );
      },
      child: _buildMenu(<Widget>[
        const Text('Currency'),
        Text(
          currencies[_selectedCurrencyIndex],
          style: const TextStyle(color: CupertinoColors.inactiveGray),
        ),
      ], cellHeight),
    );
  }

  Widget _buildStartYearPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: _selectedStartIndex);

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor:
                    CupertinoTheme.of(context).scaffoldBackgroundColor,
                onSelectedItemChanged: (int index) {
                  setState(() => _selectedStartIndex = index);
                  moneyData.currentValueStart = years[index];
                },
                children: List<Widget>.generate(years.length, (int index) {
                  return Center(
                    child: Text(years[index].toString()),
                  );
                }),
              ),
            );
          },
        );
      },
      child: _buildMenu(<Widget>[
        const Text('Start year'),
        Text(
          years[_selectedStartIndex].toString(),
          style: const TextStyle(color: CupertinoColors.inactiveGray),
        ),
      ], cellHeight),
    );
  }

  Widget _buildEndYearPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: _selectedEndIndex);

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor:
                    CupertinoTheme.of(context).scaffoldBackgroundColor,
                onSelectedItemChanged: (int index) {
                  setState(() => _selectedEndIndex = index);
                  moneyData.currentValueEnd = years[index];
                },
                children: List<Widget>.generate(years.length, (int index) {
                  return Center(
                    child: Text(years[index].toString()),
                  );
                }),
              ),
            );
          },
        );
      },
      child: _buildMenu(<Widget>[
        const Text('End year'),
        Text(
          years[_selectedEndIndex].toString(),
          style: const TextStyle(color: CupertinoColors.inactiveGray),
        ),
      ], cellHeight),
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return CupertinoTextField(
      prefix: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Text("Amount")),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      controller: textFieldController,
      clearButtonMode: OverlayVisibilityMode.editing,
      keyboardType: TextInputType.number,
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      placeholder: 'Amount of money to convert',
      onChanged: (newName) {
        setState(() {
          //name = newName;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //set white statusbar at load
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color(0xfff8f8f8)));

    final Size screenSize = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text("Inflation Calculator"),
            trailing: GestureDetector(
              //https://stackoverflow.com/a/56725450/1440037
              onTap: () {
                //https://github.com/Norbert515/dynamic_theme
                DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark);

                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                  statusBarColor:
                      CupertinoTheme.of(context).brightness != Brightness.light
                          ? Color(0xfff8f8f8)
                          : Color(0xff262626),
                ));
              },
              child: Icon(
                CupertinoIcons.gear,
              ),
            ),
          ),
          SliverFillRemaining(
            child: DefaultTextStyle(
              style: CupertinoTheme.of(context).textTheme.textStyle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                      CupertinoTheme.of(context).brightness == Brightness.light
                          ? CupertinoColors.extraLightBackgroundGray
                          : CupertinoColors.darkBackgroundGray,
                ),
                child: ListView(
                  children: <Widget>[
                    _buildAmountField(context),
                    const Padding(padding: EdgeInsets.only(top: 32.0)),
                    _buildCurrencyPicker(context),
                    _buildStartYearPicker(context),
                    _buildEndYearPicker(context),
                    const Padding(padding: EdgeInsets.only(top: 32.0)),
                    Container(
                      width: screenSize.width,
                      child: new CupertinoButton(
                        child: new Text(
                          'Calculate',
                          style: new TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _sendDataToSecondScreen(context);
                        },
                        color: CupertinoColors.activeBlue,
                      ),
                      margin: new EdgeInsets.all(20.0),
                      height: 60.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // get the text in the TextField and start the Second Screen
  void _sendDataToSecondScreen(BuildContext context) {
    String textToSend = textFieldController.text;
    moneyData.amount = num.tryParse(textToSend).toDouble();
    moneyData.currency = _selectedCurrencyIndex;

    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => SecondScreen(
            moneyData: moneyData,
          ),
        ));
  }
}

class SecondScreen extends StatelessWidget {
  final _MoneyData moneyData;

  // receive data from the FirstScreen as a parameter
  SecondScreen({Key key, @required this.moneyData}) : super(key: key);

  double calcInflation() {
    var start = moneyData.currentValueEnd.toString();
    var end = moneyData.currentValueStart.toString();
    var c = conversionHelper();
    var table;
    switch (moneyData.currency) {
      case 0:
        table = c.dollarConversionTable;
        break;
      case 1:
        table = c.poundConversionTable;
        break;
      case 2:
        table = c.liraConversionTable;
        break;
    }
    var oldCPI;
    if (table[end] != null)
      oldCPI = table[end];
    else
      oldCPI = table["2019"];
    var newCPI = table[start];
    var amountWithInflation = (moneyData.amount * (newCPI / oldCPI));
    return amountWithInflation;
//    return FlutterMoneyFormatter(amount: amountWithInflation).output.nonSymbol;
  }

  String getSymbol() {
    switch (moneyData.currency) {
      case 0:
        return "\$";
        break;
      case 1:
        return "£";
        break;
      case 2:
        return "₤";
        break;
    }
  }

  String calcInflationIncrease() {
    return ((calcInflation() * 100) / moneyData.amount).toStringAsFixed(1);
  }

  Widget _buildCard(double horizontalMargin, IconData icon, String title, String subtitle) {
    return Card(
      elevation: 8.0,
      margin:
      new EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 6.0),
      child: Container(
        decoration:
        BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        child: ListTile(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: EdgeInsets.only(right: 12.0),
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(
                        width: 1.0, color: Colors.white24))),
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
//                      Icon(Icons.linear_scale, color: Colors.yellowAccent),
              Text(subtitle,
                  style: TextStyle(color: Colors.white))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //statusbar color https://stackoverflow.com/questions/52489458/how-to-change-status-bar-color-in-flutter
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: CupertinoTheme.of(context).brightness == Brightness.light
          ? Color(0xfff8f8f8)
          : Color(0xff262626),
    ));

    var formattedAmount =
        FlutterMoneyFormatter(amount: moneyData.amount).output.nonSymbol;
    var amountWithInflation =
        FlutterMoneyFormatter(amount: calcInflation()).output.nonSymbol;
    const horizontalMargin = 16.0;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Result'),
        ),
        child: DefaultTextStyle(
          style: CupertinoTheme.of(context).textTheme.textStyle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).brightness == Brightness.light
                  ? CupertinoColors.extraLightBackgroundGray
                  : Color(0xff262626),
            ),
            child: new ListView(children: <Widget>[
              const Padding(padding: EdgeInsets.only(top: 32.0)),
              _buildCard(horizontalMargin, Icons.money_off, "${getSymbol()}$formattedAmount", "${moneyData.currentValueStart}"),
              _buildCard(horizontalMargin, Icons.monetization_on, "${getSymbol()}$amountWithInflation", "${moneyData.currentValueEnd}"),

              Container(
                padding: EdgeInsets.all(horizontalMargin),
                child: Text(
                  "${getSymbol()}${formattedAmount} in ${moneyData.currentValueStart} have the same purchasing power as ${getSymbol()}${amountWithInflation} in ${moneyData.currentValueEnd}.\nIn ${moneyData.currentValueEnd - moneyData.currentValueStart} years, inflation increased by ${calcInflationIncrease()}%",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )
            ]),
          ),
        ));
  }
}
