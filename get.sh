#/bin/sh

if [ -z "$1" -a -z "$2" -a -z "$3" -a -z "$4" -a -z "$5" ]
then
	echo "usage: $0 <output directory> <filename> <title> <subject> <keywords>"
	exit -2
fi

CONTAINER=phbaer/scan
CONTAINER=e0b407b92bf1
OUTPUT_DIR=$1
FILENAME=$2
TITLE=$3
SUBJECT=$4
KEYWORDS=$5

USERID=`id -u`
VENDOR=1083 # CANON
DEVICE=165f # P-208II
BUS=`lsusb | grep $VENDOR:$DEVICE | awk '{print $2 "/" $4'}` | tr -d ':'
docker run --rm --device=/dev/bus/usb/$BUS -v $OUTPUT_DIR:/var/scan -e USERID=$USERID $CONTAINER /usr/local/bin/scan.sh "$FILENAME" "$TITLE" "$SUBJECT" "$KEYWORDS"

