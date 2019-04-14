start transaction;

drop function julianDateToDateTime;
drop function julianDatetoDateTimeStr;
drop function dateTimeToJulianDate;
drop function unixTimeToJulianDate;
drop function julianDateToUnixTime;

delimiter //
create function julianDateToDateTimeStr( jd double )
returns varchar(255)
deterministic
begin
	declare answer varchar( 255 );
	declare j int;
	declare jj int;
	declare g int;
	declare dg int;
	declare c int;
	declare dc int;
	declare b int;
	declare db int;
	declare a int;
	declare da int;
	declare y int;
	declare m int;
	declare d int;
	declare yy int;
	declare mm int;
	declare dd int;
	declare h int;
	declare n int;
	declare s int;
	declare t double;

	set j = floor( jd + 0.5 );

	set t = (jd + 0.5 - j) * 86400;
	set h = floor( t / 3600 );
	set t = t - h*3600;
	set n = floor( t / 60 );
	set s = t - n*60;

	if s = 60 then
		set s = 0;
		set n = n + 1;
	end if;

	if n = 60 then
		set n = 0;
		set h = h + 1;
	end if;

	if h = 24 then
		set h = 0;
		set j = j + 1;
	end if;

	set jj = j + 32044;
	set g = floor( jj/146097 );
	set dg = mod( jj, 146097 );
	set c = floor( ( floor( dg/36524 ) + 1 ) * 3 / 4 );
	set dc = dg - c * 36524;
	set b = floor( dc/1461 );
	set db = mod( dc, 1461 );
	set a = floor( (floor( db/365) + 1) * 3 / 4 );
	set da = db - a * 365;
	set y = g*400 + c*100 + b*4 + a;
	set m = floor( (da*5 + 308)/153 ) - 2;
	set d = da - floor( (m + 4)*153/5 ) + 122;
	set yy = y - 4800 + floor( (m+2)/12 );
	set mm = mod( m+2, 12 ) + 1;
	set dd = d + 1;

	set answer = concat( yy, '-', mm, '-', dd, ' ', h, ':', n, ':', s );

	return answer;
end; //

create function julianDateToDateTime( jd double )
returns datetime
deterministic
begin
	return convert( julianDateToDateTimeStr( jd ), datetime );
end; //

create function dateTimeToJulianDate( dt datetime )
returns double
deterministic
begin
	declare year int;
	declare month int;
	declare day int;
	declare hours int;
	declare minutes int;
	declare seconds int;

	declare jDate double;

	declare a int;
	declare y int;
	declare m int;

	set year = extract( year from dt );
	set month = extract( month from dt );
	set day = extract( day from dt );
	set hours = extract( hour from dt );
	set minutes = extract( minute from dt );
	set seconds = extract( second from dt );

	set a = floor( (14 - month)/12 );
	set y = year + 4800 - a;
	set m = month + 12 * a - 3;
	set jDate = day + floor( (153*m + 2)/5) + 365*y + floor( y/4 ) - floor( y/100 ) + floor( y/400 ) - 32045;
	set jDate = jDate + (hours - 12.0)/24.0 + minutes/1440.0 + seconds/86400.0;

	return jDate;
end; //



create function unixTimeToJulianDate( ut bigint )
returns double
deterministic
begin
	declare jDate double;

	declare kJulianDateOfUnixEpoch double;
	declare kSecondsPerJulianDay double;

	set kJulianDateOfUnixEpoch = 2440587.5;
	set kSecondsPerJulianDay = 86400.0;

	set jDate = ut / kSecondsPerJulianDay + kJulianDateOfUnixEpoch;

	return jDate;
end; //


create function julianDateToUnixTime( jd double )
returns bigint
deterministic
begin
	declare ut bigint;

	declare kJulianDateOfUnixEpoch double;
	declare kSecondsPerJulianDay double;

	set kJulianDateOfUnixEpoch = 2440587.5;
	set kSecondsPerJulianDay = 86400.0;

	set ut = (jd - kJulianDateOfUnixEpoch) * kSecondsPerJulianDay;

	return ut;
end; //


delimiter ;
commit;
