*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot
# Test Setup         Setup_for_EAR
Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  da_09_11

${delta_plan_da_09}  delta_plan_da_09.json
${delta_plan_da_10}  delta_plan_da_10.json

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_DA_09
# USCB006139-DA#B8 Additional feature interactions - UE SRS capability
    CB006139_Delta_Commission   file_name=${delta_plan_da_09}
    start_log_collection  cell_id=2  log_type=emil+syslog+snapshot

    Setup_eGate_Env
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==============================
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=50
    sleep  10
    log to console  \nSCells activated=============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    log to console  \nStart to trigger scell release due to RLQ===================
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep  10
    log to console  \nSCell-2 Released!============================================
    detrigger_scell_rlq_release
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    log to console  \nStart to trigger step-wise Scell Addition====================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900
    sleep  10
    log to console  \nSCell activated==============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    sleep  10

    detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    stop_log_collection  log_type=emil+syslog+snapshot

CB006139_DA_10
# USCB006139-DA#B8-ALT1: Periodic SRS resource reconfiguration in the DL&UL SCell further triggers CSI-RS switch in the cell
    CB006139_Delta_Commission   file_name=${delta_plan_da_10}
    start_log_collection  cell_id=2  log_type=emil+syslog+snapshot

    Setup_eGate_Env
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    mue_detach_with_power_off  2  41
    detrigger_scell_rlq_release

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==============================
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=50
    sleep  10
    log to console  \nSCells activated=============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    log to console  \nStart to trigger scell release due to RLQ====================
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep  2
    log to console  \nSCell-2 Released!============================================
    detrigger_scell_rlq_release
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    log to console  \nStart to attach enough UE to scell to consume all periodic SRS resources
    FOR  ${ue_id}  IN RANGE  2  36  1
        CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11_nonca_t2r4  ue_id=${ue_id}
        CB006139_Change_UE_Location  ue_id=${ue_id}  enb_id=2  cell_id=5
    END
    mue_attach_and_activate_pdu  2  36
    FOR  ${ue_id}  IN RANGE  36  41  1
        CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11_nonca_t1r1  ue_id=${ue_id}
        CB006139_Change_UE_Location  ue_id=${ue_id}  enb_id=2  cell_id=5
    END
    mue_attach_and_activate_pdu  36  41

    log to console  \nStart to trigger step-wise scell addition===================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=20
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    sleep  10

    detach_ue_with_power_off  ue_id=1
    mue_detach_with_power_off  2  41
    detrigger_scell_rlq_release

    stop_log_collection  log_type=emil+syslog+snapshot

CB006139_DA_11
# USCB006139-DA#B8-ALT2: SRS configuration update in PCell
    CB006139_Delta_Commission   file_name=${delta_plan_da_09}
    start_log_collection  cell_id=5  log_type=emil+syslog+snapshot

    Setup_eGate_Env
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11  ue_id=1
    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition=================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    log to console  \nSCells activated================================================
    stop_ue_big_data_traffic  ue_id=1
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2


    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep  2
    log to console  \nSCell-2 Released!===============================================
    detrigger_scell_rlq_release
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    log to console  \nStart to trigger step-wise Scell Addition=======================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900
    sleep  10
    log to console  \nSCell activated=================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    sleep  10

    detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    stop_log_collection  log_type=emil+syslog+snapshot