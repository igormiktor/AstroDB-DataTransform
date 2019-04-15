# AstroDB-Data
Data transformation tools for the astronomy database.

This is code used to create, manage, and maintain the Astronomy Observations database.  It consists mostly of SQL code and various bash, awk, and sed scripts.

The original data sources for this database were:
- [SAC Deep Sky catalog v8.1](http://saguaroastro.org/sac-downloads/)
- [SAC Double Star catalog v4.0](http://saguaroastro.org/sac-downloads/)
- [SAC RedStars v2.0](http://saguaroastro.org/sac-downloads/)
- [General Catalog of Variable Stars (GCVS) v4.1](https://heasarc.gsfc.nasa.gov/W3Browse/all/gcvs.html)
- Planetary data from [JPL/Caltech](http://ssd.jpl.nasa.gov/)

The tools here can be used to recreate the database from original sources (all the preprocessing tools are included)
Note that asteroids and comets (except for a few that are pre-populated) are maintained in the database on an "as observed" basis (there is no "master" catalog for these; you have to create entries on-the-fly for the ones you observe).

Igor Mikolic-Torreira
igormt@alumni.caltech.edu
