*** Settings ***
Documentation    :copyright: Nokia
...              :author: Mohan
...              :contact: mohanavel.p@nokia.com
...
...             INTRODUCTION:     The user scenario targets the DRX configuration in ICS for SA UE
...             TEST SET NAME:    CB013233
...             TESTING SPLIT:    Refer CB013233
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013233 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_26392

Test Setup      Test Setup
Test Teardown   Test Teardown
Resource    CB013233_keywords.robot
Resource    expected_alarms.robot

Force Tags      VRF_BLR1_T11    VRF_BLR1

*** Variables ***
${ABSTRACT_LIB_CONFIG}=  /home/ute/testline_configuration/1_2_CLOUD480/ta_ue_config.yaml
${pva_ip}    10.53.164.219
${VM_IP}    10.43.54.232
${VM_usn}    ute
${VM_pwd}    BT5l@bus3rl0g1n
${mplane_ip}    10.53.203.223
${MCG_IP}    10.53.164.139
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
${vonr_dist}    MRBTS-30315/NRBTS-30315/NRCELL-21
${vonr_name}    Activation of mobility thresholds for VoNr UEs
${vonr_abbr}    actVoNrMobilityThresholds
${dt_name_v}    test_voice_call
${TC_AP_ON}    test_UE_AP_on
${TC_AP_Off}    test_UE_AP_off
${tl_name}		1_2_CLOUD480


*** Test Cases ***
CB013233-A#B101_Early_DRX_setup_UE_SA_mode_during_ICS_with_PDU_FDD
    [Tags]    QC_111011    CRT    SBTS00
    [Setup]    Run Keywords    Test Setup
    ${out}    set variable   ${OUTPUT_DIR}
    set test variable    ${out}
    create directory     ${out}
    #Start UE proxy in UE PC
    Prepare UE
    Start UE detach attach and start throughput
    Stop Data Transfer
    #Stop UE proxy in UE PC
    Verify DRXcycle in F1AP_UEContextSetupRequest   ${out}/${SUITE NAME}/${TEST NAME}/tcpdump
    [Teardown]      Run Keywords    Test Teardown

