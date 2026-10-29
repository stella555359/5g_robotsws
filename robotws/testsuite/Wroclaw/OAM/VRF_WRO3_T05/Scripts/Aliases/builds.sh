#!/bin/bash
printf "\nOpening browser with SW build available in UTE (younger than 7 days). If you need older build, check below server:\n
https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210118_000005_release_BTSSM_downloadable_A54.zip \n
Replace SW branch and build number in the link.\n
If you fail to find your build on above, mount Burak network drive and look there. Type 'burak' in the console\n"
sleep 5
(google-chrome http://files.ute.nsn-rdnet.net/builds/enb/base/ --ignore-certificate-errors &> /dev/null &)
(google-chrome https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/ --ignore-certificate-errors &> /dev/null &)