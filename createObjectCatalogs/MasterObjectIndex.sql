start transaction;
drop table if exists MasterObjectIndex;
drop table if exists ObjectTypes;
commit;

start transaction;
create table ObjectTypes
(
	typeId				int not null,
	description			varchar(128) not null,		-- Object type description
	kind				enum ( 'Star', 'Star Cluster', 'Nebula', 'Galaxy', 'Exotic', 'SolarSystem', 'None' ) not null,
	category			enum ( 'Stellar', 'DeepSky', 'SolarSystem', 'None' ) not null,
	inGalaxy			boolean,

	primary key ( typeId )
);

insert into ObjectTypes values
( 1,  'Asterism', 'Star', 'Stellar', true ),
( 11, 'Star', 'Star', 'Stellar', true ),

( 101, 'Globular Cluster', 'Star Cluster', 'DeepSky', true ),
( 102, 'Open Cluster', 'Star Cluster', 'DeepSky', true ),
( 103, 'Open Cluster with Nebulosity', 'Star Cluster', 'DeepSky', true ),
( 131, 'Bright Nebula', 'Nebula', 'DeepSky', true ),
( 132, 'Emission Nebula', 'Nebula', 'DeepSky', true ),
( 133, 'Reflection Nebula', 'Nebula', 'DeepSky', true ),
( 134, 'Dark Nebula', 'Nebula', 'DeepSky', true ),
( 135, 'Planetary Nebula', 'Nebula', 'DeepSky', true ),
( 136, 'Supernova Remnant', 'Nebula', 'DeepSky', true ),

( 201, 'Galaxy', 'Galaxy', 'DeepSky', false ),
( 211, 'Diffuse Nebula in a Galaxy', 'Nebula', 'DeepSky', false ),
( 212, 'Globular Cluster in a Galaxy', 'Star Cluster', 'DeepSky', false ),
( 213, 'Cluster with Nebulosity in a Galaxy', 'Star Cluster', 'DeepSky', false ),
( 251, 'Cluster with Nebulosity in the LMC', 'Star Cluster', 'DeepSky', false ),
( 252, 'Diffuse Nebula in the LMC', 'Nebula', 'DeepSky', false ),
( 253, 'Globular Cluster in the LMC', 'Star Cluster', 'DeepSky', false ),
( 254, 'Open cluster in the LMC', 'Star Cluster', 'DeepSky', false ),
( 261, 'Cluster with Nebulosity in the SMC', 'Star Cluster', 'DeepSky', false ),
( 262, 'Diffuse Nebula in the SMC', 'Nebula', 'DeepSky', false ),
( 263, 'Globular Cluster in the SMC', 'Star Cluster', 'DeepSky', false ),
( 264, 'Open cluster in the SMC', 'Star Cluster', 'DeepSky', false ),

( 299, 'Galaxy cluster', 'Galaxy', 'DeepSky', false ),

( 301, 'Quasar', 'Exotic', 'DeepSky', false ),
( 302, 'Black Hole', 'Exotic', 'DeepSky', true ),
( 303, 'Nova', 'Exotic', 'DeepSky', true ),
( 304, 'Supernova', 'Exotic', 'DeepSky', false ),

( 601, 'Sun', 'SolarSystem', 'SolarSystem', true ),
( 602, 'Moon', 'SolarSystem', 'SolarSystem', true ),

( 611, 'Planet', 'SolarSystem', 'SolarSystem', true ),
( 612, 'Asteroid', 'SolarSystem', 'SolarSystem', true ),
( 613, 'Comet', 'SolarSystem', 'SolarSystem', true ),

( 9999, 'Non-existent', 'None', 'None', \N );

commit;

start transaction;
create table MasterObjectIndex
(
	objectId					int not null auto_increment,
	name						varchar(32) not null,
	displayName					varchar(64) not null,
	otherNames					varchar(255),
	sao							varchar(10),
	objectType					int not null,
	deepSkyCatalog				boolean default null,
	multipleStarCatalog			boolean default null,
	coloredStarCatalog			boolean default null,
	variableStarCatalog			boolean default null,
	planetCatalog				boolean default null,
	asteroidCatalog				boolean default null,
	cometCatalog				boolean default null,
	specialCatalog				boolean default null,
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( objectId ),
	unique key ( name ),
	unique key ( sao ),
	foreign key ( objectType ) references ObjectTypes ( typeId )
);
commit;


start transaction;
drop function if exists addUniqueNames;
drop function if exists mergeNames;
commit;

start transaction;
delimiter //
create function addUniqueNames( nameList varchar(255), moreNames varchar(255) )
returns varchar(255)
deterministic
begin
	declare aName varchar(255);
	declare pos int;

	while moreNames is not null and char_length( moreNames ) > 0 do
		-- Extract the front-most name
		set pos = locate( ';', moreNames );
		if pos > 0 then
			-- Found a ';', save the item with trailing ';'
			set aName = trim( substring( moreNames, 1, pos ) );
			-- Eliminate this item from moreNames, trim both to get rid of leading spaces and
			-- ensure zero-length string after the last terminated item
			set moreNames = trim( substring( moreNames, pos+1 ) );
		else
			-- No ';' but non-zero length, assume we have an unterminated last name in the moreNames list
			set aName = concat( moreNames, ';' );
			set moreNames = null;
		end if;

		-- Check to see if we already have it
		if nameList is null or char_length( nameList ) = 0 then
			-- List is empty, so the new name becomes the list
			set nameList = aName;
		else
			if locate( aName, nameList ) = 0 then
				-- Not found in nameList, so add it
				set nameList = concat( nameList, ' ', aName );
			end if;
		end if;
	end while;

	return nameList;
end; //
delimiter ;
commit;


start transaction;
delimiter //
create function mergeNames( names1 varchar(255), names2 varchar(255) )
returns varchar(255)
deterministic
begin
	declare nameList varchar(255);

	set nameList = addUniqueNames( nameList, names1 );
	set nameList = addUniqueNames( nameList, names2 );
	return nameList;
end; //
delimiter ;
commit;
