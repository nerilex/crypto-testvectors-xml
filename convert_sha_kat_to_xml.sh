#!/bin/bash

#cat <(tr -d '\r \t' | egrep -o '^[^#]*' - | grep '=' | egrep -v '^[[:space:]]*$')
#exit

if [ -n "$2" ]; then
	schemaName="hash-function_kat.xsd"
	schemaLocation="$(dirname $(sed 's#[^/]\+/#../#g' <<< "$2"))/xml/schema/$schemaName"
	exec > $2
fi

if [ -z "$schemaLocation" ]; then
	schemaName="hash-function_kat.xsd"
	schemaLocation="$(dirname $(sed 's#[^/]\+/#../#g' <<< "$1"))/xml/schema/$schemaName"
fi

cat <<EOF
<?xml version="1.0"?>
<testFile
  xmlns="https://testvectors.cryptolib.org/xml-schema/v0.1/hash-function_kat" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://testvectors.cryptolib.org/xml-schema/v0.1/hash-function_kat
                      ${schemaLocation}">
<header>
EOF

echo "  <convertDate>$(date '+%FT%T%:z')</convertDate>"

if [ -n "$1" ]; then
	orig_name="$1"
	orig_sha256=$(sha256sum "$1" | cut -f1 -d' ')
	orig_sha512=$(sha512sum "$1" | cut -f1 -d' ')
	
	exec < "$1"
	
	echo "  <originalFilename>""$(basename "$orig_name")""</originalFilename>"
	echo "  <originalSha256>${orig_sha256}</originalSha256>"
	echo "  <originalSha512>${orig_sha512}</originalSha512>"
fi


header_done=0

kat_type="katVector"

index=0

while read LINE; do
	if [ "$header_done" = "0" ]; then
		A=$(sed 's/^#[[:space:]]*\(.*\)$/\1/1' <<< "$LINE")
		if [ -n "$A" ]; then
			echo "  <comment>$A</comment>"
		else
			echo -e "</header>\n"
			header_done=1
			echo -e "<body>\n"
				fi
	else
		IFS='=' read KEY VALUE <  <(tr -d '\t ' <<< "$LINE")
		if [ -n "$VALUE" ]; then
#		echo "key: $KEY"
#		echo "value: $VALUE"
#		echo "c: $index"
		case $KEY in
			Len)
				len=$VALUE
				;;
			Msg)
				if [ $(( ${#VALUE} % 2)) -eq 1 ]; then
					msg=${VALUE}0
				else
					msg=$VALUE
				fi
				;;
			MD)
				if [ $(( ${#VALUE} % 2)) -eq 1 ]; then
				digest=${VALUE}0
				else
					digest=$VALUE
				fi
					printf "  <%s index=\"%d\">\n" $kat_type $index
					printf "    <%s bitLength=\"%d\" bitOrder=\"%s\" >\n      " message $len mostSignificantFirst
					sed -e 's/\([[:alnum:]]\{64\}\)/\1\n      /g' -e '/^[[:space:]]*$/ d' <<< "$msg"
					printf "    </%s>\n" message
					printf "    <%s>%s</%s>\n" digest $digest digest
					printf "  </%s>\n\n" $kat_type
					true $((index++))
				;;
			*)
				;;
		esac
		fi
	fi
done <  <( tr -d '\r') 

cat <<EOF
</body>
</testFile>

EOF

