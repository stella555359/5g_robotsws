*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LOOO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :author: sujeet
...              :contact: sujeet.sharma@nokia.com
...
...             INTRODUCTION:     The User scenario covers new fault update and cancellation  with slice or managed object after
...             activation of feature flag .
...             TEST SET NAME:    CB013880
...             TESTING SPLIT:    Refer CB013880 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB013880 CFAM


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource          ./resources/CB013880_keyword.robot
Library          ta5g_cell_operations
Library          taf.sw.syslog
Resource        ../../../resources/robot/configuration_id.robot

*** Variables ***
${Delta_Configuration_feature_enable_2slices}    ${CURDIR}/config/scf/Delta_Configuration_feature_enable_2slices.json
${Delta_Configuration_lock_2_slices}        ${CURDIR}/config/scf/Delta_Configuration_Slices_Lock.json
${Delta_Configuration_feature_disable}      ${CURDIR}/config/scf/Delta_Configuration_feature_disable.json
${Delta_Configuration_undo_changes}      ${CURDIR}/config/scf/Delta_Configuration_undo_changes.json
${delta_configuration_slice_deletion}        ${CURDIR}/config/scf/Delta_Configuration_delete_Slices.json
${delta_configuration_slice_addition}        ${CURDIR}/config/scf/SNSSAI_1_to_2000_Configuration.json
${delta_configuration_PLMN_TAC_addition}     ${CURDIR}/config/scf/PLMN_TAC_addition_all_cell.json
${delta_configuration_Lock_1999_Slices}      ${CURDIR}/config/scf/SNSSAI_2_to_2000_Configuration_lock.json
${Delta_Configuration_2SNSSAI_addition}      ${CURDIR}/config/scf/Delta_Configuration_2SNSSAI_addition.json
${Delta_Configuration_slice-1_lock}        ${CURDIR}/config/scf/Delta_Configuration_slice-1_lock.json
${Delta_Configuration_slice-1_unlock}      ${CURDIR}/config/scf/Delta_Configuration_slice-1_unlock_sd_change.json
${Delta_Configuration_reslice-1_unlock}      ${CURDIR}/config/scf/Delta_Configuration_slice-1_unlock_resd_change.json
${Delta_Configuration_SNSSAI_1_addition_amf}    ${CURDIR}/config/scf/Delta_Configuration_SNSSAI_1_addition_amf.json
${Delta_Configuration_5_addition}     ${CURDIR}/config/scf/Delta_Configuration_5_addition.json
${Delta_Configuration_SNSSAI_2_removal}       ${CURDIR}/config/scf/Delta_Configuration_TC6_2-SNSSAI_removal.json
${Delta_Configuration_SNSSAI_1_3_removal}      ${CURDIR}/config/scf/Delta_Configuration_TC6_1_3-SNSSAI_removal.json
${Delta_Configuration_undo_TC6}         ${CURDIR}/config/scf/Delta_Configuration_undo_scf.json
${Delta_Configuration_slice-3_lock}      ${CURDIR}/config/scf/Delta_Configuration_slice-3_lock.json
${Delta_Configuration_slice-3_unlock}      ${CURDIR}/config/scf/Delta_Configuration_slice-3_unlock_sd_change.json
${Delta_Configuration_slice-1_3_lock}      ${CURDIR}/config/scf/Delta_Configuration_scf_lock_slice_1_3.json
${Delta_Configuration_slice-1_3_unlock}      ${CURDIR}/config/scf/Delta_Configuration_slice-1_3_unlock_sd_change.json
${wts_cfg_file_TC1}          ${CURDIR}/config/wts/basic_setup_2000.cfg
${wts_cfg_file_TC2}          ${CURDIR}/config/wts/basic_setup_B2.cfg
${wts_cfg_file_TC3}          ${CURDIR}/config/wts/basic_setup_B6.cfg
${wts_cfg_file_TC32}         ${CURDIR}/config/wts/basic_setup_B9.cfg

*** Test Cases ***

USCB013880-A#B9_TC32_Fault_Indication_in_case_of_feature_activation_Decativation
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Run cfg file_1      ${wts_cfg_file_TC32}

    Delta file commissioning to delete slices
    sleep    20s
    Delta file commissioning to enable feature flag & Add slices
    Check If Alarm Disappeared    8301
    Delta file commissioning to lock 2 slices
    sleep   5s
    Delta file commissioning to change sd and unlock slices-3
    Check If Alarm Appeared    8301     SNSSAI: [3]    NR:10,11,12,7,8,9
    Delta file commissioning to disable feature flag
    Check If Alarm Disappeared    8301
    Delta_Configuration_undo_changes
    Delta file commissioning to enable feature flag & Add slices
    Check If Alarm Disappeared    8301
    Delta file commissioning to lock 2 slices
    sleep   5s
    Delta file commissioning to change sd and unlock slices-3
    Check If Alarm Appeared    8301     SNSSAI: [3]    NR:10,11,12,7,8,9
    Delta file commissioning to disable feature flag
    Check If Alarm Disappeared    8301
    [Teardown]      Run keywords
	...       Log to console    " Reverting Testline"
	...       AND    Link SCOUT SCF to Configuration ID for Reporting
	...       AND    Run Keyword and Ignore Error    CB013880_keyword.Kill WTS processes Using WTS_Runner

USCB013880-A#B5_ALT2_TC14_Fault_cancellation_in_case_of_Cell_Lock
     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Run cfg file_1      ${wts_cfg_file_TC32}

    Delta file commissioning to delete slices
    sleep    20s
    Delta file commissioning to enable feature flag & Add slices
    Check If Alarm Disappeared    8301
    Delta file commissioning to lock slices-3
    sleep    5s
    Delta file commissioning to change sd and unlock slices-3
    Check If Alarm Appeared    8301     SNSSAI: [3]    NR:10,11,12,7,8,9
    CoamAdmin.Setup Admin
    CoamAdmin.Block Cell  dist_name=MRBTS-1/NRBTS-1/NRCELL-8    connection=${ADMIN_ALIAS}
    CoamAdmin.Teardown admin
    Check If Alarm Appeared     8301      SNSSAI: [3]    NR:10,11,12,7,9
    [Teardown]      Run keywords
	...       Log to console    " Reverting Testline"
	...       AND    Link SCOUT SCF to Configuration ID for Reporting
	...       AND    Run Keyword and Ignore Error    CB013880_keyword.Kill WTS processes Using WTS_Runner

USCB013880_TC29_Exploratory_Fault_Indication_with_2000_Slices_configured

     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Run cfg file      ${wts_cfg_file_TC1}

    Delta file commissioning to delete slices
    sleep    20s
    Delta file commissioning to add 2000 slices
    sleep    20s
    Delta file commissioning to add 2nd PLMN and TAC
    sleep    60s
    Delta file commissioning to Lock 1999 slices
	 [Teardown]     Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
 	 ...    AND    Run Keyword and Ignore Error    CB013880_keyword.Kill WTS processes Using WTS_Runner

USCB013880-A#B2_TC4_Fault_indication_in_case_of_slice_support_removal_from_AMF

     [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Run cfg file_1      ${wts_cfg_file_TC2}

    Check SIB messagges for all cells_TMO
    Delta file commissioning to delete slices
    sleep    20s
    Delta file commissioning to add 2 SNSSAI
    sleep    60s
    Check If Alarm Disappeared   8301
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126       ports=51000
    Start Tshark on eth3
    Delta file commissioning to lock slices-1
    sleep    5s
    Delta file commissioning to change sd and unlock slices-1
    Check If Alarm Appeared    8301     SNSSAI: [1]    NR:10,11,12,7,8,9
    Verify all cells barred except cell-8
    Delta file commissioning to lock slices-1
    sleep    5s
    Delta file commissioning to re-change sd and unlock slices-1
    Check If Alarm Disappeared   8301
    Check SIB messagges for all cells_TMO
	 [Teardown]     Run Keywords    Stop Tshark on eth3
	 ...    AND     Syslog stop
     ...    AND     Link SCOUT SCF to Configuration ID for Reporting
 	 ...    AND    Run Keyword and Ignore Error    CB013880_keyword.Kill WTS processes Using WTS_Runner




USCB013880-A#B2_ALT2_TC6_Fault_indication_in_case_of_multiple_slice_support_removal_from_AMF
         [Setup]    Run keywords
    ...        Log to console    "Setting up Testline"
    ...        AND    Configure Routes in WTS
    ...        AND    sleep    30s
    ...        AND    Run cfg file_1      ${wts_cfg_file_TC3}

    Check SIB messagges for all cells_TMO
    Delta file commissioning to delete slices
    Delta file commissioning to add 5-SNSSAI
    sleep    60s
    Check If Alarm Disappeared    8301
    Start Tshark on eth3
    Delta file commissioning to lock slices-1_3
    Delta file commissioning to change sd and unlock slices-1_3
    sleep    20s
    Stop Tshark on eth3
    Check If Alarm Appeared    8301     SNSSAI: [1], [3]    NR:10,11,12,7,8,9
    sleep     10s
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act  ip=192.168.255.126       ports=51000
    Start Tshark on eth3_1
    Delta file commissioning to lock 2 slices
    sleep    10s
    Verify all cells barred except cell-8
    Syslog stop
    Check If Alarm Appeared    8301     SNSSAI: [1]    NR:10,11,12,7,8,9
    Stop Tshark on eth3_1
    undo scf changes
    Check If Alarm Disappeared    8301
	 [Teardown]     Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
	     ...   AND    Run Keyword and Ignore Error     CB013880_keyword.Kill WTS processes Using WTS_Runner




