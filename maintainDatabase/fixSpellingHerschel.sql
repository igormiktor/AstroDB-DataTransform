-- Fix the spelling of column names related to Herschel400.
-- Note that (1) only fixes relevant tables that have columns with the misspelling
--           (2) views are fixed by dropping them and recreating them correctly (revised MakePrimaryViews.sql)
--           (3) this fixes tables IN PLACE (via alter table)
--           (4) scripts are corrected throughout so that if we ever recreate tables from scratch, they will
--               be recreated correctly
--
-- So if database is recreated from scratch, no need to apply this patch ever again.

-- Tables affected are:  DeepSkyCatalog

-- Fix SAC_DeepSky_2011_04_22
alter table SAC_DeepSky_2011_04_22 change hershel herschel boolean;
alter table DeepSkyCatalog change hershel400 herschel400 boolean;

-- After executing this, recreate the views by running (the corrected version) of MakePrimaryViews.SQL
