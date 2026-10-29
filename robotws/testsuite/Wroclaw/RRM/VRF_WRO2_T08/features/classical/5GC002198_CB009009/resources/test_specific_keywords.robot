*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     OperatingSystem
Library     DateTime
Library     ta_attenuator
Library     taf.sw.syslog   WITH NAME    taf_syslog
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ute_tshark   WITH NAME   tshark
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.anr_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${GNB_1_CELL_1_ALIAS}       GNB_1_CELL_1
${GNB_1_CELL_2_ALIAS}       GNB_1_CELL_2
${GNB_1_CELL_3_ALIAS}       GNB_1_CELL_3
${GNB_2_CELL_1_ALIAS}       GNB_2_CELL_1
${GNB_2_CELL_2_ALIAS}       GNB_2_CELL_2
${LOG_PATH}                 ${OUTPUT DIR}
${GNB_IP}                   ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${GNB_ID}                   ${tl.gnbs[0].global_bts_id}
${VM_IP}                    ${tl.test_pc.default_ssh_connection_details.addr}
${NRADJNRCELL}              ${EMPTY}
${UE_1_DRX_1}    f1ap.procedureCode == 7 and nr-rrc.reportType == 2
${UE_1_DRX_2}    f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 13
${UE_1_DRX_3}    x2ap.procedureCode == 30 and nr-rrc.drx_Config == 1 and nr-rrc.drx_LongCycleStartOffset == 13

*** Keywords ***
Test Setup
    [Arguments]     ${require_srb_3}=${TRUE}   ${require_ue}=${TRUE}
    ...             ${dedicated_DRX_profile}=${FALSE}   ${disable_removal}=${FALSE}
    Remove Special Characters From Anr Testname
    Set Test Variables   ${require_srb_3}   ${require_ue}   ${dedicated_DRX_profile}   ${disable_removal}
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Delete All Nrrel And Nradjnrcell Objects
    Collect SCF Before Test
    Set Initial Parameters   ${require_srb_3}    ${dedicated_DRX_profile}
    IF   ${require_ue} == ${TRUE}    Prepare Ue
    Setup Admin For Relation Check


Test Teardown
    IF   ${require_ue} == ${TRUE}   Run Keywords
    ...   Run Keyword And Continue On Failure    Detach Ue    UE_1   AND   Release Attenuator
    Run Keyword And Ignore Error    Stop Collecting Syslog
    Run Keyword If Test Failed      Collect Snapshot
    Add Scout Scf Id To Test Data
    Run Keyword And Ignore Error  taf_admin.Teardown All Aliases For Admin
    Delete All Nrrel And Nradjnrcell Objects
    IF    ${dedicated_DRX_profile}    Create Default Dedicated DRX profiles
    IF    ${disable_removal}    Disable Auto Removal Param
    Teardown All Admin Sessions


Setup Admin For Relation Check
    taf_admin.Setup Admin    bts_host=${gNB_IP}     name=nrrel_status


Check Counters
    [Arguments]  @{counters}  ${cell_id}=1  ${expected_value}=1
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  expected_value=${expected_value}


Inter Gnb Pci Resolution And Neighbour Relation Addition
    Log To Console    \nStarting Test
    @{counters}=       Create List                    M55124C05001  M55124C05002  M55147C01001
    @{counters2}=      Create List                    M55124C05001  M55124C05002
    @{counters3}=      Create List                    M55147C01001
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters}  expected_value=0
    Start Collecting Syslog
    Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    Sleep    60s
    Check Nrrel And Nradjrnrcell Objects Exist
    Verify Inter Frequency Inter Gnb Handover Succeeded
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters2}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters3}


Modification Disable Flag ActAutoNrNbRemoval
    Log To Console    \nStarting Test
    Wait One Removal Cycle
    Create Nradjnrcell And Nrrel Objects
    Disable Auto Removal Param
    Start Collecting Syslog   alias=cycles_count
    Log To Console    \nBoth NRREL and NRADJNRCELL Objects Should Exist For 3 Cycles...
    Nrrel And Nradjnrcell Should Exist For Three Cycles
    Stop Collecting Syslog   alias=cycles_count
    Check If Fire Time Difference Correct   auto_removal=${FALSE}


Automatic Neighbour Removal Procedure Twice IdleTime Modification
    Log To Console    \nStarting Test
    Wait One Removal Cycle
    Start Collecting Syslog   alias=5g_syslog
    Create Nradjnrcell And Nrrel Objects
    Update Idle Time For NR Removal
    Nrrel And Nradjnrcell Should Exist Before First Timer Fire
    Create Nradjnrcell And Nrrel Objects   nrradjnrcell_id=NRADJNRCELL-3   nrrel_id=NRREL-2
    Log To Console    \nBoth NRREL and NRADJNRCELL Objects Should Exist For 2 Cycles...
    Both Nrrel And Nradjnrcell Should Exist For Two Cycles
    Check If Both Nrrel Removed In Syslog
    Log To Console    \nBoth NRADJNRCELL Objects Should Exist For 1 Cycle...
    Both Nradjnrcell Should Exist For One Additional Cycle
    Check If Both Nradjnrcell Removed In Syslog
    Stop Collecting Syslog   alias=5g_syslog
    Check If Fire Time Difference Correct


TC01 CB009009_A_B1 5GC001296 and 5GC002198 flags enabled
    Log To Console    \nStarting Test
    Start Collecting Syslog   alias=5g_drx_syslog
    Create CB009009 Dedicated DRX profiles A_B1
    Log To Console    drxProfileNrAnr activated successfully!
    Stop Collecting Syslog   alias=5g_drx_syslog


TC09 CB009009_A_B2 5GC002198 flag enabled with SRB3
    Log To Console    \nStarting Test
    Create CB009009 Dedicated DRX profiles A_B2
    Start Collecting Logs
    Perform Intra Gnb Handover From Cell 1 To Cell 3
    Sleep    60s
    Check NRREL Exists
    Stop Collecting Logs
    Check Dedicated DRX ANR HO
    Verify ANR Dedicated Drx HO


Wait For X2 Link Available
    [Arguments]  ${admin_alias}
    taf_admin.Setup Admin    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Set Initial Parameters
    [Arguments]    ${require_srb_3}    ${dedicated_DRX_profile}
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=delta_commissioning
    taf_admin.Create Delta    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1    actSib1ForNsaCell    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-2    actSib1ForNsaCell    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-3    actSib1ForNsaCell    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actNsaUeBasedInterFreqAnrNr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actIntraFreqIntraGnbMobilityNSA    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actEnhanceIntraNrIntraFreqAnr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}    actNsaUeBasedAnrNr    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANR-1     actAutoNrNbRemoval    true    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-1     idleTimeForNrNbRemoval    3    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   anrThresRsrpNbCell    -140    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   idleTimeForNrNbRemoval    3    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRANRPR-2   maxNumAnrNrrelAllowed    2    delta_id=initial_params
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   maxNumNrAnrMoiAllowed    2000    delta_id=initial_params
    IF   ${require_srb_3} == ${TRUE}
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   srb3SupportEnabled    true    delta_id=initial_params
    ...     ELSE   taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   srb3SupportEnabled    false    delta_id=initial_params
    IF   ${dedicated_DRX_profile} == ${TRUE}   Run Keywords
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actDedicatedAnrDrxProfile    true    delta_id=initial_params    AND
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actSaUeBasedInterFreqAnrNr    false    delta_id=initial_params  AND
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actSaUeBasedAnrEutra    false    delta_id=initial_params
    ...     ELSE   Run Keywords
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actSaUeBasedInterFreqAnrNr    true    delta_id=initial_params    AND
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actSaIntraFreqAnrDrxProf    true    delta_id=initial_params    AND
    ...     taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}   actSaUeBasedAnrEutra    true    delta_id=initial_params
    ${delta}    taf_admin.Get_Delta    delta_id=initial_params
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=delta_commissioning
    taf_admin.Teardown Admin    connection=delta_commissioning
    Wait For X2 Link Available    cells_up


Delete All Nrrel And Nradjnrcell Objects
    [Arguments]    ${cell_1_id}=1
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nrrel_del
    ${params}    Get Empty List
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_1_id}/NRREL-256
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
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-2
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform Object Recommissioning
    ...                                         dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-3
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${GNB_IP}     alias=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb
    taf_admin.Teardown Admin    connection=admin_gnb


Start Collecting Syslog
    [Arguments]    ${alias}=5g
    ${ports}=   Create List   51000    51001    51003    50011
    taf_syslog.Start Syslog    log_dir=${LOG_PATH}/${test_name}/syslog/    log_name=syslog_${alias}.log    ip=192.168.255.126
    ...    host_ip=${VM_IP}    ports=${ports}    alias=${alias}    virtualenv_dir=/home/ute/test_repo
    Set Test Variable    ${current_syslog_path}   ${LOG_PATH}/${test_name}/syslog/syslog_${alias}.log


Stop Collecting Syslog
    [Arguments]    ${alias}=5g
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${alias}
    RETURN      ${file_path}


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2    GNB_1_CELL_3   GNB_2_CELL_1   GNB_2_CELL_2
    Set global variable   ${GNB_CELLS}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${GNB_1_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_3_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_1_ALIAS}    90dB
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}    90dB
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0dB
    Sleep  2s


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release Attenuator Cell    ${GNB_CELLS}


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Perform Attach
    Attach UE    UE_1
    Sleep   20s


Collect Snapshot
    Log To Console    \nCollecting BTS Snapshot!
    Make Snapshot In Case Of Error


Remove Special Characters From Anr Testname
    ${test_name}=    Replace String Using Regexp   ${TESTNAME}   ${space}   _
    ${test_name}=    Replace String Using Regexp   ${test_name}   &   _
    ${test_name}=    Remove String   ${test_name}   (
    ${test_name}=    Remove String   ${test_name}   )
    Set Test Variable   ${test_name}


Perform Inter Gnb Handover From Gnb Cell 1 To Gnb2 Cell 2
    Perform Attach
    Set Attenuation    ${GNB_1_CELL_1_ALIAS}    0db
    Set Attenuation    ${GNB_2_CELL_2_ALIAS}   30db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  ${GNB_1_CELL_1_ALIAS}  ${i}db
        Sleep  1s
    END


Perform Intra Gnb Handover From Cell 1 To Cell 3
    Perform Attach
    Log To Console    \nStarting IntraGnb Inter Freq HO...
    Set Attenuation    GNB_1_CELL_1    0db
    Set Attenuation    GNB_1_CELL_3    40db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END


Check Nrrel And Nradjrnrcell Objects Exist
    [Arguments]    ${cell_id_1}=1   ${nrrel_id}=NRREL-25   ${nradjnrcell_id}=NRADJNRCELL-12288
    ${nrrel_pattern}    Set Variable   distName="MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-${cell_id_1}/${nrrel_id}
    ${nradjnrcell_pattern}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/${nradjnrcell_id}
    ${scfc_file}    taf_admin.Get Scf    connection=nrrel_status
    Should Contain    ${scfc_file}   ${nrrel_pattern}
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern}


Verify Inter Frequency Inter Gnb Handover Succeeded
    Log To Console    \nChecking HO Success
    Confirm Srb3    syslog_path=${current_syslog_path}   require_srb3=${require_srb_3}
    Confirm Handover Succeeded    syslog_path=${current_syslog_path}


Set Test Variables
    [Arguments]    ${require_srb_3}   ${require_ue}    ${dedicated_DRX_profile}    ${disable_removal}
    Set Test Variable   ${require_srb_3}   ${require_srb_3}
    Set Test Variable   ${require_ue}   ${require_ue}
    Set Test Variable   ${dedicated_DRX_profile}   ${dedicated_DRX_profile}
    Set Test Variable   ${disable_removal}   ${disable_removal}


Check OnAir State And Start Syslog
    Start Collecting Syslog
    Wait For X2 Link Available    cells_up
    Log To Console    \ngNB On air


Teardown All Admin Sessions
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=delta_commissioning
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_del
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=nrrel_status
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=object_creation
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    tshark.Teardown All Aliases For Tshark


Nrrel And Nradjnrcell Should Exist For Three Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${FALSE}
        IF    ${fire_counter} == 3    BREAK
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-2
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Sleep    5s


Wait One Removal Cycle
    Start Collecting Syslog    alias=wait_one_cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    ${LOG_PATH}/${test_name}/syslog/syslog_wait_one_cycle.log   auto_removal=${TRUE}
        ${date}  Get Current Date
        IF    ${fire_counter} == 1    BREAK
        Sleep    5s
    END
    Stop Collecting Syslog    alias=wait_one_cycle


Check If Fire Time Difference Correct
    [Arguments]    ${auto_removal}=${TRUE}
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
    Wait For X2 Link Available    cells_up


Create Nradjnrcell And Nrrel Objects
    [Arguments]   ${cell_id}=1   ${nrradjnrcell_id}=NRADJNRCELL-2   ${nrrel_id}=NRREL-1
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


Create CB009009 Dedicated DRX profiles A_B1
    [Arguments]    ${drxControl_1}=intraNRNSAintraFreq  ${drx_timer_1}=80ms  ${drxLongCycle_1}=320ms  ${drxOnDurationTimer_1}=20ms
    ...            ${drxControl_2}=intraNRNSAinterFreq  ${drx_timer_2}=60ms  ${drxLongCycle_2}=640ms  ${drxOnDurationTimer_2}=20ms
    ${drxProfileNrAnrfortwo}=    get_params_for_two_drxProfileNrAnr  ${drxControl_1}
    ...                                                              ${drxControl_2}
    ...                                                              ${GNB_ID}
    ${delete_params}=    get_params_for_drxProfileNrAnr_delete
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1
    ...                                         parameter=${drxProfileNrAnrfortwo}
    ...                                         operation=update
    ...                                         connection=object_creation
    taf_admin.Create Delta    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxInactivityTimer    ${drx_timer_1}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxLongCycle    ${drxLongCycle_1}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxOnDurationTimer    ${drxOnDurationTimer_1}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxInactivityTimer    ${drx_timer_2}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxLongCycle    ${drxLongCycle_2}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxOnDurationTimer    ${drxOnDurationTimer_2}    delta_id=drxProfileRecommissioning
    ${delta}    taf_admin.Get_Delta    delta_id=drxProfileRecommissioning
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=object_creation
    taf_admin.Teardown_Admin    connection=object_creation


Create CB009009 Dedicated DRX profiles A_B2
    [Arguments]    ${drxControl}=intraNRNSAinterFreq  ${drx_timer}=80ms  ${drxLongCycle}=640ms  ${drxOnDurationTimer}=20ms  ${nrDrxDN}=5
    ...            ${drx_timer_2}=80ms  ${drxLongCycle_2}=320ms  ${drxOnDurationTimer_2}=20ms
    ${drxProfileNrAnr}=    get_params_for_drxProfileNrAnr_ab2  ${drxControl}
    ...                                                        ${GNB_ID}  ${nrDrxDN}
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1
    ...                                         parameter=${drxProfileNrAnr}
    ...                                         operation=update
    ...                                         connection=object_creation
    Sleep   5s
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-3
    ...                                         parameter=${drxProfileNrAnr}
    ...                                         operation=update
    ...                                         connection=object_creation
    Sleep   5s
    taf_admin.Create Delta    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxInactivityTimer    ${drx_timer}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxLongCycle    ${drxLongCycle}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-5    drxOnDurationTimer    ${drxOnDurationTimer}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxInactivityTimer    ${drx_timer_2}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxLongCycle    ${drxLongCycle_2}    delta_id=drxProfileRecommissioning
    taf_admin.Append Parameter Update To Delta
    ...     MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRDRX-6    drxOnDurationTimer    ${drxOnDurationTimer_2}    delta_id=drxProfileRecommissioning
    ${delta}    taf_admin.Get_Delta    delta_id=drxProfileRecommissioning
    taf_admin.Remove All Delta Id
    taf_admin.Perform Delta Recommissioning    ${delta}    connection=object_creation
    taf_admin.Teardown_Admin    connection=object_creation


Create Default Dedicated DRX profiles
    [Arguments]    ${drxControl}=any
    ${drxProfileNrAnr}=    get_params_for_drxProfileNrAnr_default    ${drxControl}
    ...                                                              ${GNB_ID}
    taf_admin.Setup_Admin      bts_host=${gNB_IP}    alias=object_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-1
    ...                                         parameter=${drxProfileNrAnr}
    ...                                         operation=update
    ...                                         connection=object_creation
    Sleep   5s
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-2
    ...                                         parameter=${drxProfileNrAnr}
    ...                                         operation=update
    ...                                         connection=object_creation
    Sleep   5s
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRCELL-3
    ...                                         parameter=${drxProfileNrAnr}
    ...                                         operation=update
    ...                                         connection=object_creation
    taf_admin.Teardown_Admin    alias=object_creation


Update Idle Time For NR Removal
    ${params}=    get_params_for_idleTimeForNrNbRemoval
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
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 1    BREAK
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-2
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    1


Both Nrrel And Nradjnrcell Should Exist For Two Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 3    BREAK
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-1   nradjnrcell_id=NRADJNRCELL-2
        Check Nrrel And Nradjrnrcell Objects Exist   nrrel_id=NRREL-2   nradjnrcell_id=NRADJNRCELL-3
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Sleep    5s


Both Nradjnrcell Should Exist For One Additional Cycle
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${current_syslog_path}   auto_removal=${TRUE}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 4    BREAK
        Check Both Nradjrnrcell Objects Exist
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    4
    Sleep    5s


Check Both Nradjrnrcell Objects Exist
    ${nradjnrcell_pattern_1}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-2
    ${nradjnrcell_pattern_2}   Set Variable   MRBTS-${GNB_ID}/NRBTS-${GNB_ID}/NRADJNRCELL-3
    taf_admin.Setup Admin      bts_host=${GNB_IP}    alias=nradj_status
    ${scfc_file}    taf_admin.Get Scf    connection=nradj_status
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern_1}
    Should Contain    ${scfc_file}   ${nradjnrcell_pattern_2}
    taf_admin.Teardown Admin    connection=nradj_status


Check NRREL Exists
    [Arguments]    ${gNB_ID}=${tl.gnbs[0].global_bts_id}    ${cell_id_1}=1
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    Should Contain    ${nrrel_status}    distName="MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id_1}/NRREL-25


Check If Both Nrrel Removed In Syslog
    Log To Console    \nChecking If NRREL Objects Removed Properly...
    Confirm Nrrel Removed   syslog_path=${current_syslog_path}

Check If Both Nradjnrcell Removed In Syslog
    Log To Console    \nChecking If NRADJNRCELL Objects Removed Properly...
    Confirm Nradjnrcell Removed    syslog_path=${current_syslog_path}


Check Dedicated DRX ANR HO
    Log To Console    \nChecking Syslog messages...
    Confirm Dedicated Drx Ho   syslog_path=${current_syslog_path}


Verify ANR Dedicated Drx HO
    Log To Console    \nChecking PCAP messages...
    Check Dedicated Drx Ho In Pcap   ${LOG_PATH}/${test_name}     ${test_name}     ${UE_1_DRX_1}    ${UE_1_DRX_2}    ${UE_1_DRX_3}


Start Collecting Logs
    Start Collecting Syslog   alias=5g_drx_gap_syslog
    Start Tcpdump On CU    filename=${test_name}_SCTP.pcap


Stop Collecting Logs
    Stop Collecting Syslog   alias=5g_drx_gap_syslog
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap
    Move File   ${LOG_PATH}/${test_name}_SCTP.pcap   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
    Set Test Variable   ${pcap_path}   ${LOG_PATH}/${test_name}/${test_name}_SCTP.pcap
