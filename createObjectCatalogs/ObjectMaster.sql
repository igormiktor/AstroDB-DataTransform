start transaction;
drop table if exists ObjectTypes;
create table ObjectTypes
(
	typeId				int not null,
	description			varchar(128) not null		-- Object type description
	kind				enum ( 'Star', 'Star Cluster', 'Nebula', 'Galaxy', 'Exotic', 'None' ) not null,
	inGalaxy			boolean,

	primary key ( typeId ),
	key ( tag ),
);

insert into ObjectTypes values
( 1, 'Asterism', 'Star', true ),
( 11, 'Star', 'Star', true ),

( 101, 'Globular Cluster', 'Star Cluster', true ),
( 102, 'Open Cluster', 'Star Cluster' )
( 103, 'Open Cluster with Nebulosity', 'Star Cluster', true ),
( 131, 'Bright Nebula', 'Nebula', true ),
( 132, 'Emission Nebula', 'Nebula', true ),
( 133, 'Reflection Nebula', 'Nebula', true ),
( 134, 'Dark Nebula', 'Nebula', true ),
( 135, 'Planetary Nebula', 'Nebula', true ),
( 136, 'Supernova Remnant', 'Nebula', true ),

( 201, 'Galaxy', 'Galaxy', false ),
( 211, 'Diffuse Nebula in a Galaxy', 'Nebula', false ),
( 212, 'Globular Cluster in a Galaxy', 'Cluster', false ),
( 213, 'Cluster with Nebulosity in a Galaxy', 'Cluster', false ),
( 251, 'Cluster with Nebulosity in the LMC', 'Cluster', false ),
( 252, 'Diffuse Nebula in the LMC', 'Nebula', false ),
( 253, 'Globular Cluster in the LMC', 'Cluster', false ),
( 254, 'Open cluster in the LMC', 'Cluster', false ),
( 261, 'Cluster with Nebulosity in the SMC', 'Cluster', false ),
( 262, 'Diffuse Nebula in the SMC', 'Nebula', false ),
( 263, 'Globular Cluster in the SMC', 'Cluster', false ),
( 264, 'Open cluster in the SMC', 'Cluster', false ),

( 299, 'Galaxy cluster', 'Galaxy', false ),

( 301, 'Quasar', 'Exotic', false ),
( 302, 'Black Hole', 'Exotic', true ),

( 9999, 'Non-existent', 'None', \N );




create table AstroObjects
(
	id					int not null auto_increment,
	name				varchar(32) not null,
	other_name			varchar(128) default null,
	type				int not null,
	constellation		char(3) not null,
	fixed				boolean,
	ra					double default null,
	decl				double default null,
	mag					float default null,
	surf_bright			float default null,
	u2k					int default null,
	tir					int default null,
	size_major			float default null,
	size_minor			float default null,
	pa					float default null,
	classification		varchar(16) default null,
	nstars				int,
	br_star				float,
	best_of_ngc			boolean,
	caldwell			boolean,
	herschel			boolean,
	messier				boolean,
	ngc_desc			varchar(64),
	notes				varchar(96),
	source				varchar(32),
	primary key ( id ),
	key ( name ),
	key ( other_name )
);



create table
(
id					int not null auto_increment,
name				varchar(32) not null,
other_name			varchar(32),
sao					varchar(10),
constellation		char(3) not null,
ra					double not null,
decl				double not null,
comp				varchar(5),
mag					float,
mag2				float,
sep					float,
pa					float,
u2k					int,
tir					int,
bsa					int,
notes				varchar(132),
source				varchar(32),
primary key( id ),
key ( name ),
key ( other_name )
);
