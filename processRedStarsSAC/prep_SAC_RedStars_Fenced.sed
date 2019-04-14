#!/bin/sed -f
/OTHER *NAMES/d
s/\r//
s/"/\\"/g
s/''/\\"/g
s/'/\\'/g
s/BD\([-+]\)/BD \1/g
s/  */ /g
s/V \([0-9][0-9]*\)/V\1/g
s/PA\([0-9]\)/PA \1/g
s/ ;/;/g
s/ |/|/g
s/| /|/g
s/||/|\\N|/g
s/||/|\\N|/g
s/||/|\\N|/g
s/^|//
s/|$//
