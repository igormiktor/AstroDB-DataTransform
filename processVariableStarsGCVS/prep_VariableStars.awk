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
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	# Preliminary fix ups
	sub( /\./, "", x )
	sub( /\*/, "", x )

	x = fixGreekNames( x )
	x = cleanUpSpaces( x )
	return quote( x )
}


function getRAandDec( x, answer ) {
	if ( isEmpty( x ) ) {
		answer["ra"] = "\\N"
		answer["dec"] = "\\N"
		return 0
	}

	# Preliminary fix ups
	gsub( /:/, "", x )

	split( x, parts, /[-+]/ )

	# Right Ascension
	hr = substr( parts[1], 1, 2 )
	min = substr( parts[1], 3, 2 )
	sec = substr( parts[1], 5, 4 )
	ra = hr + (min + sec/60.0)/60.0

	# Declination
	deg = substr( parts[2], 1, 2 )
	min = substr( parts[2], 3, 2 )
	sec = substr( parts[2], 5, 2 )
	dec = deg + (min + sec/60.0)/60.0
	if ( x ~ /-/ ) {
		dec *= -1
	}

	answer["ra"] = ra
	answer["dec"] = dec
	answer["part1"] = parts[1]
	answer["part2"] = parts[2]
	return 0
}


function getTypes( x, types ) {
	if ( isEmpty( x ) ) {
		types[1] = "\\N"
		types[2] = "\\N"
		types[3] = "\\N"
		return 0
	}

	# Preliminary fix ups
	gsub( /:/, "", x )
	sub( /\*/, "???", x )

	n = split( x, types, /[/+]/ )

	for ( i = 1; i < 4; ++i ) {
		if ( i <= n ) {
			types[i] = quote( trimSpaces( types[i] ) )
		}
		else
		{
			types[i] = "\\N"
		}
	}
	return 0
}


function getMagnitude( x, ans ) {
	ans["value"] = "\\N"
	ans["basis"] = "\\N"
	ans["amplitude"] = "\\N"
	ans["faintLimit"] = "\\N"
	ans["brightLimit"] = "\\N"
	ans["alternative"] = "\\N"
	if ( isEmpty( x ) ) {
		return 0
	}

	# Fix data errors
	sub( /}/, ")", x )

	# Check for a variety of flags
	if ( x ~ /[0-9.]+/ ) {
		ans["value"] = gensub( /[<>(]? *(-?[0-9.]*) *[a-zA-Z:* ]*[)]?/, "\\1", "1", x )
	}
	if ( x ~ /[a-zA-Z*]+/ ) {
		ans["basis"] = quote( gensub( /[<>(]? *-?[0-9.]* *([a-zA-Z*]*)[ :]*[)]?/, "\\1", "1", x ) )
	}
	ans["amplitude"] = x ~ /\(.*\)/
	ans["faintLimit"] = x ~ />/
	ans["brightLimit"] = x ~ /</
	ans["alternative"] = x ~ /[a-zA-Z*():]/

	return 0
}


function getMagnitudeType( x )
{
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	return quote( trimSpaces( x ) )
}


function getEpoch( x ) {
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	return gensub( / *[(0-9.]+)[ :+-]*/, "\\1", "1", x )
}


function getYear( x ) {
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	return gensub( / *([0-9]+)[ :]*/, "\\1", "1", x )
}


function getPeriod( x, period ) {
	if ( isEmpty( x ) ) {
		period["value"] = "\\N"
		period["approximate"] = "\\N"
		return 0
	}

	period["value"] = gensub( /[(<> ]*([0-9.]+)[ :N*+/)]*/, "\\1", "1", x )
	period["approximate"] = x ~ /[(<>:N*+/)]/
	return 0
}


function getMdashM( x ) {
	if ( isEmpty( x ) || x !~ /[0-9]/) {
		return "\\N"
	}

	return gensub( / *([0-9]+)[ :*]*/, "\\1", "1", x )
}


function getSpectrum( x ) {
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	# Eliminate trailing spaces
	sub( /[ ]+$/, "", x )

	return quote( x )
}


function getReferences( x ) {
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	return quote( x )
}


function getOtherNames( x ) {
	if ( isEmpty( x ) ) {
		return "\\N"
	}

	# Eliminate equal signs
	sub( /=/, "", x )

	return quote( cleanUpSpaces( x ) )
}


BEGIN {
	FS = "|"
	OFS = ""

	version = "GCVS " ver

	tableName = "GCVS_" strftime( "%Y_%m_%d" )

	print "start transaction;"
	print "drop table if exists ", tableName, ";"
	print "create table ", tableName
	print "("
	print "	id				int not null auto_increment,"
	print "	gcvs			varchar(32) not null,"
	print " conCode			int not null,"
	print "	name			varchar(32) not null,"
	print "	ra				double not null,"
	print "	de				double not null,"
	print "	type1			varchar(32),"
	print "	type2			varchar(32),"
	print "	type3			varchar(32),"
	print " maxMag			double,"
	print " maxBasis		varchar(32),"
	print " maxAmplitude	boolean,"
	print " maxFaintLimit	boolean,"
	print " maxBrightLimit	boolean,"
	print " maxAlternative	boolean,"
	print " minMag			double,"
	print " minBasis		varchar(32),"
	print " minAmplitude	boolean,"
	print " minFaintLimit	boolean,"
	print " minBrightLimit	boolean,"
	print " minAlternative	boolean,"
	print " magType			varchar(32),"
	print " epoch			double,"
	print " year			int,"
	print " period			double,"
	print " periodApprox	bool,"
	print " mDashM			int,"
	print " spectrum		varchar(32),"
	print " refs			varchar(32),"
	print " otherNames		varchar(32),"
	print " source			varchar(64),"
	print "	primary key ( id ),"
	print "	key ( name ),"
	print "	key ( gcvs )"
	print ");"

}

END {
	print "commit;"
}



# $1 = GSCV Number
# $2 = Name
# $3 = Coords
# $4 = Type
# $5 = Max
# $6 = Min
# $7 = MagType
# $8 = Epoch
# $9 = Year
# $10 = Period
# $11 = M-m
# $12 = Spectrum
# $13 = References
# $14 = otherNames


 {
	# If it doesn't have coordinates, skip it
	if ( !match( $3, /[0-9]/ ) ) {
		next
	}

	gcvsId = quote( trimSpaces( $1 ) )
	conCode = getConstellationCode( $1 )

	name = getName( $2 )

	raAndDec[0] = 0
	getRAandDec( $3, raAndDec )
	ra = raAndDec["ra"]
	dec = raAndDec["dec"]

	getTypes( $4, types )

	mmax[0] = 0
	getMagnitude( $5, mmax )
	mmaxValue = mmax["value"]
	mmaxBasis = mmax["basis"]
	mmaxAmplitude = mmax["amplitude"]
	mmaxFaintLimit = mmax["faintLimit"]
	mmaxBrightLimit = mmax["brightLimit"]
	mmaxAlternative = mmax["alternative"]

	mmin[0] = 0
	getMagnitude( $6, mmin )
	mminValue = mmin["value"]
	mminBasis = mmin["basis"]
	mminAmplitude = mmin["amplitude"]
	mminFaintLimit = mmin["faintLimit"]
	mminBrightLimit = mmin["brightLimit"]
	mminAlternative = mmin["alternative"]

	magType = getMagnitudeType( $7 )
	epoch = getEpoch( $8 )
	year = getYear( $9 )

	period[0] = 0
	getPeriod( $10, period )
	periodValue = period["value"]
	periodApprox = period["approximate"]

	mDashM = getMdashM( $11 )
	spectrum = getSpectrum( $12 )
	refs = getReferences( $13 )
	otherNames = getOtherNames( $14 )

	# Print the line
	print "insert into ", tableName, " ",
		"( gcvs, conCode, name, ra, de, type1, type2, type3, maxMag, maxBasis, maxAmplitude, maxFaintLimit, maxBrightLimit, maxAlternative, ",
		"minMag, minBasis, minAmplitude, minFaintLimit, minBrightLimit, minAlternative, magType, epoch, year, period, periodApprox, mDashM, spectrum, refs, otherNames, source ) ",
		"values ( ", gcvsId, ",", conCode, ",", name, ",", ra, ",", dec, ",", types[1], ",", types[2], ",", types[3], ",",
		mmaxValue, ",", mmaxBasis, ",", mmaxAmplitude, ",", mmaxFaintLimit, ",", mmaxBrightLimit, ",", mmaxAlternative, ",",
		mminValue, ",", mminBasis, ",", mminAmplitude, ",", mminFaintLimit, ",", mminBrightLimit, ",", mminAlternative, ",",
		magType, ","
	printf "%10.4f%s", epoch, ","
	print year, ",", periodValue, ",", periodApprox, ",", mDashM, ",", spectrum, ",", refs,  ",", otherNames, ",", "'GCVS 2011-03-30' );"
}
