#!/usr/bin/awk -f

function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		gsub( /'/, "\\'", x )
		return "'" x "'"
	}
}

function isEmpty( x ) {
	return ( length( x ) == 0 || !( x ~ /[^ ]/ ) )
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

	theName = substr( x, 1, 6 )

	# Preliminary fix ups
	sub( /\./, "", theName )
	sub( /\*/, "", theName )

	theName = trimSpaces( fixGreekNames( theName ) )

	theConstellation = substr( x, 7, 3 )

	fullName = theName " " theConstellation

	return quote( fullName )
}


function getNotes( x ) {
	return quote( trimSpaces( substr( x, 14 ) ) )
}


BEGIN {
	FS = "|"
	OFS = ""

	version = "GCVS " ver

	tableName = "GCVS_Notes"

	print "start transaction;"
	print "drop table if exists ", tableName, ";"
	print "create table ", tableName
	print "("
	print "	id				int not null auto_increment,"
	print "	name			varchar(32) not null,"
	print "	gcvs			varchar(32),"
	print "	notes			text,"
	print "	primary key ( id ),"
	print "	key ( name )"
	print ");"

	print "insert into " tableName " ( name, notes ) values "


}

END {
	print "( 'XXX', 'XXX' );"
	print "commit;"
}



# $1 = name 			columns 1-6
# $2 = constellation	columns 7-9
# $3 = notes			columns 14+


 {
	# If it doesn't have coordinates, skip it
	if ( isEmpty( $0 ) ) {
		next
	}

	name = getName( $0 )

	notes = getNotes( $0 )

	# Print the line
	print "( " name ", " notes " ),"
}
