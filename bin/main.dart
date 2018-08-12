import 'dart:async';
import 'dart:io';
import 'package:nus_nextbus_persistence/Config.dart';
import 'package:nus_nextbus_persistence/NusNextbusPersistence.dart';


void main(List<String> arguments){

  print("=====================================");
  print("   NUS Nextbus Data Persistance Tool ");
  print("=====================================\r\n");

  print("[*] Building NUS Nextbus Sqlite Database...");

  new NusNextbusPersistence().generateSqlScripts().then((e)=> generateDatabase());

}

Future generateDatabase() async {

  const String GENERATE_DATABASE_BATCH_FILE_PATH = 'C:\\Users\\User\\Desktop\\nus-nextbus-persistence\\bin\\generateDatabase.cmd';
  const String DATABASE_FILENAME = "dev.db";

  File dbFile = new File(DATABASE_FILENAME);

  if(dbFile.existsSync()){
    dbFile.deleteSync();
  }

  var process = await Process.start(GENERATE_DATABASE_BATCH_FILE_PATH, []);
  stdout.addStream(process.stdout);

}