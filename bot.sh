#!/bin/bash

# usage: ./run.sh tag_name

URL="https://rule34.xxx/index.php?page=post&s=list&tags="
IMG_URL="https://rule34.xxx/index.php?page=post&s=view&id="
PID="24"
INPUT="$1"
INDEX=""
FOUND=0
STOP=0

DPATH="downloads/$INPUT"

download_image()
{
	echo donwloading "${DATA[$COUNTER+1]}"
	IMG_INDEX="$1"

	if [ ! -f "$DPATH/temp/$IMG_INDEX.htm" ]
	then
		curl "$IMG_URL$IMG_INDEX" -s -o "$DPATH/temp/$IMG_INDEX.htm"
	fi

	IMAGE_URL=`cat "$DPATH/temp/$IMG_INDEX.htm" | grep '"og:image"'`
	IMAGE_URL=${IMAGE_URL/'<meta property="og:image" itemprop="image" content="'/' '}
	IMAGE_URL=${IMAGE_URL/'" />'/' '}
	IMAGE_URL=( $IMAGE_URL )
	IMAGE_URL=${IMAGE_URL[0]}

	IMAGE_URL2=${IMAGE_URL//'/'/' '}
	IMAGE_URL2=( $IMAGE_URL2 )

#	wget -q $IMAGE_URL -O "$DPATH/images/${IMAGE_URL2[4]}" --timeout=60 --tries=10
	axel -q "$IMAGE_URL" -o "$DPATH/images/${IMAGE_URL2[4]}"

}

while true
do
	mkdir -p "$DPATH"
	mkdir -p "$DPATH/images"
	mkdir -p "$DPATH/temp"

	while [ $STOP != 1 ]
	do
		FOUND=0

		curl "https://rule34.xxx/index.php?page=post&s=list&tags=$INPUT&pid=$PID" -s -o "$DPATH/index.htm"

		DATA=`cat "$DPATH/index.htm" | grep 'class="thumb"><a' `

		DATA=${DATA//'<span id="'/'main_image_index '}
		DATA=${DATA//'"'/' '}
		DATA=${DATA//'s'/' '}

		DATA=( $DATA )

		COUNTER=0

		while [ "x${DATA[$COUNTER]}" != "x" ]
		do
			if [ "${DATA[$COUNTER]}" == "main_image_index" ]
			then
				IMAGE_INDEX="$IMAGE_INDEX ${DATA[$COUNTER+1]}"

				download_image "${DATA[$COUNTER+1]}"   &

				FOUND=$(($FOUND+1))
			fi

			COUNTER=$(($COUNTER+1))
		done

		if [ $FOUND == 0 ]
		then
			echo "End of searching."
			STOP=1
			exit
		else
			echo -e "Found $FOUND pictures in index $PID"
		fi

		PID=$(($PID+24))

	done
done









