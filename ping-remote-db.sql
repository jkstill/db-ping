
set serveroutput on size unlimited

set feedback off 

var dblink_name varchar2(30);
--exec :dblink_name := 'rds_link'
exec :dblink_name := 'oci_link'

var iterations number
exec :iterations := 5


declare
	local_seconds_begin number;
	local_seconds_end number;
	local_timestamp timestamp;
	remote_seconds number;
	from_client_latency number;
	to_client_latency number;
	round_trip_latency number;
	local_time_seconds_begin number;
	local_time_seconds_end number;
	working_timestamp timestamp;
	v_sql varchar2(200);


	function get_epoch_microseconds(timestamp_in timestamp)  return number
	is
   	v_date date;
   	v_epoch_secs number default 0;
   	v_day_secs number default 0;
   	v_hour_secs number default 0;
   	v_10k_secs number(8,6) default 0;
   	v_total_secs number(22,6) default 0;
		v_working_timestamp timestamp;
	begin
		v_working_timestamp := timestamp_in;

   	v_date := timestamp_in -0; -- implicit conversion to date data type

   	v_epoch_secs   := 86400*(trunc(v_date) - to_date('1970','yyyy'));
   	v_day_secs     := 86400*(trunc(v_date,'hh24') - trunc(v_date));
   	v_hour_secs    := 86400*(trunc(v_date,'mi') - trunc(v_date,'hh24'));

   	v_10k_secs := to_number(to_char(systimestamp, 'ss.ff6')) ;

   	v_total_secs := v_epoch_secs + v_day_secs + v_hour_secs + v_10k_secs;

   	return v_total_secs;

end;


begin
	v_sql := 'select systimestamp at local from dual@' || :dblink_name;
	for i in 1 .. :iterations
	loop
		--local_seconds_begin := localtimestamp at local;
		--working_timestamp := cast(localtimestamp at local as timestamp);
		local_seconds_begin := get_epoch_microseconds(localtimestamp at local );
		execute immediate v_sql into local_timestamp;
		local_seconds_end := get_epoch_microseconds(localtimestamp at local );

		remote_seconds := get_epoch_microseconds(local_timestamp at local);
		round_trip_latency := local_seconds_end - local_seconds_begin;
		from_client_latency := remote_seconds - local_seconds_begin;

/*
	The to/from client times are not being displayed, as this will not work properly
	unless the clocks of the servers are in sync.
*/

		dbms_output.put_line('Local Seconds Begin: ' || to_char(local_seconds_begin, '999999999990.099999') );
		dbms_output.put_line('     Remote Seconds: ' || to_char(remote_seconds, '999999999990.099999') );
		dbms_output.put_line('  Local Seconds End: ' || to_char(local_seconds_begin, '999999999990.099999') );
		--dbms_output.put_line('        From Client: ' || to_char(from_client_latency, '999999999990.099999') );
		--dbms_output.put_line('          To Client: ' || to_char(to_client_latency, '999999999990.099999') );
		dbms_output.put_line('         Round Trip: ' || to_char(round_trip_latency, '999999999990.099999') );
		dbms_output.put_line('==============================');
		dbms_lock.sleep(2);
	end loop;

end;
/
