#!/bin/bash

# usage
# ./upload.sh "https://global-file-upload.3qsdn.com/api/{key}" "video/mp4" /source_folder/source.mp4

# set -x
[ $# -lt 3 ] && { echo 'Error: not enough arguments'; exit 1; }

URI="$1"
ContentType="$2"
UploadFile="$3"
FileSize=$(stat -c "%s" "$UploadFile")

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
        curl -f -X PUT \
            -H "Accept: application/json" \
            -H "Content-type: $ContentType" \
            -H "Transfer-Encoding: chunked" \
            -H "Content-Range: bytes $CurrentRange/$FileSize" \
            --data-binary "@-" \
            "$URI" \
            < <(dd if=$UploadFile skip=$UploadedBytes count=$CurrentChunkSize iflag=skip_bytes,count_bytes 2>/dev/null) \
            1>> "$UploadFile.upload.log" 2>&1;

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
        return 0;
    fi

    # upload nect chunk
    uploadNextChunk $URI $ContentType $UploadFile $FileSize $UploadedBytes
}

# upload first chunk
uploadNextChunk $URI $ContentType $UploadFile $FileSize 0
