-- PROBLEM:  all catalogs without objectId as a unique key, which then broke a bunch of
-- "group by" used by the Xataface UI in the various views deriving from DeepSkyCatalog.
-- MySQL didn't originally enforce this, so that is why it went undetected until recent
-- updates to MySQL.

-- This file fixes MultipleStarCatalog.  This is complicated because any star
-- system with more than 2 components produces multiple "duplicate" rows, with
-- one row per primary-secondary pair.  So if there are N stars in the system,
-- there will be N-1 rows (one for each primary-secondary combination).


start transaction;


-- First make a copy to preserve

create table MultipleStarCatalogOriginal like MultipleStarCatalog;
insert into MultipleStarCatalogOriginal select * from MultipleStarCatalog;

-- Create a working verion (that we can delete from)

create table MultipleStarWorking like MultipleStarCatalog;
insert into MultipleStarWorking select * from MultipleStarCatalog;

-- Everything now happens to MultipleStarWorking...


-- Delete dupes of objectId = 18942
delete from MultipleStarWorking
where
    multipleStarId >= 4097
    and multipleStarId <= 4183;

-- Delete dupes of objectId = 18943
delete from MultipleStarWorking
where
    multipleStarId >= 4224
    and multipleStarId <= 4310;

-- Delete dupes of objectId = 18944
delete from MultipleStarWorking
where
    multipleStarId >= 4351
    and multipleStarId <= 4437;

-- Delete an actual dupe of objectId = 17671
delete from MultipleStarWorking
where multipleStarId == 1476;

-- Remove errors in multiple stars (bad entries):
delete from MultipleStarWorking where multipleStarId = 1964;
delete from MultipleStarWorking where multipleStarId = 991;

-- More fixes
update MultipleStarWorking set components = "AB"
where multipleStarId = 418
    or multipleStarId = 908
    or multipleStarId = 910
    or multipleStarId = 951
    or multipleStarId = 1149
    or multipleStarId = 1408
    or multipleStarId = 1417
    or multipleStarId = 1519
    or multipleStarId = 1850
    or multipleStarId = 1925;

update MultipleStarWorking set components = "AC"
where multipleStarId = 419
    or multipleStarId = 1851;

delete from MultipleStarWorking
where multipleStarId = 909
    or multipleStarId = 1148
    or multipleStarId = 1409
    or multipleStarId = 1434
    or multipleStarId = 1520
    or multipleStarId = 1924;

update MultipleStarWorking
set magnitude = 7
where multipleStarId = 634;


-- New catalog will be in two parts:
--  (1) primary table with one row per multiple star (with unique objectId)
--  (2) secondary table with one row per secondary star per primary rows
-- Once-per-object info goes in the primary table
-- The per-secondary info goes in the secondary table

create table MultipleStarPrimaryCatalog
(
    multipleStarPrimaryId   int not null auto_increment,
    objectId                int not null,
    name                    varchar(32) not null,
    constellation           char(3) not null,
    rightAscension          double not null,
    declination             double not null,
    magnitudePri            float,
    variable                boolean,
    pageU2K                 int,
    pageSA2K                int,
    pagePSA                 int,
    pageBSA                 int,
    notes                   varchar(255),
    dataSource              varchar(32),
    lastTouched             timestamp default current_timestamp on update current_timestamp,

    primary key ( multipleStarPrimaryId ),
    unique key ( objectId ),
    key ( name ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);


create table MultipleStarSecondaries
(
    multipleStarSecondaryId     int not null auto_increment,
    objectId                    int not null,
    magnitudeSec                float,
    components                  varchar(5),
    separation                  float,
    posAngle                    float,
    variable                    boolean,
    notes                       varchar(255),

    primary key ( multipleStarSecondaryId ),
    key ( objectId ),
    foreign key ( objectId ) references MasterObjectIndex ( objectId )
);


-- To populate these correctly, we need to do some extra work...

-- Separate out the "singleton" entries (i.e., plain double stars)
create table  like MultipleStarWorking;
insert into MSsingles select * from MultipleStarWorking
    where objectId in (
        select objectId from MultipleStarWorking
        group by objectId having count(*) = 1
    );
-- Eliminate the annoying default of components = NULL implying AB.
update MSsingles set components="AB" where components is NULL;

-- Separate out the "multirow" entries (multistar systems)
create table MSmultis like MultipleStarWorking;
insert into MSmultis select * from MultipleStarWorking;
delete from MSmultis where objectId in (select objectId from MSsingles);

-- Grab all the mutli-entries that have an "AB" component row

create table MSonlyABrows like MultipleStarWorking;
insert into MSonlyABrows select * from MSmultis where components = "AB";

create table MSfullABsets like MultipleStarWorking;
insert into MSfullABsets select * from MSmultis
where objectId in (select objectId from MSonlyABrows);

create table MSleft like MultipleStarWorking;
insert into MSleft select * from MSmultis
where objectId not in (select objectId from MSonlyABrows);

create table MSleftSingles like MultipleStarWorking;
insert into MSleftSingles select * from MSleft
where multipleStarId = 31
    or multipleStarId = 37
    or multipleStarId = 132
    or multipleStarId = 406
    or multipleStarId = 540
    or multipleStarId = 633
    or multipleStarId = 713
    or multipleStarId = 827
    or multipleStarId = 974
    or multipleStarId = 1141
    or multipleStarId = 1713;

-- MSleft is now the full row sets corresponding to MSleftSingles

-- Create the primary table from MSsingles, MSonlyABrows, and the MSleftSingles

insert into MultipleStarPrimaryCatalog
( objectId, name, constellation, rightAscension, declination, magnitudePri,
variable, pageU2K, pageSA2K, pagePSA, pageBSA, notes, dataSource )
select
a.objectId, a.name, a.constellation, a.rightAscension, a.declination, a.magnitude,
a.variable, a.pageU2K, a.pageSA2K, a.pagePSA, a.pageBSA, a.notes, a.datasource
from MSsingles a;

insert into MultipleStarPrimaryCatalog
( objectId, name, constellation, rightAscension, declination, magnitudePri,
variable, pageU2K, pageSA2K, pagePSA, pageBSA, notes, dataSource )
select
a.objectId, a.name, a.constellation, a.rightAscension, a.declination, a.magnitude,
a.variable, a.pageU2K, a.pageSA2K, a.pagePSA, a.pageBSA, a.notes, a.datasource
from MSonlyABrows a;

insert into MultipleStarPrimaryCatalog
( objectId, name, constellation, rightAscension, declination, magnitudePri,
variable, pageU2K, pageSA2K, pagePSA, pageBSA, notes, dataSource )
select
a.objectId, a.name, a.constellation, a.rightAscension, a.declination, a.magnitude,
a.variable, a.pageU2K, a.pageSA2K, a.pagePSA, a.pageBSA, a.notes, a.datasource
from MSleftSingles a;


-- Create the secondaries table from the full row collections found in
-- MSsingles, MSfullABsets, MSleft

insert into MultipleStarSecondaries
( objectId, magnitudeSec, components, separation, posAngle, variable, notes )
select
a.objectId, a.magnitude2, a.components, a.separation, a.posAngle, a.variable, a.notes
from MSsingles a;

insert into MultipleStarSecondaries
( objectId, magnitudeSec, components, separation, posAngle, variable, notes )
select
a.objectId, a.magnitude2, a.components, a.separation, a.posAngle, a.variable, a.notes
from MSfullABsets a;

insert into MultipleStarSecondaries
( objectId, magnitudeSec, components, separation, posAngle, variable, notes )
select
a.objectId, a.magnitude2, a.components, a.separation, a.posAngle, a.variable, a.notes
from MSleft a;

-- Everything is done, except best for the file to be naturally ordered by RA
-- So this quick fix..
alter table MultipleStarPrimaryCatalog rename MultipleStarPrimaryCatalogOld;
create table MultipleStarPrimaryCatalog like MultipleStarPrimaryCatalogOld;
select a.objectId, a.name, a.constellation, a.rightAscension, a.declination, a.magnitudePri, a.variable, a.pageU2K, a.pageSA2K, a.pagePSA, a.pageBSA, a.notes, a.datasource
from MultipleStarPrimaryCatalogOld a order by a.rightAscension;

commit;
