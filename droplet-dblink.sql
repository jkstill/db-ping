
-- for a dblink the oracle server must have access to wallets
-- so the wallets must be available on the db server

drop database link droplet_link;

-- via ssh tunnel on local machine

-- needs an ssh tunnel running on the db server
-- ezconnect works for db links :)
create database link droplet_link connect to pingtest identified by XXXX using
	'localhost:6789/ORCLPDB1'
/




	
