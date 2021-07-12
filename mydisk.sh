#!/bin/sh

min=10
width=60

if echo $2 | egrep -q '^[1-9][0-9]*$';then
	min=$2
elif echo $1 | egrep -q '^[1-9][0-9]*$';then
	min=$1
fi

tmp="/tmp/mydisk`echo $PWD | sed 's/\//-/g'`"
if test ! -f "$tmp" -o "$1" = "-f" -o "$2" = "-f";then
	echo Scanning directories...
	du -bax "." > "$tmp"
fi

total=`tail -n1 "$tmp" | cut -f1`

cat "$tmp" | awk -F'	' '
	BEGIN {	
		ORS = ""; 
		bold = "\033[1m";
		nc = "\033[0m";
		for(c=31; c<39; c++)
			color[c-30] = "\033[0;"c"m";
	}
	{
		if ((p = $1*100/'$total') > '$min')
		{
			p =int(p);

			padding = $2;
			gsub(/[^\/]/,"", padding);
			c = 1 + gsub(/\//,"    ", padding);

			w = int(p*'$width'/100);
			i = 0;
			visual = "";
			while(i < w)
			{
				visual = visual "#";
				i++;
			}

			while(i < '$width')
			{
				visual = visual ".";
				i++;
			}
			
			if ($2 == ".")
				file = "'$PWD'";
			else
				file = $2;

			print padding color[c] "[" visual "]" nc "\n";
			print padding color[c] p "% " file " (" int($1*100/1024/1024)/100 "M) " nc  "\n"; 

#			lastfile = $2;
		}
	}
' | tac
