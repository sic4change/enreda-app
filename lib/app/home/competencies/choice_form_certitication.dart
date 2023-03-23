import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}


class _MyFormState extends State<MyForm> {
  int _selectedChoice = 0;

  void _selectChoice(int choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  void _handleSubmit() {
    if (_selectedChoice == 0) {
      // Handle option 1
    } else {
      // Handle option 2
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ChoiceChip(
              label: Text('Option 1'),
              selected: _selectedChoice == 0,
              onSelected: (bool selected) {
                _selectChoice(0);
              },
            ),
            SizedBox(width: 10),
            ChoiceChip(
              label: Text('Option 2'),
              selected: _selectedChoice == 1,
              onSelected: (bool selected) {
                _selectChoice(1);
              },
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
