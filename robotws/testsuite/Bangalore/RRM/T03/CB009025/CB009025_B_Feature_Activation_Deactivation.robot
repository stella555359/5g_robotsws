*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Parveen
...              :contact: shaheena.parveen@nokia.com
...
...             INTRODUCTION:     This user scenario describes Intra-NR-PLMN NG HO with 5QI-65 without MRL
...             TEST SET NAME:    CB009025-SR
...             TESTING SPLIT:    Refer CB015854 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009025_CFAM
...             Requirement ID:   12980780


Resource        ../../../resources/robot/WTS_Runner_Keywords.robot
Resource        ../../../resources/robot/configuration_id.robot
Resource        ${CURDIR}/resources/CB009025_keywords.robot

*** Variables ***
${delta_configuration_commission}        ${CURDIR}/scf/Delta_Configuration_CB009025_B_activate.json
${delta_configuration_decommission}       ${CURDIR}/scf/Delta_Configuration_CB009025_B_deactivate.json
${wts_cfg_file_TC1}          ${CURDIR}/wts/wts_rjio.lua
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip


*** Test Cases ***
[1]CB009025_B_Feature_Activation_Deactivatiob
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    Delta file commissioning for Feature Activation
    ...        AND    sleep    60s
    ...        AND    Update bsr package
    ...        AND    sleep    60s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}
    ${hhmm}     Get Current Time As HHMM
    ${Log_Path}    Create Log Directory     CB009025${hhmm}
    set test variable      ${Log_Path}
    Check SIB messagges for all cells_RJIO
    sleep    10s
    start Data call on ue

	[Teardown]   	Run keywords
	...       Log to console    " Reverting Testline"
	...       AND    detach_ue_with_power_off  ue_id=1
	...       AND    Delta file de-commissioning for Feture Deactivation
	...       AND    sleep    60s
	...       AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
