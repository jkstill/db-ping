
Ping for Remote Oracle Database
===============================

Using a database link, a connection from a local database can be used to get the round trip latency for an RDS or other remote database.
Note: ping against and RDS database IP does not work.  Likely ICMP is blocked

## Create a Database Link

A database link from the local database to the remote database is used to measure the latency.

### rds-dblink.sql

This script was used to create a database link to an AWS RDS database.

### atp-dblink.sql

This script was used to create a database link to an Oracle Autonomous Transaction database.


### droplet-dblink.sql

This database link relies on an ssh tunnel.  The following entrie is used in `~/.ssh/config`

```text
# equivalent to
# ssh -N -L 1521:137.nnn.nn.nnn:6790 jkstill@137.nnn.nn.nnn
Host pingtest-tunnel
   User myusername
   Hostname 137.nnn.nn.nnn
   Port 22
   IdentityFile /home/myusername/.ssh/digital-ocean-centos7
   IdentitiesOnly yes
   # 6789 at localhost is forwarded to 1521 at remote
   # sqlplus scott/tiger@localhost:6789/dbname-here
   LocalForward 6789 localhost:1521
```

Then an ssh session is started for the duration of testing.

## Testing

The following tests were performed using the database link created by `droplet-dblink.sql`.

### ping-remote-db.sql

Create a database link to be used for the ping test, as shown previously.

The following testing is useing the 

You can modify one of the dblink scripts provided for that purpose, or create your own.

The script `ping-remote-db.sql` will run a query against the remote database via the database link, and measure the round trip latency.

Adjust the values for `:dblink_name` and `:iterations` as needed.

Connect to the local database where the database link was created.

Now run `ping-remote-db.sql`.

The default is to get 5 pings, 2 seconds apart.

The output will appear when the job has finished, in 10-15 seconds.

The following example is from a database running in the same rack as my workstation, to an Oracle database in the California Bay area.

```text
$  echo exit | sql -S -L jkstill/XXX@orcl/pdb1 @ping-remote-db.sql
Local Seconds Begin:    1641480615.772064
     Remote Seconds:    1641480616.191254
  Local Seconds End:    1641480615.772064
         Round Trip:             0.419177
==============================
Local Seconds Begin:    1641480618.231498
     Remote Seconds:    1641480618.282833
  Local Seconds End:    1641480618.231498
         Round Trip:             0.051322
==============================
Local Seconds Begin:    1641480620.343469
     Remote Seconds:    1641480620.401936
  Local Seconds End:    1641480620.343469
         Round Trip:             0.058456
==============================
Local Seconds Begin:    1641480622.455464
     Remote Seconds:    1641480622.507981
  Local Seconds End:    1641480622.455464
         Round Trip:             0.052506
==============================
Local Seconds Begin:    1641480624.567963
     Remote Seconds:    1641480624.624368
  Local Seconds End:    1641480624.567963
         Round Trip:             0.056373
==============================

```

In the previous example, the latency varies from 42-58 milliseconds.

How does this compare to the `ping` utility?

```text
$  ping -i 2 -c 5 137.nnn.nn.nn4
PING 137.nnn.nn.nnn (137.nnn.nn.nnn) 56(84) bytes of data.
64 bytes from 137.nnn.nn.nnn: icmp_seq=1 ttl=48 time=25.1 ms
64 bytes from 137.nnn.nn.nnn: icmp_seq=2 ttl=48 time=22.8 ms
64 bytes from 137.nnn.nn.nnn: icmp_seq=3 ttl=48 time=28.4 ms
64 bytes from 137.nnn.nn.nnn: icmp_seq=4 ttl=48 time=29.3 ms
64 bytes from 137.nnn.nn.nnn: icmp_seq=5 ttl=48 time=23.5 ms

--- 137.nnn.nn.nn4 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 8008ms
rtt min/avg/max/mdev = 22.837/25.871/29.346/2.611 ms
```

The times of the database ping are approximately 2x the standard ping are times.

There is extra overhead for the database ping as compared to the ping utility, so it would be expected to take a more time.

### ping-remote-db-multirow.sql

A test could be devised to measure the latency per packet received from a multi-row return set.

ie.

```sql
select systimetamp at local, rpad('X',1500-35-28,'X')
from dual
connect by level <= 20
```

That is what `ping-remote-db-multirow.sql` does.

The standard packet size is 1500 bytes, the length of `systimestamp at local` is 35, and the ICMP header is 28 bytes (on Linux anyway).

As the number of packets increases, the average time per row should be close to the ping time. 

Here are the results of that test with 100 rows:

```text
$  echo exit | sql -S -L jkstill/XXX@orcl/pdb1 @ping-remote-db-multirow.sql
Local Seconds Begin:    1641484445.954942
     Remote Seconds:
  Local Seconds End:    1641484445.954942
         Round Trip:             0.000013
==============================
Local Seconds Begin:    1641484445.982099
     Remote Seconds:
  Local Seconds End:    1641484445.982099
         Round Trip:             0.000012
==============================

...

==============================
Local Seconds Begin:    1641484448.441338
     Remote Seconds:
  Local Seconds End:    1641484448.441338
         Round Trip:             0.000021
==============================
     Round Trip Avg:             0.025115
```

The average round trip per row is nearly the same as the times obtained via `ping`.


