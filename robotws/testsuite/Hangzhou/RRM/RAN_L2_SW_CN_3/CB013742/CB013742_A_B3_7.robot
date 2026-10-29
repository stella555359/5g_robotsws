*** Settings ***
Documentation
...
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_chen    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_BOO_AP_LOO

Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../resources/KISS/robot/common_resource.robot
Resource          ../resources/sg10/internal_resource/internal_resource.robot
Library           taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}        CB013742-A_B3_7.xml
${AIRPHONE_NAME}    IPHY_CB013742-A_B3_7.xml
${WTS_NAME}         wts_CB013742-A_B3_7.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${UE_ID}    101
@{Rdparameter1}    0x5809B8:1
@{Rdparameter2}    0x58057a:4
@{Rdparameter3}    0x580580:0x800000

*** Test Cases ***
CB013742-A_B3_7_NSA _TDD_PRB_randomization_during_Dynamic_Transform_Precoder_Switching
     Modify Swconfig for GNB
     Prepare gnb onair
     Start capture gnb and ap syslog in 'after_onair' file
     Attach LTE UE'${UE_ID}'
     Send DL data to UE'${UE_ID}'
     Enter to TP due to low SINR and check tti for DCI format
     Log To Console   scell delete


*** Keywords ***
Modify Swconfig for GNB
     Add GNB swconfig    @{Rdparameter1}
     Add GNB swconfig    @{Rdparameter2}
     Add GNB swconfig    @{Rdparameter3}

Attach LTE UE'${UE_ID}'
 	 Log To Console    ${\n}Attach NSA UE
     Airphone Nsa Attach     ${UE_ID}
     Wait '3s' for stabible

Send DL data to UE'${UE_ID}'
     NSA send ue '${UE_ID}' mutiple trf '16' for each '10M' UL data
          Wait '10s' for stabible

Enter to TP due to low SINR and check tti for DCI format
    Start collect ttitrace
    Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=11 pathloss\=135
    airphone_execute_egate_command    ue_testmode_set_nr id\=101 testmode\=ul_sinr profile_id\=11 scell\=8 action\=activate
    Wait for '15s' to stop ttitrace with name'tti'
    Log To Console   ${\n}---check tti---
 	Set test Variable    ${tti_title_tag}		tti_ul.csv
 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_dci_format.ini   i
     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
    airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=ul_sinr profile_id\=11 scell\=8 action\=deactivate

