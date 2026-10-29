*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Test Suite for CB008048, CB008967, CB01797


Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.btslog  WITH NAME   btslog
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library     taf.nms.netact    WITH NAME    NMS
Library     OperatingSystem     WITH NAME    os
Resource    ./resources/CB008048_keywords.robot

Test Setup  	Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
TC_01_CB008048-E_ORU Software upgrade from MANTARAY & ORU troubleshooting log collection
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC01
    ${out}    set variable    ${OUTPUT_DIR}/ORU_sw_upgrade_mantaray
    set test variable    ${out}
    os.create directory     ${out}
    ORU Software upgrade from MANTARAY

TC_04_CB008048-B_ Verification of change or replace SSDORU parameters change under same authentication method from WebEM
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC04
    ${out}    set variable    ${OUTPUT_DIR}/SSD_provisioning_via_webem
    set test variable    ${out}
    os.create directory     ${out}
    Verification of change or replace SSDORU parameters change from WebEM

TC_05_CB008048-D_Verification of RU reception window Measurement counters WEBEM & MantaRay
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC05
    ${out}    set variable    ${OUTPUT_DIR}/counter_verification
    set test variable    ${out}
    os.create directory     ${out}
    Verification of RU reception window Measurement counters WEBEM & MantaRay

TC_06_CB008967-F-CR_Verification of kpialarmtrigger for RMOD Temperature counters_O-RU Counters_O_RAN_RADIO_TEMPERATURE
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC06
    ${out}    set variable    ${OUTPUT_DIR}/CB008967F
    set test variable    ${out}
    os.create directory     ${out}
    CB008967-F-CR_Verification of kpialarmtrigger for RMOD Temperature counters_O-RU Counters_O_RAN_RADIO_TEMPERATURE

TC_07_CB010797-D_RF-Diagnostic_CLI
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC07
    ${out}    set variable    ${OUTPUT_DIR}/RF-Diagnostic_CLI
    set test variable    ${out}
    os.create directory     ${out}
    CB010797-D_RF-Diagnostic_CLI

TC_08_CB010797-E_Antenna Line Online Monitoring
    [Tags]    CRT    QCP_RAN_VRF    TC08
    ${out}=    Set Variable    ${OUTPUT_DIR}/Antenna_Line_Online_Monitoring
    Set Test Variable    ${out}
    os.create directory    ${out}
    CB010797-E_Antenna Line Online Monitoring

TC_02_CB008048-B_Verification TCP DL UL data transfer after multiple ORU & vDU resets via WEBEM
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC02
    ${out}    set variable    ${OUTPUT_DIR}/multiple_resets
    set test variable    ${out}
    os.create directory     ${out}
    Multiple ORU/vDU resets via WEBEM along with L3 call

TC_03_CB008048-G_Verification of Mantaray import SSD RAML file when authenticationMethod sshserver = Public key based
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC03
    ${out}    set variable    ${OUTPUT_DIR}/mantaray_import_SSD_RAML_file
    set test variable    ${out}
    os.create directory     ${out}
    Verification of Mantaray import SSD RAML file

TC_09_CB007518-CR Test Predefine RU Configuration after Radio power on-off for predefined radios
    [Tags]    CRT    QCD_MN_RAN    QCP_RAN_VRF    TC09
    ${out}    set variable    ${OUTPUT_DIR}/CB007518
    set test variable    ${out}
    os.create directory     ${out}
    Test Predefine RU Configuration
