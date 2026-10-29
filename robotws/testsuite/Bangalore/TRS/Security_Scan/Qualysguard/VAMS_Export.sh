OUTPUT=`curl --insecure -X POST -v https://vams3.americas.nsn-net.net/api/cicd/automatedscans -H 'Authorization: Token 0728631aaa31f0404146543f04026eba72e80bb4' -H 'Content-Type:multipart/form-data' -F "uploaded_file=@report.xml" -F "release=001_Test || 001-Test R1" -F'software={"name":"CICD Test SubRel", "swtype":"subRelease"}' -F "synchronous_mode=true" -F "preview_mode=false" -F "delat_mode=true"`
echo OUTPUT
echo $OUTPUT > output.json
