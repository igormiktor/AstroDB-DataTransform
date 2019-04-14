
set foreign_key_checks = 0;
start transaction;

drop table if exists Seeing;
drop table if exists Transparency;
drop table if exists Telescopes;
drop table if exists TelescopeTypes;
drop table if exists Eyepieces;
drop table if exists Barlows;
drop table if exists Filters;
drop table if exists Sites;
drop table if exists Observers;
drop table if exists TimeZones;

commit;
set foreign_key_checks = 1;


start transaction;
create table TimeZones
(
	zoneId			int not null auto_increment,
	zone			varchar( 48 )  not null,
	offsetToUTC		int not null,

	primary key ( zoneId ),
	unique key( zone )
);

insert into TimeZones  ( zoneId, zone, offsetToUTC ) values
( 1, 'US Eastern Time', 5 ),
( 2, 'US Central Time', 6 );

commit;




start transaction;

create table Seeing
(
	seeingId			int not null,
	tag 				varchar( 32 ) not null,
	description			varchar( 255 ) not null,

	primary key ( seeingId ),
	key ( tag )
);

insert into Seeing values ( 1, 'Perfectly stable', 'Perfect motionless diffraction pattern' );
insert into Seeing values ( 2, 'Mostly stable', 'Light undulations across diffraction rings' );
insert into Seeing values ( 3, 'Somewhat stable', 'Central disc deformations. Broken diffraction rings' );
insert into Seeing values ( 4, 'Unstable', 'Important eddy streams in the central disc; missing or partly missing diffraction rings' );
insert into Seeing values ( 5, 'Very unstable', 'Boiling image without any sign of diffraction pattern' );
insert into Seeing values ( 0, 'Unknown', 'Unknown or not recorded' );

commit;



start transaction;

create table Transparency
(
	transparencyId		int not null,
	tag 				varchar( 32 ) not null,
	description			varchar( 255 ) not null,

	primary key ( transparencyId ),
	key ( tag )
);

insert into Transparency values ( 1, 'Extremely clear', 'Milky Way and M31 visible. 7 Little Dipper stars visible' );
insert into Transparency values ( 2, 'Clear', 'No clouds. Milky Way visible with averted vision. 6 Little Dipper stars visible' );
insert into Transparency values ( 3, 'Mostly clear', 'Slight haze. 4 or 5 Little Dipper stars visible' );
insert into Transparency values ( 4, 'Somewhat clear', 'Cirrus or moderate haze. 3 or 4 Little Dipper stars visible' );
insert into Transparency values ( 5, 'Poor', 'Partly cloudy or heavy haze. 1 or 2 Little Dipper stars visible' );
insert into Transparency values ( 0, 'Unknown', 'Unknown or not recorded' );

commit;



start transaction;

create table TelescopeTypes
(
	telescopeTypeId		int not null auto_increment,
	telescopeType		varchar( 255 ) not null,

	primary key ( telescopeTypeId )
);

insert into TelescopeTypes values ( 1, 'Newtonian reflector' );
insert into TelescopeTypes values ( 2, 'Dobsonian reflector' );
insert into TelescopeTypes values ( 3, 'Schmidt-Cassegrian reflector' );
insert into TelescopeTypes values ( 4, 'Achromatic refractor' );
insert into TelescopeTypes values ( 5, 'Apochromatic refractor' );
insert into TelescopeTypes values ( 6, 'Binoculars' );
insert into TelescopeTypes values ( 7, 'Finder' );



create table Telescopes
(
	telescopeId				int not null auto_increment,
	name					varchar( 255 ) not null,
	nickname				varchar( 32 ) not null,
	telescopeType			int not null,
	aperture				double not null,
	focalLength				double,
	obstruction				double not null,
	finderAperture			double,
	finderFoV				double,
	active					boolean not null,
	notes					text,

	primary key ( telescopeId ),
	key ( name ),
	key ( nickname ),
	foreign key ( telescopeType ) references TelescopeTypes ( telescopeTypeId )
);

insert into Telescopes values ( 1, "Edmund Palomar Jr.", "Pal Jr", 1, 108.0, 1004.0, 0.04, 30.0, 5.0, 1, \N );
insert into Telescopes values ( 2, "Zhumell Z-10", "Z-10", 2, 250.0, 1230.0, 0.04, 50.0, 5.6, 1, \N );
insert into Telescopes values ( 3, "SkyWatcher S-90", "S-90", 4, 90.0, 910.0, 0.0, 50.0, 5.6, 1, \N );
insert into Telescopes values ( 4, "Z-10/S-90 Finder", "Finder", 7, 50.0, 250, 0.0, \N, \N, 1, \N );
insert into Telescopes values ( 5, "Galileoscope", "Galileoscope", 4, 50.0, 500.0, 0.0, \N, \N, 1, \N );
insert into Telescopes values ( 6, "Pentax Binoculars", "Binoculars", 6, 50.0, \N, 0.0, \N, \N, 1, \N );

commit;


start transaction;

create table Eyepieces
(
	eyepieceId				int not null auto_increment,
	name					varchar( 255 ) not null,
	nickname				varchar( 32 ) not null,
	barrelSize				double not null,
	focalLength				double not null,
	apparentFoV				double not null,
	active					boolean not null,
	notes					text,

	primary key ( eyepieceId ),
	key ( name ),
	key ( nickname )
);

insert into Eyepieces values ( 1, 'Zhumell 2" wide-field 32mm', 'Zhumell 32mm', 2.0, 32.0, 64.0, 1, 'Came with Z-10' );
insert into Eyepieces values ( 2, 'Zhumell 1.25" wide-field 9mm', 'Zhumell 9mm', 1.25, 9.0, 50.0, 1, 'Plossl; came with Z-10' );
insert into Eyepieces values ( 3, 'Orion Highlight Plossl 6.3mm', 'Plossl 6.3mm', 1.25, 6.3, 52.0, 1, \N );
insert into Eyepieces values ( 4, 'Edmund Kellner 12mm', 'Kellner 12mm', 1.25, 12.5, 43.0, 1, 'Old Edmund Kellner from the mid-1970s' );
insert into Eyepieces values ( 5, 'Edmund 24mm', 'Edmund 24mm', 1.25, 24.0, 43.0, 1, 'Came with Palomar Jr; probable Erfle' );
insert into Eyepieces values ( 6, 'Meade Series 4000 QX 26mm', 'Meade QX 26mm', 2.0, 26.0, 70.0, 1, \N );
insert into Eyepieces values ( 7, 'Meade Series 4000 QX 15mm', 'Meade QX 15mm', 1.25, 15.0, 70.0, 1, \N );
insert into Eyepieces values ( 8, 'TMB Planetary 7mm', 'TMB 7mm', 1.25, 7.0, 58.0, 1, \N );
insert into Eyepieces values ( 9, 'TMB Planetary 5mm', 'TMB 5mm', 1.25, 5.0, 58.0, 1, \N );
insert into Eyepieces values ( 10, 'Plossl 12mm', 'Plossl 12mm', 1.25, 12.0, 52.0, 1, 'Came with Skywatcher S-90' );
insert into Eyepieces values ( 11, 'Plossl 25mm', 'Plossl 25mm', 1.25, 25.0, 52.0, 1, 'Came with Skywatcher S-90' );
insert into Eyepieces values ( 12, 'Finder EP', 'Finder EP', 0.965, 31.0, 44.0, 1, 'Eyepiece on 8x50 Finder' );

commit;


start transaction;

create table Barlows
(
	barlowId				int not null auto_increment,
	name					varchar( 255 ) not null,
	nickname				varchar( 32 ) not null,
	magnification			double not null,
	barrelSize				double not null,
	active					boolean not null,
	notes					text,

	primary key ( barlowId ),
	key ( name ),
	key ( nickname )
);

insert into Barlows values ( 1, 'University Optics 2" 2x Barlow', '2x Barlow (2")', 2.0, 2.0, 1, \N );
insert into Barlows values ( 2, 'Skyquest 1.25" 2x Barlow', '2x Barlow (1.25")', 2.0, 1.25, 1, 'Came with Skyquest S-90' );

commit;


start transaction;

create table Filters
(
	filterId				int not null auto_increment,
	name					varchar( 128 ) not null,
	filterType				enum ( 'Eyepiece', 'Aperture' ) not null,
	filterSize				double not null,
	bandpassMin				double,
	bandpassMax				double,
	minExitPupil			double,
	active					boolean not null,
	notes					text,

	primary key ( filterId ),
	key ( name )
);

insert into Filters values ( 1, '11 Yellow-Green', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 2, '15 Deep Yellow', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 3, '21 Orange', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 4, '23A Light Red', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 5, '56 Light Green', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 6, '80A Light Blue', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );
insert into Filters values ( 7, 'UltraBlock 1.25"', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Orion Narrowband filter (1.25")' );
insert into Filters values ( 8, 'UltraBlock 2.0"', 'Eyepiece', 2.0, \N, \N, \N, 1, 'Orion Narrowband filter (2.0")' );
insert into Filters values ( 9, 'OIII', 'Eyepiece', 2.0, \N, \N, \N, 1, 'Thousand Oaks O-III narrowband filter (2.0")' );
insert into Filters values ( 10, 'Pal Jr Solar Filter', 'Aperture', 110, \N, \N, \N, 1, 'Home-made solar filter made from Baader film for the 4.25" Edmund Palomar Jr' );
insert into Filters values ( 11, 'S-90 Solar Filter', 'Aperture', 90, \N, \N, \N, 1, 'Agena Astro Baader solar filter for the Skywatcher S-90' );
insert into Filters values ( 12, '12 Yellow', 'Eyepiece', 1.25, \N, \N, \N, 1, 'Antares' );

commit;


start transaction;

create table Sites
(
	siteId					int not null auto_increment,
	name					varchar( 255 ) not null,
	nickname				varchar( 32 ) not null,
	latitude				double,
	longitude				double,
	altitude				double,
	skyBrightness			double,
	timezone				int not null,
	notes					text,

	primary key ( siteId ),
	key ( name ),
	key ( nickname ),
	foreign key ( timezone ) references TimeZones ( zoneId )
);

insert into Sites values ( 1, '205 Vassar Place, Alexandria, VA 22314', 'Home', 38.8102777777778, -77.0786111111111, 24.0,
	18.0, 1, \N );
insert into Sites values ( 2, 'Chinquapin Park, Alexandria, VA', 'Chinquapin',  38.8208333333333, -77.0813888888889, 24.0,
	18.2, 1, \N );
insert into Sites values ( 3, 'Phyrst, Corolla, NC', 'Phyrst Corolla',  36.300474, -75.802214, 10.0,
	21.0, 1, \N );
insert into Sites values ( 4, 'St. Michael, MD', 'St. Michael',  37.78772, -76.21780, 10.0,
	20.0, 1, \N );

commit;



start transaction;

create table Observers
(
	observerId				int not null auto_increment,
	name					varchar( 255 ) not null,
	nickname				varchar( 32 ) not null,
	birthday				date,
	notes					text,

	primary key ( observerId ),
	key ( name ),
	key ( nickname )
);

insert into Observers values ( 1, 'Igor Mikolic-Torreira', 'Igor', '1961-02-18', \N );

commit;




