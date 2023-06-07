import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../widgets/loading_animation.dart';

import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
 
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tank Water Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute:LoginScreen.route,
      routes: {
        LoginScreen.route: (context) => LoginScreen(),
        RegistrationScreen.route: (context) => RegistrationScreen(),
        MyHomePage.route: (context) => MyHomePage(),

      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String route = "/main_screen";
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool status = false;
 Map<Object, Object> db;
 DatabaseReference fbdata =  FirebaseDatabase.instance.ref('SYSTEM/');
 
  @override
  Widget build(BuildContext context) {
   fbdata.onValue.listen((DatabaseEvent event) {
}).onData((data) {setState(() {
  print(db);
      db = data.snapshot.value;
    });});
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("SMART AGRITANK"),
          actions: [IconButton(onPressed: (){
             Navigator.pop(context);
     
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.route, (route) => false);
          }, icon: Icon(Icons.logout))],
        ),
        body:SafeArea(
          child: db!=null?Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Column(
                    children: [
                      indicator(context, "Water Level", (double.parse(db['WATER_LEVEL'])).toDouble()),
                     
                    ],
                  ),
                  Column(
                    children: [
                      indicator(context, "Moisture Level", (double.parse(db['MOISTURE_LEVEL'])).toDouble()),
                     
                    ],
                  )
                ],),
                SizedBox(height: 100,),
                ButtonBuilder(context),
              ],
            ),
          ): Center()
        )
      ),
    );
  }
 
  Widget indicator(BuildContext context, String name, double value){
    return CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 13.0,
                animation: true,
                percent: value,
                animateFromLastPercent: true,
                center: new Text(
                  "${value*100}%",
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                footer: new Text(
                  name,
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.purple,
              );
  }

  Widget ButtonBuilder(BuildContext  context){
    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                CupertinoSwitch(
                  activeColor: Colors.purple,
                  value: db['TANK_MOTOR']=="1"?true:false,
                  onChanged: (value) async{
                    
                   if(value){
                      await fbdata.update({'TANK_MOTOR': '1'});
                    }else{
                     await fbdata.update({'TANK_MOTOR': '0'});
                    }
                  },
                ),
                 SizedBox(height: 12.0,),
            Text('Motor', style: TextStyle(
              color: Colors.black,
              fontSize: 20.0
            ),),
              ],
            ),
           
            Column(
              children: [
                CupertinoSwitch(
                  activeColor: Colors.purple,
                  value: db['WATERING_MOTOR']=="1"?true:false,
                  onChanged: (value) async{
                    if(value){
                      await fbdata.update({'WATERING_MOTOR': '1'});
                    }else{
                     await fbdata.update({'WATERING_MOTOR': '0'});
                    }
                  },
                ),
                SizedBox(height: 12.0,),
            Text('Plant', style: TextStyle(
              color: Colors.black,
              fontSize: 20.0
            ),)
              ],
            ),
            
            
          ],
        ),
      ),
    );
  }
}

