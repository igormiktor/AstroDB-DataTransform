drop table if exists VariableStarPhotometricSystems;
create table VariableStarPhotometricSystems
(
	id				int not null auto_increment,
	code			varchar(32) not null unique,
	description		text,
	primary key ( id ),
	unique key ( code )
);

insert into VariableStarPhotometricSystems ( code, description ) values
( 'P', 'Photographic magnitudes' ),
( 'V', 'Visual, photovisual, or Johnson''s V' ),
( '1.', '1.04 micrometer band of the system introduced by G.W.Lockwood' ),
( 'u', 'Stroemgren system u' ),
( 'v', 'Stroemgren system v' ),
( 'b', 'Stroemgren system b' ),
( 'y', 'Stroemgren system y' ),
( 'Ic', 'Cousins'' I system' ),
( 'Rc', 'Cousins'' I system' ),
( 'g', 'System of Thuan and Gunn' ),
( 'T', 'Broad-band Tycho magnitudes formed from B and V measurements' ),
( 'r', 'Red magnitudes not tied to a particular system' ),
( '*', 'Unknown' ),
( 'B', 'Unknown' ),
( 'B*', 'Unknown' ),
( 'H', 'Unknown' ),
( 'Hp', 'Unknown' ),
( 'I', 'Unknown' ),
( 'J', 'Unknown' ),
( 'K', 'Unknown' ),
( 'Ks', 'Unknown' ),
( 'L', 'Unknown' ),
( 'L''', 'Unknown' ),
( 'p', 'Unknown' ),
( 'R', 'Unknown' ),
( 'U', 'Unknown' ),
( 'Y', 'Unknown' );