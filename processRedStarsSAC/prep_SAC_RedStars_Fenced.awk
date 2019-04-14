#!/usr/bin/awk -f

#
# $1 = NAME
# $2 = OTHER NAMES
# $3 = Constellation
# $4 = R.A. hour min.d
# $5 = DEC deg min
# $6 = Visual magnitude
# $7 = B-V
# $8 = Spectral Type
# $9 = Notes

function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		return "'" x "'"
	}
}


function isVariable( x, y ) {
	if ( match( x, "[A-Z] [A-Z][a-zA-Z][a-zA-Z]" ) || match( x, "[A-Z][A-Z] [A-Z][a-zA-Z][a-zA-Z]" ) || match( x, "V[0-9]+ [A-Z][a-zA-Z][a-zA-Z]" ) ) {
		# Name indicates a variable
		return 1
	} else if ( match( y, "[Pp]eriod" ) || match( y, "[Vv]ariable" ) ) {
		# Notes indicate a variable
		return 1
	}
	return 0
}


function isMultiple( x ) {
	if ( match( x, "[Mm]ultiple" ) || match( x, "[[Dd]ouble" ) || match( x, "DBL[*]" ) || match( x, "comp[*]" ) || match( x, "PA [0-9]" ) ) {
		return 1
	}
	return 0
}


function extractSAO( x, y ) {
	if ( match( x, "SAO [0-9]+" ) ) {
		sao = substr( x, RSTART, RLENGTH )
	} else if ( match( y, "SAO [0-9]+" ) ) {
		sao = substr( y, RSTART, RLENGTH )
	} else {
		sao = "\\N"
	}
	return quote( sao )
}


function fixOtherNameTermination( x ) {
	# Terminate with a ";" to permit effective searches for other names
	if ( x != "\\N" && x != "" ) {
		return x ";"
	} else {
		return x
	}
}


BEGIN {
	FS = "|"
	OFS = ""

	version = "SAC Red Stars " ver

	tableName = "SAC_RedStar_" strftime( "%Y_%m_%d" )
	print "start transaction;"
	print "drop table if exists ", tableName, ";"
	print "create table ", tableName
	print "("
	print "id				int not null auto_increment,"
	print "name				varchar(32) not null,"
	print "other_name		varchar(48),"
	print "sao				varchar(10),"
	print "constellation	char(3) not null,"
	print "ra				double not null,"
	print "decl				double not null,"
	print "mag				float,"
	print "b_v				float,"
	print "spectral			varchar(6),"
	print "multiple			boolean,"
	print "variable			boolean,"
	print "notes			varchar(96),"
	print "source			varchar(32),"
	print "primary key( id ),"
	print "key ( name ),"
	print "key ( other_name )"
	print ");"
}

END {
	print "commit;"
}


{
	name = quote( $1 )
	otherNames = quote( fixOtherNameTermination( $2 ) )
	sao = extractSAO( $1, $2 )
	cons = quote( $3 )

	# Compute R.A.
	split( $4, raParts, " " )
	ra = raParts[1] + raParts[2]/60.0

	# Compute Dec
	split( $5, decParts, " " )
	dec = ( decParts[1] < 0 ) ? decParts[1] - decParts[2]/60.0 : decParts[1] + decParts[2]/60.0

	mag = $6
	bv = $7
	spectral = quote( $8 )
	notes = quote( $9 )
	source = quote( version )

	variable = ( isVariable( $1, $9 ) ) ? "true" : "false"
	multiple = ( isMultiple( $9 ) ) ? "true" : "false"

	print "insert into ", tableName,
	" ( name, other_name, sao, constellation, ra, decl, mag, b_v, spectral, multiple, variable, notes, source ) ",
		"values ( ", name, ",", otherNames, ",", sao, ",", cons, ",", ra, ",", dec, ",",
		mag, ",", bv, ",", spectral, ",", multiple, ",", variable, ",", notes, ",", source, " );"
}


