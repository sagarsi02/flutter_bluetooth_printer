import 'package:flutter/material.dart';
import '../main.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_plus/flutter_bluetooth_plus.dart';
import 'package:flutter_bluetooth_plus_example/PrintPage/print_page.dart';
class PrintPage extends StatefulWidget {
    

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  void _sendData() async {
    String Company_name = 'GramPower';
    List<int> bytes = latin1
        .encode(
            // Company NameF
            '$Company_name\n'
                // Address
                +
                '3rd Floor,Arihant Plaza,Block F,Vaishali Nagar,Jaipur 302021 \n\n'
                // Customer Name and Details
                +
                'Name : Sagar Singh \n Address : A396, Vaishali Nagar, Jaipur \n Designation : Back-end Developer \n Location : Jaipur\n\n\n\n')
        .toList();
    print('\n\n\n');
    print(_sendData);

    await bluetoothManager.writeData(bytes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print Page'),
      ),
      body: Center(
        child: FloatingActionButton(
          child: Icon(Icons.print),
          // onPressed: connected ? _sendData : null,
          onPressed: _sendData,
        ),
      ),
    );
  }
}