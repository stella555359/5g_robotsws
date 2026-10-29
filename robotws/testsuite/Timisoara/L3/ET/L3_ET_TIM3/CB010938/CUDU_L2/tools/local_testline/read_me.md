This article teach you how to do TA easily.
<h1> local testline maintain
<h2> download Auto5G code and taf lib

<h2> update gnb
you can run local_testline_for_KVM.sh
if your control pc doesn't install aria2c, install it first.
> sudo apt update; sudo apt install aria2c

get gnb package:
> aria2c -j 16 -x 16 -s 16 https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS22R1/SBTS22R1_ENB_0000_000351_000000_release_BTSSM_downloadable_A54.zip

> aria2c -j 16 -x 16 -s 16 https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_211015_000001_release_BTSSM_downloadable_A54.zip

login webem to install gnb package.

<h2> update airphone

download this file to /home/ute/
> https://wrgitlab.ext.net.nokia.com/5G/robotws5g/-/blob/master/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/update_ap.sh

execute cmd:
> sh update_ap.sh

<h2> update ttitrace

> sh update_ttitrace.sh
<h2> install wireshark

<h2> update mchsark
<h1> TA keyword document

ute document  
http://doc.ute.nsn-rdnet.net/

taf document  
https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/

L2 CN1 document  
http://10.131.148.5/robotws5g/index.html

L2 CN3 document  
http://10.131.148.10/index.html

robotframework offical document

regex debug website

<h1> Code Repository

TA code
https://wrgitlab.int.net.nokia.com/5G/robotws5g

TAF lib  
https://wrgitlab.int.net.nokia.com/TAF?page=1

testconfig lib
https://gerrit.ext.net.nokia.com/gerrit/#/c/MN/5G/TEST/testconfigs/+/3352294/


<h1> Useful website

QC system

Ute cloud

REP

> ute_reporting_portal send -ie -ro /home/ute/test_results/5GC002329//5GC002329_A/output.xml -p UTE -ca 5G_SW_CN_1 -v -l CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD' | '--sw_version SBTS22R1_ENB_0000_000490_000000 -tl 2_16_UTE5GCLASSICAL1674

NIDD

Conference

<h1> Different Logs  
<h2> ttitrace
if you can't parse it manually.
connect Papic, Milorad (Nokia - DE/Ulm) <milorad.papic@nokia.com>
if you can parse it manually, but TA failed,
connect Richter, Juergen (Nokia - DE/Ulm) <juergen.richter@nokia.com>

<h1> Smart way of working

<h1> Q&A

