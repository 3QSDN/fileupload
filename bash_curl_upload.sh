#!/bin/bash

# usage
# ./bash_curl_upload.sh {Your-API-KEY} {ProjectId} mp4 videofile.mp4
#
# if you want to replace the source video of a file add the FileId
# ./bash_curl_upload.sh {Your-API-KEY} {ProjectId} mp4 videofile.mp4 {FileId}


# set -x
[ $# -lt 4 ] && { echo 'Error: not enough arguments'; exit 1; }

APIKEY="$1"
ProjectId="$2"
ContentType="$3"
UploadFile="$4"
FileSize=$(stat -c "%s" "$UploadFile")
HTTPMethode="POST"
APIURI="https://sdn-dev.3qsdn.com/api/v2/projects/$ProjectId/files"

if [ $# -eq 5 ]; then
    # if FileID given, add it to APIURI + replace
    APIURI="$APIURI/$5/replace"
    # if replace http methode must be PUT
    HTTPMethode="PUT"
fi

function uploadNextChunk {
    [ $# -lt 5 ] && { echo 'Error uploadNextChunk(): not enough arguments'; exit 1; }

    # function parameters
    URI="$1"
    ContentType="$2"
    UploadFile="$3"
    FileSize="$4"
    UploadedBytes="$5"

    # 25 MB max chunk size, compute current chunk size
    MaxChunkSize=`expr 25 \* 1024 \* 1024`
    RemainingChunkSize=`expr $FileSize - $UploadedBytes`
    if [ $MaxChunkSize -lt $RemainingChunkSize ]; then
        CurrentChunkSize=$MaxChunkSize
    else
        CurrentChunkSize=$RemainingChunkSize
    fi

    # Content-Range Header
    CurrentRangeEnd=`expr $UploadedBytes + $CurrentChunkSize - 1`;
    CurrentRange="$UploadedBytes-$CurrentRangeEnd";

    # upload current chunk
    retryCount=0
    returnCode=127
    while [ $returnCode -gt 0 ]; do
        curlResponse=$(curl -f -s -X PUT \
            -H "Accept: application/json" \
            -H "Content-type: $ContentType" \
            -H "Transfer-Encoding: chunked" \
            -H "Content-Range: bytes $CurrentRange/$FileSize" \
            --data-binary "@-" \
            "$URI" \
            < <(dd if=$UploadFile skip=$UploadedBytes count=$CurrentChunkSize iflag=skip_bytes,count_bytes 2>/dev/null) \
            2>/dev/null)

        returnCode=$?
        if [ $retryCount -gt 5 ]; then
            echo "Upload Error for file $UploadFile: max retry count reached with curl exit code $returnCode" >&2
            exit 1
        fi
        if [ $returnCode -gt 0 ]; then
            retryCount=`expr $retryCount + 1`
            sleep 30
        fi
    done

    # check if upload completed
    UploadedBytes=`expr $UploadedBytes + $CurrentChunkSize`
    if [ $UploadedBytes -eq $FileSize ]; then
        echo -n "FileId of new File is "
        echo "$curlResponse" | cut -d ':' -f2 | tr -d '"}'
        return 0;
    fi

    # upload next chunk
    uploadNextChunk $URI $ContentType $UploadFile $FileSize $UploadedBytes
}

# get upload location from api
curlResponse=$(curl -isv -X "$HTTPMethode" \
    -H "X-AUTH-APIKEY:$APIKEY" \
    -H "Accept: application/json" \
    -H "Content-Type:application/json" \
    --data "{\"FileName\":\"$UploadFile\",\"FileFormat\":\"$ContentType\"}" \
    "$APIURI" 2>/dev/null)

# parse curlResponse for Location Header
UPLOADURI=$(echo "$curlResponse" | grep "[Ll]ocation: " | cut -d ' ' -f2 | tr -d '\n\r\t')
echo "Upload file to $UPLOADURI"

# upload first chunk
uploadNextChunk "$UPLOADURI" $ContentType $UploadFile $FileSize 0
