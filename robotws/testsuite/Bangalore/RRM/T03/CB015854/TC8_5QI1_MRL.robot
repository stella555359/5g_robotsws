*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Priya
...              :contact: Priya.Bakshi@nokia.com
...
...             INTRODUCTION:     This user scenario describes inter-gnb inter-plmn intra AMF Handover with MRL
...             TEST SET NAME:    CB015854-SR
...             TESTING SPLIT:    Refer CB015854 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB015854_CFAM
...             Requirement ID:    12980788


Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/configuration_id.robot
Resource         ${CURDIR}/resources/CB015854_keywords.robot

*** Variables ***
${delta_configuration_commission}        ${CURDIR}/scf/Delta_Configuration_scf_MRBTS-1_2_16_UTE5GCLASSICAL4016_20251222-1703.json
${delta_configuration_decommission}       ${CURDIR}/scf/Delta_Configuration_decommission.json
${wts_cfg_file_TC1}          ${CURDIR}/wts/wts_rjio_tc05.lua
${BSR_FILENAME}=    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001.zip



*** Test Cases ***
[1]CB015854-A#B01_TC8 Successful Intra-NR Inter-PLMN NG HO preparation for non-standard slice with 5QI-1 bearer and MRL provided

     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
	...        AND    Delta file commissioning for Handover
	...        AND    sleep    60s
	...        AND    Update bsr package
    ...        AND    sleep    60s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}



    Check SIB messagges for all cells_RJIO
	Configure MRL for UE1
    sleep    10s
	Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
	Start Tshark on eth3
	sleep    5s
	start VONR call on ue 5QI_1
	sleep    5s
	Run Keyword And Ignore Error  Link SCOUT SCF to Configuration ID for Reporting
	sleep     2s
    check NR stats
    sleep     2s

	Log to Console  \nUE1 should perform Ng Handover
	Send_EventA3_Measurement_Report  ue_id=1  meas_id=3  phycell_id=7
	sleep   5s
    verify 5QI-1 and successful HO in wireshark
    sleep   5s
	check NR stats
	sleep    5s
	Log to Console  \nUE1 perform Ng Handover as expected

	Log to Console  \nUE1 should perform reverse Ng Handover
	perform reverse handover
	sleep    5s
	check NR stats
	sleep     5s
    Stop Tshark on eth3
	Log to Console  \nUE1 perform reverse Ng Handover as expected

	[Teardown]   	Run keywords
	...       Log to console    " Reverting Testline"
	...       AND    detach_ue_with_power_off  ue_id=1
	...       AND    Delta file de-commissioning for Handover
	...       AND    sleep    60s
	...       AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
