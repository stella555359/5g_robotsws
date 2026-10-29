*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_EAR
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  da_01_05

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}

CB006139_DA_01
# CB006139_DA_01_Common _Preconditions_Verification_on_webEM
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98339

    Log to Console  \nStart to Configure to disable CB006139
    @{gnb_para_list}     Create List
    ...  actBufferBasedSCellAddition  sCellExcludelistTimerFr1
    ...  actSCellReleaseBadSCellRlq  sCellDeactivationBadRlqCount  actSCellReleaseForInactiveSCell
    ...  actHighestEstNrTputBcSel  sCellActivationMethod
    @{gnb_mo_list}       Create List
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    @{gnb_value_list}    Create List
    ...  oneShot_Dl_Fr1  20
    ...  enabled_Fr1  100  disabled
    ...  true  blind
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

    Log to Console  \nStart to Configure to enable CB006139
    @{gnb_para_list}     Create List
    ...  actBufferBasedSCellAddition  sCellExcludelistTimerFr1
    ...  actSCellReleaseBadSCellRlq  sCellDeactivationBadRlqCount  actSCellReleaseForInactiveSCell
    ...  actHighestEstNrTputBcSel  sCellActivationMethod
    @{gnb_mo_list}       Create List
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    ...  MRBTS-1/NRBTS-1  MRBTS-1/NRBTS-1
    @{gnb_value_list}    Create List
    ...  oneShot_stepWise_Dl_Fr1  10
    ...  enabled_Fr1  1  disabled
    ...  true  blind
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_DA_02
# CB006139_DA_02_Buffer-based_step-wise_NR_FR1_SCell_addition_feature_activation
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98340

    Setup_eGate_Env
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    # CB006139_Change_UE_Capability  ${ue_capability_6cc_normal}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc_normal  ue_id=1
    Run Keyword And Ignore Error
    ...  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release

    # start_log_collection  cell_id=6

    Log to Console  \nStart to Configure to disable CB006139
    CB006139_Change_actBufferBasedSCellAddition  value=oneShot_Dl_Fr1

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    log to console  \nSCells activated
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    Log to Console  \nStart to Configure to enable CB006139
    CB006139_Change_actBufferBasedSCellAddition  value=oneShot_stepWise_Dl_Fr1

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    log to console  \nSCells activated
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    detach_ue_with_power_off  ue_id=1

    # stop_log_collection


CB006139_DA_03
# USCB006139-DA#B4 Step-wise SCell Addition accompanied with CSI-RS downgrade in PCell
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98341

    start_log_collection  cell_id=6  log_type=emil+syslog+snapshot

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 250 to 0===========================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=0

    sleep  30
    Setup_eGate_Env
    Run Keyword And Ignore Error  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    # CB006139_Change_UE_Capability  ${ue_capability_da_03_05}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_03_05  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition====================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=10
    sleep  10
    log to console  \nSCells activated===================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    detrigger_scell_rlq_release

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 0 to 250===========================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=250

    log to console  \nStart to trigger step-wise SCell Addition==========================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  10
    log to console  \nSCells activated===================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    stop_log_collection  log_type=emil+syslog+snapshot

CB006139_DA_04
# USCB006139-DA#B4-ALT1 //Only CSI-RS downgrade in PCell is possible because CSI-RS number > 1 in PCell only
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98342

    start_log_collection  cell_id=6  log_type=emil+syslog+snapshot
    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 250 to 0============================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=0

    Setup_eGate_Env
    Run Keyword And Ignore Error  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    # CB006139_Change_UE_Capability  ${ue_capability_da_04}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_04  ue_id=1


    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition======================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=10
    sleep  10
    log to console  \nSCells activated======================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    detrigger_scell_rlq_release

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 0 to 250==============================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=250

    log to console  \nStart to trigger step-wise SCell Addition=============================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  10
    log to console  \nSCells activated======================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10

    detach_ue_with_power_off  ue_id=1
    stop_log_collection  log_type=emil+syslog+snapshot

CB006139_DA_05
# USCB006139-DA#B4-ALT3 // CB013742 is enabled
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_98343

    start_log_collection  cell_id=6  log_type=emil+syslog+snapshot

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 250 to 0=================================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=0
    @{value}  create_list  true  true
    CB006139_Change_actEnhRrcReconfUlPrbRandom  value=@{value}

    Setup_eGate_Env
    Run Keyword And Ignore Error  detach_ue_with_power_off  ue_id=1
    detrigger_scell_rlq_release
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    # CB006139_Change_UE_Capability  ${ue_capability_da_03_05}  ue_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_03_05  ue_id=1


    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=10
    sleep  10
    log to console  \nSCells activated=========================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    log to console  \nStart to trigger scell release due to RLQ=======================
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    detrigger_scell_rlq_release

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 0 to 250=================================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=250

    log to console  \nStart to trigger step-wise SCell Addition================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  10
    log to console  \nSCells activated=========================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    stop_log_collection  log_type=emil+syslog+snapshot