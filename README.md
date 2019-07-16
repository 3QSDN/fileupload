# 3Q SDN Fileupload Examples

## Upload via JavaScript
The Fileupload works in 2 Steps:

1. Get Upload Location from the API
    
    `POST https://sdn.3qsdn.com/api/v2/projects/[Project_Id]/files`
    
    with the Header `X-AUTH-APIKEY` for authentication and in the body `FileName` and `FileFormat` in JSON

2. Extract the Upload Location URI form the `Location` Header of the `201` response

3. PUT the File Content to that location in a whole file or in chunks. Chunked uploads are resumable.

4. When the upload is finished the FileId will be returned as JSON in a 201 response.

See the example `js_upload.html` for more details.

##### js_upload.html
Set projectId and apiKey to your values and enjoy!

## Upload via CURL

1. Get Upload Location from the API

    `POST https://sdn.3qsdn.com/api/v2/projects/[Project_Id]/files`

    with the Header `X-AUTH-APIKEY` for authentication and in the body `FileName` and `FileFormat` in JSON

2. Extract the Upload Location URI form the `Location` Header of the `201` response

3. PUT the File Content to that location.

4. When the upload is finished the FileId will be returned as JSON in a 201 response.

See the example `bash_curl_upload.sh` for more details.

##### bash_curl_upload.sh

    ./bash_curl_upload.sh {Your-API-KEY} {ProjectId} mp4 videofile.mp4

## Replace via CURL

It works like the Upload of a new Video, but you must

    PUT https://sdn.3qsdn.com/api/v2/projects/[Project_Id]/files/[File_Id]/replace
    
with the Header `X-AUTH-APIKEY` for authentication and in the body `FileName` and `FileFormat` in JSON

Then continue as in point 2 above

##### bash_curl_upload.sh

If you want to replace the source video of a file add the FileId

    ./bash_curl_upload.sh {Your-API-KEY} {ProjectId} mp4 videofile.mp4 {FileId}


