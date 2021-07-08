-- PROBLEM:  all catalogs without objectId as a unique key, which then broke a bunch of
-- "group by" used by the Xataface UI in the various views deriving from DeepSkyCatalog.
-- MySQL didn't originally enforce this, so that is why it went undetected until recent
-- updates to MySQL.

-- This file PATCHES the existent database by creating duplicate catalogs (with "2" appended),
-- which are the same as the original catalog except they have objectId as a unique key.
-- Data is then loaded from the original table into the new table.  And then the
-- original catalog table is renamed to <same name>0, and then the new version is
-- renamed to the original.  All the views referencing that catalog table now work fine.

-- If you want to check for the duplicate in xyzCatalog, run this:
-- select objectId, count( xyzId ) c from xyzCatalog group by objectId having c > 1;

-- This fixes all catalogs EXCEPT:
--    (1) DeepSkyCatalog (fixed previously by file fixDeepSkyCatalog.sql)
--    (2) MultipleStarCatalog (which needs a complex fix)
--    (3) VariableStarCatalog (in a separate fix)


start transaction;


create table PlanetCatalog2
(
    planetId                int not null auto_increment,
    objectId                int not null,
    name                    varchar(32) not null,
    semiMajorAxis           double not null,
    semiMajorAxisRate       double not null,
    eccentricity            double not null,
    eccentricityRate        double not null,
    inclination             double not null,
    inclinationRate         double not null,
    longitude               double not null,
    longitudeRate           double not null,
    perihelion              double not null,
    perihelionRate          double not null,
    ascendingNode           double not null,
    ascendingNodeRate       double not null,
    notes                   varchar(255),
    dataSource              varchar(32),
    lastTouched             timestamp default current_timestamp on update current_timestamp,

    primary key ( planetId ),
    unique key ( objectId ),
    unique key ( name ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into PlanetCatalog2
( objectId, name, semiMajorAxis, semiMajorAxisRate, eccentricity, eccentricityRate,
inclination, inclinationRate, longitude, longitudeRate, perihelion, perihelionRate,
ascendingNode, ascendingNodeRate, dataSource )
select
pc.objectId, pc.name, pc.semiMajorAxis, pc.semiMajorAxisRate, pc.eccentricity, pc.eccentricityRate,
pc.inclination, pc.inclinationRate, pc.longitude, pc.longitudeRate, pc.perihelion, pc.perihelionRate,
pc.ascendingNode, pc.ascendingNodeRate, pc.dataSource
from PlanetCatalog pc;

alter table PlanetCatalog rename PlanetCatalog0;
alter table PlanetCatalog2 rename PlanetCatalog;


-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


create table CometCatalog2
(
    cometId             int not null auto_increment,
    objectId            int not null,
    designation         varchar(32) not null,
    name                varchar(64) not null,
    notes               varchar(255),
    dataSource          varchar(32),
    lastTouched         timestamp default current_timestamp on update current_timestamp,

    primary key ( cometId ),
    unique key ( objectId ),
    unique key ( designation ),
    key ( name ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into CometCatalog2
( objectId, name, designation, dataSource )
select
cc.objectId, cc.name, cc.designation, cc.dataSource
from CometCatalog cc;

alter table CometCatalog rename CometCatalog0;
alter table CometCatalog2 rename CometCatalog;


-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


create table AsteroidCatalog2
(
    asteroidId          int not null auto_increment,
    objectId            int not null,
    name                varchar(64) not null,
    number              int not null,
    notes               varchar(255),
    dataSource          varchar(32),
    lastTouched         timestamp default current_timestamp on update current_timestamp,

    primary key ( asteroidId ),
    unique key ( objectId ),
    unique key ( name ),
    unique key ( number ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into AsteroidCatalog2
( objectId, name, number, dataSource )
select
ac.objectId, ac.name, ac.number, ac.dataSource
from AsteroidCatalog ac;

alter table AsteroidCatalog rename AsteroidCatalog0;
alter table AsteroidCatalog2 rename AsteroidCatalog;


-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

-- Don't touch Special Catalog

-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


-- There is a duplicate in the original ColoredStarCatalog (coming from SAC_RedStar_2011_04_22).
-- We fix this by ignoring coloredStarId = 294 we insert from the original table into the new table.

create table ColoredStarCatalog2
(
    coloredStarId           int not null auto_increment,
    objectId                int not null,
    name                    varchar(32) not null,
    constellation           char(3) not null,
    rightAscension          double not null,
    declination             double not null,
    magnitude               float,
    BminusV                 float,
    spectralType            varchar(6),
    multiple                boolean,
    variable                boolean,
    pageU2K                 int,
    pageSA2K                int,
    pagePSA                 int,
    pageBSA                 int,
    notes                   varchar(255),
    dataSource              varchar(32),
    lastTouched             timestamp default current_timestamp on update current_timestamp,

    primary key ( coloredStarId ),
    unique key ( objectId ),
    unique key ( name ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);

insert into ColoredStarCatalog2
( objectId, name, constellation, rightAscension, declination, magnitude, BminusV, spectralType,
multiple, variable, notes, dataSource )
select
csc.objectId, csc.name, csc.constellation, csc.rightAscension, csc.declination, csc.magnitude,
csc.BminusV, csc.spectralType, csc.multiple, csc.variable, csc.notes, csc.dataSource
from ColoredStarCatalog csc
where csc.coloredStarId <> 294;

alter table ColoredStarCatalog rename ColoredStarCatalog0;
alter table ColoredStarCatalog2 rename ColoredStarCatalog;

commit;
