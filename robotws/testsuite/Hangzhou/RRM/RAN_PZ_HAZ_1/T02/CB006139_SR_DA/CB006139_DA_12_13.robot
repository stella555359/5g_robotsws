*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_EAR
Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF   CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  da_12_13

${delta_plan_da_12}  delta_plan_da_12.json
${delta_plan_da_13}  delta_plan_da_13.json

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_DA_12
# USCB006139-DA#B9 Step-wise SCell Addition accompanied with aCSI release in PCell
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98350

    CB006139_Delta_Commission   file_name=${delta_plan_da_12}

    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell-7 to 0
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=0

    # Delta_plan may trigger RAT reset, so put start_log_collection after it
    start_log_collection  cell_id=6

    Setup_eGate_Env
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    # CB006139_Change_UE_Capability  ${ue_capability_da_12}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_12  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition=============================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=10
    sleep  10
    log to console  \nSCells activated============================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    detrigger_scell_rlq_release

    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell-7 to 250
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=250
    log to console  \nStart to trigger step-wise Scell Addition===================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  60
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    stop_log_collection

CB006139_DA_13
# USCB006139-DA#B9-ALT1 Step-wise SCell Addition accompanied with aCSI release in FDD PCell
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98351

    CB006139_Delta_Commission   file_name=${delta_plan_da_13}
    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell2 to 0=====================
    CB006139_Change_maxNumOfSCellAlloc  cell_id=2  value=0

    # Delta_plan may trigger RAT reset, so put start_log_collection after it
    start_log_collection  cell_id=2

    Setup_eGate_Env
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    # CB006139_Change_UE_Capability  ${ue_capability_da_13}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_13  ue_id=1

    sleep  1
    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=10
    sleep  10
    log to console  \nSCells activated=========================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    detrigger_scell_rlq_release

    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell2 to 250===================
    CB006139_Change_maxNumOfSCellAlloc  cell_id=2  value=250
    log to console  \nStart to trigger step-wise Scell Addition===================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    stop_log_collection