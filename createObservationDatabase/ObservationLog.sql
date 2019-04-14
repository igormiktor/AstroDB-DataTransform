
set foreign_key_checks = 0;
start transaction;
drop table if exists ObservationDetails1;
drop table if exists Observations1;
drop table if exists Sessions1;
commit;
set foreign_key_checks = 1;


-- Create the table of observing sessions

start transaction;
create table Sessions1
(
	sessionId 			int not null auto_increment,
	startTime			datetime not null,
	finishTime 			datetime not null,
	startTimeU			bigint not null,
	finishTimeU 		bigint not null,
	startTimeJ			double not null,
	finishTimeJ			double not null,
	name				varchar( 255 ),
	site 				int not null,
	observer 			int not null,
	seeing 				int not null,
	transparency 		int not null,
	notes 				text,
	source				varchar( 64 ),
	sessionT			timestamp not null,
	AP_id				varchar(32),

	primary key ( sessionId ),
	foreign key ( site ) references Sites ( siteId ),
	foreign key ( observer ) references Observers (observerId ),
	foreign key ( seeing ) references Seeing ( seeingId ),
	foreign key ( transparency ) references Transparency ( transparencyId )
);

-- Populate it with data from AP

insert into Sessions1
(
	startTime,
	finishTime,
	startTimeU,
	finishTimeU,
	startTimeJ,
	finishTimeJ,
	name,
	notes,
	site,
	observer,
	seeing,
	transparency,
	source,
	AP_id
)
select
	startTime,
	endTime,
	startTimeU,
	endTimeU,
	startTimeJ,
	endTimeJ,
	name,
	trim( concat( notes, ' ', usertext ) ),
	site,
	observer,
	seeing,
	transparency,
	source,
	AP_id
from AP_Sessions_2011_08_24;

commit;


-- Create the table of observations

start transaction;
create table Observations1
(
	observationId			int not null auto_increment,
	session					int not null,
	observationTime			datetime not null,
	observationTimeEnd		datetime not null,
	observationTimeU		bigint not null,
	observationTimeEndU		bigint not null,
	observationTimeJ		double not null,
	observationTimeEndJ		double not null,
	object					int,
	objectName				varchar(32),
	found					boolean not null default TRUE,
	notes					text,
	source					varchar( 64 ),
	observationT			timestamp not null,
	AP_id					varchar(32),
	AP_objectId				varchar(32),
	AP_objectName			varchar(256),

	primary key ( observationId ),
	key ( observationTime ),
	foreign key ( object ) references MasterObjectIndex( objectId ),
	foreign key ( session ) references Sessions1 ( sessionId )
);


-- Populate it with data from AP

insert into Observations1
(
	session,
	observationTime,
	observationTimeEnd,
	observationTimeU,
	observationTimeEndU,
	observationTimeJ,
	observationTimeEndJ,
	notes,
	source,
	AP_id,
	AP_objectId,
	AP_objectName
)
select
	s.sessionId,
	o.observationTime,
	o.observationTime,
	o.observationTimeU,
	o.observationTimeU,
	o.observationTimeJ,
	o.observationTimeJ,
	o.notes,
	o.source,
	o.AP_id,
	o.AP_objectId,
	o.objectName
from AP_Observations_2011_08_24 o, Sessions1 s, AP_Sessions_2011_08_24 sap where sap.id = o.sessionId and s.AP_id = sap.AP_id;

commit;



-- Fix ups of the names of objects in the existing AP observation database

start transaction;

delete from Observations1 where AP_objectId = '???';

update Observations1 set AP_objectName = concat( 'SAO 83500, ', AP_objectName ) 	where AP_objectName like '%Izar%';
update Observations1 set AP_objectName = concat( 'SAO 33693, ', AP_objectName ) 	where AP_objectName like '%Garnet%';
update Observations1 set AP_objectName = concat( 'SAO 138917, ', AP_objectName ) 	where AP_objectName like '%Porrima%';
update Observations1 set AP_objectName = concat( 'SAO 37734, ', AP_objectName ) 	where AP_objectName like '%Alamach%';
update Observations1 set AP_objectName = concat( 'SAO 308, ', AP_objectName ) 		where AP_objectName like '%Polaris%';
update Observations1 set AP_objectName = concat( 'SAO 63256, ', AP_objectName ) 	where AP_objectName like '%Cor Caroli%';
update Observations1 set AP_objectName = concat( 'SAO 64686, ', AP_objectName ) 	where AP_objectName like '%Mu Bootis%';
update Observations1 set AP_objectName = concat( 'SAO 131063, ', AP_objectName ) 	where AP_objectName like '%40 Eri%';

update Observations1 set AP_objectName = concat( 'SAO 131907, ', AP_objectName ) 	where AP_objectId = 'RIGEL';

update Observations1 set AP_objectId = 'Kr 60' 			where AP_objectName like '%Kruger 60%' or AP_objectName like '%KR60%';
update Observations1 set AP_objectId = 'Lambda Ori' 	where AP_objectName like '%Lamda Ori%';
update Observations1 set AP_objectId = 'Iota Ori' 		where AP_objectName like '%IotaOri%';
update Observations1 set AP_objectId = 'Kemble 1' 		where AP_objectName like '%Kemble%';
update Observations1 set AP_objectId = 'Cr 399' 		where AP_objectName like '%Coathanger%';

commit;



-- Match up our observed objects to the Master Object Index

start transaction;

update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where moi.name = o.AP_objectId;
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.otherNames like concat( trim(o.AP_objectId), ';%' );
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.otherNames like concat( '%; ', trim(o.AP_objectId), ';%' );
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.name = o.AP_objectName;
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.otherNames like concat( trim(o.AP_objectName), ';%' );
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.otherNames like concat( '%; ', trim(o.AP_objectName), ';%' );
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and moi.sao like AP_objectId;
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and AP_objectName like concat( '%', moi.sao, '%' );
update Observations1 o, MasterObjectIndex moi set o.object = moi.objectId where o.object is null and AP_objectName like concat( '%', moi.name, '%' );

commit;

-- At this point all objects are match to an entry in the Master Object Index



-- Create the table of observation details

start transaction;

create table  ObservationDetails1
(
	observationDetailId			int not null auto_increment,
	observation					int default null,
	telescope  					int default null,
	eyepiece 					int default null,
	barlow 						int default null,
	filter 						int default null,
	found						boolean not null default true,
	rating 						int default null,
	source						varchar( 64 ),
	observationDetailT			timestamp not null,
	AP_id						varchar(32) not null,
	AP_telescope				varchar(128) not null,
	AP_eyepiece 				varchar(128),
	AP_barlow					varchar(128),
	AP_filter					varchar(128),
	primary key ( observationDetailId ),
	foreign key ( observation ) references Observations1 ( observationId ),
	foreign key ( telescope ) references Telescopes ( telescopeId ),
	foreign key ( eyepiece ) references Eyepieces ( eyepieceId ),
	foreign key ( barlow ) references Barlows ( barlowId ),
	foreign key ( filter ) references Filters ( filterId )
);


insert into ObservationDetails1
(
	observation,
	telescope,
	eyepiece,
	barlow,
	filter,
	found,
	rating,
	source,
	AP_id,
	AP_telescope,
	AP_eyepiece,
	AP_barlow,
	AP_filter
)
select
	o.observationId,
	oi.telescope,
	oi.eyepiece,
	oi.barlow,
	oi.filter,
	oi.found,
	oi.rating,
	oi.source,
	oi.AP_id,
	oi.AP_telescope,
	oi.AP_eyepiece,
	oi.AP_barlow,
	oi.AP_filter
from AP_ObservationItems_2011_08_24 oi, Observations1 o, AP_Observations_2011_08_24 oap where oap.id = oi.observationId and o.AP_id = oap.AP_id;

commit;


-- Set the found flag correctly in the observations tables (true if any one of the details are found)

update Observations1 o, ObservationDetails1 od set o.found = true where o.observationId = od.observation and od.found is true;

