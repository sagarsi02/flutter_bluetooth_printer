import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_plus/flutter_bluetooth_plus.dart';
import 'package:flutter_bluetooth_plus_example/PrintPage/print_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GramPower',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headline6: TextStyle(fontSize: 15.0, fontStyle: FontStyle.italic),
        ),
      ),
      home: MyHomePage(title: 'GramPower Bill Generation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  bool _connected = false;
  BluetoothDevice _device;
  String tips = 'No Device Connected';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothManager.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothManager.isConnected;

    bluetoothManager.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothManager.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Connected';
          });
          break;
        case BluetoothManager.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Disconnected';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _onConnect() async {
    if (_device != null && _device.address != null) {
      await bluetoothManager.connect(_device);
    } else {
      setState(() {
        tips = 'please select device';
      });
      print('please select device');
    }
  }

  void _onDisconnect() async {
    await bluetoothManager.disconnect();
  }

/////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothManager.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(
                      tips, 
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothManager.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address),
                            onTap: () async {
                              setState(() {
                                _device = d;
                              });
                            },
                            trailing:
                                _device != null && _device.address == d.address
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                          ))
                      .toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text('connect'),
                          onPressed: _connected ? null : _onConnect,
                        ),
                        SizedBox(width: 10.0),
                        ElevatedButton(
                          child: Text('disconnect'),
                          onPressed: _connected ? _onDisconnect : null,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 170, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Bluetooth Refresh Button
                          StreamBuilder<bool>(
                            stream: bluetoothManager.isScanning,
                            initialData: false,
                            builder: (c, snapshot) {
                              if (snapshot.data) {
                                return FloatingActionButton(
                                  child: Icon(Icons.stop),
                                  onPressed: () => bluetoothManager.stopScan(),
                                  backgroundColor: Colors.red,
                                );
                              } else {
                                return FloatingActionButton(
                                    child: Icon(Icons.refresh),
                                    onPressed: () =>
                                        bluetoothManager.startScan(timeout: Duration(seconds: 4)));
                              }
                            },
                          ),
                          // Print or Next Button

                          // FloatingActionButton(                      
                          //   child: Icon(Icons.print),
                          //   onPressed: _connected ? _sendData : null,
                          // ),
                          _connected ?
                          FloatingActionButton(                      
                            child: Icon(Icons.arrow_circle_right),
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PrintPage()),
                              );
                            },
                          ) : 
                          FloatingActionButton(                      
                            child: Icon(Icons.arrow_circle_right),
                            onPressed: (){
                              final snackBar = SnackBar(
                                content: const Text('Please Connect With Bluetooth Device'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
