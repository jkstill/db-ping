
drop database link rds_link;

create database link rds_link connect to admin identified by XXXX
 using '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=rds01.XXXXXXXX.us-west-2.rds.amazonaws.com)(PORT=1521))(CONNECT_DATA=(SID=DATABASE)))'

/


	
