
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

Local Seconds Begin:    1641640285.703832
  Local Seconds End:    1641640285.799489
         Round Trip:             0.095657
==============================
Local Seconds Begin:    1641640287.864372
  Local Seconds End:    1641640288.054133
         Round Trip:             0.189761
==============================
Local Seconds Begin:    1641640290.103683
  Local Seconds End:    1641640290.471617
         Round Trip:             0.367934
==============================
Local Seconds Begin:    1641640292.537824
  Local Seconds End:    1641640292.671595
         Round Trip:             0.133771
==============================
Local Seconds Begin:    1641640294.711450
  Local Seconds End:    1641640295.176477
         Round Trip:             0.465027
==============================
         Iterations:      5

```

In the previous example, the latency varies from 95 - 465 milliseconds.

How does this compare to the `ping` utility?

```text
$  ping -c 10 137.nnn.nn.nnn
PING 137.184.84.204 (137.184.84.204) 56(84) bytes of data.
64 bytes from 137.184.84.204: icmp_seq=1 ttl=48 time=409 ms
64 bytes from 137.184.84.204: icmp_seq=2 ttl=48 time=192 ms
64 bytes from 137.184.84.204: icmp_seq=3 ttl=48 time=297 ms
64 bytes from 137.184.84.204: icmp_seq=4 ttl=48 time=76.5 ms
64 bytes from 137.184.84.204: icmp_seq=5 ttl=48 time=353 ms
64 bytes from 137.184.84.204: icmp_seq=6 ttl=48 time=36.5 ms
64 bytes from 137.184.84.204: icmp_seq=7 ttl=48 time=127 ms
64 bytes from 137.184.84.204: icmp_seq=8 ttl=48 time=356 ms
64 bytes from 137.184.84.204: icmp_seq=9 ttl=48 time=38.5 ms
64 bytes from 137.184.84.204: icmp_seq=10 ttl=48 time=646 ms

--- 137.nnn.nn.nnn ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9011ms
rtt min/avg/max/mdev = 36.570/253.478/646.856/185.977 ms
```
The first few times I tested this, the times of the database ping are approximately 2x the standard ping times.
Testing on other days shows less of a difference between the times.

There is extra overhead for the database ping as compared to the ping utility, so it would be expected to take a more time.

Just how much more time varies with internet performance, as the remote databases are accessed via the internet.


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

Here are the results of that test with 10 rows:

```text
$  echo exit | sql -S -L jkstill/XXX@orcl/pdb1 @ping-remote-db-multirow.sql

Local Seconds Begin:    1641645258.069000
  Local Seconds End:    1641645258.176678
         Round Trip:             0.107678
==============================
Local Seconds Begin:    1641645258.176710
  Local Seconds End:    1641645258.267604
         Round Trip:             0.090894
==============================
Local Seconds Begin:    1641645258.267632
  Local Seconds End:    1641645258.340432
         Round Trip:             0.072800
==============================
Local Seconds Begin:    1641645258.340464
  Local Seconds End:    1641645258.666498
         Round Trip:             0.326034
==============================
Local Seconds Begin:    1641645258.666535
  Local Seconds End:    1641645259.416426
         Round Trip:             0.749891
==============================
Local Seconds Begin:    1641645259.416462
  Local Seconds End:    1641645259.460180
         Round Trip:             0.043718
==============================
Local Seconds Begin:    1641645259.460209
  Local Seconds End:    1641645259.569515
         Round Trip:             0.109306
==============================
Local Seconds Begin:    1641645259.569545
  Local Seconds End:    1641645259.891270
         Round Trip:             0.321725
==============================
Local Seconds Begin:    1641645259.891300
  Local Seconds End:    1641645260.038614
         Round Trip:             0.147314
==============================
Local Seconds Begin:    1641645260.038652
  Local Seconds End:    1641645260.253008
         Round Trip:             0.214356
==============================
       Connect Time:             4.883269
     Round Trip Avg:             0.227265
         Iterations:     10

```

The average round trip per row is nearly the same as the times obtained via `ping`.

The internet performance this day was not particularly good.  The latency vary quite a bit, and are quite slow.

When there are complaints about slowness for a remote database, this test can help explain where the time is going.

```text

```

