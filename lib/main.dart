import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spaceattackergame/asteroid_model.dart';
import 'package:spaceattackergame/collision_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Attacker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double shipX = 0.0, shipY = 0.0;
  double maxHeight = 0.0;
  double initialPosition = 0.0;
  double time = 0.0;
  double velocity = 2.9;
  double gravity = -4.9;
  bool isGameRunning = false;
  List<GlobalKey>globalKeys=[];
  GlobalKey shipGlobalkey =GlobalKey();
  int score =0;
  List <AsteroidData>asteroidData=[];
  List<AsteroidData> setAsteroidData (){
     List<AsteroidData> data =[
       AsteroidData(alignment:Alignment(2.9,0.7),size:Size(50, 50)),
       AsteroidData(alignment:Alignment(1.4,-0.7),size:Size(60, 80)),
       AsteroidData(alignment:Alignment(2,-0.9),size:Size(40, 40)),
       AsteroidData(alignment:Alignment(2.3,0.5),size:Size(60, 60)),
     ];
     return data;
   }
   void initialiseGlobalKeys(){
    for(int i=0;i<4;i++){
         globalKeys.add(GlobalKey());
    }
   }
  void startGame() {
    restData();
    isGameRunning = true;
    Timer.periodic(Duration(milliseconds: 30), (timer) {
      time = time + 0.02;
      setState(() {
        maxHeight = velocity * time + gravity * time * time;
        shipY = initialPosition - maxHeight;
        if(isShipCollided()){
          timer.cancel();
          isGameRunning=false;
          // restData();
        }
      });
      moveAsteroid();
    });
  }

  void onJump() {
    setState(() {
      time = 0;
      initialPosition = shipY;
    });
  }
  bool isShipCollided(){
    if(shipY > 1){
      print("Upper Collision");
      return true;
    }else if (checkCollision()){
      return true;
    }else if (shipY < -1.2){
      print("Lower Collision");
      return true;
    }else{
      return false;
    }
  }
  void restData(){
  setState(() {
    asteroidData =setAsteroidData();
    shipX=0.0;
    shipY=0.0;
    maxHeight = 0.0;
    initialPosition = 0.0;
    time = 0.0;
    velocity = 2.9;
    gravity = -4.9;
    score=0;
    isGameRunning = false;
  });

  }

  bool checkCollision(){
    bool isCollided=false;
    RenderBox  shipRenderBox =shipGlobalkey.currentContext!.findRenderObject() as RenderBox;
    List<CollisionData>collisionData =[];
    for(var element in globalKeys){
      RenderBox renderBox = element.currentContext!.findRenderObject() as RenderBox;
      collisionData.add(
          CollisionData(
        sizeOfObject: renderBox.size,
        positionOfBox: renderBox.localToGlobal(Offset.zero),
      ));
    }
    for(var element in collisionData){
        final shipPosition=shipRenderBox.localToGlobal(Offset.zero);
        final asteroidPosition =element.positionOfBox;
        final asteroidSize = element.sizeOfObject;
        final shipSize = shipRenderBox.size;
        bool _isCollided = (
            shipPosition.dx < asteroidPosition.dx + asteroidSize.width &&
            shipPosition.dx + shipSize.width > asteroidPosition.dx &&
            shipPosition.dy<asteroidPosition.dy+asteroidSize.height&&
            shipPosition.dy+shipSize.height>asteroidPosition.dy);
        if(_isCollided){
            isCollided =true;
            print("Collision:$isCollided");
            print("Ap-y:${asteroidPosition.dy}::Sp-y:${shipPosition.dy}");
            print("Ap-x:${asteroidPosition.dx}::Sp-x:${shipPosition.dx}");
            break;
        }else{
          isCollided=false;
        }
    }
    return isCollided;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asteroidData=setAsteroidData();
    initialiseGlobalKeys();
  }
  double generateRandomNumber(){
    Random rand =Random();
    double randomDouble = rand.nextDouble() *(-1.0 -1.0) +1.0;
    return randomDouble;
  }
  void moveAsteroid(){
    Alignment asteroid1=asteroidData[0].alignment;
    Alignment asteroid2=asteroidData[1].alignment;
    Alignment asteroid3=asteroidData[2].alignment;
    Alignment asteroid4=asteroidData[3].alignment;
    if(asteroid1.x >-1.4){
      asteroidData[0].alignment=Alignment(asteroid1.x - 0.02,asteroid1.y);
    }else{
      asteroidData[0].alignment=Alignment(3.9,generateRandomNumber());
    }
    if(asteroid2.x >-1.4){
      asteroidData[1].alignment=Alignment(asteroid2.x - 0.02,asteroid2.y);
    }else{
      asteroidData[1].alignment=Alignment(1.8,generateRandomNumber());
    }
    if(asteroid3.x >-1.4){
      asteroidData[2].alignment=Alignment(asteroid3.x - 0.02,asteroid3.y);
    }else{
      asteroidData[2].alignment=Alignment(3,generateRandomNumber());
    }
    if(asteroid4.x >-1.4){
      asteroidData[3].alignment=Alignment(asteroid4.x - 0.02,asteroid4.y);
    }else{
      asteroidData[3].alignment=Alignment(2.3,generateRandomNumber());
    }
    if(asteroid1.x <=0.021 && asteroid1.x>=0.001){
      score++;
    }
    if(asteroid2.x <=0.021 && asteroid2.x>=0.001){
      score++;
    }
    if(asteroid3.x <=0.021 && asteroid3.x>=0.001){
      score++;
    }
    if(asteroid4.x <=0.021 && asteroid4.x>=0.001){
      score++;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap:isGameRunning? onJump: startGame,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/space.jpg"),
                  fit: BoxFit.cover)),
          child: Stack(
            children: [
              Align(
                alignment: Alignment(shipX, shipY),
                child: Container(
                  key:shipGlobalkey,
                  height: 40,
                  width: 80,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/ship.png"),
                    ),
                  ),
                ),
              ),
              Align(
                alignment:asteroidData[0].alignment,
                child: Container(
                  key: globalKeys[0],
                  height: asteroidData[0].size.height,
                  width: asteroidData[0].size.width,
                  decoration:  BoxDecoration(
                    image: DecorationImage(image: AssetImage(asteroidData[0].path),),
                  ),
                ),
              ),
              Align(
                alignment:asteroidData[1].alignment,
                child: Container(
                  key: globalKeys[1],
                  height: asteroidData[1].size.height,
                  width: asteroidData[1].size.width,
                  decoration:  BoxDecoration(
                    image: DecorationImage(image: AssetImage(asteroidData[1].path),),
                  ),
                ),
              ),
              Align(
                alignment:asteroidData[2].alignment,
                child: Container(
                  key: globalKeys[2],
                  height: asteroidData[2].size.height,
                  width: asteroidData[2].size.width,
                  decoration:  BoxDecoration(
                    image: DecorationImage(image: AssetImage(asteroidData[2].path),),
                  ),
                ),
              ),
              Align(
                alignment:asteroidData[3].alignment,
                child: Container(
                  key: globalKeys[3],
                  height: asteroidData[3].size.height,
                  width: asteroidData[3].size.width,
                  decoration:  BoxDecoration(
                    image: DecorationImage(image: AssetImage(asteroidData[3].path),),
                  ),
                ),
              ),
             isGameRunning
                 ? SizedBox()
                 : Align(
                  alignment:Alignment(0,-0.3),
                  child: Text(
                    "TAP TO PLAY",style: TextStyle(
                    letterSpacing: 4,
                      fontSize: 25,
                      color:Colors.white,
                      fontWeight: FontWeight.bold),
                  ),
             ),
              Align(
                  alignment:Alignment(0,0.95),
                  child: Text(
                    "Score: $score",style: TextStyle(
                      letterSpacing: 4,
                      fontSize: 25,
                      color:Colors.white,
                      fontWeight: FontWeight.bold),))
            ],
          ),
        ),
      ),
    );
  }
}
