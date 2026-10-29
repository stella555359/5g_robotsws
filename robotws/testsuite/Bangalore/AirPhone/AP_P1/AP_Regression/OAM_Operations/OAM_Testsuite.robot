*** Settings ***

Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description: Testing basic OAM operations on iterations to verify the stability of the system.

Resource        ../../Resources/robot/suite_common_keywords.robot
Resource        ../../Resources/robot/ue_operations.robot
Resource        ../../Resources/robot/gnb.robot
Library         ../../../AP_P1/scripts/Runner/APGNBControl.py    WITH NAME    ap_gnb_interface

Suite Setup       Run Keywords    Common Suite Setup    feature_folder=OAM_operations
...               AND    Run keyword If    '${IS_ORAN}'=='True'    Set variables for ORAN TC

*** Variables ***
${dl_tput}               3
${ul_tput}               3
@{SA_UE_List}            1
${CELL_LOCK_UNLOCK_REPETITIONS}    2
${RU_RESET_REPETITIONS}            2
${CELL_BLOCK_UNBLOCK_REPETITIONS}  2
${SITE_RESET_REPETITIONS}          2
${BBMOD_RESET_REPETITIONS}         2
${AMF_LOCK_UNLOCK_REPETITIONS}         2
${RU_LOCK_UNLOCK_REPETITIONS}         2
${MODULE_REBOOT_REPETITIONS}    15
${RFM_Plugin}                 RFMPlugin_O-RU_FJ_TA08029-B311-01_0006.zip
${ORAN_custom_config_folder}    ${CURDIR}/Config_Files/LO_AP_LOOO_ORAN
&{amf_params}        actEnhancedNgRanSupport=true    actNgcFlexSaMode=true    ngInducedCellDeactDelayTimer=10

*** Test Cases ***
CellLockUnlock_TC1_Verify Cell Lock and Unlock with 3DL_3UL Traffic
    [Documentation]    Verify Cell Lock and Unlock with 10DL_10UL Traffic
    [Tags]    AP_REG    CellLockUnlock_TC1     p3_boo_ap_loo    p3_lo_ap_lo    P3_REG
    [Setup]    Test Setup based on condition    feature=Cell_Lock_Unlock    cell_deployment=SA    syslog_err_count=112
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    FOR    ${index}    IN RANGE    ${CELL_LOCK_UNLOCK_REPETITIONS}
        Log to console    ***********CELL LOCK UNLOCK ITERATION ${index} STARTS **************
        Perform NR Cell Lock and Unlock
        Sleep    30s
        Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
        ...     downlink_tput=${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        Log to console    ***********CELL LOCK UNLOCK ITERATION ${index} STARTS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

RU_reset via WebGUI
    [Documentation]    This testcase is mainly for reset the radio modules and checking the traffic
    [Tags]    AP_REG    RU_reset    p3_boo_ap_loo    p3_lo_ap_lo    P3_REG
    [Setup]    Test Setup based on condition    feature=RU_reset    cell_deployment=SA    syslog_err_count=61
    FOR    ${reset}    IN RANGE    ${RU_RESET_REPETITIONS}
        Log to console    ***********RU RESET ITERATION ${reset} STARTS **************
        RU reset via webgui
        Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        sleep    5
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        sleep    30sec
        Log to console    ***********RU RESET ITERATION ${reset} STARTS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Cell_block_unblock_scenario
    [Documentation]    This testcase verifies cell block unblock
    [Tags]    AP_REG    cell_block_unblock    p3_boo_ap_loo    p3_lo_ap_lo    P3_REG
    [Setup]   Test Setup based on condition    feature=Cell_Block_Unblock    cell_deployment=SA    syslog_err_count=108
    Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    sleep    5
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    FOR    ${block_count}    IN RANGE    ${CELL_BLOCK_UNBLOCK_REPETITIONS}
        Log to console    ***********CELL BLOCK UNBLOCK ITERATION ${block_count} STARTS **************
        Perform NR Cell Block and Unblock
        sleep    30
        Wait Until Keyword Succeeds    3min    30sec    Validate Cell Setup Pattern After oam operation    ${block_count}+1
        Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        sleep    5
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        sleep    30sec
        Log to console    ***********CELL BLOCK UNBLOCK ITERATION ${block_count} ENDS **************
    END
    Run Keyword and continue on failure    Validate Cell Setup Pattern After oam operation    ${CELL_BLOCK_UNBLOCK_REPETITIONS}
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Site_reset_Verify site reset with with 3DL_3UL Traffic
    [Documentation]    Verify site reset
    [Tags]    AP_REG    Site_reset_TC1    p3_boo_ap_loo    p3_lo_ap_lo    P3_REG
    [Setup]    Test Setup based on condition    feature=Site_reset    cell_deployment=SA    syslog_err_count=222
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    FOR    ${index}    IN RANGE    ${SITE_RESET_REPETITIONS}
        Log to console    ***********SITE RESET ITERATION ${index} STARTS **************
        Perform Reset Site and Check BTS Status
        Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
        ...     downlink_tput=${dl_tput}
        Sleep    600s
        Run Keyword and continue on failure    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}
        ...    expected_dl_tput=${dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        Log to console    ***********SITE RESET ITERATION ${index} ENDS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

BBMOD_reset_Verify BMMOD reset scenario
    [Documentation]    Verify BBMOD reset
    [Tags]    AP_REG    BBMOD_reset_TC1    p3_boo_ap_loo    p3_lo_ap_lo    P3_REG
    [Setup]    Test Setup based on condition    feature=BBMOD_reset    cell_deployment=SA    syslog_err_count=80
    Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
    ...     downlink_tput=${dl_tput}
    Sleep    30s
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    FOR    ${index}    IN RANGE    ${BBMOD_RESET_REPETITIONS}
        Log to console    *********** BBMOD RESET ITERATION ${index} STARTS **************
        Perform BBMOD Reset and Check BTS Status
        Register and Start Traffic For SA UEs    ${SA_UE_List}   uplink_tput=${ul_tput}
        ...     downlink_tput=${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        Log to console    *********** BBMOD RESET ITERATION ${index} ENDS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Verify AMF lock unlock scenario
    [Documentation]    This testcase verifies AMF lock unlock
    [Tags]    AP_REG    amf_lock_unlock    P3_REG
    [Setup]   Test Setup based on condition    feature=AMF_Lock_Unlock    cell_deployment=SA    syslog_err_count=108
    Enable mandatory params for AMF lock Unlock
    Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    sleep    5
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    sleep    30s
    FOR    ${amf_count}    IN RANGE    ${AMF_LOCK_UNLOCK_REPETITIONS}
        Log to console    *********** AMF LOCK UNLOCK ITERATION ${amf_count} STARTS **************
        Perform AMF lock Unlock operation    iteration=${amf_count}
        sleep    120
        Wait Until Keyword Succeeds    3min    30sec    Validate Cell Setup Pattern After oam operation    ${amf_count}+1
        Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        sleep    5
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        sleep    30sec
        Log to console    *********** AMF LOCK UNLOCK ITERATION ${amf_count} ENDS **************
    END
    Run Keyword and continue on failure    Validate Cell Setup Pattern After oam operation    ${AMF_LOCK_UNLOCK_REPETITIONS}
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

RU soft reset
    [Documentation]    This testcase verifies soft reset of the radio modules and checking the traffic
    [Tags]    RU_reset_soft    P3_REG
    [Setup]    Test Setup based on condition    feature=RU_reset_soft    cell_deployment=SA    syslog_err_count=61
    Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    sleep   60
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    sleep    30sec
    FOR    ${reset}    IN RANGE    ${RU_RESET_REPETITIONS}
        Log to console    *********** RU RESET ITERATION ${reset} STARTS **************
        RU reset via webgui    reset_type=Soft
        Wait Until Keyword Succeeds    3min    30sec    Validate Cell Setup Pattern After oam operation    ${reset}+1
        Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        sleep    5
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        sleep    30sec
        Log to console    *********** RU RESET ITERATION ${reset} ENDS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

RU_lock_unlock
    [Documentation]    This testcase verifies RU lock unlock
    [Tags]    RU_lockUnlock    p3_lo_ap_lo    P3_REG
    [Setup]   Test Setup based on condition    feature=RU_Lock_Unlock    cell_deployment=SA    syslog_err_count=108
    Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
    sleep    5
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    sleep    30s
    FOR    ${ru_count}    IN RANGE    ${RU_LOCK_UNLOCK_REPETITIONS}
        Log to console    ***********RU LOCK UNLOCK ITERATION ${ru_count} STARTS **************
        Perform RMOD lock Unlock operation
        Register and Start Traffic For SA UEs    sa_ue_list=${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}
        sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
        sleep    30sec
        Log to console    ***********RU LOCK UNLOCK ITERATION ${ru_count} ENDS **************
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

Verify_Disable_airphone_partition_switch
    [Documentation]    This testcase verifies after system-module-reboot,active partition should be same as before reboot
    [Tags]    airphone_partition
    [Setup]    Disable TTI And Run Generic Setup
    FOR    ${reboot_count}    IN RANGE    ${MODULE_REBOOT_REPETITIONS}
        ${active_before_reboot}    ${standby_before_reboot}=    ap_gnb_interface.get_airphone_active_standby_partition
        Reboot Airphone And Check Airphone is Ready
        Wait Until Keyword Succeeds    5 min    10 sec    Verify Reset Loop Counter Is Zero
		Verify Partition Unchanged
        ...    ${active_before_reboot}
        ...    ${standby_before_reboot}
    END
	Sleep    60s
    [Teardown]    Simple Test Teardown

*** Keywords ***
Set variables for ORAN TC
    [Arguments]    &{kwargs}
    Log    Setting variables for ORAN TC
    #Set Suite Variable    ${IS_ORAN}    True
    Set Suite Variable    ${custom_config}    True
    Set Suite Variable    ${custom_config_folder}    ${CURDIR}/Config_Files/LO_AP_LOOO_ORAN

Test Setup for ORAN
    [Arguments]    ${feature}=${EMPTY}    ${cell_deployment}=SA    &{kwargs}
    Set variables for ORAN TC
    Generic Test Setup    feature=${feature}    cell_deployment=${cell_deployment}    custom_config=True
    ...    custom_config_folder=${ORAN_custom_config_folder}


Test Setup based on condition
    [Arguments]    ${feature}=${EMPTY}    ${cell_deployment}=SA    &{kwargs}
    Run keyword If    '${IS_ORAN}'=='True'    Test Setup for ORAN    ${feature}   cell_deployment=${cell_deployment}    &{kwargs}
    ...    ELSE    Generic Test Setup    feature=${feature}    cell_deployment=${cell_deployment}    &{kwargs}

Enable mandatory params for AMF lock Unlock
    Delete Delta If Alread Present    name=default
    Initialise Delta Store
    ${NRBTS_DISTNAME}    admin_helper.get_distname_for_nrbts
    set test variable    ${NRBTS_DISTNAME}
    delta_store.update managed object and parameter to delta    dist_name=${NRBTS_DISTNAME}    &{amf_params}
    ${delta_store}    Collect Delta Store
    Recommission GNB With Delta    delta_file=${delta_store}    should_activate=${True}
    log to console     recommissioned gnb with amf lock unlock parameters: ${amf_params}
    sleep    30s
    Wait Until Keyword Succeeds    5min    30sec     Ensure gnb and radio is up

Verify Partition Unchanged
    [Arguments]    ${active_before}    ${standby_before}
    ${active_after}    ${standby_after}=    ap_gnb_interface.get_airphone_active_standby_partition
    Should Be Equal    ${active_before}    ${active_after}    Active partition changed after reboot
    Should Be Equal    ${standby_before}   ${standby_after}   Standby partition changed after reboot

Verify Reset Loop Counter Is Zero
    ${ddal_return}    ${val}=    ap_gnb_interface.get_DDAL_RETURN_VALUE
    Should Be Equal As Integers    ${ddal_return}    0
    Should Be Equal As Integers    ${val}    0

Reboot Airphone And Check Airphone is Ready
    Run And Return Rc And Output    ssh 192.168.200.1 uptime
    ap_gnb_interface.Reboot Ap
    ap_gnb_interface.wait_for_ap_to_go_down
    ap_gnb_interface.wait_for_ap_to_be_reachable
    Run Keyword And Ignore Error    ap_gnb_interface.check_adet_ready
    Run And Return Rc And Output    ssh 192.168.200.1 uptime

Disable TTI And Run Generic Setup
    Set Test Variable    ${AP_TTI_TRACE_NEEDED}    ${False}
    Generic Test Setup    feature=airphone_partition