-- Fix the way the old rating system was transformed to the interest rating

start transaction;

update ObservationDetails
set interestRating = (6 - rating) where rating is not null and rating > 0 and rating <= 5;

update ObservationDetails
set interestRating = 1 where rating is not null and rating > 5;

commit;

