#!/usr/bin/awk -f

#
# $1 = CON
# $2 = NAME
# $3 = R.A. hour min.d
# $4 = DEC deg min
# $5 = COMP
# $6 = OTHER NAMES
# $7 = Mag
# $8 = Mag2
# $9 = SEP
# $10 = PA
# $11 = NOTES
# $12 = U2K
# $13 = TIR
# $14 = BSA
# $15 = SAO

function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		return "'" x "'"
	}
}

function sao_quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		return "'SAO " x "'"
	}
}

function fixCatalogs( x ) {
	# Do some catalog naming fixes to avoid conflicts

	# Change Sh = South & Herschel to SH to distinguish from Sh = Sharpless
	sub( /Sh /, "SH ", x )

	# Change B (followed by dddd) = Bos, W.H. van den to Bos distinguish from B = Barnard
	if ( match( x, /B [0-9]/ ) && !match( x, /[a-zA-Z]H [0-9]/ ) ) {
		# Then the next subsitution won't accidentally grab a catalog ending in H  or Herschel
		# Two step substitution due to lack of sub-element matches
		sub( /B [0-9]/, "zzz&", x )
		sub( /zzzB/, "Bos", x )
	}

	return x
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

	version = "SAC Double Star " ver

	tableName = "SAC_DoubleStar_" strftime( "%Y_%m_%d" )
	print "drop table if exists ", tableName, ";"
	print "start transaction;"
	print "create table ", tableName
	print "("
	print "id				int not null auto_increment,"
	print "name				varchar(32) not null,"
	print "other_name		varchar(32),"
	print "sao				varchar(10),"
	print "constellation	char(3) not null,"
	print "ra				double not null,"
	print "decl				double not null,"
	print "comp				varchar(5),"
	print "mag				float,"
	print "mag2				float,"
	print "sep				float,"
	print "pa				float,"
	print "multiple			boolean,"
	print "variable			boolean,"
	print "u2k				int,"
	print "tir				int,"
	print "bsa				int,"
	print "notes			varchar(132),"
	print "source			varchar(32),"
	print "primary key( id ),"
	print "key ( name ),"
	print "key ( other_name )"
	print ");"
#	print "commit;"
#	print "start transaction;"
}

END {
	print "commit;"

# 	Perform a few fix-ups
	print "start transaction;"
	print "update ", tableName, " set sao = 'SAO 231444' where name = 'Theta Gru' and sao = 'SAO 132444';"
	print "update ", tableName, " set other_name = 'Keid;' where sao = 'SAO 131063';"
	print "commit;"
}


{
	cons = quote( $1 )
	name = quote( fixCatalogs( $2 ) )

	# Compute R.A.
	split( $3, raParts, " " )
	ra = raParts[1] + raParts[2]/60.0

	# Compute Dec
	split( $4, decParts, " " )
	dec = ( decParts[1] < 0 ) ? decParts[1] - decParts[2]/60.0 : decParts[1] + decParts[2]/60.0

	comp = quote( $5 )
	otherNames = quote( fixOtherNameTermination( fixCatalogs( $6 ) ) )

	# Deal with var magnitudes
	variable = "false"
	addedNotes = ""
	if ( $7 ~ /[vV]/ ) {
		if ( match( $7, /[0-9][0-9.]*/ ) ) {
			$7 = substr( $7, RSTART, RLENGTH )
		} else {
			$7 = "\\N"
		}
		addedNotes = "Primary var"
		variable = "true"
	}
	mag = $7

	if ( $8 ~ /[vV]/ ) {
		if ( match( $8, /[0-9][0-9.]*/ ) ) {
			$8 = substr( $10, RSTART, RLENGTH )
		} else {
			$8 = "\\N"
		}
		addedNotes = (addedNotes == "") ?  "Secondary var" : addedNotes "; Secondary var"
		variable = "true"
	}
	mag2 = $8

	sep = $9
	pa = $10

	# deal with added notes
	if ( addedNotes != "" ) {
		if ( $11 == "\\N" ) {
			$11 = addedNotes
		} else {
			$11 = addedNotes "; " $11
		}
	}
	notes = quote( fixCatalogs( $11 ) )

	u2k = $12
	tir = $13
	bsa = $14
	sao = sao_quote( $15 )
	source = quote( version )

	multiple = "true"

	print "insert into ", tableName,
	" ( name, other_name, sao, constellation, ra, decl, comp, mag, mag2, sep, pa, multiple, variable, u2k, tir, bsa, notes, source ) ",
		"values ( ", name, ",", otherNames, ",", sao, ",", cons, ",", ra, ",", dec, ",",
		comp, ",", mag, ",", mag2, ",", sep, ",", pa, ",", multiple, ",", variable, ",",
		u2k, ",", tir, ",", bsa, ",", notes, ",", source, " );"
}


