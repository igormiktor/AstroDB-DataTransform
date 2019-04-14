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


function cleanUpSeeing( x ) {
	# Get rid of the roman numeral prefixes
	sub( /^I+\. +/, "", x )
	sub( /^IV\. +/, "", x )
	sub( /^V\. +/, "", x )
	return x
}


# Fields are:
# $1 = UniqueID (varchar),
# $2 = start time (double)
# $3 = finish time (double)
# $4 = notes (text)
# $5 = session name (text)
# $6 = site (text)
# $7 = observer (text)
# $8 = seeing (text)
# $9 = transparency (text)
# $10 = user (text),
# $11 = ended (boolean),
# $12 = displayUT (boolean),
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

	print "start transaction;"
	print "drop table if exists " sesTableName ";"
	print "create table " sesTableName
	print "("
	print "id					int not null auto_increment,"
	print "AP_id				varchar(32) not null,"
	print "startTime			datetime not null,"
	print "endTime				datetime not null,"
	print "startTimeU			bigint not null,"
	print "endTimeU				bigint not null,"
	print "startTimeJ			double not null,"
	print "endTimeJ				double not null,"
	print "name					text,"
	print "AP_site				text,"
	print "AP_observer			text,"
	print "AP_seeing			text,"
	print "AP_transparency		text,"
	print "site					int default null,"
	print "observer				int default null,"
	print "seeing				int default null,"
	print "transparency			int default null,"
	print "notes				text,"
	print "usertext				text,"
	print "source				varchar(32),"
	print "primary key ( id ),"
	print "key ( AP_id )"
	print ");"

}

END {
	print "commit;"

	# Now perform various loads to prepare the data for inclusion in the master data set

	# Load our seeing values
	print "start transaction;"
	print "update " sesTableName " ap, Seeing s set ap.seeing = s.seeingId where ap.AP_seeing = s.tag;"
	print "update " sesTableName " ap, Seeing s set ap.seeing = s.seeingId where ap.AP_seeing is null and s.tag like '%Unknown%';"
	print "commit;"

	# Load our transparency values
	print "start transaction;"
	print "update " sesTableName " ap, Transparency t set ap.transparency = t.transparencyId where ap.AP_transparency = t.tag;"
	print "update " sesTableName " ap, Transparency t set ap.transparency = t.transparencyId where ap.AP_transparency is null and t.tag like '%Unknown%';"
	print "commit;"

	# Load our sites
	print "start transaction;"
	print "update " sesTableName " ap, Sites s set ap.site = s.siteId where ap.AP_site like concat( '%', s.nickname ,'%' );"
	print "update " sesTableName " ap, Sites s set ap.site = s.siteId where ap.AP_site like '%Phyrst%' and s.nickname like '%Phyrst%';"
	print "update " sesTableName " ap, Sites s set ap.site = s.siteId where ap.AP_site is null and s.nickname like '%Home%';"
	print "commit;"

	# Load our observers
	print "start transaction;"
	print "update " sesTableName " ap, Observers o set ap.observer = o.observerId where ap.AP_observer like concat( '%', o.nickname ,'%' );"
	print "update " sesTableName " ap, Observers o set ap.observer = o.observerId where ap.AP_observer is null and o.nickname like '%Igor%';"
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

	# If we have a session without an AP_Id, just skip it
	if ( csv[0] == "" || csv[0] == "\\N" ) {
		next
	}

	# Grab the components that make the session record.

	apId = quote( csv[0] )
	startTime = adjustTimeStampEpoch( csv[1] )
	startTimeJ = computeJulianDate( startTime )
	endTime = adjustTimeStampEpoch( csv[2] )
	endTimeJ = computeJulianDate( endTime )
	notes = quote( escapeQuotes( csv[3] ) )
	name = quote( escapeQuotes( csv[4] ) )
	apSite = quote( escapeQuotes( csv[5] ) )
	apObserver = quote( escapeQuotes( csv[6] ) )
	apSeeing = quote( escapeQuotes( cleanUpSeeing( csv[7] ) ) )
	apTransparency = quote( escapeQuotes( csv[8] ) )
	userText = quote( escapeQuotes( csv[9] ) )

	print "insert into ", sesTableName,
		" ( AP_id, startTime, endTime, startTimeU, endTimeU, startTimeJ, endTimeJ, ",
		"name, AP_site, AP_observer, AP_seeing, AP_transparency, notes, usertext, source ) values ( ", apId, ","

	printf "%s%13.5f%s%13.5f%s", "julianDateToDateTime(", startTimeJ, "),julianDateToDateTime(", endTimeJ, "), "
	print startTime, ",", endTime, ","
	printf "%13.5f%s%13.5f%s", startTimeJ, ",", endTimeJ, ","
	print name, ",", apSite, ",", apObserver, ",", apSeeing, ",", apTransparency, ",", notes, ",", userText, ",", source, " );"

}

