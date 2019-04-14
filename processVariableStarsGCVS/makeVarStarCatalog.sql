start transaction;
drop table if exists VariableStarCatalog;
create table VariableStarCatalog
(
	variableStarId				int not null auto_increment,
	objectId					int not null,
	name						varchar(32) not null,
	gcvs						varchar(32) not null,
	constellation				char(3) not null,
	rightAscension				double not null,
	declination					double not null,
	type1						varchar(32) default null,
	type2						varchar(32) default null,
	type3						varchar(32) default null,
	magnitudeMax				float default null,
	magnitudeMin				float default null,
	amplitude					float default null,
	minIsBrightLimit			bool default false,
	photometricSystem			varchar(32) default null,
	epoch						double default null,
	novaYear					int(11) default null,
	period						double default null,
	periodApprox				bool default false,
	risingOrDuration			double default null,
	spectrum					varchar(32) default null,
	notes						text default null,
	dataSource 					varchar(32) default null,
	lastTouched					timestamp default current_timestamp on update current_timestamp,

	primary key ( variableStarId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId ),
	foreign key ( constellation ) references Constellations ( abbreviationIAU ),
	foreign key ( type1 ) references VariableStarTypes ( code ),
	foreign key ( type2 ) references VariableStarTypes ( code ),
	foreign key ( type3 ) references VariableStarTypes ( code ),
	foreign key ( photometricSystem ) references VariableStarPhotometricSystems ( code )
);

insert into VariableStarCatalog
( objectId, name, gcvs, constellation, rightAscension, declination, type1, type2, type3, magnitudeMax, magnitudeMin, amplitude, minIsBrightLimit, photometricSystem,
epoch, novaYear, period, periodApprox, risingOrDuration, spectrum, notes, dataSource )
select
v.objectId, v.name, v.gcvs, v.constellation, v.ra, v.de, v.type1, v.type2, v.type3, v.maxMag, if( v.minAmplitude is true, v.maxMag + v.minMag, v.minMag ),
if( v.minAmplitude is true, v.minMag, v.minMag - v.maxMag ), v.minBrightLimit, v.magType, v.epoch, v.year, v.period, v.periodApprox, v.mDashM, v.spectrum,
v.notes, v.source
from GCVS_Bright v;


drop view if exists VariableStars;
create view VariableStars as
select moi.name, moi.sao, moi.otherNames, vs.constellation, vs.rightAscension, vs.declination, vs.type1, vs.type2, vs.type3,
vs.magnitudeMax, vs.magnitudeMin, vs.amplitude, vs.minIsBrightLimit, vs.photometricSystem, vs.epoch, vs.novaYear, vs.period, vs.periodApprox, vs.risingOrDuration,
vs.spectrum, vs.notes, moi.objectId
from MasterObjectIndex moi
join VariableStarCatalog vs on ( moi.objectId = vs.objectId );


commit;