*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***
@{counter_ru}    M55318C00002    M55318C00004
@{counter_ru_ex}    M55318C00006    M55318C00008    M55318C00010    M55318C00012
@{counter_rau}   M55318C00001    M55318C00003    M55318C00005    M55318C00007    M55318C00009

*** Keywords ***
5GC000399_eCPRI_U-plane_Fast_C-plane_counters
    [Setup]    Test Setup
    Modify parameter online    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1    parameter=miNrEcpriUpFCp    value=5min
    sleep    6min
	Check Counter normal
    Check Counter abnormal
    Modify parameter online    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1    parameter=miNrEcpriUpFCp    value=15min
	sleep    16min
	Check Counter normal
    Check Counter abnormal
    [Teardown]   Test Teardown
