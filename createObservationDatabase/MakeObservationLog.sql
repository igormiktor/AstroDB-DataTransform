

set foreign_key_checks = 0;
start transaction;
drop table if exists ObservationDetails;
drop table if exists Observations;
drop table if exists Sessions;
commit;
set foreign_key_checks = 1;


-- Create the table of observing sessions

start transaction;
create table Sessions
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

	primary key ( sessionId ),
	foreign key ( site ) references Sites ( siteId ),
	foreign key ( observer ) references Observers (observerId ),
	foreign key ( seeing ) references Seeing ( seeingId ),
	foreign key ( transparency ) references Transparency ( transparencyId )
);

-- Populate it with data from the preprocessed sessions table

insert into Sessions
(
	sessionId,
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
	source
)
select
	sessionId,
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
	source
from Sessions1;

commit;


-- Create the table of observations

start transaction;
create table Observations
(
	observationId			int not null auto_increment,
	sessionId				int not null,
	observationTime			datetime not null,
	observationTimeEnd		datetime not null,
	observationTimeU		bigint not null,
	observationTimeEndU		bigint not null,
	observationTimeJ		double not null,
	observationTimeEndJ		double not null,
	objectId				int,
	found					boolean not null default TRUE,
	notes					text,
	source					varchar( 64 ),
	observationT			timestamp not null,

	primary key ( observationId ),
	key ( observationTime ),
	foreign key ( objectId ) references MasterObjectIndex( objectId ),
	foreign key ( sessionId ) references Sessions ( sessionId )
);


-- Populate it with data from preprocess observations table

insert into Observations
(
	observationId,
	sessionId,
	observationTime,
	observationTimeEnd,
	observationTimeU,
	observationTimeEndU,
	observationTimeJ,
	observationTimeEndJ,
	objectId,
	notes,
	source
)
select
	observationId,
	session,
	observationTime,
	observationTimeEnd,
	observationTimeU,
	observationTimeEndU,
	observationTimeJ,
	observationTimeEndJ,
	object,
	notes,
	source
from Observations1;

commit;



-- Create the table of observation details

start transaction;

create table  ObservationDetails
(
	observationDetailId			int not null auto_increment,
	observationId				int default null,
	telescope  					int default null,
	eyepiece 					int default null,
	barlow 						int default null,
	filter 						int default null,
	found						boolean not null default true,
	rating 						int default null,
	source						varchar( 64 ),
	observationDetailT			timestamp not null,
	primary key ( observationDetailId ),
	foreign key ( observationId ) references Observations ( observationId ),
	foreign key ( telescope ) references Telescopes ( telescopeId ),
	foreign key ( eyepiece ) references Eyepieces ( eyepieceId ),
	foreign key ( barlow ) references Barlows ( barlowId ),
	foreign key ( filter ) references Filters ( filterId )
);


insert into ObservationDetails
(
	observationDetailId,
	observationId,
	telescope,
	eyepiece,
	barlow,
	filter,
	found,
	rating,
	source
)
select
	observationDetailId,
	observation,
	telescope,
	eyepiece,
	barlow,
	filter,
	found,
	rating,
	source
from ObservationDetails1;

commit;



