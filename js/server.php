<?php

$ProjectId = YourProjectID;
$APIKey = "Your API Key";
$APIURI = "https://sdn.3qsdn.com/api/v2/projects/{$ProjectId}/files";
$Location = "";

$ch = curl_init($APIURI);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, array(
    "X-AUTH-APIKEY: $APIKey",
    "Content-Type: application/json; charset=utf-8",
    "Accept: application/json; charset=utf-8"
));

// pass the json Body to SDN API
$inputJSON = file_get_contents('php://input');
curl_setopt($ch, CURLOPT_POSTFIELDS, $inputJSON);

// extract location header value
curl_setopt($ch, CURLOPT_HEADERFUNCTION,
    function($curl, $header) use (&$Location) {
        $len = strlen($header);
        $header = explode(':', $header, 2);

        // Location header value
        if (strtolower(trim($header[0])) == "location") $Location = trim($header[1]);

        return $len;
    }
);
$resultstr = curl_exec($ch);

// return upload location to js
echo $Location;