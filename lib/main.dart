import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './models/transaction.dart';
import './widgets/chart_list.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      fontFamily: 'Quicksand',
      primarySwatch: Colors.blueGrey,
      appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      )),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transactions',
      themeMode: ThemeMode.light,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondary: Colors.amber,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [];
  bool _showChart = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  List<Transaction> get _recentTransaction => _userTransactions.where((tx) {
    return tx.date.isAfter(
      DateTime.now().subtract(
        const Duration(days: 7),
      ),
    );
  }).toList();

  void _startAddNewTransaction() => showModalBottomSheet(
        context: context,
        builder: (_) {
          return NewTransaction(_addNewTransaction);
        },
      );

  void _addNewTransaction(Transaction transaction) => setState(() {
        _userTransactions.add(transaction);
        _saveTransactions();
      });

  void _deleteTransaction(String id) => setState(() {
        _userTransactions.removeWhere((element) => element.id == id);
        _saveTransactions();
      });

  Widget _buildLandscapeContent() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Show chart",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).primaryColor,
            value: _showChart,
            onChanged: (value) => setState(() => _showChart = value),
          ),
        ],
      );

  PreferredSizeWidget _buildAppBar() {
    const appName = 'TransactionsApp';
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text(appName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: _startAddNewTransaction,
                  child: const Icon(CupertinoIcons.add),
                )
              ],
            ),
          )
        : AppBar(
            title: const Text(appName),
            actions: <Widget>[
              IconButton(
                onPressed: _startAddNewTransaction,
                icon: const Icon(Icons.add),
              )
            ],
          ) as PreferredSizeWidget;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape &&
        (Platform.isAndroid || Platform.isIOS);
    final PreferredSizeWidget appBar = _buildAppBar();

    // Appbar, StatusBar, content
    final txListWidget = SizedBox(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          (isLandscape ? 0.8 : 0.7),
      child: TransactionList(
        _userTransactions,
        _deleteTransaction,
      ),
    );

    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              SizedBox(
                height: (mediaQuery.size.height -
                        appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                    0.2,
                child: _buildLandscapeContent(),
              ),
            _showChart || !isLandscape
                ? SizedBox(
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                            mediaQuery.padding.top) *
                        (isLandscape ? 0.8 : 0.3),
                    child: ChartList(_recentTransaction),
                  )
                : txListWidget,
            if (!isLandscape) txListWidget,
          ],
        ),
      ),
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: appBar as CupertinoNavigationBar,
            child: pageBody,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButton: Platform.isIOS
                ? const SizedBox.shrink()
                : FloatingActionButton(
                    onPressed: _startAddNewTransaction,
                    child: const Icon(Icons.add),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
          );
  }

  void _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('transactions');
    if (json == null) return;
    final Iterable l = jsonDecode(json);
    final List<Transaction> transactions =
        List<Transaction>.from(l.map((e) => Transaction.fromJson(e)));
    _userTransactions.addAll(transactions);
  }

  void _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(_userTransactions);
    prefs.setString("transactions", json);
  }
}
