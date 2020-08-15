import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:mig/batch.dart';
import 'package:mig/qr.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'extensions.dart';
import 'generateQr.dart';
import 'namechange.dart';

const greenPercent = Color(0xff14c4f7);

class AddMachineList extends StatefulWidget {
  @override
  _AddMachineListState createState() => _AddMachineListState();
}

class _AddMachineListState extends State<AddMachineList> {
  var box = Hive.box('myBox');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF1c6b92),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop()),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
      ),
      appBar: AppBar(
          backgroundColor: Color(0xFF1c6b92),
          title: Text('Machine Setup',
              style: TextStyle(
                color: Color(0xffFFFFFF),
              ))),
      body: SafeArea(
        child: StreamBuilder(
          stream:
              Firestore.instance.collection(box.get('companyId')).snapshots(),
          builder: (context, snapshot) {
            assert(snapshot != null);
            if (!snapshot.hasData) {
              return Text('Please Wait');
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot machines = snapshot.data.documents[index];
                  return MachineItem(
                    name: machines['name'],
                    c_percent: machines['coolant-percent'],
                    last_updated: machines['last-updated'].substring(0, 10),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1c6b92),
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  height: 250,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Machine',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => _handleWidget()));
                          },
                          onLongPress: () => {},
                          child: Container(
                              height: 50,
                              width: 300,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Colors.lightBlue,
                                    Colors.lightBlueAccent
                                  ])),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_applications,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' Add Machine',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        ),
                      ).padding(),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        _handleWidgetBatch()));
                          },
                          onLongPress: () => {},
                          child: Container(
                              height: 50,
                              width: 300,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Colors.blue,
                                    Colors.blueAccent
                                  ])),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ' Batch Add',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        ),
                      ).padding(),
                    ],
                  ).padding(),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MachineItem extends StatelessWidget {
  final String docRef;
  final String name;
  final String last_updated;
  final String c_percent;
  final dynamic notes;

  MachineItem(
      {this.name, this.last_updated, this.c_percent, this.notes, this.docRef});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Card(
          color: Color(0xFFffffff),
          elevation: 3.0,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ExpandablePanel(
              header: Text(
                name != null ? name : 'Name',
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey[500]),
              ),
              collapsed: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(last_updated != null ? last_updated : 'LastUpdated'),
                  Card(
                    color: double.parse(c_percent) < 6
                        ? Colors.grey[200]
                        : greenPercent,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Text(
                        c_percent != null ? c_percent : 'Coolant Percent',
                        style: TextStyle(
                            fontSize: 24.0,
                            color: double.parse(c_percent) < 6
                                ? Color(0xFFff0000)
                                : Colors.white),
                      ),
                    )),
                  )
                ],
              ),
              expanded: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Text(last_updated != null
                            ? last_updated
                            : 'LastUpdated'),
                      ],
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateMachinePage(docRef, name),
                          ),
                        );
                      },
                      onLongPress: () => {},
                      child: Container(
                        height: 40,
                        width: 350,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(colors: [
                              Colors.lightBlue[300],
                              Colors.lightBlue[400]
                            ])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Enter Coolant %',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      8,
                      0,
                      8,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNamePage(docRef),
                          ),
                        );
                      },
                      onLongPress: () => {},
                      child: Container(
                          height: 40,
                          width: 350,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: LinearGradient(colors: [
                                Color(0xFF1c6b92),
                                Color(0xFF217ca9)
                              ])),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Edit Name',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              )
                            ],
                          )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GenerateScreen(
                            name: name,
                            docRef: docRef,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => {},
                    child: Container(
                        height: 40,
                        width: 350,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                                colors: [Colors.blueGrey, Colors.blueGrey])),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Generate Qr Code',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddMachinePage extends StatefulWidget {
  AddMachinePage({Key key}) : super(key: key);

  @override
  _AddMachinePageState createState() => _AddMachinePageState();
}

class _AddMachinePageState extends State<AddMachinePage> {
  var time = new DateTime.now();

  static const double _topSectionTopPadding = 50.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  String _inputErrorText;
  final TextEditingController _textController = TextEditingController();

  String name;

  TextEditingController controller;
  String cmin;
  String cmax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            var box = Hive.box('myBox');
            Firestore.instance
                .collection(box.get('companyId'))
                .document("$name")
                .setData({
              "name": "$name",
              "coolant-percent": "0.0",
              "last-updated": "$time",
              "last-cleaned": "$time",
              "c-min": "$cmin",
              "c-max": "$cmax"
            });
            Firestore.instance
                .collection(box.get('companyId'))
                .document("$name")
                .collection('notes')
                .document("$time")
                .setData({"note": "No Notes", "time": "$time"});
            Firestore.instance
                .collection(box.get('companyId'))
                .document("$name")
                .collection('history')
                .document("$time")
                .setData({"data": "0.0", "time": "$time"});
            Navigator.pop(context);
          }),
      appBar: AppBar(
        title: Text('Add Machine'),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1c6b92),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file(_dataString, '$_dataString.png', pngBytes, 'image/png');
    } catch (e) {
      print(e.toString());
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 5),
            child: Text(
              "Add a Machine",
              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 20.0,
              right: 10.0,
              bottom: _topSectionBottomPadding,
            ),
            child: Container(
              height: _topSectionHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            name = value;
                          });
                        },
                        controller: controller,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Add Machine Name',
                            labelStyle: TextStyle(fontSize: 15)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FlatButton(
                      color: Colors.blueAccent[700],
                      child: Text(
                        "Get QR",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          _dataString = _textController.text;
                          _inputErrorText = null;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cmin = value;
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Min',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        cmax = value;
                      });
                    },
                    controller: controller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Max',
                        labelStyle: TextStyle(fontSize: 15)),
                  ),
                ),
              ),
            ],
          ).padding(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RepaintBoundary(
                      key: globalKey,
                      child: QrImage(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        data: _dataString,
                        size: 0.4 * bodyHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _handleWidget() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('myBox').listenable(),
    builder: (BuildContext context, box, Widget child) {
      var isAdmin = box.get('admin');
      if (isAdmin == false) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF1c6b92),
            ),
            body: Center(
                child: Text("Denied: Must be an Administrator",
                    style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ))));
      } else {
        return AddMachinePage();
      }
    },
  );
}

Widget _handleWidgetBatch() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('myBox').listenable(),
    builder: (BuildContext context, box, Widget child) {
      var isAdmin = box.get('admin');
      if (isAdmin == false) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF1c6b92),
            ),
            body: Center(
                child: Text("Denied: Must be an Administrator",
                    style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ))));
      } else {
        return BatchAddPage();
      }
    },
  );
}
