start transaction;

drop table if exists SpecialTemp;
create table SpecialTemp
(
	name 						varchar( 64 ) not null,
	otherNames					varchar( 255 ),
	sao							varchar(10),
	typ							int not null,
	con							char(3) not null,
	ra							double not null,
	decl						double not null,
	magnitude					float,
	notes						varchar(255),
	primary key ( name )
);

insert into SpecialTemp ( name, otherNames, sao, typ, con, ra, decl, magnitude, notes ) values
( 'Cygnus X-1', 'HDE 226868; SAO 69181; V1357;', 'SAO 69181', 302, 'Cyg', 19.9726876667, 35.2016041667, 8.93, 'Cyg X-1 is the black hole orbiting HDE 226868' ),
( '3C 273', 'PGC 41121; HIP 60936;', \N, 301, 'Vir', 12.0 + (29 + 06.8/60.0)/60.0, 2.0 + (3.0 + 7.0/60.0)/60.0,	12.8, 'First quasar; distance is 2.5 GLy / 750 Mpc' ),
( 'Mrk 421', 'B2 1101+38; UGC 6132; PGC 33452; 2E 2393; QSO B1101+384;', \N, 301, 'UMa', 11.0 + (4.0 + 27.3/60.0)/60.0, 38.0 + (12.0 + 32.0/60.0)/60.0, 13.2, 'Blazar; BL Lacertae object; Highly variable; Easy to find next to 6 mag star; Distance is 0.4 GLy / 130 Mpc' ),
( 'Mrk 501', '4C 39.49;', \N, 301, 'Her', 16.0 + (53.0 + 52.2/60.0)/60.0, 39.0 + (45.0 + 37.0/60.0)/60.0, 13.9, 'Blazar; BL Lacertae object; Other stars of similar mag nearby; Distance is 0.5 GLy / 140 Mpc' ),
( 'OJ 287', 'EGO 0851+202; 3EG J0853+1941; RGB J0854+201;', \N, 301, 'Cnc', 8.0 + (54.0 + 48.9/60.0)/60.0, 20.0 + (6.0 + 32.0/60.0)/60.0, 14.2, 'Blazar; Varies greatly in brightness; Distance is 3.5 GLy / 1,070 Mpc' ),
( 'SN 2011dh', \N, \N, 304, 'CVn', 13.0 + (30.0 + 05.08/60.0)/60.0, 47.0 + (10.0 + 11.2/60.0)/60.0, 12.1, 'Type II supernova in M 51; Peak at apparent magnitude 12.1 on 19 June 2011' );

commit;


-- Insert objects into the Master Index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, specialCatalog )
select st.name, st.name, st.othernames, st.sao, 613, true from SpecialTemp st
on duplicate key update specialCatalog = true;
commit;



start transaction;

drop table if exists SpecialCatalog;
create table SpecialCatalog
(
	specialId					int not null auto_increment,
	objectId					int not null,
	name						varchar( 64 ) not null,
	otherNames					varchar( 255 ),
	sao							varchar( 10 ),
	objectType					int not null,
	constellation				char( 3 ) not null,
	rightAscension				double not null,
	declination					double not null,
	magnitude					float,
	notes						varchar( 255 ),
	dataSource					varchar( 32 ),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( specialId ),
	unique key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId ),
	foreign key ( objectType ) references ObjectTypes ( typeId ),
	foreign key ( constellation ) references Constellations ( abbreviationIAU )
);

insert into SpecialCatalog
( objectId, name, otherNames, sao, objectType, constellation, rightAscension, declination, magnitude, notes, dataSource )
select moi.objectId, st.name, st.otherNames, st.sao, st.typ, st.con, st.ra, st.decl, st.magnitude, st.notes, 'Hand-entered IMT Aug 2011'
from SpecialTemp st, MasterObjectIndex moi
where moi.name = st.name;

drop table if exists SpecialTemp;

commit;
