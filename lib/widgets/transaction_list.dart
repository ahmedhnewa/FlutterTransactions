import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '/generated/assets.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> userTransactions;
  final Function deleteItem;

  const TransactionList(this.userTransactions, this.deleteItem, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return userTransactions.isNotEmpty
        ? ListView(
            children: userTransactions.map((e) {
              return _TransactionItem(
                e,
                deleteItem,
                ValueKey(e.id),
              );
            }).toList(),
          )
        : LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.1,
                    child: Text(
                      'No transactions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  SizedBox(
                    height: constraints.maxHeight * 0.9,
                    width: double.infinity,
                    child: Lottie.asset(Assets.lottieNoData),
                  ),
                ],
              );
            },
          );
  }
}

class _TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final Function deleteItem;

  const _TransactionItem(this.transaction, this.deleteItem, Key key)
      : super(key: key);

  @override
  State<_TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<_TransactionItem> {
  late final Color color;

  @override
  void initState() {
    super.initState();
    const availableColors = [
      Colors.redAccent,
      Colors.blue,
      Colors.black,
      Colors.purple
    ];
    final randomIndex = Random().nextInt(availableColors.length);
    color = availableColors[randomIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(
                '\$${widget.transaction.amount.toStringAsFixed(2)}',
              ),
            ),
          ),
        ),
        title: Text(
          widget.transaction.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(widget.transaction.date),
        ),
        trailing: MediaQuery.of(context).size.width > 460
            ? TextButton.icon(
                onPressed: () => widget.deleteItem(widget.transaction.id),
                icon: const Icon(Icons.delete),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).errorColor),
                label: const Text('Delete'),
              )
            : IconButton(
                onPressed: () => widget.deleteItem(widget.transaction.id),
                icon: const Icon(Icons.delete),
                color: Theme.of(context).errorColor,
              ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final Function deleteItem;

  const _TransactionRow(this.transaction, this.deleteItem);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(
              color: Theme.of(context).primaryColor,
              width: 2,
            )),
            child: Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                transaction.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                DateFormat.yMMMd().format(transaction.date),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
