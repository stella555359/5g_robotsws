Usage:
Install Defensics Package
pip install taf.sw.security.defensics -i https://artifactory-espoo1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple/

Option 1: Start Defensics Scan with Build Download and Update
    sh start_scan.sh <build_release> <suite_ip> <suite>
    Example: sh start_scan.sh SBTS00_ENB_9999_221224_000005 10.53.123.12 ipv4

Option 2 : Start Defensics Scan and Get Report
    python defensics_suite.py <suite_ip> <suite>
    Example: python defensics_suite.py 10.53.123.12 ipv4