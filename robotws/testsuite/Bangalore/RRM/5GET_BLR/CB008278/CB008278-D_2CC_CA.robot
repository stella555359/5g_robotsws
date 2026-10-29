*** Settings ***
Resource    ./resources/CB008278_resource.robot
Resource    ./resources/common_setup_teardown.robot
Resource         ../resources/robot/configuration_id.robot


Suite Setup    Common Suite Setup
Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    RAN_5G    RAN_5G_TDD   CRT

Documentation
...
...             author:            Mohan
...             maintainer:        mohanavel.p@nokia.com
...             INTRODUCTION:     CB008278-D#TC2_Single UE with DL and UL CA TDD FR1 10MHz as PCell and FDD as Scell
...             TESTING SPLIT:    Refer CB008278 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008278 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18760

*** Variables ***
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${SCF_PATH}    ${CURDIR}/config
${ROOT_TYPE}    hard_reboot


*** Test Cases ***

CB008278-D#TC2_Single UE with DL and UL CA TDD FR1 10MHz as PCell and FDD as Scell
    [Documentation]
    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
    ...    2.set sCellActivationMethod parameter = 0 (blind)
    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring
    ...    to the FDD cell and containing parameter sCellAdditionMethod is set to blind
    Start Gnb Cell Setup Log
    CB008278_resource.Start WTS And Check OnAir
    Stop Gnb Cell Setup Log   ${SUITE_LOG_DIRECTORY}
    Start Gnb BIP Log
    ${pcell_dl_tp}   ${scell_dl_tp}   ${pcell_ul_tp}   ${scell_ul_tp}   Attach Single SA CA UE and Get Throughput
    ...     UE_ID=1   dl_tp_set=170   ul_tp_set=50
    Should Be True   ${pcell_dl_tp}>0 and ${scell_dl_tp}>0
    Should Be True   ${pcell_ul_tp}>0 and ${scell_ul_tp}>0
    [Teardown]    Run Keywords   Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
    ...         AND   Link SCOUT SCF to Configuration ID for Reporting

