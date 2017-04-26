#!/bin/bash
usage="$(basename "$0") [-h] [-c] [-i] -- program to 

where:
    -h  host of KIE Server
    -c  KIE Container
    -i  help"

while getopts ih:c: option
do
        case "${option}"
        in
                i) echo "$usage"
                   exit;;
                h) HOST=${OPTARG};;
                c) CONTAINER=${OPTARG};;
        esac
done

echo "Host: $HOST"
echo "Container: $CONTAINER"


read -p "Create the container, press enter to continue"

#Create the KIE Container - snapshot
createContainer=$(curl -X PUT -H 'Content-type: application/xml' -u 'kieuser:password1' --data @snapshot.xml --insecure "https://$HOST/services/rest/server/containers/$CONTAINER")
echo ${createContainer} | xmllint --format -

read -p "Run the process, press enter to continue"

runProcess=$(curl -X POST -H 'Content-type: application/json' -H 'X-KIE-ContentType: JSON' -u 'kieuser:password1' --data @startProcess.json "https://$HOST/services/rest/server/containers/$CONTAINER/processes/hello/instances")
echo ${runProcess}

read -p "Start the scanner, press enter to continue"

startScanner=$(curl -X POST -H 'Content-type: application/xml' -u 'kieuser:password1' --data @startScanner.xml "https://$HOST/services/rest/server/containers/$CONTAINER/scanner")
echo ${startScanner} | xmllint --format -

read -p "Run the process in a loop, press enter to continue"

while true; do sleep 1; curl -X POST -H 'Content-type: application/json' -H 'X-KIE-ContentType: JSON' -u 'kieuser:password1' --data @startProcess.json "https://$HOST/services/rest/server/containers/$CONTAINER/processes/hello/instances"; done
