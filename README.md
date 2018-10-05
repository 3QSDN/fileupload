# 3Q SDN Fileupload Examples

## Upload via JavaScript
The Fileupload works in 2 Steps:

1. Get Upload Location from the API
    
    `POST https://sdn.3qsdn.com/api/v2/projects/[Project_Id]/files`
    
    with the Header `X-AUTH-APIKEY` for authentication and in the body `FileName` and `FileFormat` in JSON

2. Extract the Upload Location URI form the created File Entity from the `Location` Header of the `201` response

3. PUT the File Content to that location in a whole file or in chunks. Chunked uploads are resumable.

See the example `js_upload.html` for more details.

#### js_upload.html
Set projectId and apiKey to your values and enjoy!

## Upload via CURL

1. Get Upload Location from the API

    `POST https://sdn.3qsdn.com/api/v2/projects/[Project_Id]/files`

    with the Header `X-AUTH-APIKEY` for authentication and in the body `FileName` and `FileFormat` in JSON

2. Extract the Upload Location URI form the `Location` Header of the `201` response

3. PUT the File Content to that location.

See the example `bash_curl_upload.sh` for more details.

#### bash_curl_upload.sh

`./bash_curl_upload.sh {Your-API-KEY} {ProjectId} mp4 videofile.mp4`

