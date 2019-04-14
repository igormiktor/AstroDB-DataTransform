

-- Find dupes in the DeepSky table (not supposed to have them)
-- select a.* from SAC_DeepSky_2011_04_22 a, SAC_DeepSky_2011_04_22 b where a.name = b.name and a.id <> b.id;

-- Check for dupes between names and other_names in the DeepSky table (happens a lot)
-- select a.id, a.name, a.other_name, b.id, b.name, b.other_name from SAC_DeepSky_2011_04_22 a, SAC_DeepSky_2011_04_22 b
-- where a.other_name like concat( '%', b.name, ';%' ) and a.id <> b.id;

-- Find dupes in the MultiStar table (should happen only for multistars)
-- select a.* from SAC_DoubleStar_2011_04_22 a, SAC_DoubleStar_2011_04_22 b where a.name = b.name and a.id <> b.id;

-- Check for dupes between names and other_names in the DeepSky table (happens a lot)
-- select a.id, a.name, a.other_name, b.id, b.name, b.other_name from SAC_DeepSky_2011_04_22 a, SAC_DeepSky_2011_04_22 b
-- where a.other_name like concat( '%', b.name, ';%' ) and a.id <> b.id;


-- Insert DeepSky objects into the index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, objectType, deepSkyCatalog )
select ds.name, ds.name, ds.other_name, t.our_type, true from SAC_DeepSky_2011_04_22 ds join SAC_ObjectTypes t
on ( ds.obj_type = t.designator ) where ds.name != '3C 273' on duplicate key update objectId = objectId;
commit;

-- Insert MultiStar objects into the index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, multipleStarCatalog )
select ms.name, ms.name, ms.other_name, ms.sao, 11, true from SAC_DoubleStar_2011_04_22 ms
on duplicate key update multipleStarCatalog = true;
commit;

-- Insert RedStar objects into the index
start transaction;
insert into MasterObjectIndex ( name, displayName, otherNames, sao, objectType, coloredStarCatalog )
select rs.name, rs.name, rs.other_name, rs.sao, 11, true from SAC_RedStar_2011_04_22 rs
on duplicate key update coloredStarCatalog = true;
commit;


-- Update information
start transaction;
update MasterObjectIndex moi, SAC_DeepSky_2011_04_22 ds
set moi.otherNames = mergeNames( moi.otherNames, ds.other_name )
where moi.name = ds.name;

update MasterObjectIndex moi, SAC_DoubleStar_2011_04_22 ms
set moi.otherNames = mergeNames( moi.otherNames, concat( ms.other_name, ms.sao, ";" ) )
where moi.name = ms.name;

update MasterObjectIndex moi, SAC_RedStar_2011_04_22 rs
set moi.otherNames = mergeNames( moi.otherNames, concat( rs.other_name, rs.sao, ";" ) )
where moi.name = rs.name;
commit;

-- Fix ups
start transaction;
delete from MasterObjectIndex where name = '3C 273';
update MasterObjectIndex set otherNames = if ( otherNames is null, 'Kruger 60;', concat( 'Kruger 60; ', otherNames ) ) where name = 'Kr 60';
update MasterObjectIndex set otherNames = if ( otherNames is null, 'Kemble\'s Cascade;', concat( 'Kemble\'s Cascade; ', otherNames ) ) where name = 'Kemble 1';
update MasterObjectIndex set otherNames = 'Brocchi\'s Cluster; Coathanger Cluster;' where name = 'Cr 399';
commit;

