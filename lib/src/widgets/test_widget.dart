/// Flutter code sample for showModalBottomSheet

// This example demonstrates how to use `showModalBottomSheet` to display a
// bottom sheet that obscures the content behind it when a user taps a button.
// It also demonstrates how to close the bottom sheet using the [Navigator]
// when a user taps on a button inside the bottom sheet.

import 'package:flutter/material.dart';

/// This is the main application widget.
class Test extends StatelessWidget {

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MyStatelessWidget();
      
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Text('context');
            },
          );
        },
      ),
    );
  }



  


}
