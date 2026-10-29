*** Settings ***
Resource    ./resources/CB008278_resource.robot
Resource    ./resources/common_setup_teardown.robot


Suite Setup    Common Suite Setup 4cc
Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2


Documentation
...
...             author:            Lavanya.TV
...             maintainer:        Lavanya.t_v@nokia.com
...
...             INTRODUCTION:     NSA data call on 10MHZ TDD with CB006878 enable CB008278-C Interworking with DL CA
...             TEST SET NAME:    USCB008278-C#IWK1 gNB configuration for the activation of 3T + 1F / 1F+3T DL CA with 10MHz TDD cell
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18762

#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS00    RAN_5G    RAN_5G_TDD CRT
*** Variables ***
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${SCF_PATH}    ${CURDIR}/config/4cc
${ROOT_TYPE}    hard_reboot

*** Test Cases ***

CB008278-C_TC1_gNB configuration for the activation of 1F+3T DL CA with 10MHz TDD cell along with DL data traffic
    [Documentation]
    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
    ...    2.set sCellActivationMethod parameter = 0 (blind)
    ...    3.CA relation between FR1-FDD and TDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
    ...    sCellAdditionMethod is set to blind

    Start Gnb Cell Setup Log
    CB008278_resource.Start WTS And Check OnAir 4cc
    sleep      30s
    Stop Gnb Cell Setup Log   ${SUITE_LOG_DIRECTORY}
    Start Gnb BIP Log
    ${pcell_tp}  ${scell1_tp}  ${scell2_tp}  ${scell3_tp}       Attach Single SA CA UE and Get Throughput 4cc
    ...     UE_ID=1   dl_tp_set=175
    Should Be True      ${pcell_tp}>=125
    Should Be True      ${scell1_tp}>=40
    Should Be True      ${scell2_tp}>=272
    Should Be True      ${scell3_tp}>=216
    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}


