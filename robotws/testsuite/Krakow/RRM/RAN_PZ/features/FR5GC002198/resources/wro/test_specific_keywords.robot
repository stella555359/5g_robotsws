*** Settings ***
Documentation
...    Test specific keywords for 5GC002198.

Library     OperatingSystem
Library     ta_attenuator
Library     ute_syslog
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/wro/test_specific_keywords.py
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/SlaveGnb.py
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/Positioner.py
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/MediaTek.py
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/MasterGnb.py
Library     testsuite/Krakow/RRM/RAN_PZ/features/FR5GC002198/resources/HpePdu.py
Library     testsuite/Krakow/RRM/RAN_PZ/features/CB009009/resources/keywords.py
Library     testsuite/Krakow/RRM/RAN_PZ/resources/webUI_operations.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    taf/rfrl/bts/robot/common/gnb_counter.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${LOG_PATH}                   ${OUTPUT DIR}
${GNB_IP}                     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GNB_ID}                     ${tl.gnbs[0].global_bts_id}
${VM_IP}                      ${tl.test_pc.default_ssh_connection_details.addr}
${NRADJNRCELL}                ${EMPTY}
@{additional_allowed_alarms}  ${EMPTY}

*** Keywords ***
Enable CP Debug Logs in Syslog
    Log To Console    \nEnabling Debug Logs in Syslog
    enable_syslog_cp_debugs

Perform Slave gNB Upgrade and Commissioning
    [Arguments]    ${branch_name}    ${cloud_tl}    ${skip_upgrade}=${False}
    clone_repositories
    get_gnb_sw_info  branch_name=${branch_name}  cloud_tl=${cloud_tl}
    upgrade_gnb_sw  skip_upgrade=${skip_upgrade}
    perform_gnb_commissioning
    verify_slave_gnb_is_on_air

Perform Slave gNB Commissioning
    [Arguments]    ${upgrade}=${False}  ${trunk_sw}=${False}
    clone_repositories
    perform_gnb_commissioning  gnb_upgraded=${upgrade}  trunk_softwre=${trunk_sw}
    verify_slave_gnb_is_on_air

Preconditions Without Logs Collection
    Modify Moler Logging Directory    mode=test case
    Wait Until Keyword Succeeds     180 sec     10 sec   Verify All Radio Module Status
    gnbcell.wait_for_all_cells_to_be_onair    timeout=180
    Verify gNB is onAir
    Add Custom Allowed Alarms If Defined
    Verify Default Allowed Alarms on gNB

Test Setup
    [Arguments]     ${require_srb_3}=${TRUE}   ${require_anr_moi_allowed}=${FALSE}   ${require_ue}=${TRUE}
    ...             ${require_reset}=${FALSE}  ${max_ho_rerun}=3
    Set Test Variables   ${require_srb_3}   ${require_anr_moi_allowed}   ${require_ue}   ${max_ho_rerun}
    Run Keyword If   ${require_ue} == ${FALSE}   Preconditions Without Logs Collection
    ...   ELSE   Common Preconditions
    Run Keyword And Ignore Error  taf_admin.Teardown All Aliases For Admin
    Delete All Nrrel And Nradjnrcell Objects
    Collect SCF Before Test
    Set Initial Parameters   ${require_srb_3}    ${require_anr_moi_allowed}
    Run Keyword If   ${require_reset} == ${TRUE}   Perform Site Reset And Wait For OnAir State

Get Global Cell Id Ue Attaches To
    ${GNB_CELL_ID} =  get_global_cell_id
    Set Suite Variable   ${GNB_CELL_ID}

Test Teardown
    Run Keyword If   ${require_anr_moi_allowed} == ${TRUE}
    ...    set_max_number_allowed_neighbour_relations    max_relations=20000
    Common Postconditions
    Delete All Nrrel And Nradjnrcell Objects
    Teardown All Admin Sessions

Test Teardown With Disabled UL Proactive Grant Scheduling
    Set Ul Proactive Grant Parameters  teardown=${TRUE}
    Test Teardown

Inter Gnb Pci Resolution And Neighbour Relation Addition
    [Arguments]    ${FreqType}=InterFreq    ${check_ul_proactive_grant}=${FALSE}
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    Verify Handover Milestone Msgs In Syslog  syslog_path=${current_syslog_path}  freq_type=${FreqType}
    ...  check_grant=${check_ul_proactive_grant}
    Wait Until Keyword Succeeds    12x    10s    Check Nrrel And Nradjrnrcell Objects Exist  nrrel_id=NRREL-256
    Verify Inter Frequency Inter Gnb Handover Succeeded

Inter Gnb Pci Resolution And Neighbour Relation Addition With MaxNumNrNrrelMoiAllowed
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    Repeat Keyword     10 times    Check Nrrel And Nradjrnrcell Objects Not Exist  nrrel_id=NRREL-256
    Verify Inter Frequency Inter Gnb Handover Failed

Modification Disable Flag ActAutoNrNbRemoval
    Create Nradjnrcell And Nrrel Objects
    Disable Auto Removal Param
    MasterGnb.Start Syslog
    Log To Console    \nBoth NRREL and NRADJNRCELL Objects Should Exist For 3 Cycles...
    Nrrel And Nradjnrcell Should Exist For Three Cycles
    MasterGnb.Stop Syslog
    Check If Fire Time Difference Correct   auto_removal=${FALSE}

Automatic Neighbour Removal Procedure Twice IdleTime Modification
    MasterGnb.Start Syslog
    Create Nradjnrcell And Nrrel Objects
    Update Idle Time For NR Removal
    Nrrel And Nradjnrcell Should Exist Before First Timer Fire
    Create Nradjnrcell And Nrrel Objects   nrradjnrcell_id=NRADJNRCELL-2   nrrel_id=NRREL-2
    Log To Console    \nBoth NRREL and NRADJNRCELL Objects Should Exist For 2 Cycles...
    Both Nrrel And Nradjnrcell Should Exist For Two Cycles
    Check If Both Nrrel Removed In Syslog
    Log To Console    \nBoth NRREL and NRADJNRCELL Objects Should Exist For 1 Cycle...
    Both Nradjnrcell Should Exist For One Additional Cycle
    Check If Both Nradjnrcell Removed In Syslog
    MasterGnb.Stop Syslog
    Check If Fire Time Difference Correct

Measure Gap Release And DRX Setup In UE To Allow Inter Frequency NR-CGI Measurement Reporting
    [Arguments]    ${FreqType}=InterFreq    ${check_ul_proactive_grant}=${FALSE}
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2    next_pm_period=${TRUE}
    Verify Handover Milestone Msgs In Syslog  syslog_path=${current_syslog_path}  freq_type=${FreqType}
    ...  check_grant=${check_ul_proactive_grant}
    Confirm Handover Succeeded    syslog_path=${current_syslog_path}
    verify_nr_cgi_report_counters    syslog_path=${current_syslog_path}
    Verify Drx Setup And Nrcgi Measurement Report   pcap_file=${pcap_path}

Set Initial Parameters
    [Arguments]    ${require_srb_3}    ${require_anr_moi_allowed}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=delta_commissioning
    taf_admin.Create Delta    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${GNB_CELL_ID}  actSib1ForNsaCell  true  delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actNsaUeBasedInterFreqAnrNr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actEnhanceIntraNrIntraFreqAnr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actNsaUeBasedAnrNr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANR-1     actAutoNrNbRemoval    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-1     idleTimeForNrNbRemoval    3    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   anrThresRsrpNbCell    -110    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   idleTimeForNrNbRemoval    3    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   maxNumAnrNrrelAllowed    2    delta_id=initial_params
    Run Keyword If   ${require_srb_3} == ${TRUE}
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   srb3SupportEnabled    true    delta_id=initial_params
    ...     ELSE   taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   srb3SupportEnabled    false    delta_id=initial_params
    Run Keyword If   ${require_anr_moi_allowed} == ${TRUE}   taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   maxNumNrAnrMoiAllowed    0    delta_id=initial_params
    ...     ELSE   taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   maxNumNrAnrMoiAllowed    2000    delta_id=initial_params
    ${delta}    taf_admin.Get_Delta    delta_id=initial_params
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=delta_commissioning
    taf_admin.Teardown Admin    connection=delta_commissioning
    gnbcell.wait_for_all_cells_to_be_onair  timeout=900

Delete All Nrrel And Nradjnrcell Objects
    [Arguments]    ${cell_1_id}=${GNB_CELL_ID}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    ${params}    Get Empty List
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-0
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del

Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${GNB_IP}     alias=admin_gnb
    taf_admin.Get Current Scf File  ${LOG_PATH}/    backup_scf.xml    timeout=${300}    connection=admin_gnb
    taf_admin.Teardown Admin    connection=admin_gnb

Collect Snapshot
    Log To Console    \nCollecting BTS Snapshot!
    Make Snapshot In Case Of Error

Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    [Arguments]    ${next_pm_period}=${FALSE}
    Log To Console    \nHandover Procedure Started
    Wait Until Keyword Succeeds    ${max_ho_rerun}x    30s    Perform Handover And Verify Measurement A3A5
    ...    next_pm_period=${next_pm_period}

Perform Handover And Verify Measurement A3A5
    [Arguments]    ${next_pm_period}
    reboot_mtk_ue
    verify_slave_gnb_is_on_air
    Run Keyword If   ${next_pm_period} == ${TRUE}
    ...     gnb_counter.Wait for next PM period    interval=15
    trigger_handover_with_log_collection
    verify_measurement_a3a5_in_syslog    syslog_path=${current_syslog_path}
    [Teardown]    MediaTek.detach

Check Nrrel And Nradjrnrcell Objects Exist
    [Arguments]    ${cell_id_1}=${GNB_CELL_ID}   ${nrrel_id}=NRREL-25   ${nradjnrcell_id}=NRADJNRCELL-12288
    ${nrrel_pattern}    Set Variable   distName="MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_id_1}/${nrrel_id}
    ${nradjnrcell_pattern}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjnrcell_id}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_status
    ${scfc_file}    taf_admin.Get Scf    connection=nrrel_status
    Should Contain    ${scfc_file}   ${nrrel_pattern}
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern}
    taf_admin.Teardown Admin    connection=nrrel_status

Check Nrrel And Nradjrnrcell Objects Not Exist
    [Arguments]    ${cell_id_1}=${GNB_CELL_ID}   ${nrrel_id}=NRREL-25   ${nradjnrcell_id}=NRADJNRCELL-12288
    ${nrrel_pattern}    Set Variable   distName="MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_id_1}/${nrrel_id}
    ${nradjnrcell_pattern}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjnrcell_id}
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_status
    ${scfc_file}    taf_admin.Get Scf    connection=nrrel_status
    Should Not Contain    ${scfc_file}   ${nrrel_pattern}
    Should Not Contain    ${scfc_file}   ${nradjnrcell_pattern}
    taf_admin.Teardown Admin    connection=nrrel_status

Verify Inter Frequency Inter Gnb Handover Succeeded
    Log To Console    \nChecking HO Success
    Confirm Srb3    syslog_path=${current_syslog_path}   require_srb3=${require_srb_3}
    Confirm Handover Succeeded    syslog_path=${current_syslog_path}

Verify Inter Frequency Inter Gnb Handover Failed
    Log To Console    \nChecking HO Failure
    Confirm Srb3    syslog_path=${current_syslog_path}   require_srb3=${require_srb_3}
    Confirm Handover Failed    syslog_path=${current_syslog_path}

Set Test Variables
    [Arguments]    ${require_srb_3}   ${require_anr_moi_allowed}   ${require_ue}   ${max_ho_rerun}
    Set Test Variable   ${require_srb_3}   ${require_srb_3}
    Set Test Variable   ${require_anr_moi_allowed}   ${require_anr_moi_allowed}
    Set Test Variable   ${require_ue}   ${require_ue}
    Set Test Variable   ${max_ho_rerun}   ${max_ho_rerun}

Perform Site Reset And Wait For OnAir State
    Perform Site Reset
    gnbcell.wait_for_all_cells_to_be_onair  timeout=900

Perform Site Reset
    taf_admin.Setup_Admin    bts_host=${GNB_IP}    alias=site_reset
    taf_admin.Reset_Site    timeout=600s    connection=site_reset
    taf_admin.Teardown_Admin    alias=site_reset

Teardown All Admin Sessions
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=delta_commissioning
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_del
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_status
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=object_creation

Nrrel And Nradjnrcell Should Exist For Three Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${FALSE}
        Exit For Loop If    ${fire_counter} == 3
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-1
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Sleep    5s

Check If Fire Time Difference Correct
    [Arguments]    ${auto_removal}=${TRUE}
    Log To Console    \nChecking time difference in progress
    Check Time Difference    syslog_path=${current_syslog_path}      auto_removal=${auto_removal}

Disable Auto Removal Param
    Log To Console    \nSetting Up actAutoNrNbRemoval
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=delta_commissioning
    taf_admin.Create Delta    delta_id=update_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANR-1     actAutoNrNbRemoval    false    delta_id=update_params

    ${delta}    taf_admin.Get_Delta    delta_id=update_params
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=delta_commissioning
    taf_admin.Teardown Admin    connection=delta_commissioning
    gnbcell.wait_for_all_cells_to_be_onair  timeout=900

Create Nradjnrcell And Nrrel Objects
    [Arguments]   ${cell_id}=${GNB_CELL_ID}   ${nrradjnrcell_id}=NRADJNRCELL-1   ${nrrel_id}=NRREL-1
    ${nradjnrcell_params}=    Get Params For Nradjnrcell Object   ${nrradjnrcell_id}
    ${nrrel_params}=    Get Params For Nrrel Object   ${nrradjnrcell_id}
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nrradjnrcell_id}
    ...                                         parameter=${nradjnrcell_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    Sleep   5s
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_id}/${nrrel_id}
    ...                                         parameter=${nrrel_params}
    ...                                         operation=create
    ...                                         connection=object_creation
    taf_admin.Teardown_Admin    alias=object_creation

Update Idle Time For NR Removal
    ${params}=    get_params_for_idletimefornrnbremoval
    taf_admin.Setup_Admin      bts_host=${GNB_IP}    alias=idleTimeForNrNbRemoval_update
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-1
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=idleTimeForNrNbRemoval_update
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2
    ...                                         parameter=${params}
    ...                                         operation=update
    ...                                         connection=idleTimeForNrNbRemoval_update
    taf_admin.Teardown_Admin    alias=idleTimeForNrNbRemoval_update

Nrrel And Nradjnrcell Should Exist Before First Timer Fire
    FOR    ${i}    IN RANGE    70
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        Exit For Loop If    ${fire_counter} == 1
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-1
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    1

Both Nrrel And Nradjnrcell Should Exist For Two Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        Exit For Loop If    ${fire_counter} == 3
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-1
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-2   nradjnrcell_id=NRADJNRCELL-2
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Sleep    5s

Both Nradjnrcell Should Exist For One Additional Cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        Exit For Loop If    ${fire_counter} == 4
        Check Both Nradjrnrcell Objects Exist
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    4
    Sleep    5s

Check Both Nradjrnrcell Objects Exist
    ${nradjnrcell_pattern_1}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-1
    ${nradjnrcell_pattern_2}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-2
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradj_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradj_status
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern_1}
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern_2}
    taf_admin.Teardown Admin    connection=nradj_status

Check If Both Nrrel Removed In Syslog
    Log To Console    \nChecking If NRREL Objects Removed Properly...
    Confirm Nrrel Removed   syslog_path=${current_syslog_path}

Check If Both Nradjnrcell Removed In Syslog
    Log To Console    \nChecking If NRADJNRCELL Objects Removed Properly...
    Confirm Nradjnrcell Removed    syslog_path=${current_syslog_path}

Verify Drx Setup And Nrcgi Measurement Report
    [Arguments]   ${pcap_file}
    Log To Console   \nChecking DRX And NR-CGI Msgs In Pcap File...
    Confirm Drx Setup And Nrcgi Report   ${pcap_file}
