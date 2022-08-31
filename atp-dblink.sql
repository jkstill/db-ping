
-- for a dblink the oracle server must have access to wallets
-- so the wallets must be available on the db server

create database link oci_link connect to  jkstill identified by XXXX using
'(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-phoenix-1.oraclecloud.com))(connect_data=(service_name=****************atp21c01_high.adb.oraclecloud.com))(security=(ssl_server_dn_match=true)(ssl_server_cert_dn="CN=****.uscom-east-1.oraclecloud.com,OU=Oracle BMCS US,O=Oracle Corporation,L=Redwood City,ST=California,C=US")(my_wallet_directory=/u01/app/oracle/wallets/atp21c01)))'
/

