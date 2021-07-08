-- PROBLEM:  DeepSkyCatalog was created with a duplicate (two entries with objectId = 5280).
-- This precluded making objectId a unique key, which then broke a bunch of "group by" used by
-- the Xataface UI in the various views deriving from DeepSkyCatalog.  MySQL didn't originally
-- enforce this, so that is why it went undetected until recent updates to MySQL.

-- This duplicate originates from a dupe in SAC_DeepSky_2011_04_22 (that I missed originall).
-- The duplicate to ignore is SAC_DeepSky_2011_04_22 id=5280 (which maps to DeepSkyCatalog deepSkyId=5280).

-- This file PATCHES the existent database by creating DeepSkyCatalog2, which is the same
-- as DeepSkyCatalog except: (1) has objectId as a unique key, and (2) loads all the data from
-- DeepSkyCatalog except the undesired duplicate with deepSkyId = 5280.

-- It then renames the original DeepSkyCatalog to DeepSkyCatalog0, and then renames the new
-- DeepSkyCatalog2 to DeepSkyCatalog.  All the views now work fine.

-- If you want to check for the duplicate in DeepSkyCatalog, run this:
-- select objectId, count( deepSkyId ) c from DeepSkyCatalog group by objectId having c > 1;

start transaction;

create table DeepSkyCatalog2
(
	deepSkyId						int not null auto_increment,
	objectId						int not null,
	name								varchar(32) not null,
	constellation				char(3) not null,
	rightAscension			double not null,
	declination					double not null,
	magnitude						float,
	surfBright					float,
	sizeMajor						float,
	sizeMinor						float,
	posAngle						float,
	classification			varchar(16),
	nbrStars						int,
	brightestStar				float,
	pageU2K							int,
	pageSA2K						int,
	pagePSA							int,
	pageBSA							int,
	messier							boolean,
	bestOfNGC						boolean,
	caldwell						boolean,
	herschel400					boolean,
	ngcDesc							varchar(64),
	notes								varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( deepSkyId ),
  unique key ( objectId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into DeepSkyCatalog2
( objectId, name, constellation, rightAscension, declination, magnitude, surfBright, sizeMajor, sizeMinor, posAngle, classification,
nbrStars, brightestStar, pageU2K, pageSA2K, bestOfNGC, caldwell, herschel400, messier, ngcDesc, notes, dataSource )
select
dsc.objectId, dsc.name, dsc.constellation, dsc.rightAscension, dsc.declination, dsc.magnitude, dsc.surfBright, dsc.sizeMajor, dsc.sizeMinor,
dsc.posAngle, dsc.classification, dsc.nbrStars, dsc.brightestStar, dsc.pageU2K, dsc.pageSA2K, dsc.bestOfNGC, dsc.caldwell, dsc.herschel400,
dsc.messier, dsc.ngcDesc, dsc.notes, dsc.dataSource
from DeepSkyCatalog dsc
where deepSkyId <> 5280;


alter table DeepSkyCatalog rename DeepSkyCatalog0;
alter table DeepSkyCatalog2 rename DeepSkyCatalog;

commit;
