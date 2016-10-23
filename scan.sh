#!/bin/bash
# 2016 by phbaer
# Based on scan script by Konrad Voelkel: http://www.konradvoelkel.com/2013/03/scan-to-pdfa/
# Tested only with Canon ImageFormula P-208II so far

TARGET=/var/scan/
TMP=`mktemp -d`

if [ -z "$1" -a -z "$2" -a -z "$3" ]
then
	echo "usage: $0 filename.pdf title subject keywords"
	exit -2
fi

TITLE=$2
SUBJECT=$3
KEYWORDS=$4
JHOVE_PATH=/opt/jhove/bin
PDFA_VER=3

cd $TMP

echo "Scanning... ($1)"
scanimage --mode Gray --source "ADF Duplex" --format pnm --stapledetect=yes -b
EXITCODE=$?

if [ $EXITCODE != "0" ]
then
	echo "Unable to scan image! Exit code $EXITCODE."
	exit -1
fi

PDFS=
for F in `ls out*.pnm`
do
	BASENAME=`basename -s .pnm $F`
	TIF_FILENAME=$BASENAME.tif
	PDF_FILENAME=$BASENAME.pdf
	PDF_FILENAME_TMP=$BASENAME.tmp.pdf
	PDF_FILENAME_BACKUP=$PDF_FILENAME.backup
	PDF_FILENAME_BACKUP2=$PDF_FILENAME.backup2
	DUMPDATA=$PDF_FILENAME.dump
	PNG_FILENAME=$BASENAME.png
	JPG_FILENAME=$BASENAME.jpg
	HOCR_FILENAME=$BASENAME.hocr
	TESSERACT_LOG=$BASENAME.tesseract.log

	echo "Processing $BASENAME..."

	scantailor-cli --color-mode=black_and_white --despeckle=normal $F .
	rm -rf cache $F &> /dev/null


	tesseract -l deu $TIF_FILENAME $BASENAME pdf &> $TESSERACT_LOG
	rm -f $TIF_FILENAME $PNG_FILENAME &> /dev/null

	if [ -n "`cat $TESSERACT_LOG | grep "Empty page!!"`" ]
	then
		rm -f $PDF_FILENAME $TESSERACT_LOG &> /dev/null
		echo "Empty page detected, skipping!"
		continue
	fi
	rm -f $TESSERACT_LOG &> /dev/null

	PDFS="$PDFS $PDF_FILENAME"
done

pdftk $PDFS cat output $1.tmp

METADATA_FILENAME=metadata.dump

cat <<EOF > $METADATA_FILENAME
InfoBegin
InfoKey: Author
InfoValue: $AUTHOR
InfoBegin
InfoKey: Title
InfoValue: $TITLE
InfoBegin
InfoKey: Keywords
InfoValue: $KEYWORDS
EOF

pdftk $1.tmp update_info_utf8 $METADATA_FILENAME output $1

rm -f $PDFS $METADATA_FILENAME &> /dev/null

echo "Validating $1..."
java -jar $JHOVE_PATH/JhoveApp.jar -m PDF-hul "$1" | egrep "Status|Message"

cp $1 $TARGET/
chown $USERID $TARGET/$1
