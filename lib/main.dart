import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded( () {
    runApp(MyApp());
  }, ( error, stackTrace ) {
    FirebaseCrashlytics.instance.recordError( error, stackTrace );
  });

}

class MyApp extends StatelessWidget {

  final analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage( title: 'Flutter Demo Home Page'),
      navigatorObservers: [
        FirebaseAnalyticsObserver( analytics: analytics ),
      ],
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

  int count1 = 0;
  int count2 = 0;
  String vicTeam = "";
  final String documentId = '5HU0TTNEEkfH1gWfSlUv';

  int _counter = 0;

  _MyHomePageState() {
    print("Init");
  }

  //void didUpdateWidget(MyHomePage oldWidget) {
  //super.didUpdateWidget(oldWidget);
  @override
  void didChangeDependencies() {

    debugPrint('Child widget: didChangeDependencies(), counter = $_counter');
    super.didChangeDependencies();

    // TODO: start a transition between the previous and new value
    print("didChangeDependencies");

    FirebaseFirestore.instance
        .collection('pingpongcount')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {

        setState(() {
          count1 = doc['count1'];
          count2 = doc['count2'];
        });

        print("Counts: ${count1}, ${count2}");
      });
    });

  }

  void updateCount( int cnt1, int cnt2 ) {

    setState(() {

      count1 += cnt1 != 0 ? cnt1 : 0;
      count2 += cnt2 != 0 ? cnt2 : 0;

      if ( count1 > 10 ) {
        vicTeam = "패스트대학 승리";
      } else if ( count2 > 10) {
        vicTeam = "캠퍼스대학 승리";
      } else {
        vicTeam = "";
      }

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),

      body: Column (

        children: <Widget>[

          Container(height: 50),
          Text("탁구 대회", style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold ) ),

          Container(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("패스트 대학"),
              Text("캠퍼스 대학"),
            ],
          ),

          Container(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("${count1}점", style: TextStyle( fontSize: 25, fontWeight: FontWeight.bold ) ),
              Text("$count2점", style: TextStyle( fontSize: 25, fontWeight: FontWeight.bold )),
            ],
          ),

          Container(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () { updateCount( 1, 0 ); },
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () { updateCount( -1, 0 ); },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () { updateCount( 0, 1 ); },
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () { updateCount( 0, -1 ); },
                  ),
                ],
              ),

            ],
          ),

          Container(height: 20),
          GetCounts(documentId),

          Container(height: 20),
          //CountInformation(),

          Container(height: 20),
          Text(vicTeam, style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold, color: Colors.deepOrange ) ),

        ],
      ),

    );
  }
}



class GetCounts extends StatelessWidget {
  final String documentId;

  GetCounts(this.documentId);
  @override
  Widget build(BuildContext context) {
    CollectionReference counts = FirebaseFirestore.instance.collection('pingpongcount');

    return FutureBuilder<DocumentSnapshot>(
      future: counts.doc(documentId).get(),
      builder: ( BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot ) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          //return Text( "Success!");
          Map<String, dynamic> data = snapshot.data.data() as Map<String, dynamic>;
          return Text("Server Counts: ${data['count1']}, ${data['count2']}");
          //return Text("Full Name: ${data['full_name']} ${data['last_name']}");
        }
        //return Text("loading");
        return LinearProgressIndicator();
      },
    );
  }
}


