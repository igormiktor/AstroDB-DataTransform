start transaction;

drop table if exists AsteroidTemp;
create table AsteroidTemp
(
	number					int not null,
	name 					varchar(64) not null,
	primary key ( name )
);

insert into AsteroidTemp ( number, name ) values
( 1, 'Ceres' ),
( 2, 'Pallas' ),
( 3, 'Juno' ),
( 4, 'Vesta' ),
( 5, 'Astraea' ),
( 6, 'Hebe' ),
( 7, 'Iris' ),
( 8, 'Flora' ),
( 9, 'Metis' ),
( 10, 'Hygiea' ),
( 11, 'Parthenope' ),
( 12, 'Victoria' ),
( 13, 'Egeria' ),
( 14, 'Irene' ),
( 15, 'Eunomia' ),
( 16, 'Psyche' ),
( 17, 'Tethis' ),
( 18, 'Melpomene' ),
( 19, 'Fortuna' ),
( 20, 'Massalia' ),
( 21, 'Lutetia' ),
( 22, 'Kalliope' ),
( 23, 'Thalia' ),
( 24, 'Themis' ),
( 25, 'Phocaea' );

commit;


-- Insert objects into the Master Index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, objectType, asteroidCatalog )
select at.name, at.name, concat( 'Asteroid ', at.number, ';'), 612, true from AsteroidTemp at
on duplicate key update asteroidCatalog = true;
commit;



start transaction;

drop table if exists AsteroidCatalog;
create table AsteroidCatalog
(
	asteroidId					int not null auto_increment,
	objectId					int not null,
	name						varchar(64) not null,
	number						int not null,
	notes						varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( asteroidId ),
    unique key( objectId ),
	unique key ( name ),
	unique key ( number ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into AsteroidCatalog
( objectId, name, number, dataSource )
select moi.objectId, at.name, at.number, 'Hand-entered IMT Aug 2011'
from AsteroidTemp at, MasterObjectIndex moi
where moi.name = at.name;

drop table if exists AsteroidTemp;

commit;
