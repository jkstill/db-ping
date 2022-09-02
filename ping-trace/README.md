
Connected to database pdb1
Database Link `droplet_link` connects to a database running on a Digital Ocean Droplet in California Bay Area.

10046 tracing enabled
then strace started on db server
@ping-remote-db.sql


Two of the 'SQL*Net message from client' lines were removed from the Oracle trace file, as they occurred while sitting at the command line.

```text
$  diff cdb1_ora_15440_PINGTEST.trc  original/
54a55
> WAIT #140174154976552: nam='SQL*Net message from client' ela= 10074708 driver id=1413697536 #bytes=1 p3=0 obj#=774 tim=9578284639769
341a343
> WAIT #140174154976552: nam='SQL*Net message from client' ela= 1340626 driver id=1413697536 #bytes=1 p3=0 obj#=774 tim=9578296607971
```

mrskew output

```text
$  mrskew cdb1_ora_15440_PINGTEST.trc
input files:
        'cdb1_ora_15440_PINGTEST.trc'

where expression:
        ((1) and ($dep==$depmin)) and ($nam=~/.+/i)

group expression:
        $nam

matched input files:
        'cdb1_ora_15440_PINGTEST.trc'

matched call names:
        'CLOSE'
        'EXEC'
        'PARSE'
        'PL/SQL lock timer'
        'SQL*Net message from client'
        'SQL*Net message from dblink'
        'SQL*Net message to client'
        'SQL*Net message to dblink'
        'XCTEND'
        'library cache lock'
        'rdbms ipc reply'

CALL-NAME                     DURATION       %  CALLS      MEAN       MIN       MAX
---------------------------  ---------  ------  -----  --------  --------  --------
PL/SQL lock timer            10.301060   96.6%      5  2.060212  2.057524  2.062658
SQL*Net message from dblink   0.355877    3.3%     14  0.025420  0.020389  0.027911
EXEC                          0.007077    0.1%      9  0.000786  0.000000  0.005376
SQL*Net message from client   0.003268    0.0%      9  0.000363  0.000248  0.000569
library cache lock            0.000576    0.0%      1  0.000576  0.000576  0.000576
SQL*Net message to dblink     0.000092    0.0%     14  0.000007  0.000002  0.000034
PARSE                         0.000081    0.0%      8  0.000010  0.000000  0.000021
rdbms ipc reply               0.000068    0.0%      1  0.000068  0.000068  0.000068
CLOSE                         0.000058    0.0%     16  0.000004  0.000000  0.000031
SQL*Net message to client     0.000033    0.0%     11  0.000003  0.000001  0.000016
XCTEND                        0.000000    0.0%      1  0.000000  0.000000  0.000000
---------------------------  ---------  ------  -----  --------  --------  --------
TOTAL (11)                   10.668190  100.0%     89  0.119867  0.000000  2.062658

```


```text
JKSTILL@ora192rac01/pdb1.jks.com > alter session set tracefile_identifier = 'PINGTEST';

Session altered.

JKSTILL@ora192rac01/pdb1.jks.com > select value from v$diag_info where name = '
  2
JKSTILL@ora192rac01/pdb1.jks.com >
JKSTILL@ora192rac01/pdb1.jks.com > ed
Wrote file afiedt.buf

  1* select value from v$diag_info where name = 'Default Trace File'
JKSTILL@ora192rac01/pdb1.jks.com > /

VALUE
----------------------------------------------------------------------
/u01/app/oracle/diag/rdbms/cdb/cdb1/trace/cdb1_ora_15440_PINGTEST.trc

1 row selected.

JKSTILL@ora192rac01/pdb1.jks.com > @ ping-remote-db.sql

JKSTILL@ora192rac01/pdb1.jks.com > @10046

Session altered.

JKSTILL@ora192rac01/pdb1.jks.com > @ping-remote-db.sql
Local Seconds Begin:    1641058784.640994
     Remote Seconds:    1641058784.744906
  Local Seconds End:    1641058784.640994
         Round Trip:             0.103899
==============================
Local Seconds Begin:    1641058786.807915
     Remote Seconds:    1641058786.859515
  Local Seconds End:    1641058786.807915
         Round Trip:             0.051587
==============================
Local Seconds Begin:    1641058788.920126
     Remote Seconds:    1641058788.975021
  Local Seconds End:    1641058788.920126
         Round Trip:             0.054883
==============================
Local Seconds Begin:    1641058791.032810
     Remote Seconds:    1641058791.085748
  Local Seconds End:    1641058791.032810
         Round Trip:             0.052927
==============================
Local Seconds Begin:    1641058793.144148
     Remote Seconds:    1641058793.193114
  Local Seconds End:    1641058793.144148
         Round Trip:             0.048954
==============================

```


