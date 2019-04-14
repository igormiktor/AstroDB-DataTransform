#!/bin/sed -f
/OTHER *NAMES/d
s/\r//
s/"/\\"/g
s/''/\\"/g
s/'/\\'/g
s/  */ /g
s/ ;/;/g
s/ |/|/g
s/| /|/g
s/||/|\\N|/g
s/||/|\\N|/g
s/||/|\\N|/g
s/^|//
s/|$//
