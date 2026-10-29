*** Settings ***
Documentation    :copyright: Nokia
...              :author: Sruthi Jacob
...              :contact:sruthi.jacob@nokia.com
...
...             INTRODUCTION:
...             TEST SET NAME:    CB008925
...             TESTING SPLIT:    CB008925-SR_AB2
...             CONTACTS:         Sruthi Jacob
...             REFERENCES:       CB008925 CFAM
...             Requirement ID:   RRM_LTE_SFS_RRM_URSC.6250

Test Setup      Setup Test
Test Teardown   Test Teardown
Resource    ../CB013233/CB013233_keywords.robot
Resource    ./CB008925_keywords.robot

*** Variables ***
#${pva_ip}    10.53.164.219
${VM_IP}    10.53.164.31
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${MCG_IP}    10.53.164.142
${MCG_usn}    ute
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${DURATION}    800s
@{UE_alias}=    UE1
@{capabilities}=    LEGACY_1
@{timeout}=    100
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    1000
@{direction_dl}=      dl
@{direction_ul}=    ul
@{CALL_type}    UDP
${tl_name}		1_2_CLOUD465


*** Test Cases ***
[1]CB008925-SR-A-B2_FDD_20Mhz_ABIO_CPRI_ST_Robustness_Single_Ue_Dedicated_downlink_power_level_for_a_standalone_NB_IoT_cell_in_Duplicated TM2
    ${out}    set variable   ${OUTPUT_DIR}
    set test variable    ${out}
    create directory     ${out}
    Prepare Test UE
#    Set Active Bands For Test Ue    2
    Start GNB TcpdumpLogs
    Attach Test UE
    Start DL Data Traffic
#    sleep  10s
#    Start UL Data Traffic    alias=Quectel_UE    dt_index=${1}
    Detach Test UE
    stop tcpdumplogs   tcpdump






