*** Settings ***
Documentation
...    author:  Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     taf.sw.syslog   WITH NAME   taf_syslog
Library     ta_attenuator
Library     ute_ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf_admin
Library     ./test_specific_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.anr_utils
Library     OperatingSystem
Library     DateTime
Library     testsuite/Wroclaw/RRM/resources/webUI_operations.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot

*** Variables ***
${NRADJNRCELL}      ${EMPTY}
${LOG_PATH}         ${OUTPUT DIR}
${gNB_IP}           ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${gNB_ID}           ${tl.gnbs[0].global_bts_id}
${VM_IP}            ${tl.test_pc.default_ssh_connection_details.addr}
${syslog_path}      syslog/syslog_5g.log
${syslog_path_ho}      syslog/syslog_5g_2.log
${syslog_count_path}    syslog/syslog_5g_cycles_count.log

*** Keywords ***
Test Setup
    [Arguments]    ${d_tc08}=${FALSE}    ${d_tc07}=${FALSE}    ${d_tc01}=${FALSE}    ${require_ue}=${FALSE}    ${syslog}=${FALSE}
    ...            ${disable_removal}=${FALSE}
    Set Test Variables    ${d_tc01}    ${d_tc07}    ${d_tc08}    ${require_ue}    ${syslog}    ${disable_removal}
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    Delete All NRELLs
    Collect SCF Before Test
    IF    ${d_tc07}    Set Initial Parameters for 5GC001296_D_TC07
    IF    ${d_tc01}    Set Initial Parameters for 5GC001296-D_001_B_B1
    IF    ${d_tc08}    Set Initial Parameters for 5GC001296_D_TC08
    IF    ${require_ue}    Prepare Ue
    IF    ${syslog}    Start Collecting Syslog
    Setup Admin For Relation Check


Test Teardown
    Run Keyword And Ignore Error    Stop Collecting Syslog
    Run Keyword If Test Failed    Log To Console    Collecting BTS Snapshot!
    Make Snapshot In Case Of Error
    Add Scout Scf Id To Test Data
    IF   ${require_ue}    Run Keyword And Ignore Error    Detach Ue    UE_1
    Run Keyword And Ignore Error    Release Attenuator
    Run Keyword And Ignore Error    Delete All NRELLs
    IF    ${d_tc08}    Create NRANRPR_1
    IF    ${disable_removal}    Disable Auto Removal Param
    Run Keyword And Ignore Error    taf_admin.Teardown All Aliases For Admin
    Run Keyword And Ignore Error    taf_admin.Teardown Admin    connection=admin_gnb
    Run Keyword And Ignore Error    interface.Common Step Trigger


Set Test Variables
    [Arguments]    ${d_tc01}    ${d_tc07}    ${d_tc08}    ${require_ue}    ${syslog}    ${disable_removal}
    Set Test Variable    ${d_tc01}    ${d_tc01}
    Set Test Variable    ${d_tc07}    ${d_tc07}
    Set Test Variable    ${d_tc08}    ${d_tc08}
    Set Test Variable    ${require_ue}    ${require_ue}
    Set Test Variable    ${syslog}    ${syslog}
    Set Test Variable    ${disable_removal}    ${disable_removal}


Setup Admin For Relation Check
    taf_admin.Setup Admin    bts_host=${gNB_IP}     name=nrrel_status


Collect SCF Before Test
    taf_admin.Setup Admin    bts_host=${gNB_IP}     name=admin_gnb
    Log To Console    \nCollecting Backup SCF
    taf_admin.Get Current Scf File  ${LOG_PATH}/${test_name}/scf/  backup_scf.xml  timeout=60  connection=admin_gnb


Check Counters
    [Arguments]  @{counters}  ${cell_id}=1  ${expected_value}=1
    Collect Counters
    ${updated_counter_values}    Get Last Counter Values    @{counters}
    Cleanup All Downloaded Counter Files
    ${results}=  Check If Counters Increased  ${updated_counter_values}  cell_id=${cell_id}  expected_value=${expected_value}


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


[1]5GC001296-D_007_C_B2_Automatic_Neighbor_Removal_online_enable_and_change_of_removal_time
    Log To Console    \nStarting Test
    Check OnAir State And Start Syslog
    Create NRELL
    Check NRREL-1 exists
    Sleep    150s
    Update removal parameters at once 5GC001296_D_TC07
    Stop Collecting Syslog
    Log To Console    \nRemoval Parameters Updated, NRREL Should Exist For Three Cycles...
    Start Collecting Syslog For Cycles Count
    NRREL Should Exist For Three Cycles
    Stop Collecting Syslog For Cycles Count
    Log To Console    \nChecking if NRREL will be removed...
    Sleep    60s
    Check NRREL Not Exists
    Check All Removal Entries In Syslog
    Check If Fire Time Difference Correct
    Start Collecting Syslog     NAME=5g_2
    Set Initial Attenuation
    Attach UE    UE_1
    Trigger Inter-gNB HO
    Sleep   60s
    Check NRREL Exists
    Check NRADJNRCELL Exists
    Stop Collecting Syslog    NAME=5g_2
    Confirm Inter gNB HO  syslog_path=${LOG_PATH}/${test_name}/${syslog_path_ho}


[1]5GC001296-D_001_B_B1_Successful_Intra_Frequency_Inter_Du_PCI_Resolution_And_Neighbour_Addition_Without_SRB3
    Log To Console    \nStarting Test
    @{counters_1}=      Create List                    M55124C05001  M55124C05002  M55147C01001
    @{counters_2}=      Create List                    M55124C05001  M55124C05002
    @{counters_3}=      Create List                    M55147C01001
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_1}  expected_value=0
    Attach UE    UE_1
    Sleep   10s
    Trigger Inter-gNB HO
    Sleep   60s
    Check NRREL Exists
    Check NRADJNRCELL Exists
    Log To Console    \nChecking HO success
    Confirm Inter gNB HO  syslog_path=${LOG_PATH}/${test_name}/${syslog_path}
    Stop Collecting Syslog
    Detach UE    UE_1
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_2}
    Wait Until Keyword Succeeds  6x  60s              Check Counters  @{counters_3}
    Start Collecting Syslog     NAME=5g_2
    Create ADJ_NRPLMNSET_NSA
    Set Initial Attenuation
    Attach UE    UE_1
    Trigger Inter-gNB HO
    Log To Console    \nChecking HO success
    Stop Collecting Syslog    NAME=5g_2
    Confirm Inter gNB HO  syslog_path=${LOG_PATH}/${test_name}/${syslog_path_ho}


[1]5GC001296-D_008_D_EC1_NSA_Measurement_report_handling_when_ANR_profile_not_configured
    Log To Console    \nStarting Test
    Create NRANRPR_2 And Delete NRANRPR_1
    Attach UE    UE_1
    Sleep   10s
    Trigger Intra-gNB HO From Cell 1 to Cell 2
    Sleep   10s
    Log To Console    \nChecking UE drop msg in Syslog
    Confirm Ue Drop  syslog_path=${LOG_PATH}/${test_name}/${syslog_path}


Set Initial Attenuation
    ${cell_list}=   Create list   GNB_1_CELL_1    GNB_1_CELL_2  GNB_2_CELL_1   GNB_2_CELL_2
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    Set Attenuation    ${CELL_1_ALIAS}    0dB
    Set Attenuation    ${CELL_2_ALIAS}    90dB
    Set Attenuation    ${CELL_3_ALIAS}    90dB
    Set Attenuation    ${CELL_4_ALIAS}    90dB
    Sleep  2s


Start Collecting Syslog
    [Arguments]    ${NAME}=5g
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}  Set Variable  ${LOG_PATH}/${test_name}/syslog/
    taf_syslog.Start Syslog    log_dir=${CURRENT_SYSLOG_PATH}    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...    host_ip=${VM_IP}    ports=${ports}    alias=${NAME}    virtualenv_dir=/home/ute/test_repo


Stop Collecting Syslog
    [Arguments]    ${NAME}=5g
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${NAME}
    RETURN      ${file_path}


Start Collecting Syslog For Cycles Count
    [Arguments]    ${NAME}=5g_cycles_count
    ${ports}=   Create List   51000    51001    51003    50011
    ${CURRENT_SYSLOG_PATH}    Set Variable    ${LOG_PATH}/${test_name}/syslog/
    taf_syslog.Start Syslog    log_dir=${CURRENT_SYSLOG_PATH}    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...    host_ip=${VM_IP}    ports=${ports}    alias=${NAME}    virtualenv_dir=/home/ute/test_repo


Stop Collecting Syslog For Cycles Count
    [Arguments]    ${NAME}=5g_cycles_count
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${NAME}
    RETURN      ${file_path}


Check OnAir State And Start Syslog
    Start Collecting Syslog
    Wait For X2 Link Available    cells_up
    Log To Console    \ngNB On air


Prepare Ue
    Set Initial Attenuation
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Detach Ue     UE_1


Release Attenuator
    Set Attenuation For All Cells  90dB
    Release attenuator cell    ${gnb_cells}


Trigger Intra-gNB HO From Cell 1 to Cell 2
    Set Attenuation    GNB_1_CELL_1    0db
    Set Attenuation    GNB_1_CELL_2    30db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END


Trigger Inter-gNB HO
    Log To Console    \nStarting Inter-gNB Handover...
    Set Attenuation    GNB_2_CELL_1    10db
    FOR    ${i}  IN RANGE  0  90  2
        Set Attenuation  GNB_1_CELL_1  ${i}db
        Sleep  1s
    END


Set Initial Parameters for 5GC001296_D_TC07
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Create_Delta    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1    actSib1ForNsaCell    true    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-2    actSib1ForNsaCell    true    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-3    actSib1ForNsaCell    true    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actIntraFreqIntraGnbMobilityNSA    true    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    anrThresRsrpNbCell    -140    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actNsaUeBasedAnrNr    true    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   srb3SupportEnabled    false    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   idleTimeForNrNbRemoval    2    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1   actAutoNrNbRemoval    false    delta_id=TC07_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   maxNumAnrNrrelAllowed    10    delta_id=TC07_D_delta
    ${delta}    taf_admin.Get_Delta    delta_id=TC07_D_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Set Initial Parameters for 5GC001296-D_001_B_B1
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Create_Delta    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   srb3SupportEnabled    false    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actIntraFreqIntraGnbMobilityNSA    true    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    anrThresRsrpNbCell    -140    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actNsaUeBasedAnrNr    true    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   idleTimeForNrNbRemoval    3    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1   actAutoNrNbRemoval    true    delta_id=D_001_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   maxNumAnrNrrelAllowed    10    delta_id=D_001_delta
    ${delta}    taf_admin.Get_Delta    delta_id=D_001_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Set Initial Parameters for 5GC001296_D_TC08
    Log To Console    \nSetting Up Initial Parameters
    taf_admin.Create_Delta    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actIntraFreqIntraGnbMobilityNSA    true    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    anrThresRsrpNbCell    -140    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}    actNsaUeBasedAnrNr    true    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   idleTimeForNrNbRemoval    2    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1   actAutoNrNbRemoval    true    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   maxNumAnrNrrelAllowed    10    delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   actNsaUeBasedInterFreqAnrNr   false   delta_id=TC08_D_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   actSaUeBasedInterFreqAnrNr   false   delta_id=TC08_D_delta
    taf_admin.append_managed_object_to_delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    delete   delta_id=TC08_D_delta
    ${delta}    taf_admin.Get_Delta    delta_id=TC08_D_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Wait For X2 Link Available
    [Arguments]  ${admin_alias}
    taf_admin.Setup Admin    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    taf_admin.Teardown Admin    connection=${admin_alias}


Create NRANRPR_2 And Delete NRANRPR_1
    Log To Console    \nCreating New NRANRPR
    taf_admin.Create_Delta    delta_id=NRANRPR_delta
    taf_admin.append_managed_object_to_delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    create  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    anrThresholdSelector	RSRP  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    anrThresRsrpNbCell	-140  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    cellDepMode	 SA+NSA	  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    consecRecheckForNrNbRemoval  5  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    idleTimeForNrNbRemoval	2     delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    maxNumAnrNrrelAllowed	50  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    nrAnrPrId	2      delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    ssbFrequency  64666   delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    nrarfcn  176500   delta_id=NRANRPR_delta
    taf_admin.append_managed_object_to_delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    delete  delta_id=NRANRPR_delta
    ${delta}    taf_admin.Get_Delta    delta_id=NRANRPR_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Create NRANRPR_1
    Log To Console    \nCreating New NRANRPR
    taf_admin.Create_Delta    delta_id=NRANRPR_delta
    taf_admin.append_managed_object_to_delta    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    create  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    anrThresholdSelector  RSRP  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    anrThresRsrpNbCell	 -140  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    cellDepMode	 SA+NSA	  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    consecRecheckForNrNbRemoval  5  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    idleTimeForNrNbRemoval	 2  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    maxNumAnrNrrelAllowed	50  delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1    nrAnrPrId	1      delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    ssbFrequency  176670   delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-2    anrThresRsrqNbCell  -24   delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   actNsaUeBasedInterFreqAnrNr   true   delta_id=NRANRPR_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}   actSaUeBasedInterFreqAnrNr   true   delta_id=NRANRPR_delta
    ${delta}    taf_admin.Get_Delta    delta_id=NRANRPR_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Update removal parameters at once 5GC001296_D_TC07
    taf_admin.Create_Delta    delta_id=TC07_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-1/NRREL-1    removeNotAllowed    false    delta_id=TC07_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANRPR-1   idleTimeForNrNbRemoval    3    delta_id=TC07_delta
    taf_admin.Append_Parameter_Update_To_Delta  MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRANR-1   actAutoNrNbRemoval    true    delta_id=TC07_delta
    ${delta}    taf_admin.Get_Delta    delta_id=TC07_delta
    taf_admin.Remove_All_Delta_Id
    taf_admin.Perform_Delta_Recommissioning    ${delta}    connection=admin_gnb
    Wait For X2 Link Available    cells_up


Create NRELL
    [Arguments]   ${cell_id}=1
    ${params}=    get_params_for_nrrel0
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrrel_creation
    taf_admin.Perform_Object_Recommissioning    dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=create
    ...                                         connection=nrrel_creation
    taf_admin.Teardown Admin    connection=nrrel_creation


Create ADJ_NRPLMNSET_NSA
    ${params}=    get_params_for_nrplmnset
    Log To Console    \nCreating ADJ_NRPLMNSET_NSA object...
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrplmnset_creation
    ${release}    taf_admin.Get SW Release Name    connection=nrplmnset_creation
    Log To Console    ${release}
    Run Keyword If
    ...     '${release}'=='SBTS23R3' or '${release}'=='SBTS23R4'    taf_admin.Perform_Object_Recommissioning
    ...                                 dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-12288/ADJ_NRPLMNSET_NSA-1
    ...                                 parameter=${params}
    ...                                 operation=create
    ...                                 connection=nrplmnset_creation
    taf_admin.Teardown Admin    connection=nrplmnset_creation


Delete All NRELLs
    [Arguments]    ${cell_1_id}=1    ${dist_name}=${NRADJNRCELL}
    taf_admin.Setup Admin      bts_host=${gNB_IP}    name=nrrel_del
    ${params}=    get_empty_list
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-255
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-256
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_1_id}/NRREL-1
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=${dist_name}
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    Run Keyword And Ignore Error   taf_admin.Perform_Object_Recommissioning
    ...                                         dist_name=MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-12288
    ...                                         parameter=${params}
    ...                                         operation=delete
    ...                                         connection=nrrel_del
    taf_admin.Teardown Admin    connection=nrrel_del


Check NRREL Exists
    [Arguments]    ${cell_id_1}=1
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    Should Contain    ${nrrel_status}    distName="MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id_1}/NRREL-25


Check NRADJNRCELL Exists
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    ${distname}    Should Match Regexp    ${nrrel_status}    MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRADJNRCELL-\[0-9]{2,}
    Should Contain    ${nrrel_status}    ${distname}
    Set Test Variable    ${NRADJNRCELL}    ${distname}


Check NRREL-1 Exists
    [Arguments]    ${cell_id}=1
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    Should Contain    ${nrrel_status}    distName="MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}/NRREL-1


Check NRREL Not Exists
    [Arguments]    ${cell_id}=1
    ${nrrel_status}    taf_admin.Get Scf    connection=nrrel_status
    Should Not Contain    ${nrrel_status}    distName="MRBTS-${gNB_ID}/NRBTS-${gNB_ID}/NRCELL-${cell_id}/NRREL-1


NRREL Should Exist For Three Cycles
    FOR    ${i}    IN RANGE    200
        ${fire_counter}=    Count Fires    syslog_path=${LOG_PATH}/${test_name}/${syslog_count_path}
        ${date}  Get Current Date
        Log To Console   ${fire_counter}:${date}
        IF    ${fire_counter} == 3    BREAK
        Check NRREL-1 Exists
        Sleep    60s
    END
    Should Be Equal As Integers    ${fire_counter}    3
    Sleep    5s


Check If Fire Time Difference Correct
    Check Time Difference    syslog_path=${LOG_PATH}/${test_name}/${syslog_path}


Check All Removal Entries In Syslog
    Check Removal Entries In Syslog    syslog_path=${LOG_PATH}/${test_name}/${syslog_count_path}
