*** Settings ***
Documentation       Test suite for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SKIP_PARAM_RELATION_ERRORS}    ${False}    # Should relation errors be skipped (True, False)
${COMMISSIONING_TIMEOUT}    400    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
@{IGNORE_ALARMS}    {"faultId":"2403"}    {"faultId":"61524"}    {"faultId":"61652"}    {"faultId":"61649"}
...    {"faultId":"6286"}    # fault ids that should be ignored
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml

#Parameters to modify
@{MODIFICATION_STRINGS}    modify:CABLINK-4:secondEndpointDN=APEQM-1/RMOD-1
...                        modify:LCELNR-2/CHANNELGROUP-1/CHANNEL-5:antlDN=RMOD-5/ANTL-1
...                        modify:LCELNR-2/CHANNELGROUP-1/CHANNEL-6:antlDN=RMOD-5/ANTL-1
...                        modify:MPLANENW-1:mPlaneIpv4AddressDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...                        modify:TRSNW-0:cPlane:ipV4AddressDN1=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1


*** Keywords ***
CM__CB008660_011_Loading_SCF_containing_both_FDN_format_and_SDN_format_for_Classical
        [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   For CB008660 this case. Loading SCF containing both Fully Distinguished Name (FDN) format and Shortened Distinguished Name
    ...   (SDN) format
    ...  The main steps performed for the test are:
    ...  - Generate Target SCF based on Basic scf
    ...  - Perform SCF commission
    ...  - Check all state after site startup
    ...  Pass criteria: Target SCF commisson success. Site is OK with no any unexpected alarm
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.02.2023 - Commit to GIT

    Set Tags    CA-CM    OWNER-yuan.1.gao@nokia-sbell.com    MAINTAINER-yuan.1.gao@nokia-sbell.com     AUTHOR-yuan.1.gao@nokia-sbell.com
    ...    PHASE-CRT    SW-SBTS22R3    FEATURE-CB008660    GROUP_IN_CHARGE-SRAN_PROD_HZ1
    LOG    ${TEST_NAME} of ${SUITE_NAME} start.    console=${True}
    Step 1: Generate Target SCF
    Step 2: Perform Commssionning SCF Contain both FDN and SDN format
    Step 3: Check site state after site startup

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}    SetValidatePlanAgainstDetectedHW=${False}

Step ${index}: Generate Target SCF
    Log    Step ${index}: Generate Target SCF    console=True
    Log  Modifications: ${MODIFICATION_STRINGS}   console=TRUE
    scf.load_scf    file_path=${scf_path}
    scf.perform_scf_modification    modification_strings=${MODIFICATION_STRINGS}
    scf.save_scf    file_path=${Test Results Dir}/TestFiles/FDN_SDN.xml


Step ${index}: Perform Commssionning SCF Contain both FDN and SDN format
    Log    Step ${index}: Perform Commssionning SCF Contain both FDN and SDN format    console=True
    SBTS commissioning    ${Test Results Dir}/TestFiles/FDN_SDN.xml

Step ${index}: Check site state after site startup
    Log    Step ${index}: Check site state after site startup    console=True
    Wait Until Keyword Succeeds    30 min    60 sec    Check SBTS SMOD RMOD Cells Alarms


SBTS commissioning
    [Arguments]    ${SCF_PATH}
    [Timeout]    30 min
    Log    SBTS commissioning    console=True
    Admin Get bts_id and perform commissioning    ${SCF_PATH}    ${SKIP_PARAM_RELATION_ERRORS}    ${COMMISSIONING_TIMEOUT}
    Log    Commissioning done. Site will start reset    console=True

CaseTearDown
    Log    CaseTearDown    console=True
    SBTS commissioning    ${COMMISSIONING_PATH}
    Wait Until Keyword Succeeds    20 min    60 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS    collect_snapshot=never