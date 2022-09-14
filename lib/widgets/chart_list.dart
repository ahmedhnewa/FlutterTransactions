import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/chart.dart';

class ChartList extends StatelessWidget {
  const ChartList(this.recentTransactions, {Key? key}) : super(key: key);
  final List<Transaction> recentTransactions;

  double totalSpending() {
    return charts.fold(0.0, (sum, item) {
      return sum + item.amount;
    });
  }

  double getSpendingPctOfTotal(Chart e) {
    if (totalSpending() <= 0) return 0;
    return e.amount / totalSpending();
  }

  List<Chart> get charts {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      var totalSum = 0.0;

      for (var i = 0; i < recentTransactions.length; i++) {
        var date = recentTransactions[i].date;
        if (date.day == weekDay.day &&
            date.month == weekDay.month &&
            date.year == weekDay.year) {
          totalSum += recentTransactions[i].amount;
        }
      }

      return Chart(day: DateFormat.E().format(weekDay), amount: totalSum);
    }).reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: charts.map((e) {
            return Expanded(
              child: _ChartBar(e, getSpendingPctOfTotal(e)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final Chart _chartItem;
  final double _pct;

  const _ChartBar(this._chartItem, this._pct);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: <Widget>[
            SizedBox(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(
                child: Text('\$${_chartItem.amount.toStringAsFixed(0)}'),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.05,
            ),
            SizedBox(
              height: constraints.maxHeight * 0.6,
              width: 10,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(220, 220, 220, 1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: _pct,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.05),
            SizedBox(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(child: Text(_chartItem.day)),
            )
          ],
        );
      },
    );
  }
}
