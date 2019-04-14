-- Create the primary views

start transaction;

drop view if exists DeepSkyObjects;
create view DeepSkyObjects as
select moi.name, moi.otherNames, ot.description, ds.constellation, ds.rightAscension, ds.declination, ds.magnitude,
ds.surfBright, ds.sizeMajor, ds.sizeMinor, ds.posAngle, ds.classification, ds.nbrStars, ds.brightestStar,
ds.pageU2K, ds.pageSA2K, ds.pagePSA, ds.pageBSA, ds.messier, ds.bestOfNGC, ds.caldwell, ds.hershel400, ds.ngcDesc,
ds.notes, ot.kind, ot.category, moi.objectId
from MasterObjectIndex moi
join DeepSkyCatalog ds on ( moi.objectId = ds.objectId )
join ObjectTypes ot on ( moi.objectType = ot.typeId )
where ot.category = 'DeepSky';

drop view if exists BrightDeepSkyObjects;
create view BrightDeepSkyObjects as
select * from DeepSkyObjects
where description <> 'Dark Nebula';

drop view if exists DarkNebulas;
create view DarkNebulas as
select * from DeepSkyObjects
where description = 'Dark Nebula';

drop view if exists PlanetaryNebulas;
create view PlanetaryNebulas as
select * from BrightDeepSkyObjects
where description = 'Planetary Nebula';

drop view if exists BrightNebulas;
create view BrightNebulas as
select * from BrightDeepSkyObjects
where kind = 'Nebula';

drop view if exists StarClusters;
create view StarClusters as
select * from DeepSkyObjects
where kind = 'Star Cluster';

drop view if exists OpenClusters;
create view OpenClusters as
select * from StarClusters
where kind = 'Star Cluster' and description like '%Open%';

drop view if exists GlobularClusters;
create view GlobularClusters as
select * from StarClusters
where kind = 'Star Cluster' and description like '%Globular%';

drop view if exists Galaxies;
create view Galaxies as
select * from DeepSkyObjects
where kind = 'Galaxy';

drop view if exists Exotics;
create view Exotics as
select * from DeepSkyObjects
where kind = 'Exotic';

drop view if exists MessierObjects;
create view MessierObjects as
select * from DeepSkyObjects
where messier is true;

drop view if exists CaldwellObjects;
create view CaldwellObjects as
select * from DeepSkyObjects
where caldwell is true;

drop view if exists BestOfNGC;
create view BestOfNGC as
select * from DeepSkyObjects
where bestOfNGC is true;

commit;


start transaction;

drop view if exists MultipleStars;
create view MultipleStars as
select moi.name, moi.sao, moi.otherNames, ms.constellation, ms.rightAscension, ms.declination, ms.components,
ms.magnitude, ms.magnitude2, ms.separation, ms.posAngle, ms.variable, ms.pageU2K, ms.pageSA2K, ms.pagePSA, ms.pageBSA,
ms.notes, moi.objectId
from MasterObjectIndex moi
join MultipleStarCatalog ms on ( moi.objectId = ms.objectId );

commit;


start transaction;

drop view if exists ColoredStars;
create view ColoredStars as
select moi.name, moi.sao, moi.otherNames, cs.constellation, cs.rightAscension, cs.declination,
cs.magnitude, cs.BminusV, cs.spectralType, cs.multiple, cs.variable,
cs.pageU2K, cs.pageSA2K, cs.pagePSA, cs.pageBSA, cs.notes, moi.objectId
from MasterObjectIndex moi
join ColoredStarCatalog cs on ( moi.objectId = cs.objectId );

commit;


start transaction;

drop view if exists Comets;
create view Comets as
select moi.name, moi.otherNames, cc.designation, cc.notes, moi.objectId from MasterObjectIndex moi
join CometCatalog cc on ( moi.objectId = cc.objectId );

commit;


start transaction;

drop view if exists Asteroids;
create view Asteroids as
select moi.name, moi.otherNames, ac.number, ac.notes, moi.objectId from MasterObjectIndex moi
join AsteroidCatalog ac on ( moi.objectId = ac.objectId ) order by ac.number asc;
