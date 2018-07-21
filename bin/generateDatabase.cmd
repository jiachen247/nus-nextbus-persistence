SET db_name=dev.db

del %db_name%
ping 127.0.0.1 -n 4 > nul

C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\1-init.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\2-populate-operating-hours.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\3-populate-ifrequency.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\4-populate-iservices.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\5-populate-eservices.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\6-populate-stops.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\7-populate-iroutes.sql
C:\Users\User\Desktop\nus-nextbus-persistence\bin\sqlite3 %db_name% < C:\Users\User\Desktop\nus-nextbus-persistence\build\8-populate-eroutes.sql


exit