/*
  !!! create tables!!!
  todo: work out fks and indexs
 */

-- Create Stops Table--
CREATE TABLE Stop(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  icode TEXT UNIQUE,
  ecode TEXT UNIQUE,
  caption TEXT,
  description TEXT,
  roadName Text NOT NULL,
  latitude REAL NOT NULL ,
  longitude REAL NOT NULL,

  FOREIGN KEY(icode) REFERENCES IService(serviceCode),
  FOREIGN KEY(ecode) REFERENCES EService(serviceNumber)
);

CREATE INDEX StopIndex ON Stop(id, icode, ecode, latitude, longitude);

-- Create Internal Service Table--
CREATE TABLE IService (
  serviceCode TEXT PRIMARY KEY,
  express BOOLEAN NOT NULL,
  frequency TEXT NOT NULL,
  operatingHours TEXT,
  remarks TEXT,
  FOREIGN KEY(frequency) REFERENCES IFrequency(serviceGroup),
  FOREIGN KEY(operatingHours) REFERENCES IOperatingHours(serviceGroup)
);

-- Create Internal Operating Hours Table--
CREATE TABLE IOperatingHours (
  serviceGroup TEXT PRIMARY KEY,
  weekdayFirst TEXT,
  weekdayLast TEXT,
  satFirst TEXT,
  satLast TEXT,
  sunPhFirst TEXT,
  sunPhLast TEXT
);

-- Create Internal Frequency Table--
CREATE TABLE IFrequency (
  serviceGroup TEXT NOT NULL,
  chronology INTEGER NOT NULL,
  timeRange TEXT NOT NULL,
  peak BOOLEAN NOT NULL,
  semester BOOLEAN NOT NULL,
  weekday TEXT,
  saturday TEXT,
  sundayPh TEXT,

  PRIMARY KEY (serviceGroup, chronology, semester),
  FOREIGN KEY(serviceGroup) REFERENCES IService(serviceCode)
);

CREATE INDEX FrequencyIndex ON IFrequency(serviceGroup, chronology);

-- Create Internal Route Table --
CREATE TABLE IRoute (
  serviceCode TEXT NOT NULL,
  stopCode TEXT NOT NULL,
  stopNumber INTEGER NOT NULL,
  stopDesc TEXT NOT NULL,
  PRIMARY KEY (serviceCode, stopCode, stopNumber),
  FOREIGN KEY(serviceCode) REFERENCES IService(serviceCode)

);
CREATE INDEX IRoute ON IRoute(serviceCode, stopCode, stopNumber);

CREATE TABLE EService (
  serviceNumber TEXT NOT NULL,
  operator TEXT NOT NULL,
  direction INTEGER NOT NULL,
  category TEXT NOT NULL,
  originCode TEXT NULLABLE ,
  destinationCode TEXT NULLABLE ,
  amPeakFrequency TEXT,
  amOffpeakFrequency TEXT,
  pmPeakFrequency TEXT,
  pmOffpeakFrequency TEXT,
  loopDescription TEXT NULLABLE,
  origin TEXT NOT NULL,
  destination TEXT NOT NULL,
  PRIMARY KEY (serviceNumber, direction)
);

CREATE INDEX EServiceIndex
  on EService (serviceNumber, direction, originCode, destinationCode);

CREATE TABLE ERoute (
  serviceNumber TEXT NOT NULL,
  operator TEXT NOT NULL,
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

CREATE INDEX ERouteIndex
  on ERoute (serviceNumber, stopSequence, busStopCode);



