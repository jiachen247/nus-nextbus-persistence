import 'dart:async';
import 'dart:io';
import 'package:nus_nextbus_api/nus_nextbus_api.dart';
import 'package:nus_nextbus_api/src/models/BusStop.dart';
import 'package:nus_nextbus_api/src/models/BusStops.dart';
import 'package:nus_nextbus_api/src/models/Route.dart';
import 'package:nus_nextbus_api/src/models/RouteStop.dart';
import 'package:nus_nextbus_persistence/StaticSource.dart';

class NusNextbusPersistence {
  NusNextBusApi api = new NusNextBusApi();

  final String NULL = "NULL";

  final String BUILD_DIRECTORY = "build";
  final String TEMPLATE_DIRECTORY = "template";

  final String INIT_DB_FILENAME = "1-init.sql";
  final String POPULATE_INTERNAL_OPERATING_HOURS = "2-populate-operating-hours.sql";
  final String POPULATE_INTERNAL_FREQUENCY  = "3-populate-ifrequency.sql";
  final String POPULATE_INTERNAL_SERVICES = "4-populate-iservices.sql";
  final String POPULATE_EXTERNAL_SERVICES = "5-populate-eservices.sql";
  final String POPULATE_STOPS_DB_FILENAME = "6-populate-stops.sql";
  final String POPULATE_INTERNAL_ROUTE = "7-populate-iroutes.sql";
  final String POPULATE_EXTERNAL_ROUTE = "8-populate-eroutes.sql";

  final String STOP_TABLE_NAME = "Stop";
  final String ISERVICE_TABLE_NAME = "IService";
  final String IOPERATING_HOURS_TABLE_NAME = "IOperatingHours";
  final String IFREQUENCY_TABLE_NAME = "IFrequency";
  final String IROUTE_TABLE_NAME = "IRoute";

  final String ESERVICES_TABLE_NAME = "EService";
  final String EROUTE_TABLE_NAME = "ERoute";

  StaticSource source = new StaticSource();

  Map staticIServices;
  List staticEServices;
  Map staticStops;
  Map staticFrequency;
  Map staticOperatingHours;
  Map staticERoutes;

  Future generateSqlScripts() async {
    await _initialize();

    /*

      Order for insert
      1. IOperatingHours
      2. IFrequency
      3. IService
      4. EService
      5. Stop
      6. IRoute
     */

    //await generateStops();

    //await generateIServices();

    //await generateIFrequency();


    await generateIOperatingHours();
    await generateIFrequency();
    await generateIServices();
    await generateEServices();
    await generateStops();
    await generateIRoute();
    await generateERoute();

    print("finished yay :)");
  }

  String _isNullFormat(String s){
      if(s == null) return NULL;
      else return "'${s}'";
  }
  String _isNullFormatDouble(String s){
      if(s == null) return NULL;
      else return "\"${s}\"";
  }

  Future _initialize()async {
    print("[+] initializing...");

    var directory = new Directory("./${BUILD_DIRECTORY}");

    if(directory.existsSync()){
      print("[=] './${BUILD_DIRECTORY}' exist - deleting folder and everything in it...");
      directory.deleteSync(recursive: true);
    }
    print("[=] creating build directory: './${BUILD_DIRECTORY}'");
    directory.createSync(recursive: true);


    new File("./${TEMPLATE_DIRECTORY}/${INIT_DB_FILENAME}")
      ..copySync("./${BUILD_DIRECTORY}/${INIT_DB_FILENAME}");


    print("[+] Init static data...");
    staticIServices = await source.getStaticIServices();
    staticEServices = await source.getStaticEServices();
    staticStops = await source.getStaticStops();
    staticFrequency = await source.getStaticFrequency();
    staticOperatingHours = await source.getStaticOperatingHours();
    staticERoutes = await source.getStaticERoutes();

  }

    Future generateStops() async {
    print("[+] generating stops!!!");

    BusStops stops = await api.getBusStops();

    BusStop getStop(String busStopCode){

      BusStop s = null;

      stops.busStops.forEach((BusStop stop){
        if(stop.name == busStopCode) s= stop;
      });

      return s;
    }


    List staticStopsData = staticStops["data"];

    File stopSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_STOPS_DB_FILENAME}")..createSync();
    IOSink sink = stopSqlFile.openWrite();

    sink.write('-- NusNextbusPersistence: Stop Table --\r\n');
    sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");

    staticStopsData.forEach((Map staticStop){
      String icode = staticStop["name"];
      String ecode = staticStop["lta_code"];


      BusStop stop = getStop(icode);


        icode = _isNullFormat(icode);
        ecode = _isNullFormat(ecode);

      String caption = stop==null?null:_isNullFormatDouble(stop.caption);
      String description = _isNullFormatDouble(staticStop["description"]);
      String roadName = _isNullFormatDouble(staticStop["road_name"]);

      double lat = (stop==null?staticStop["latitude"]:stop.latitude);
      double long = (stop==null?staticStop["longitude"]:stop.longitude);




      sink.write("INSERT INTO 'Stop' ('icode','ecode' ,'caption' ,'description' ,'roadName' ,'latitude', 'longitude') "
          "VALUES (${icode},${ecode},${caption},${description}, ${roadName}, ${lat}, ${long});\n");
    });

    sink.write("\r\n\r\n -- EOF --");
    sink.close();


  }

    Future generateIServices() async {
        print("[+] generating i services!!!");
        List staticServicesData = staticIServices["data"];

        String serviceCode;
        String express;
        String frequency;
        String operatingHours;
        String remarks;

        File stopSqlFile = new File(
            "./${BUILD_DIRECTORY}/${POPULATE_INTERNAL_SERVICES}")
            ..createSync();
        IOSink sink = stopSqlFile.openWrite();

        sink.write('-- NusNextbusPersistence: IService Table --\r\n');
        sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");

        staticServicesData.forEach((Map json) {
            serviceCode = _isNullFormat(json["serviceCode"]);
            express = json["express"] ? "TRUE" : "FALSE";
            frequency = _isNullFormat(json["frequency"]);
            operatingHours = _isNullFormat(json["operating_hours"]);

            remarks = _isNullFormat(json["remarks"]);


            sink.write("INSERT INTO 'IService' VALUES ("
                "${serviceCode}, ${express}, ${frequency}, ${operatingHours}, ${remarks} "
                ");\r\n");
        });

    sink.write("\r\n\r\n -- EOF --");
    sink.close();
  }

  Future generateIFrequency() async{

      print("[+] generating i frequency!!!");

      File freqSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_INTERNAL_FREQUENCY}")..createSync();
      IOSink sink = freqSqlFile.openWrite();

      sink.write('-- NusNextbusPersistence: IFrequency Table --\r\n');
      sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");

      String serviceGroup;
      int chronology;
      String timeRange;
      bool peak;
      bool semester;
      String weekday;
      String saturday;
      String sundayPh;

      int insertFrequency(String serviceGroup, int chronology, String timeRange,
          bool peak, bool semester, String weekday, String saturday, String sundayPH){

          sink.write("INSERT INTO '${IFREQUENCY_TABLE_NAME}' VALUES ("
          "'${serviceGroup}', ${chronology}, ${timeRange}, ${peak}, ${semester}, ${weekday}, ${saturday}, ${sundayPh}"
          ");\r\n");
      }

      staticFrequency.forEach((String k, Map v) {
          int index = 0;
          serviceGroup = k;

          List semesterData = v["semester"];
          List vacationData = v["vacation"];

          if (semesterData != null) {
              semesterData.forEach((Map sem) {
              semester = true;
              chronology = index++;

              timeRange = _isNullFormat(sem["timing"]);
              peak = sem["peak"];

              weekday = _isNullFormat(sem["weekdays"]);
              saturday = _isNullFormat(sem["saturdays"]);
              sundayPh = _isNullFormat(sem["sundaysPh"]);

              insertFrequency(
                 serviceGroup,
                  chronology,
                  timeRange,
                  peak,
                  semester,
                  weekday,
                  saturday,
                  sundayPh);
              });
          }

          if (vacationData != null) {
              index = 0;
              vacationData.forEach((Map vac) {
                  semester = false;
                  chronology = index++;

                  timeRange = _isNullFormat(vac["timing"]);
                  peak = vac["peak"];

                  weekday = _isNullFormat(vac["weekdays"]);
                  saturday = _isNullFormat(vac["saturdays"]);
                  sundayPh = _isNullFormat(vac["sundaysPh"]);


                  insertFrequency(
                      serviceGroup,
                      chronology,
                      timeRange,
                      peak,
                      semester,
                      weekday,
                      saturday,
                      sundayPh);
              });
          };
      });
      sink.write("\r\n\r\n -- EOF --");
      sink.close();

  }

  Future<List> generateIRoute() async {

      getListOfServices(){
          List<String> services = [];
          
          staticIServices["data"].forEach((Map service) => services.add(service["serviceCode"]));
          return services;
      }
      print("[+] generating internal route!!!");

      File irouteSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_INTERNAL_ROUTE}")..createSync();
      IOSink sink = irouteSqlFile.openWrite();

      List services = getListOfServices();

      sink.write('-- NusNextbusPersistence: Internal Route Table --\r\n');
      sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");


      int index = 0;
      services.forEach((String serviceCode) async {

          Route route = await api.getRoute(serviceCode);
          index = 0;

          route.routeStops.forEach(await (RouteStop routeStop){

              // Last Bus Stop does not include Bus Stop Id

              if(routeStop.busStopCode == null || routeStop.busStopCode == ""){
                  switch(routeStop.stopName){
                      case "Prince George's Park": {
                            routeStop.busStopCode = "PGPT";
                      }
                      break;
                      case "BIZ 2": {
                          routeStop.busStopCode = "BIZ2";
                      }
                      break;
                    }

                    if(routeStop.stopName.contains("Kent Ridge Bus Terminal")){
                        routeStop.busStopCode = "KR-BT";
                    }
              }



              sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
                  "${_isNullFormat(serviceCode)}, ${_isNullFormat(routeStop.busStopCode)}, "
                  "${index++}, ${_isNullFormatDouble(routeStop.stopName)}"
                  ");\r\n");
          });

      });

      // TODO: A2E is not working to do manually.
      index = 0;
      sink.write("\r\n\r\n-- A2E Special --\r\n ");


      sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
          "\"A2E\", \"LT13\", ${index++}, \"LT13\""
          ");\r\n");

      sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
          "\"A2E\", \"COMCEN\", ${index++}, \"Information Technology\""
          ");\r\n");

      sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
          "\"A2E\", \"S17\", ${index++}, \"S17\""
          ");\r\n");

      sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
          "\"A2E\", \"KR-MRT-OPP\", ${index++}, \"Opp Kent Ridge MRT\""
          ");\r\n");

      sink.write("INSERT INTO '${IROUTE_TABLE_NAME}' VALUES ("
          "\"A2E\", \"LT13\", ${index++}, \"LT13\""
          ");\r\n");

      sink.write("\r\n -- EOF --\r\n");
      //sink.close();
  }

  Future generateIOperatingHours() async{
    print("[+] generating i operating Hours!!!");

    File operatingHoursSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_INTERNAL_OPERATING_HOURS}")..createSync();
    IOSink sink = operatingHoursSqlFile.openWrite();

    sink.write('-- NusNextbusPersistence: Ope'
        '.0rating Hours Table --\r\n');
    sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");
    
    staticOperatingHours.forEach((k, v) {

      String weekdayFirst = NULL;
      String weekdayLast = NULL;
      String saturdayFirst = NULL;
      String saturdayLast = NULL;
      String sundayFirst = NULL;
      String sundayLast =  NULL;

      weekdayFirst = _isNullFormat(v["weekdays"]["first"]);
      weekdayLast = _isNullFormat(v["weekdays"]["last"]);
      saturdayFirst = _isNullFormat(v["saturdays"]["first"]);
      saturdayLast = _isNullFormat(v["saturdays"]["last"]);
      sundayFirst = _isNullFormat(v["sundaysPh"]["first"]);
      sundayLast = _isNullFormat(v["sundaysPh"]["last"]);

      sink.write("INSERT INTO '${IOPERATING_HOURS_TABLE_NAME}' VALUES ("
          "'${k}', ${weekdayFirst}, ${weekdayLast}, ${saturdayFirst}, ${saturdayLast}, ${sundayFirst}, ${sundayLast}"
          ");\r\n");
    });

    sink.write("\r\n -- EOF --\r\n");
    sink.close();

  }



  Future generateEServices() {

      print("[+] generating e services!!!");

      File operatingHoursSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_EXTERNAL_SERVICES}")..createSync();
      IOSink sink = operatingHoursSqlFile.openWrite();

      sink.write('-- NusNextbusPersistence: Eservices Table --\r\n');
      sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");

      parseEService(Map service){

          String serviceNo = _isNullFormat(service["ServiceNo"]);
          String op = _isNullFormat(service["Operator"]);
          int direction = service["Direction"];
          String category = _isNullFormat(service["Category"]);
          String originCode = _isNullFormat(service["OriginCode"]);
          String destinationCode = _isNullFormat(service["DestinationCode"]);
          String amPeak = _isNullFormat(service["AM_Peak_Freq"]);
          String amOffPeak = _isNullFormat(service["AM_Offpeak_Freq"]);
          String pmPeak = _isNullFormat(service["PM_Peak_Freq"]);
          String pmOffPeak = _isNullFormat(service[""]);
          String loopDesc = _isNullFormat(service["LoopDesc"]);
          String origin = _isNullFormat(service["Origin"]);
          String destination = _isNullFormat(service["Destination"]);


          sink.write("INSERT INTO '${ESERVICES_TABLE_NAME}' VALUES ("
              "${serviceNo}, ${op}, ${direction}, ${category}, ${originCode}, "
              "${destinationCode}, ${amPeak}, ${amOffPeak}, ${pmPeak}, "
              "${pmOffPeak}, ${loopDesc}, ${origin}, ${destination}"
              ");\r\n");

      }

      staticEServices.forEach(parseEService);


      sink.write("\r\n -- EOF --");
      sink.close();

  }

  Future generateERoute() {



      print("[+] generating e routes!!!");

      File operatingHoursSqlFile = new File("./${BUILD_DIRECTORY}/${POPULATE_EXTERNAL_ROUTE}")..createSync();
      IOSink sink = operatingHoursSqlFile.openWrite();

      sink.write('-- NusNextbusPersistence: ERoute Table --\r\n');
      sink.write("-- Created: ${new DateTime.now()} --\r\n\r\n");

      parseERoute(Map route){

          String serviceNo = _isNullFormat(route["ServiceNo"]);
          String op = _isNullFormat(route["Operator"]);
          int direction  = route["Direction"];
          int stopSequence = route["StopSequence"];
          String busStopCode = _isNullFormat(route["BusStopCode"]);
          double distance = route["Distance"].toDouble();
          String wdfirst  = _isNullFormat(route["WD_FirstBus"]);
          String wdlast = _isNullFormat(route["WD_LastBus"]);
          String satfirst = _isNullFormat(route["SAT_FirstBus"]);
          String satlast = _isNullFormat(route["SAT_LastBus"]);
          String sunfirst = _isNullFormat(route["SUN_FirstBus"]);
          String sunlast = _isNullFormat(route["SUN_LastBus"]);

          sink.write("INSERT INTO '${EROUTE_TABLE_NAME}' VALUES ("
              "${serviceNo}, ${op}, ${direction}, ${stopSequence}, ${busStopCode}, "
              "${distance}, ${wdfirst}, ${wdlast}, ${satfirst}, ${satlast}, "
              "${sunfirst}, ${sunlast}"
          ");\r\n");
      }

      staticERoutes.forEach((k,List v )=> v.forEach(parseERoute));

      sink.write("\r\n -- EOF --");
      sink.close();


  }



}