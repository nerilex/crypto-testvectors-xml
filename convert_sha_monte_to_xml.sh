#!/bin/bash

#cat <(tr -d '\r \t' | egrep -o '^[^#]*' - | grep '=' | egrep -v '^[[:space:]]*$')
#exit

schemaName="hash-function_monte"

if [ -n "$2" ]; then
	schemaLocation="$(dirname $(sed 's#[^/]\+/#../#g' <<< "$2"))/xml/schema/${schemaName}.xsd"
	exec > $2
fi

if [ -z "$schemaLocation" ]; then
	schemaLocation="$(dirname $(sed 's#[^/]\+/#../#g' <<< "$1"))/xml/schema/${schemaName}.xsd"
fi

cat <<EOF
<?xml version="1.0"?>
<testFile
  xmlns="https://testvectors.cryptolib.org/xml-schema/v0.1/${schemaName}" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://testvectors.cryptolib.org/xml-schema/v0.1/${schemaName}
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

seed=""
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
			Seed)
				if [ -n "${seed}" ]; then
					printf "  </%s>\n" monteVector
				fi
				printf "  <%s>\n" monteVector
				seed=$VALUE
				printf "  <%s>\n" seed
				printf "    %s\n" ${VALUE}
				printf "  </%s>\n" seed
				;;
			COUNT)
				count=$VALUE
				;;
			MD)
				if [ $(( ${#VALUE} % 2)) -eq 1 ]; then
				digest=${VALUE}0
				else
					digest=$VALUE
				fi
					printf "  <%s count=\"%d\">\n" digest $count
					printf "    %s\n" $digest
					printf "  </%s>\n\n" digest
					true $((index++))
				;;
			*)
				;;
		esac
		fi
	fi
done <  <( tr -d '\r') 

cat <<EOF
  </monteVector>
</body>
</testFile>

EOF

