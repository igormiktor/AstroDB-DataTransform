#!/bin/sed -f
/^PRAGMA/d;
/^BEGIN/d;
/^CREATE/d;
/^COMMIT/d;
/^INSERT/s/);$//;
/^INSERT/s/INSERT INTO "Observations" VALUES(//;
/^INSERT/s/INSERT INTO "Sessions" VALUES(//;
s/SAO\([0-9][0-9*]\)/SAO \1/;
s/NGC\([0-9][0-9*]\)/NGC \1/;
