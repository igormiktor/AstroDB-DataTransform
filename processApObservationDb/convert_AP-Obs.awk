#!/usr/bin/awk -f


#**************************************************************************
#
# This file is in the public domain.
#
# For more information email LoranceStinson+csv@gmail.com.
# Or see http://lorance.freeshell.org/csv/
#
# Parse a CSV string into an array.
# The number of fields found is returned.
# In the event of an error a negative value is returned and csverr is set to
# the error. See below for the error values.
#
# Parameters:
# string  = The string to parse.
# csv     = The array to parse the fields into.
# sep     = The field separator character. Normally ,
# quote   = The string quote character. Normally "
# escape  = The quote escape character. Normally "
# newline = Handle embedded newlines. Provide either a newline or the
#           string to use in place of a newline. If left empty embedded
#           newlines cause an error.
# trim    = When true spaces around the separator are removed.
#           This affects parsing. Without this a space between the
#           separator and quote result in the quote being ignored.
#
# These variables are private:
# fields  = The number of fields found thus far.
# pos     = Where to pull a field from the string.
# strtrim = True when a string is found so we know to remove the quotes.
#
# Error conditions:
# -1  = Unable to read the next line.
# -2  = Missing end quote.
# -3  = Missing separator.
#
# Notes:
# The code assumes that every field is preceded by a separator, even the
# first field. This makes the logic much simpler, but also requires a
# separator be prepended to the string before parsing.
#**************************************************************************

function parse_csv(string,csv,sep,quote,escape,newline,trim, fields,pos,strtrim) {
    # Make sure there is something to parse.
    if (length(string) == 0) return 0;
    string = sep string; # The code below assumes ,FIELD.
    fields = 0; # The number of fields found thus far.
    while (length(string) > 0) {
        # Remove spaces after the separator if requested.
        if (trim && substr(string, 2, 1) == " ") {
            if (length(string) == 1) return fields;
            string = substr(string, 2);
            continue;
        }
        strtrim = 0; # Used to trim quotes off strings.
        # Handle a quoted field.
        if (substr(string, 2, 1) == quote) {
            pos = 2;
            do {
                pos++
                if (pos != length(string) &&
                    substr(string, pos, 1) == escape &&
                    (substr(string, pos + 1, 1) == quote ||
                     substr(string, pos + 1, 1) == escape)) {
                    # Remove escaped quote characters.
                    string = substr(string, 1, pos - 1) substr(string, pos + 1);
                } else if (substr(string, pos, 1) == quote) {
                    # Found the end of the string.
                    strtrim = 1;
                } else if (newline && pos >= length(string)) {
                    # Handle embedded newlines if requested.
                    if (getline == -1) {
                        csverr = "Unable to read the next line.";
                        return -1;
                    }
                    string = string newline $0;
                }
            } while (pos < length(string) && strtrim == 0)
            if (strtrim == 0) {
                csverr = "Missing end quote.";
                return -2;
            }
        } else {
            # Handle an empty field.
            if (length(string) == 1 || substr(string, 2, 1) == sep) {
                csv[fields] = "";
                fields++;
                if (length(string) == 1)
                    return fields;
                string = substr(string, 2);
                continue;
            }
            # Search for a separator.
            pos = index(substr(string, 2), sep);
            # If there is no separator the rest of the string is a field.
            if (pos == 0) {
                csv[fields] = substr(string, 2);
                fields++;
                return fields;
            }
        }
        # Remove spaces after the separator if requested.
        if (trim && pos != length(string) && substr(string, pos + strtrim, 1) == " ") {
            trim = strtrim
            # Count the number fo spaces found.
            while (pos < length(string) && substr(string, pos + trim, 1) == " ") {
                trim++
            }
            # Remove them from the string.
            string = substr(string, 1, pos + strtrim - 1) substr(string,  pos + trim);
            # Adjust pos with the trimmed spaces if a quotes string was not found.
            if (!strtrim) {
                pos -= trim;
            }
        }
        # Make sure we are at the end of the string or there is a separator.
        if ((pos != length(string) && substr(string, pos + 1, 1) != sep)) {
            csverr = "Missing separator.";
            return -3;
        }
        # Gather the field.
        csv[fields] = substr(string, 2 + strtrim, pos - (1 + strtrim * 2));
        fields++;
        # Remove the field from the string for the next pass.
        string = substr(string, pos + 1);
    }
    return fields;
}




function adjustTimeStampEpoch( timeStamp ) {

	# Adjust to be relative to 1970/1/1 at 00:00:00

	kEpochChange = 2082844800
	return int( timeStamp ) - kEpochChange
}


function computeJulianDate( timeStamp ) {

	# Return the Julian Date for the timeStamp

	kJulianDateOfUnixEpoch = 2440587.5
	kSecondsPerJulianDay = 86400.0
	return timeStamp / kSecondsPerJulianDay + kJulianDateOfUnixEpoch
}


function quote( x ) {
	if ( x == "\\N" ) {
		return x
	} else if ( x == "" ) {
		return "\\N"
	} else {
		return "'" x "'"
	}
}


function blankToNull( x ) {
	if ( x == "\\N" ) {
		return x
	} else if ( x == "" ) {
		return "\\N"
	} else {
		return x
	}
}

function fixObjectId( x ) {
	# Check for things like M31, NGC1234, etc
	if ( match( x, /[a-zA-Z][0-9]/ ) ) {
		# Find a long string of letters and add a space
		sub( /[a-zA-Z]+/, "& ", x )
	}
	return x
}

function escapeQuotes( x ) {
	# Handle the corner case
	sub( /^'/, "\\'", x )
	# Escape quotes until we don't find any more
	do {
		# Two step process to make the correct substitution
		nbrChanges = sub( /[^\\]'/, "&zzzz", x )
		sub( /'zzzz/, "\\'", x )
	} while ( nbrChanges == 1 )
	return x
}


# Fields are:
# $1 = KeyVal (varchar),
# $2 = DateTime (varchar)
# $3 = Rating (varchar) TABBED,
# $4 = Telescope (varchar) TABBED,
# $5 = Eyepiece (varchar) TABBED,
# $6 = Imager (text) TABBED,
# $7 = Filter (varchar) TABBED,
# $8 = Aid (varchar) TABBED,
# $9 = Observed (varchar) TABBED,
# $10 = Notes (varchar),
# $11 = UserFields (text),
# $12 = Files (varchar),
# $13 = Plan (varchar),  ignore
# $14 = ID (varchar),   catalog name?
# $15 = GUID (integer),  no idea
# $16 = Name (varchar), extended name?
# $17 = RA double,
# $18 = Dec double,
# $19 = Type varchar,
# $20 = Constellation varchar,
# $21 = GMTOffset double,
# $22 = Flags integer,
# $23 = UseUT integer,
# $24 = Special varchar
#
# 2,082,844,800 seconds between 1904/1/1 and 1970/1/1 at 00:00:00
#
# date +%s -d"Jan 1, 1980 00:00:01" Replace '-d' with '-ud' to input in GMT/UTC time.
#
# date -d @1190000000 Replace 1190000000 with your epoch, needs recent version of 'date'.
# Replace '-d' with '-ud' for GMT/UTC time.
#



BEGIN {
	FS = ","
	OFS = ""
	line = 0

	version = "AP_Obs_" strftime( "%Y_%m_%d" )
	source = quote( version )

	sesTableName = "AP_Sessions_" strftime( "%Y_%m_%d" )
	obsTableName = "AP_Observations_" strftime( "%Y_%m_%d" )
	obsItemsTableName = "AP_ObservationItems_" strftime( "%Y_%m_%d" )

	print "start transaction;"
	print "drop table if exists " obsTableName ";"
	print "create table " obsTableName
	print "("
	print "id					int not null auto_increment,"
	print "sessionId			int default null,"
	print "AP_id				varchar(32) not null,"
	print "observationTime		datetime not null,"
	print "observationTimeU		bigint not null,"
	print "observationTimeJ		double not null,"
	print "AP_objectId			varchar(32) not null,"
	print "objectId				int default null,"
	print "objectName			varchar(256),"
	print "notes				text,"
	print "source				varchar(32),"
	print "primary key ( id ),"
	print "key ( AP_id ),"
	print "key ( AP_objectId )"
	print ");"

	print "drop table if exists " obsItemsTableName ";"
	print "create table " obsItemsTableName
	print "("
	print "id					int not null auto_increment,"
	print "observationId		int default null,"
	print "AP_id				varchar(32) not null,"
	print "AP_telescope			varchar(128) not null,"
	print "AP_eyepiece 			varchar(128),"
	print "AP_barlow			varchar(128),"
	print "AP_filter			varchar(128),"
	print "telescope  			int default null,"
	print "eyepiece 			int default null,"
	print "barlow 				int default null,"
	print "filter 				int default null,"
	print "found				boolean not null,"
	print "rating 				int,"
	print "source				varchar(32),"
	print "primary key ( id ),"
	print "key ( AP_id )"
	print ");"

}

END {
	print "commit;"

	# Now perform various loads to prepare the data for inclusion in the master data set

	# Fix up referential ids
	print "start transaction;"
	print "update " obsItemsTableName " oi, " obsTableName " o set oi.observationId = o.id where oi.AP_id = o.AP_id;"
	print "commit;"
	print "start transaction;"
	print "update " obsTableName " o, " sesTableName " s set o.sessionId = s.id where o.observationTimeU >= s.startTimeU and o.observationTimeU <= s.endTimeU;"
	print "commit;"

	# Set the telescopes
	print "start transaction;"
	print "update " obsItemsTableName " oi, Telescopes t set oi.telescope = t.telescopeId where t.name like concat( '%', oi.AP_telescope, '%' );"
	print "update " obsItemsTableName " oi, Telescopes t set oi.telescope = t.telescopeId where oi.AP_telescope like '%Finder%' and t.nickname = 'Finder';"
	print "commit;"

	# Set the eyepieces
	print "start transaction;"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Zhumell%9%' and e.nickname like '%Zhumell%9%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Zhumell%32%' and e.nickname like '%Zhumell%32%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%TMB%5%' and e.nickname like '%TMB%5%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%TMB%7%' and e.nickname like '%TMB%7%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%QX%26%' and e.nickname like '%QX%26%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%QX%15%' and e.nickname like '%QX%15%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Kellner%' and e.nickname like '%Kellner%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Orion%' and e.name like '%Orion%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Plossl%12%' and e.nickname like '%Plossl%12%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece like '%Plossl%25%' and e.nickname like '%Plossl%25%';"
	print "update " obsItemsTableName " oi, Eyepieces e set oi.eyepiece = e.eyepieceId where oi.AP_eyepiece is null and oi.AP_telescope like '%Finder%' and e.nickname like '%Finder%';"
	print "commit;"

	# Set the barlow
	print "start transaction;"
	print "update " obsItemsTableName " oi, Barlows b set oi.barlow = b.barlowId where oi.AP_barlow like '%2x%Barlow%' and b.nickname like '%Barlow%2\"%';"
	print "update " obsItemsTableName " oi, Barlows b set oi.barlow = \\N where oi.AP_barlow like '%None%';"
	print "update " obsItemsTableName " oi, Barlows b set oi.barlow = \\N where oi.AP_barlow is null;"
	print "commit;"

	# Set the filter
	print "start transaction;"
	print "update " obsItemsTableName " oi, Filters f set oi.filter = f.filterId where oi.AP_filter like concat( '%', f.name, '%' ) and oi.AP_filter rlike '[0-9][0-9].*';"
	print "update " obsItemsTableName " oi, Filters f set oi.filter = f.filterId where oi.AP_filter like '%Yelllow%' and f.name like '15%';"
	print "update " obsItemsTableName " oi, Filters f set oi.filter = f.filterId where oi.AP_filter like '%OIII%' and f.name like '%OIII%';"
	print "update " obsItemsTableName " oi, Filters f, Telescopes t set oi.filter = f.filterId where oi.AP_filter like '%Solar%' and oi.telescope = t.telescopeId and t.nickname like '%Pal%' and f.name like '%Pal%Solar%';"
	print "update " obsItemsTableName " oi, Filters f, Eyepieces e set oi.filter = f.filterId where oi.AP_filter like '%Ultra%' and oi.eyepiece = e.eyepieceId and e.barrelSize = 1.25 and f.filterSize = 1.25;"
	print "update " obsItemsTableName " oi, Filters f, Eyepieces e set oi.filter = f.filterId where oi.AP_filter like '%Ultra%' and oi.eyepiece = e.eyepieceId and e.barrelSize = 2 and f.filterSize = 2;"
	print "update " obsItemsTableName " oi, Filters f set oi.filter = \\N where oi.AP_filter like '%None%';"
	print "update " obsItemsTableName " oi, Filters f set oi.filter = \\N where oi.AP_filter is null;"
	print "commit;"

}


{
	line++ # The current line number
	# Parse the line.
	fields = parse_csv( $0, csv, ",", "'", "'", "\r" )
	# Check for errors.
	if ( fields < 0 ) {
        print "ERROR: " csverr " at line # "line | "cat 1>&2"
        next
    }

	# If we have an observation without an objectId, just skip it (somehow these got into the AP database)
	if ( csv[13] == "" || csv[13] == "\\N" ) {
		next
	}

	# Grab the components that make the observation record.

	apId = quote( csv[0] )
	observationTime = adjustTimeStampEpoch( csv[1] )
	observationTimeJ = computeJulianDate( observationTime )
	objectId = quote( fixObjectId( csv[13] ) )
	objectName = quote( escapeQuotes( csv[15] ) )
	notes = quote( escapeQuotes( csv[9] ) )

	print "insert into ", obsTableName,
		" ( AP_id, observationTime, observationTimeU, observationTimeJ, AP_objectId, objectName, notes, source ) values ( ",
		apId, ","
	printf "%s%13.5f%s", "julianDateToDateTime(", observationTimeJ, "),"
	print observationTime, ","
	printf "%13.5f%s", observationTimeJ, ","
	print objectId, ",", objectName, ",", notes, ",", source, " );"

	# Parse the various telescope and eyepiece combos
	# Items to parse are
	#
	# $3 = Rating (varchar) TABBED,
	# $4 = Telescope (varchar) TABBED,
	# $5 = Eyepiece (varchar) TABBED,
	# $6 = Imager (text) TABBED,
	# $7 = Filter (varchar) TABBED,
	# $8 = Aid (varchar) TABBED,
	# $9 = Observed (varchar) TABBED,
	#
	# But I don't use "Imager" ($6)

	split( csv[2], ratings, "\t" )
	split( csv[3], telescopes, "\t" )
	split( csv[4], eyepieces, "\t" )
	split( csv[6], filters, "\t" )
	split( csv[7], barlows, "\t" )
	nbr = split( csv[8], found, "\t" )
	for ( i = 1; i <= nbr; ++i ) {
		tel = quote( telescopes[i] )
		ep = quote( eyepieces[i] )
		bar = quote( barlows[i] )
		fil = quote( filters[i] )
		fnd = blankToNull( found[i] )
		rat = blankToNull( ratings[i] )
		print "insert into ", obsItemsTableName,
			" ( AP_id, AP_telescope, AP_eyepiece, AP_barlow, AP_filter, found, rating, source ) values ( ",
		apId, ",", tel, ",", ep, ",", bar, ",", fil, ",", fnd, ",", rat, ",", source, " );"
	}

}

