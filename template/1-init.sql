/*
  !!! create tables!!!
  todo: work out fks and indexs
 */

-- Create Stops Table--
/*
 {
    "BusStopCode": "00481",
    "RoadName": "Woodlands Rd",
    "Description": "BT PANJANG TEMP BUS PK",
    "Latitude": 1.383764,
    "Longitude": 103.7583
  }
 */

CREATE TABLE Stop (
  busStopCode TEXT PRIMARY KEY,
  roadName TEXT NOT NULL,
  description TEXT NOT NULL,
  latitude REAL NOT NULL,
  longtitude REAL NOT NULL
);

-- Create Service Table --
/*
{
    "ServiceNo": "118",
    "Operator": "GAS",
    "Direction": 1,
    "Category": "TRUNK",
    "OriginCode": "65009",
    "DestinationCode": "97009",
    "AM_Peak_Freq": "06-08",
    "AM_Offpeak_Freq": "08-15",
    "PM_Peak_Freq": "10-12",
    "PM_Offpeak_Freq": "11-15",
    "LoopDesc": ""
}
 */
CREATE TABLE Service (
  serviceNumber TEXT NOT NULL,
  operator INTEGER NOT NULL,
  direction INTEGER NOT NULL,
  category INTEGER NOT NULL,
  originCode TEXT NULLABLE ,
  destinationCode TEXT NULLABLE ,
  amPeakFrequency TEXT NOT NULL,
  amOffpeakFrequency TEXT NOT NULL,
  pmPeakFrequency TEXT NOT NULL,
  pmOffpeakFrequency TEXT NOT NULL,
  loopDescription STRING NULLABLE,
  PRIMARY KEY (serviceNumber, direction),
  FOREIGN KEY(originCode) REFERENCES Stop(busStopCode),
  FOREIGN KEY(destinationCode) REFERENCES Stop(busStopCode)
);

CREATE INDEX ServiceIndex
  on Service (serviceNumber, direction, originCode,destinationCode);

-- Create Route --
/*
{
    "ServiceNo": "10",
    "Operator": "SBST",
    "Direction": 1,
    "StopSequence": 1,
    "BusStopCode": "75009",
    "Distance": 0,
    "WD_FirstBus": "0500",
    "WD_LastBus": "2300",
    "SAT_FirstBus": "0500",
    "SAT_LastBus": "2300",
    "SUN_FirstBus": "0500",
    "SUN_LastBus": "2300"
}
 */

CREATE TABLE Route (
  serviceNumber TEXT NOT NULL,
  operator INTEGER NOT NULL,
  direction INTEGER NOT NULL,
  stopSequence INTEGER NOT NULL,
  busStopCode TEXT NOT NULL,
  distance REAL NOT NULL,
  weekdayFirstBus TEXT NOT NULL,
  weekdayLastBus TEXT NOT NULL,
  saturdayFirstBus TEXT NOT NULL,
  saturdayLastBus TEXT NOT NULL,
  sundayFirstBus TEXT NOT NULL,
  sundayLastBus TEXT NOT NULL,
  PRIMARY KEY (serviceNumber, direction, stopSequence),
  FOREIGN KEY(busStopCode) REFERENCES Stop(busStopCode)
);


CREATE INDEX RouteIndex
  on Route (serviceNumber, stopSequence, busStopCode);

CREATE VIEW ServiceExtended AS
  SELECT service.*,
    origin.description as originDescription,
    destination.description AS destinationDescription
  FROM service AS service
    LEFT OUTER JOIN stop AS origin ON service.originCode = origin.busStopCode
    LEFT OUTER JOIN stop AS destination ON service.destinationCode = destination.busStopCode
  ORDER BY service.serviceNumber ASC;--

CREATE VIEW RouteExtended AS
  SELECT route.*, stop.*
  FROM route
    LEFT OUTER JOIN stop AS stop ON route.busStopCode = stop.busStopCode
  ORDER BY stopSequence ASC;--

