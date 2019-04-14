-- Add to observation details a rating system as inspired by Tony Flander's system
-- (see http://mysite.verizon.net/vze55p46/id16.html)

set foreign_key_checks = 0;
start transaction;
drop table if exists ObjectVisibility;
drop table if exists ObjectInterest;
commit;
set foreign_key_checks = 1;



start transaction;


-- Create the visibility rating system

create table ObjectVisibility
(
	objectVisibilityId			int not null auto_increment,
	objectVisibilityCode		char not null unique,
	objectVisibilityTag			varchar( 32 ) not null,
	objectVisibilityDesc 		varchar( 255 ) not null,
	primary key ( objectVisibilityId ),
	key( objectVisibilityCode )
);

insert into ObjectVisibility values
( 1, "1", "very easy", "very easy, obvious even to a beginner" ),
( 2, "2", "easy", "Easy, immediately obvious to an experienced observer" ),
( 3, "3", "moderate", "Moderate, may take a little looking" ),
( 4, "4", "hard", "Hard, need to know where in the field to look" ),
( 5, "5", "very hard", "Very hard, borderline observation, intermittently visible" );



-- Create the interest rating system

create table ObjectInterest
(
	objectInterestId			int not null auto_increment,
	objectInterestCode			char(1) not null unique,
	objectInterestTag			varchar( 64 ) not null,
	objectInterestDesc 			varchar( 255 ) not null,
	primary key ( objectInterestId ),
	key ( objectInterestCode )
);

insert into ObjectInterest values
( 1, "A", "spectacular", "Spectacular; show off to others" ),
( 2, "B", "beautiful or unusual", "Beautiful or unusual; worth revisiting and showing to others" ),
( 3, "C", "unspectacular but interesting", "Unspectacular but interesting; worth a revisit" ),
( 4, "D", "detectable but nearly featureless", "Detectable but nearly featureless; revisit under better conditions" ),
( 5, "F", "uninteresting", "Not interesting; not worth a revisit" );



-- Alter the ObservationDetails table to list visibility and interest and reference the visibility and interest tables

alter table ObservationDetails
add column visibilityRating int default null after rating;

alter table ObservationDetails
add column interestRating int default null after visibilityRating;

alter table ObservationDetails
add foreign key ( visibilityRating ) references ObjectVisibility ( objectVisibilityId );

alter table ObservationDetails
add foreign key ( interestRating ) references ObjectInterest ( objectInterestId );


-- The Current rating is really an interest rating, so transfer accordingly

update ObservationDetails
set interestRating = rating where rating is not null and rating > 0 and rating <= 5;

update ObservationDetails
set interestRating = 5 where rating is not null and rating > 5;

commit;


