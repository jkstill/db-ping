
Ping for Remote Oracle Database
===============================

Using a database link, a connection from a local database can be used to get the round trip latency for an RDS or other remote database.
Note: ping against and RDS database IP does not work.  Likely ICMP is blocked

## Create a Database Link

A database link from the local database to the remote database is used to measure the latency.

### rds-dblink.sql

This script can be modified to connect to the remote database.

### ping-remote-db.sql

The script `ping-remote-db.sql` will run a query against the remote database, and measure the round trip latency.

Adjust the values for `:dblink_name` and `:iterations` as needed.

Connect to the local database.

Now run `ping-remote-db.sql`.

The default is to get 5 pings, 2 seconds apart.

The output will appear when the job has finished, in 10-15 seconds.

The following example is from a local to me database, to an RDS database in the Oregon AWS Region:

```text
$  echo exit | sql -s -L jkstill/XXX@ora192rac01/swingbench.jks.com @ping-remote-db.sql
Local Seconds Begin:    1610730908.889966
       RDS  Seconds:    1610730909.268691
  Local Seconds End:    1610730908.889966
         Round Trip:             0.378714
==============================
Local Seconds Begin:    1610730911.315574
       RDS  Seconds:    1610730911.351524
  Local Seconds End:    1610730911.315574
         Round Trip:             0.035938
==============================
Local Seconds Begin:    1610730913.362590
       RDS  Seconds:    1610730913.397263
  Local Seconds End:    1610730913.362590
         Round Trip:             0.034662
==============================
Local Seconds Begin:    1610730915.410759
       RDS  Seconds:    1610730915.451528
  Local Seconds End:    1610730915.410759
         Round Trip:             0.040758
==============================
Local Seconds Begin:    1610730917.458928
       RDS  Seconds:    1610730917.481304
  Local Seconds End:    1610730917.458928
         Round Trip:             0.022366
==============================
```

In the previous example, the latency after the connection is established is 22-40 milliseconds.


