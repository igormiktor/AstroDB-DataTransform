
-- This is the master catalog of Deep Sky objects

start transaction;
drop table if exists DeepSkyCatalog;
create table DeepSkyCatalog
(
	deepSkyId					int not null auto_increment,
	objectId					int not null,
	name						varchar(32) not null,
	constellation				char(3) not null,
	rightAscension				double not null,
	declination					double not null,
	magnitude					float,
	surfBright					float,
	sizeMajor					float,
	sizeMinor					float,
	posAngle					float,
	classification				varchar(16),
	nbrStars					int,
	brightestStar				float,
	pageU2K						int,
	pageSA2K					int,
	pagePSA						int,
	pageBSA						int,
	messier						boolean,
	bestOfNGC					boolean,
	caldwell					boolean,
	hershel400					boolean,
	ngcDesc						varchar(64),
	notes						varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( deepSkyId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId ),
	foreign key ( constellation ) references Constellations ( abbreviationIAU )
);

insert into DeepSkyCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, surfBright, sizeMajor, sizeMinor, posAngle, classification,
nbrStars, brightestStar, pageU2K, pageSA2K, bestOfNGC, caldwell, hershel400, messier, ngcDesc, notes, dataSource )
select
moi.objectId, moi.name, con.abbreviationIAU, ds.ra, ds.decl, ds.mag, ds.surf_bright, ds.size_major, ds.size_minor,
ds.pa, ds.obj_class, ds.nstars, ds.br_star, ds.u2k, ds.tir, ds.best_of_ngc, ds.caldwell, ds.hershel, ds.messier,
ds.ngc_desc, ds.notes, ds.source
from SAC_DeepSky_2011_04_22 ds, MasterObjectIndex moi, Constellations con
where moi.name = ds.name and ds.constellation = con.abbreviationSAC;
commit;


-- This is the master catalog of multiple stars

start transaction;
drop table if exists MultipleStarCatalog;
create table MultipleStarCatalog
(
	multipleStarId				int not null auto_increment,
	objectId					int not null,
	name						varchar(32) not null,
	constellation				char(3) not null,
	rightAscension				double not null,
	declination					double not null,
	magnitude					float,
	magnitude2					float,
	components					varchar(5),
	separation					float,
	posAngle					float,
	variable					boolean,
	pageU2K						int,
	pageSA2K					int,
	pagePSA						int,
	pageBSA						int,
	notes						varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( multipleStarId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId ),
	foreign key ( constellation ) references Constellations ( abbreviationIAU )
);


insert into MultipleStarCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, magnitude2, components, separation, posAngle,
variable, pageU2K, pageSA2K, pageBSA, notes, dataSource )
select
moi.objectId, moi.name, con.abbreviationIAU, ms.ra, ms.decl, ms.mag, ms.mag2, ms.comp, ms.sep, ms.pa, ms.variable,
ms.u2k, ms.tir, ms.bsa, ms.notes, ms.source
from SAC_DoubleStar_2011_04_22 ms, MasterObjectIndex moi, Constellations con
where moi.name = ms.name and ms.constellation = con.abbreviationSAC;
commit;


start transaction;
start transaction;
drop table if exists ColoredStarCatalog;
create table ColoredStarCatalog
(
	coloredStarId				int not null auto_increment,
	objectId					int not null,
	name						varchar(32) not null,
	constellation				char(3) not null,
	rightAscension				double not null,
	declination					double not null,
	magnitude					float,
	BminusV						float,
	spectralType				varchar(6),
	multiple					boolean,
	variable					boolean,
	pageU2K						int,
	pageSA2K					int,
	pagePSA						int,
	pageBSA						int,
	notes						varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( coloredStarId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId ),
	foreign key ( constellation ) references Constellations ( abbreviationIAU )
);

insert into ColoredStarCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, BminusV, spectralType,
multiple, variable, notes, dataSource )
select
moi.objectId, moi.name, con.abbreviationIAU, cs.ra, cs.decl, cs.mag, cs.b_v, cs.spectral,
cs.multiple, cs.variable, cs.notes, cs.source
from SAC_RedStar_2011_04_22 cs, MasterObjectIndex moi, Constellations con
where moi.name = cs.name and cs.constellation = con.abbreviationSAC;
commit;



-- Additions to master catalogs

start transaction;  -- Tau Cyg

insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, multipleStarCatalog ) values
( 'Tau Cyg', 'Tau Cyg', '65 Cygni; HR 8130; BD+37°4240; HD 202444; SAO 71121; HIP 104887; GC 29723;', 'SAO 71121', 11, true );

insert into MultipleStarCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, magnitude2, components, separation, posAngle,
variable, pageU2K, pageSA2K, pageBSA, pagePSA, notes, dataSource )
select
moi.objectId, moi.name, 'Cyg', 21+(14+47.4916/60.0)/60.0, 38+(2+43.141/60.0)/60.0, 3.84, 6.44, 'AB', 0.9, \N, 0,
121, 9, 8, 62, 'A is a yellowish white subgiant star, type F2IV; B is a yellow main sequence star, type G0V', 'IMT 2011-08-21; Wikipedia'
from MasterObjectIndex moi, Constellations con
where moi.name = 'Tau Cyg';

commit;


start transaction;  -- STF 737

insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, multipleStarCatalog ) values
( 'STF 737', 'STF 737', 'ADS 4194; BD +34 1107; SAO 58234; WDS 05364+3408;', 'SAO 58234', 11, true );

insert into MultipleStarCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, magnitude2, components, separation, posAngle,
variable, pageU2K, pageSA2K, pageBSA, pagePSA, notes, dataSource )
select
moi.objectId, moi.name, 'Aur', 5+(36+23/60.0)/60.0, 34+(8+2/60.0)/60.0, 9.13, 9.38, 'AB', 11, 305, 0,
97, 5, \N, 12, 'Lies near the center of the open cluster M 36; a widely spaced pair of white stars of equal magnitude.', 'IMT 2011-08-21; http://x.astrogeek.org/'
from MasterObjectIndex moi, Constellations con
where moi.name = 'STF 737';

commit;


start transaction;  -- SEI 350

insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, multipleStarCatalog ) values
( 'SEI 350', 'SEI 350', 'WDS 05362+3407;', \N, 11, true );

insert into MultipleStarCatalog
( objectId, name, constellation, rightAscension, declination, magnitude, magnitude2, components, separation, posAngle,
variable, pageU2K, pageSA2K, pageBSA, pagePSA, notes, dataSource )
select
moi.objectId, moi.name, 'Aur', 5+(36+14.08/60.0)/60.0, 34+(7+8.2/60.0)/60.0, 10.48, 10.55, 'AB', 15.3, 074, 0,
97, 5, \N, 12, 'Lies in open cluster M 36; a widely spaced pair of stars of equal magnitude stars.', 'IMT 2011-08-21; http://stelledoppie.goaction.it/'
from MasterObjectIndex moi, Constellations con
where moi.name = 'SEI 350';

commit;
