import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/%20DataHandler/appData.dart';
import 'package:rider_app/Assistants/resquestAssitant.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods {

  ///**************************************afno location dine wala **************************************///

  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyBq2VipXviy3jvfa_4ZNvrcJJ1muIdTv7U";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      // placeAddress = response['results'][0]['formatted_address'];
      st1 = response["results"][0]["address_components"][0]
          ["long_name"]; //society
      st2 = response["results"][0]["address_components"][1]
          ["long_name"]; //society
      st3 = response["results"][0]["address_components"][5]
          ["long_name"]; //society
      st4 = response["results"][0]["address_components"][6]
          ["long_name"]; //society

      placeAddress = st1 + ", " + st2 + ", " + st3; //concating

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return placeAddress;
  }


  //*************************************Direction api used *****************************************//

  static Future<DirectionDetails> obtainDirectionDetails(LatLng initialPosition ,LatLng finalPosition)async{
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude} &key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints=res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText=res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue=res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText=res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue=res["routes"][0]["legs"][0]["duration"]["value"];


    return directionDetails;




  }

  //**********************************fare calculation per km ****************************//

  static int calculatefares(DirectionDetails directionDetails){
    //interms of USD//for each minute we are charging $.20
    double timeTraveledfare = (directionDetails.durationValue/60) * 0.10;
    //per km $.20
    double distanceTraveledfare = (directionDetails.distanceValue/1000) * 0.10;

    double totalFareAmount = timeTraveledfare + distanceTraveledfare;


    //1$ = 120

   double totalLocalAmount =  totalFareAmount * 120;

   return totalLocalAmount.truncate();

  }

  //getting current user inforamtion

  static void getCureentOnlineUserInfo() async{
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;

    DatabaseReference reference = 
    FirebaseDatabase.instance.reference().child("users").child(userId);



    reference.once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value!=null){
        userCurrentInfo = Users.fromSnapshot(dataSnapshot);

      }
    });

  }


}
