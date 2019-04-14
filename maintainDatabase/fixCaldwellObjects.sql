-- Fix some errors in Caldwell Object designations in the MasterObjectIndex.

# Fix Cave Nebula
update MasterObjectIndex set otherNames = concat( 'C9; ', otherNames ) where objectId = 1701;

# Fix second of the Double Clusters
update MasterObjectIndex set otherNames = concat( 'C14; ', otherNames ) where objectId = 7033;

# This piece of Veil Nebula is not a Caldwell object
update DeepSkyCatalog set caldwell = false where objectId = 3340;

# Fix the Rosette Nebula (all these are part of the view)
update MasterObjectIndex set otherNames = concat( 'C33; ', otherNames ) where objectId = 6154;
update MasterObjectIndex set otherNames = concat( 'C33; ', otherNames ) where objectId = 6162;

# NGC 6067 is not a Caldwell object (error in the original, the description is clearly NGC 6087, already tagged as C89)
update DeepSkyCatalog set caldwell = false where objectId = 6307;
