#!/bin/sh
# crawl the web to get a picture for each name on a list

set -e

# google server to search from
server="www.google.com"

# 'nfpr=1' seems to perform exact string search - does not show most likely match results or suggested search.
search_match_type="&nfpr=1"

# 'tbm=isch' seems to search for images
search_type="&tbm=isch"

# 'tbs=itp:face' to search for faces
search_faces="&tbs=itp:face"

# 'hl=en' seems to be language
search_language="&hl=fr"

# 'site=imghp' seems to be result layout style
search_style="&site=imghp"

# page group to load = 0 (first page)
search_group="&ijn=0"

# pointer starts at result = 0 (first result)
search_start="&start=0"

# http://whatsmyuseragent.com
useragent='Mozilla/5.0 (X11; Linux x86_64; rv:46.0) Gecko/20100101 Firefox/46.0'

timeout=15
retries=1

if [ $# -lt 1 -o "$1" = '-h' -o "$1" = '--help' ]
then
	cat <<ENDCAT

Crawl the web to get a picture for each name on a list.

Usage: `basename "$0"` NAMES_FILE [DOWNLOAD_DIR] [SITE]

Arguments :
    NAMES_FILE      The path to a file containing names (one on each line, no special chars, no quote)
    DOWNLOAD_DIR    (Optional) The path to a directory (if it doesn't exist it will be created, default is the current directory)
    SITE            (Optional) Download pictures only from this site (example: linkedin.com), but always through google

ENDCAT
	exit 0
fi

names_file="$1"
if [ ! -f "$names_file" ]
then
	echo "Error: names file '$names_file' doesn't exist" >&2
	exit 1
fi

download_dir="$2"
if [ "$download_dir" = "" ]
then
	download_dir=`pwd`
fi
if [ ! -e "$download_dir" ]
then
	echo "Creating download dir '$download_dir'"
	mkdir -p "$download_dir"
fi

site=$3
if [ "$site" != "" ]
then
	force_site="+site:$site"
fi

tmp_file=`mktemp '/tmp/wget-output.tmp.XXXXXXXXXX'`

while read name
do
	# image file path
	file_path="$download_dir"/"`echo "$name"|sed 's/ /_/g'`".jpg
	if [ -e "$file_path" ]
	then
		echo "$name (skipped : existing)"
		continue
	else
		echo "$name"
	fi

	# 'q=' is the user supplied search query
	search_phrase="&q=\"$(echo $name | tr ' ' '+')\"${force_site}" # replace whitepace with '+' to suit curl/wget

	if wget -q --no-check-certificate --user-agent "$useragent" --output-document "$tmp_file" "https://${server}/search?${search_type}${search_faces}${search_match_type}${search_phrase}${search_language}${search_style}${search_group}${search_start}"
	then
		#picture_link=`cat "$tmp_file"| sed 's|<div|\n\n&|g'| grep '<div class=\"rg_meta\">.*http'| sed '/youtube/Id;/vimeo/Id;s|http|\n&|;s|","tw".*||'| sed -e '/^<div/d' -e 's|\\\\u003d|=|g'|head -n 1`
		picture_link=`cat "$tmp_file"| sed 's|<div|\n\n&|g'| grep '<div class=\"rg_meta\">.*http'| grep -o '"ou":"[^"]\+"' |sed -e 's/"ou":"\([^"]\+\)"/\1\n/g' -e 's|\\\\u003d|=|g'|head -n 1`
		if [ "$picture_link" = "" ]
		then
			echo "\tWarning: no download link available"
			continue
		fi
		if ! wget -q --no-check-certificate --max-redirect 0 --timeout=${timeout} --tries=${retries} --user-agent "$useragent" --output-document "$file_path" "$picture_link"
		then
			echo "Failed to download picture for '$name' ($picture_link)" >&2
			#rm -f "$tmp_file" "$file_path"
			rm -f "$file_path"
			exit 1
		fi
	else
		echo "Error: failed to download result page for '$name'" >&2
		rm -f "$tmp_file"
		exit 1
	fi

done < "$names_file"

rm -f "$tmp_file"
exit 0

