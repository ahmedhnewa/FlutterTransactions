import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import './adaptive_text_button.dart';
import './adaptive_button.dart';

class NewTransaction extends StatefulWidget {
  const NewTransaction(this.onButtonClick, {Key? key}) : super(key: key);

  final Function onButtonClick;

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _showErrors = false;

  DateTime? _selectedDate;

  String? _validateTitle() {
    if (_titleController.text.isEmpty) {
      return "Title should not be empty";
    }

    return null;
  }

  String? _validateAmount() {
    try {
      final double amount = double.parse(_amountController.text);
      if (amount <= 0) return "The amount should be more than 0";
    } on Exception catch (e) {
      return "Enter a valid amount";
    }

    return null;
  }

  void _submitData() => setState(() {
        _showErrors = true;
        if (_validateAmount() != null || _validateTitle() != null) return;

        final title = _titleController.text;
        final double amount = double.parse(_amountController.text);

        final date = _selectedDate == null ? DateTime.now() : _selectedDate!;
        final transaction = Transaction(
            id: date.millisecondsSinceEpoch.toString(),
            title: title,
            amount: amount,
            date: date);
        widget.onButtonClick(transaction);

        Navigator.of(context).pop();
      });

  void _chooseDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) return;
      setState(() {
        _selectedDate = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Form(
            onChanged: () => setState(() {
              _showErrors = true;
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Title",
                    errorText: _showErrors ? _validateTitle() : null,
                  ),
                  controller: _titleController,
                  onFieldSubmitted: (_) => _submitData(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Amount",
                    errorText: _showErrors ? _validateAmount() : null,
                  ),
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onFieldSubmitted: (_) => _submitData(),
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? "No date chosen"
                              : DateFormat.yMd().format(_selectedDate!),
                        ),
                      ),
                      AdaptiveTextButton("Choose Date", _chooseDate),
                    ],
                  ),
                ),
                AdaptiveButton("Add", _submitData)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
