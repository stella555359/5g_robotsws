#pip install ute-common-admin --upgrade
source /home/ute/test_repo/bin/activate; robot -L TRACE -v SNAPSHOT_FLAG:pass:False,fail:False -v SOS_REPORT_FLAG:pass:False,fail:False -v UTE_WIRESHARK_FLAG:False -d /home/ute "$1"
