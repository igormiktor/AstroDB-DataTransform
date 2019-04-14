-- Delete the Catalogs, Master Index, and related stuff

SET foreign_key_checks = 0;

start transaction;

drop view if exists DeepSkyObjects;
drop view if exists BrightDeepSkyObjects;
drop view if exists DarkNebulas;
drop view if exists PlanetaryNebulas;
drop view if exists BrightNebulas;
drop view if exists StarClusters;
drop view if exists OpenClusters;
drop view if exists GlobularClusters;
drop view if exists Galaxies;
drop view if exists Exotics;
drop view if exists MultipleStars;
drop view if exists ColoredStars;

drop table if exists DeepSkyCatalog;
drop table if exists MultipleStarCatalog;
drop table if exists ColoredStarCatalog;
drop table if exists PlanetCatalog;
drop table if exists CometCatalog;
drop table if exists AsteroidCatalog;
drop table if exists SpecialCatalog;

drop table if exists MasterObjectIndex;
drop table if exists ObjectTypes;

commit;

SET foreign_key_checks = 1;







