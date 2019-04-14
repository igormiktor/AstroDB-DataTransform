start transaction;

drop table if exists CometTemp;
create table CometTemp
(
	designation					varchar( 32 ) not null,
	name 						varchar( 64) not null,
	primary key ( designation )
);

insert into CometTemp ( designation, name ) values
( '1P/Halley', 'Halley' ),
( '2P/Encke', 'Encke' ),
( '3P/Biela', 'Biela' ),
( '103P/Hartley', 'Hartley 2' ),
( 'C/2007 N3', 'Lulin' ),
( 'C/1973 E1', 'Kohoutek' ),
( 'C/1975 V1', 'West' ),
( 'C/2009 P1', 'Garradd' );

commit;


-- Insert objects into the Master Index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, objectType, cometCatalog )
select ct.designation, ct.designation, concat( ct.name, ';'), 613, true from CometTemp ct
on duplicate key update cometCatalog = true;
commit;



start transaction;

drop table if exists CometCatalog;
create table CometCatalog
(
	cometId						int not null auto_increment,
	objectId					int not null,
	designation					varchar(32) not null,
	name						varchar(64) not null,
	notes						varchar(255),
	dataSource					varchar(32),
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( cometId ),
	unique key ( designation ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into CometCatalog
( objectId, name, designation, dataSource )
select moi.objectId, ct.name, ct.designation, 'Hand-entered IMT Aug 2011'
from CometTemp ct, MasterObjectIndex moi
where moi.name = ct.designation;

drop table if exists CometTemp;

commit;
