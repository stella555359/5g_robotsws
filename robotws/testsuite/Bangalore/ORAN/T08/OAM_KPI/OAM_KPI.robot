*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Test Suite for OAM KPI


Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.nms.netact    WITH NAME    NMS
Library     OperatingSystem     WITH NAME    os
Resource    ./OAM_KPI_keywords.robot

Test Setup  	Test Setup
Test Teardown   Test Teardown

*** Test Cases ***

TC_01_CB013257_Verification_of_Reset_KPI52_of_Cloud_gNB_vDU_ORU_configuration_using_WebEM
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
    ${out}    set variable    ${OUTPUT_DIR}/KPI52
    set test variable    ${out}
    os.create directory     ${out}
    Verification of Reset KPI#52

TC_02_CB013257_Verification_of_ORU_reset_KPI51a_with_Cloud_vDU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    ${out}    set variable    ${OUTPUT_DIR}/KPI51a
    set test variable    ${out}
    os.create directory     ${out}
    Verification of O-RU reset KPI#51a

TC_03_CB013257_Verification_of_KPI17a_17b_Manual_cell_block_unblock_duration_for_vDU
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${out}    set variable    ${OUTPUT_DIR}/KPI17ab
    set test variable    ${out}
    os.create directory     ${out}
    Verification of Cell block/unblock KPI#17a
