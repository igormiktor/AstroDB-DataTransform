-- An xataface bug related to "not null" columns force these columns to be marked as "default null"
-- instead of "not null".  Xataface bug has now been fixed, so this will restore the "not null" settings
-- for these columns.


alter table Sessions modify startTimeU bigint not null;
alter table Sessions modify finishTimeU bigint not null;
alter table Sessions modify startTimeJ double not null;
alter table Sessions modify finishTimeJ double not null;
alter table Sessions modify name varchar(255) not null;


alter table Observations modify observationTimeU bigint not null;
alter table Observations modify observationTimeEndU bigint not null;
alter table Observations modify observationTimeJ double not null;
alter table Observations modify observationTimeEndJ double not null;
alter table Observations modify objectId int not null;

alter table ObservationDetails modify observationId int not null;
