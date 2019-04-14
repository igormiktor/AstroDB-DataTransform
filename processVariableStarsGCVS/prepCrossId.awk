#!/usr/bin/awk -f

function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		sub( /'/, "\\'", x )
		return "'" x "'"
	}
}

function isEmpty( x ) {
	return ( length( x ) == 0 || !( x ~ /[^ ]/ ) )
}


function getConstellationCode( x ) {
	return substr( x, 1, 2 )
}


function fixGreekNames( x ) {
	# These two must come first
	sub( /eta/, "Eta", x )
	sub( /psi/, "Psi", x )

	sub( /alf/, "Alpha", x )
	sub( /bet/, "Beta", x ) 		#***
	sub( /gam/, "Gamma", x )
	sub( /del/, "Delta", x )
	sub( /eps/, "Epsilon", x ) 		#***
	sub( /zet/, "Zeta", x ) 		#***
	sub( /tet/, "Theta", x )
	sub( /iot/, "Iota", x )
	sub( /kap/, "Kappa", x )
	sub( /lam/, "Lambda", x )
	sub( /mu/, "Mu", x )
	sub( /nu/, "Nu", x )
	sub( /ksi/, "Xi", x )
	sub( /omi/, "Omicron", x )
	sub( /pi/, "Pi", x )
	sub( /rho/, "Rho", x )
	sub( /sig/, "Sigma", x )
	sub( /tau/, "Tau", x )
	sub( /ups/, "Upsilon", x )  	#***
	sub( /phi/, "Phi", x )
	sub( /khi/, "Chi", x )
	sub( /ome/, "Omega", x )

	return x
}


function trimSpaces( x ) {
	# Eliminate leading spaces
	sub(/^[ ]+/, "", x )
	# Eliminate trailing spaces
	sub(/[ ]+$/, "", x )

	return x
}

function cleanUpSpaces( x ) {
	# Turn multiple spaces into single spaces
	gsub( /[ ]+/, " ", x )

	return trimSpaces( x )
}


function getName( x ) {

	sub( /GCVS/, "", x )
	x = cleanUpSpaces( x )
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	x = fixGreekNames( x )
	x = cleanUpSpaces( x )
	return quote( x )
}

function getOtherName( x ) {

	sub( /=/, "", x )
	x = cleanUpSpaces( x )
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	x = fixGreekNames( x )
	x = cleanUpSpaces( x )
	return quote( x )
}



BEGIN {
	FS = "|"
	OFS = ""

	version = "GCVS " ver

	tableName = "GCVS_CrossId_" strftime( "%Y_%m_%d" )

	print "start transaction;"
	print "drop table if exists ", tableName, ";"
	print "create table ", tableName
	print "("
	print "	id				int not null auto_increment,"
	print "	name1			varchar(32) not null,"
	print "	name2			varchar(32) not null,"
	print "	primary key ( id ),"
	print "	key ( name1 ),"
	print "	key ( name2 )"
	print ");"

	print "insert into ", tableName, " ( name1, name2 ) values "

}

END {
	print "( 'xxxx', 'xxxx' );"
	print "commit;"
}



# $1 = GSCV name
# $2 = =name


 {
	name1 = getName( $1 )
	name2 = getOtherName( $2 )

	if ( name1 == "\\N" || name2 == "\\N" ) {
		next
	}

	# Print the line
	print "( " name1 "," name2, "),"
}
