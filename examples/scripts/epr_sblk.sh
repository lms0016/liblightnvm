#!/usr/bin/env bash

function usage {
	echo "usage: ./sbl_ewr.sh LNVM_DEV CH_BGN CH_END LUN_BGN LUN_END BLK DRY"
	exit
}

LNVM_DEV=$1
CH_BEGIN=$2
CH_END=$3
LUN_BEGIN=$4
LUN_END=$5
BLK=$6
DRY=$7

if [ -z "$LNVM_DEV" ] || [ -z "$CH_BEGIN" ] || [ -z "$CH_END" ] || \
   [ -z "$LUN_BEGIN" ] || [ -z "$LUN_END" ] || [ -z "$BLK" ] || [ -z "$DRY" ]; then
	usage
fi

SZ=$((${#LNVM_DEV} -2))
NVME_DEV=`echo "$LNVM_DEV" | cut -c-$SZ`
NCHANNELS=`cat /sys/class/nvme/$NVME_DEV/$LNVM_DEV/lightnvm/num_channels`
NLUNS=`cat /sys/class/nvme/$NVME_DEV/$LNVM_DEV/lightnvm/num_luns`

echo "** $LNVM_DEV with nchannels($NCHANNELS) and nluns($NLUNS)"

echo "** E 'spanned' block"
if [ $DRY -ne "1" ]; then
	/usr/bin/time nvm_sblk erase $LNVM_DEV $CH_BEGIN $CH_END $LUN_BEGIN $LUN_END $BLK
	ERR=$?
	if [ $ERR -ne 0 ]; then
		echo "sblk operation error($ERR)"
		exit
	fi
fi

echo "** P 'spanned' blk($BLK) on $LNVM_DEV"
if [ $DRY -ne "1" ]; then
	/usr/bin/time nvm_sblk pad $LNVM_DEV $CH_BEGIN $CH_END $LUN_BEGIN $LUN_END $BLK
	ERR=$?
	if [ $ERR -ne 0 ]; then
		echo "sblk operation error($ERR)"
		exit
	fi
fi

echo "** R 'spanned' blk($BLK) on $LNVM_DEV"
if [ $DRY -ne "1" ]; then
	/usr/bin/time nvm_sblk read $LNVM_DEV $CH_BEGIN $CH_END $LUN_BEGIN $LUN_END $BLK
	ERR=$?
	if [ $ERR -ne 0 ]; then
		echo "sblk operation error($ERR)"
		exit
	fi
fi

