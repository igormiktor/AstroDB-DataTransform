-- This code was used to find some errors in the tables
-- NOT NEEDED FOR PRODUCTION OR PATCHING

create table MScross
(
    theId                       int not null auto_increment,
    objectId                    int not null,
    nameA                       varchar(32),
    nameB                       varchar(32),
    constellationA              char(3),
    constellationB              char(3),
    IdA                         int,
    IdB                         int,

    primary key( theId )
);

insert into MScross
( objectId, nameA, nameB, constellationA, constellationB, IdA, IdB )
select
a.objectId, a.name, b.name, a.constellation, b.constellation, a.multipleStarId, b.multipleStarId
from MSmultis a inner join MSmultis b
where a.objectId = b.objectId;

select * from MScross where constellationA <> constellationB;


-- More testing stuff

select p.objectId, p.name, p.constellation, p.magnitudePri, s.magnitudeSec, s.components,
s.separation, p.variable, s.variable, p.notes, s.notes
from MultipleStarPrimaryCatalog p inner join MultipleStarSecondaries s
where p.objectId = s.objectId
into outfile "/home/igor/tmp/test.txt" fields terminated by '|';

create table MStestJoin
select p.objectId, p.name, p.constellation, p.magnitudePri, s.magnitudeSec, s.components,
s.separation, p.variable varP, s.variable VarS, p.notes notesP, s.notes notesS
from MultipleStarPrimaryCatalog p inner join MultipleStarSecondaries s
where p.objectId = s.objectId
order by p.rightAscension; 
