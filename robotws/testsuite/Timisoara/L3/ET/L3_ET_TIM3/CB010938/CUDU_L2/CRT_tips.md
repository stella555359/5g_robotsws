# environment issue
## Environment issue:git clone testconfigs from gerrit failed.
Reason:1. testline can't connect to gerrit.ext.net.nokia.com,firewall is not open.
2.Network is unstable when test runs.
Action:If it always happens on this testline,raise jira to UTE due to reason 1.
If it happens sometimes,you can ommit due to network unstable.
## TA scripts issue:can't get cfg file info from testconfig for current testline type.
Reason:the content of config.yaml in testconfig is not suitable for your testline.
## SimMode is ready now
Reason: testline is broken,10.0.2.80 can't be connected
## WRN:can't connect to WFT,firewall not open
Reason: lterel.es-si-s3-z2.eecloud.nsn-net.net,443 port doesn't open firewall.
error cmd: wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_221109_000001_ADMIN_CLI.zip -P /tmp/
## WRN:VM ping GNB EIF failed!
## WRN:GNB EIF ping VM failed!
## WRN:VM ping AP EIF failed!
## WRN:AP EIF ping VW failed!
## WRN:Crash happened!!! Do report PR!!!
## WRN:cell is not configured.Check SCF para!
## WRN:L2lo Crash happened!!! Do report PR to L2 team!!!
## WRN:L2ps Crash happened!!! Do report PR to L2 team!!!
## WRN:L2hi Crash happened!!! Do report PR to L2 team!!!
## Check PDU Status
Check PDU Status
WRN:VM ping GNB EIF failed!,WRN:GNB EIF ping VM failed!,WRN:VM ping AP EIF failed!,WRN:AP EIF ping VW failed!
WRN:L2lo Crash happened!!!,WRN:L2ps Crash happened!!!,WRN:L2hi Crash happened!!!