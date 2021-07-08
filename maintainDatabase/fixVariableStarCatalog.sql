-- PROBLEM:  all catalogs without objectId as a unique key, which then broke a bunch of
-- "group by" used by the Xataface UI in the various views deriving from DeepSkyCatalog.
-- MySQL didn't originally enforce this, so that is why it went undetected until recent
-- updates to MySQL.

-- This file fixes VariableStarCatalog.  See the file fixCatalogsUniqueKey.sql for a
-- description of how it works.

-- There is a duplicate in the original VariableStarCatalog.
-- We fix this by ignoring variableStarId = 1467 we insert from the original table
-- into the new table.


start transaction;


create table VariableStarCatalog2
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
    unique key ( objectId ),
	key ( name ),
	foreign key ( objectId ) references MasterObjectIndex ( objectId )
--	foreign key ( constellation ) references Constellations ( abbreviationIAU ),
--	foreign key ( type1 ) references VariableStarTypes ( code ),
--	foreign key ( type2 ) references VariableStarTypes ( code ),
--	foreign key ( type3 ) references VariableStarTypes ( code ),
--	foreign key ( photometricSystem ) references VariableStarPhotometricSystems ( code )
);

insert into VariableStarCatalog2
( objectId, name, gcvs, constellation, rightAscension, declination, type1, type2, type3, magnitudeMax, magnitudeMin, amplitude,
minIsBrightLimit, photometricSystem, epoch, novaYear, period, periodApprox, risingOrDuration, spectrum, notes, dataSource )
select
vsc.objectId, vsc.name, vsc.gcvs, vsc.constellation, vsc.rightAscension, vsc.declination, vsc.type1, vsc.type2, vsc.type3,
vsc.magnitudeMax, vsc.magnitudeMin, vsc.amplitude, vsc.minIsBrightLimit, vsc.photometricSystem, vsc.epoch, vsc.novaYear,
vsc.period, vsc.periodApprox, vsc.risingOrDuration, vsc.spectrum, vsc.notes, vsc.dataSource
from VariableStarCatalog vsc
where variableStarId <> 1467;

alter table VariableStarCatalog rename VariableStarCatalog0;
alter table VariableStarCatalog2 rename VariableStarCatalog;


commit;
