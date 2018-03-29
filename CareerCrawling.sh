#!/bin/bash

			################Pulls from list of websites and assigns it to variable##############
for i in $(cat list.txt)
do
	echo $i

		################Following line can commented out to keep from spamming during testing################
	wget --spider ${i}/careers -a testing1 
	if grep -qE "${i}.*404" testing1
	then
		echo "404: careers not found"
	else	
		grep $i testing1 | grep -E "careers" | tail -n 1 
	fi
	
	wget --spider ${i}/jobs -a testing1
	if grep -qE "${i}.*404" testing1
	then
		echo "404: jobs not found"
	else
		grep $i testing1 | grep -E "jobs" | tail -n 1
	fi
	echo ""
done
