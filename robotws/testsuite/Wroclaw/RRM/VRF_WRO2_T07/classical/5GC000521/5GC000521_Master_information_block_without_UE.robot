*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...
...   The purpose of this testcases is to check Master Information Block using collected logs.

Force Tags    PY36

Library     resources/verify.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2    WITH NAME    L1L2
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils

Suite Setup       prepare_testline

Test Teardown     Run Keywords
...               stop_and_collect_btslog                                       AND
...               L1L2.teardown_gnbmirroring                                    AND
...               Run keyword if test failed    AdminUtils.collect_snapshot


*** Test Cases ***
[1][2.0] 5GC000521_F_Master_Information_Block_without_UE
    [Documentation]  This test case testing procedure for encoding and sending MIB without UE in gNB-DU
    ...              after cell setup procedure successful. Verifies that cellBarred and intraFreqReselection
    ...              fields have same value as in NIDD.
    [Setup]   Run keywords
    ...       start_btslog_on_local_machine
    L1L2.start_gnbmirroring   filename=MIB
    BuiltIn.Sleep  5s   reason=Collecting L1L2 logs
    ${l1l2_pcap}=   L1L2.stop_gnbmirroring_and_download_logs
    Verify mib information   ${l1l2_pcap}
