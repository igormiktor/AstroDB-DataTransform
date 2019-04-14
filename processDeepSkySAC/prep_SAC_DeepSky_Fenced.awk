#!/usr/bin/awk -f

function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else {
		return "'" x "'"
	}
}

function convertSizeToSeconds( x ) {
	if ( x == "\\N" ) {
		size = "\\N"
	} else {
		split( $11, sizeParts, " " )
		if ( sizeParts[2] == "d" ) {
			size = sizeParts[1] * 60.0 * 60.0
		} else if ( sizeParts[2] == "m" ) {
			size = sizeParts[1] * 60.0
		} else if ( sizeParts[2] = "s" ) {
			size = sizeParts[1]
		} else {
			print "SIZE is bad, line " NR > /dev/stderr
			size = "\\N"
		}
	}
	return size
}

function fixCatalogs( x ) {
	# Do some catalog naming fixes to avoid conflicts

	# Change Kr = Krasnogorskaja to Kra to distinguish from Kr = Kruger (from Double Star catalog)
	sub( /Kr /, "Kra ", x )

	# Change H (followed by d-dd) = Haro from H = Herschel (Hershel is followed by Roman numerals)
	if ( match( x, /H [0-9]-/ ) && !match( x, /[a-zA-Z]H [0-9]-/ ) ) {
		# Then the next subsitution won't accidentally grab a catalog ending in H  or Herschel
		# Two step substitution due to lack of sub-element matches
		sub( /H [0-9]-/, "zzz&", x )
		sub( /zzzH/, "Haro", x )
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

	version = "SAC Deep Sky " ver

	tableName = "SAC_DeepSky_" strftime( "%Y_%m_%d" )

	print "start transaction;"
	print "drop table if exists ", tableName, ";"
	print "create table ", tableName
	print "("
	print "	id				int not null auto_increment,"
	print "	name			varchar(32) not null,"
	print "	other_name		varchar(32),"
	print "	obj_type		varchar(5) not null,"
	print "	constellation	char(3) not null,"
	print "	ra				double not null,"
	print "	decl			double not null,"
	print "	mag				float,"
	print "	surf_bright		float,"
	print "	u2k				int,"
	print "	tir				int,"
	print "	size_major		float,"
	print "	size_minor		float,"
	print "	pa				float,"
	print "	obj_class		varchar(16),"
	print "	nstars			int,"
	print "	br_star			float,"
	print "	best_of_ngc		boolean,"
	print "	caldwell		boolean,"
	print "	hershel			boolean,"
	print "	messier			boolean,"
	print "	ngc_desc		varchar(64),"
	print "	notes			varchar(96),"
	print "	source			varchar(32),"
	print "	primary key ( id ),"
	print "	key ( name ),"
	print "	key ( other_name )"
	print ");"

}

END {
	print "commit;"

# 	Perform a few fix-ups
	print "start transaction;"
	print "update ", tableName, " set other_name = 'Brocchi's cluster; Coathanger Cluster;' where name = 'Cr 399';"
	print "commit;"
}



# $1 = OBJECT
# $2 = OTHER
# $3 = TYPE
# $4 = CON
# $5 = RA hh mm.m
# $6 = DEC  +dd mm
# $7 = MAG
# $8 = SUBR
# $9 = U2K
# $10 = TI
# $11 = SIZE_MAX
# $12 = SIZE_MIN
# $13 = PA
# $14 = CLASS
# $15 = NSTS
# $16 = BRSTR
# $17 = BCHM
# $18 = NGC DESCR
# $19 = NOTES                                                                                 |


 {
	name = quote( $1 )

	# Do some catalog naming fixes to avoid conflicts
	other = quote( fixOtherNameTermination( fixCatalogs( $2 ) ) )

	type = quote( $3 )
	cons = quote( $4 )

	# Fix up RA
	if ( $5 ~ /[0-2][0-9] [0-5][0-9]\.[0-9]/ ) {
		split( $5, raParts, " " )
		ra = raParts[1] + raParts[2]/60.0
	} else if ( $5 == "\\N" ) {
		ra = $5
	} else {
		print "RA is bad, line " NR > /dev/stderr
		ra = "\\N"
	}

	# Fix up Dec
	if ( $6 ~ /[-+][0-9][0-9] [0-5][0-9]/ ) {
		split( $6, decParts, " " )
		dec = (decParts[1] < 0 ) ? decParts[1] - decParts[2]/60.0 : decParts[1] + decParts[2]/60.0
	} else if ( $6 == "\\N" ) {
		dec = $6
	} else {
		print "DEC is bad, line " NR > /dev/stderr
		dec = "\\N"
	}

	mag = $7
	surf_bright = $8
	u2k = $9
	tir = $10

	# Fix up size max
	sizeMax = convertSizeToSeconds( $11 )

	# Fix up size min
	sizeMin = convertSizeToSeconds( $12 )

	pa = $13;
	objClass = quote( $14 )
	nStars = $15
	brStar = $16

	# Fix up BCHM
	best = ( $17 ~ /B/ ) ? 1 : 0
	caldwell = ( $17 ~ /C/ ) ? 1 : 0
	herschel = ( $17 ~ /H/ ) ? 1 : 0
	messier = ( $17 ~ /M/ ) ? 1 : 0

	ngcDesc = quote( $18 )

	# Do some catalog naming fixes to avoid conflicts
	notes = quote( fixCatalogs( $19 ) )

	source = quote( version )

	# Print the line
	print "insert into ", tableName, " ",
		"( name, other_name, obj_type, constellation, ra, decl, mag, surf_bright, u2k, tir, size_major, size_minor, pa, ",
		"obj_class, nstars, br_star, best_of_ngc, caldwell, hershel, messier, ngc_desc, notes, source ) ",
		"values ( ", name, ",", other, ",", type, ",", cons, ",", ra, ",", dec, ",",
		mag, ",", surf_bright, ",", u2k, ",", tir, ",", sizeMax, ",", sizeMin, ",", pa, ",", objClass, ",", nStars, ",",
		brStar, ",", best, ",", caldwell, ",", herschel, ",", messier, ",", ngcDesc, ",", notes, ",", source, " );"
}
