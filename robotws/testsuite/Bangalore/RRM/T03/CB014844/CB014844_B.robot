*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:
...             TEST SET NAME:    CB014844
...             TESTING SPLIT:    Refer CB014844
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB014844 CFAM
...             Requirement ID:   12742206,12730341,12705075,12742724,12742727,12730141,12707297,12705000,12774440,12705033

Test Setup      Test Setup
Test Teardown   Test Teardown
Resource    CB014844_keywords.robot

Force Tags      VRF_BLR1_T03    VRF_BLR1

*** Variables ***
${ABSTRACT_LIB_CONFIG}=  /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T03/CB014844/ta_ue_config.yaml
${VM_IP}    10.43.54.241
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${mplane_ip}    10.53.203.216
${MCG_IP}    10.53.164.141
${MCG_usn}    ute
${MCG_pwd}    BT5l@bus3rl0g1n
${MCG_domain}      NOKLAB
${DURATION}    800s
@{UE_alias}=    UE1
@{capabilities}=    Legacy_1
@{timeout}=    100
${dt_name_dl}=    iperf_dl_test_1
${dl_name}=    iperf_dl_test_1
@{deviation_dl}=    100
@{throughput_dl}=    1000
@{direction_dl}=      dl
@{direction_ul}=    ul
@{CALL_type}    UDP
${nrcel_source_cell}    MRBTS-30328/NRBTS-30328/NRCELL-21
${lncel_source_cell}    MRBTS-30328/LNBTS-30328/LNCEL-12
${vonr_name}    Activation of mobility thresholds for VoNr UEs
${vonr_abbr}    actVoNrMobilityThresholds
${dt_name_v}    test_voice_call
${TC_AP_ON}    test_UE_AP_on
${TC_AP_Off}    test_UE_AP_off
${tl_name}		10_2_CLOUD476


*** Test Cases ***
CB014844-B#B1 Successful QCIx redirection in CB014844 redirection mode
#    [Tags]    QC_244197    CRT    SBTS00
    [Setup]    Run Keywords    Test Setup
    ${out}    set variable   ${OUTPUT_DIR}
    set suite variable    ${out}
    create directory     ${out}
    set attenuator   ${pva_ports}   ${port_values1}
    Prepare UE
    Start UE detach attach and start throughput
    Stop Data Transfer
    Verify syslog for successful Handover
    Verify Redirect Counter Value
    [Teardown]      Run Keywords    Test Teardown

