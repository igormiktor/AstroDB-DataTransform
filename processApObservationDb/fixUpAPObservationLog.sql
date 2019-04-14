start transaction;

update AP_Sessions_2011_04_09 ap, Seeing s set ap.seeing = s.seeingId where ap.AP_seeing = s.value;

commit;

update AP_Sessions_2011_04_09 ap, Transparency t set ap.transparency = t.transparencyId where ap.AP_transparency = t.tag;

update AP_Sessions_2011_04_09 ap, Sites s set ap.site = s.siteId where ap.AP_site like concat( '%', s.nickname ,'%' );


create table Observers
(
observerId int not null auto_increment,
name varchar( 255 ) not null,
nickname varchar( 32 ) not null,
birthdate date,
notes text,
primary key ( observerId ),
key ( name ),
key ( nickname )
);


update AP_ObservationItems oi, Telescopes t set oi.telescope = t.telescopeId where t.name like concat( '%', oi.AP_telescope, '%' );

update AP_ObservationItems_2011_04_09 oi, Telescopes t set oi.telescope = t.telescopeId where oi.AP_telescope like '%Finder%' and t.nickname = 'Finder';