*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: Vishwas H N
...              :contact: vishwas.h_n@nokia.com
...
...             INTRODUCTION:     This user scenario covers new fault indication after activation of the cell handling a
...             slice which is not supported by any connected AMF's
...             TEST SET NAME:    CB013880
...             TESTING SPLIT:    Refer CB013880 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013880 CFAM
...             Requirement ID:   12680563

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource          ./resources/CB013880_keyword_A_B1.robot
Library          ta5g_cell_operations
Library          taf.sw.syslog
Resource        ../../../resources/robot/configuration_id.robot

*** Variables ***
${delta_configuration_Lock_Slices}       ${CURDIR}/config/scf/Delta_Configuration_lock_Slices.json
${delta_configuration_Unlock_Slices}      ${CURDIR}/config/scf/Delta_Configuration_unlock_Slices.json
${delta_configuration_Update_Slices}       ${CURDIR}/config/scf/Delta_Configuration_update_Slices.json
${delta_configuration_Update_Slices_TC3}       ${CURDIR}/config/scf/Delta_Configuration_update_Slices_TC3.json
${decommission_A_B1_TC1}      ${CURDIR}/config/scf/decommission_A_B1_TC1.json
${decommission_A_B1_TC2}      ${CURDIR}/config/scf/decommission_A_B1_TC2.json
${wts_cfg_file_TC1}          ${CURDIR}/config/wts/basic_setup_A_B1.cfg
${delta_configuration_TC2_lock}    ${CURDIR}/config/scf/Delta_Configuration_TC2_lock.json
${delta_configuration_TC2_unlock}    ${CURDIR}/config/scf/Delta_Configuration_TC2_unlock.json
${delta_configuration_TC2_addition}    ${CURDIR}/config/scf/Delta_Configuration_TC2_addition.json
${delta_configuration_TC3_lock}    ${CURDIR}/config/scf/Delta_Configuration_TC3_lock.json
${delta_configuration_TC3_unlock}    ${CURDIR}/config/scf/Delta_Configuration_TC3_unlock.json
${delta_configuration_TC3_addition}    ${CURDIR}/config/scf/Delta_Configuration_TC3_addition.json
&{WTS}                      Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}                  /opt/iphy/latest
${BTS_ADDRESS}              10.0.1.2
${BTS_PORT}                  443
${USE_SSL}                   True
${Log_Path}

*** Test Cases ***
USCB013880-A#B1_TC1_Fault_Indication_in_case_of_setup_of_the_cell_handling_a_slice_not_supported_by_AMF


     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    CB013880_keyword_A_B1.Update bsr package
    ...        AND    sleep    10s
     ...       AND    Run cfg file      ${wts_cfg_file_TC1}

    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delta file commissioning to lock slices
    sleep    5s
    Delta file commissioning to update slices
    sleep    5
    Delta file commissioning to unlock slices
    sleep    5
    Check SIB messagges for all cells
    Check If Alarm Appeared for NRCELL2_tc1    8301    MRBTS-1/NRBTS-1/NRCELL-2
    Verify cell-2 barred
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
	[Teardown]     Run Keywords  Delta file commissioning to lock slices
	 ...    AND     sleep    5s
	 ...    AND     Decommission the feature changes
	 ...    AND     sleep    5s
    ...    AND     Delta file commissioning to unlock slices
    ...    AND     sleep    5s
	 ...    AND    Log to console    " Reverting Testline"
	 ...    AND    Link SCOUT SCF to Configuration ID for Reporting
	 ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog
 	 ...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


USCB013880-A#B1_ALT1_TC2_Fault_update_in_case_of_setup_of_the_cell_handling_a_slice_not_supported_by_AMF

  [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    CB013880_keyword_A_B1.Update bsr package
    ...        AND    sleep    5s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}

    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delta file commissioning to lock slices
    sleep    5s
    Delta file commissioning to update slices
    sleep    5s
    Delta file commissioning to unlock slices
    sleep    5s
    Check SIB messagges for all cells
    Check If Alarm Appeared for NRCELL2_tc1    8301    MRBTS-1/NRBTS-1/NRCELL-2
    Verify cell-2 barred
    sleep    10s
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
    Delta file commissioning to lock slice_1
    Add slice_1 for NRCELL_2
    Check If Alarm Disappeared_tc2    8301
    Delta file commissioning to unlock slice_1
    sleep    10s

	[Teardown]     Run Keywords  Delta file commissioning to lock slices
	 ...    AND     sleep    5s
	 ...    AND     Decommission the feature changes
	 ...    AND     sleep    5s
     ...    AND     Delta file commissioning to unlock slices
     ...    AND     sleep    5s
	 ...    AND    Log to console    " Reverting Testline"
	 ...    AND    Link SCOUT SCF to Configuration ID for Reporting
	 ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog
 	 ...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

USCB013880-A#B1_ALT2_TC3_Fault_Update_with_Unsupported_Slice_added_to_TAC
  [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    CB013880_keyword_A_B1.Update bsr package
    ...        AND    sleep    5s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}

    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act.log  alias=feat_act  ip=192.168.255.126   ports=51000
    Delta file commissioning to lock slices
    sleep    5s
    Delta file commissioning to update slices for TC3
    sleep    5s
    Delta file commissioning to unlock slices
    sleep    5s
    Check SIB messagges for all cells
    Check If Alarm Appeared for NRCELL2_tc1    8301    MRBTS-1/NRBTS-1/NRCELL-2
    Verify cell-2 barred
    sleep    10s
    taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True    alias=feat_act
     sleep  5s
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog  log_dir=/tmp  log_name=feat_act1.log  alias=feat_act  ip=192.168.255.126  ports=51000
    Delta file commissioning to lock slice_3
    Add slice_3 for NRCELL_2
    Delta file commissioning to unlock slice_3
    sleep    5s
    Check If Alarm Appeared for NRCELL2_tc1    8301    MRBTS-1/NRBTS-1/NRCELL-2
    Verify cell-2 barred
    sleep    10s
    taf.sw.syslog.Collect Syslog Results  destination=${OUTPUTDIR}${/}feat_act1.log    unzip=True  alias=feat_act
	[Teardown]     Run Keywords  Log to console    " Reverting Testline"
	 ...    AND    Link SCOUT SCF to Configuration ID for Reporting
	 ...    AND    taf.sw.syslog.teardown_all_aliases_for_syslog
 	 ...    AND    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner


