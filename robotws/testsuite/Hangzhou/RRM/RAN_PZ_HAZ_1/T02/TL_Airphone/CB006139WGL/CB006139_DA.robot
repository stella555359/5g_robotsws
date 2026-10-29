*** Settings ***
Documentation
...                 author:  Wu Guoliang

Resource    ./Resource_CB006139.robot

Force Tags        CRT

*** Variables ***
${config_tag}  da_01_05

*** Test Cases ***
CB006139_DA_06_Stepwise_SCell_Addition_accompanied_with_refinement_beam_disabling
    #start_log_collection

    Setup_for_CB006139
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=6  value=0
    CB006139_Change_sCellInactivityReleaseTimer  cell_id=1  value=1
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5
    attach_ue_and_activate_pdu  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    # check scell_status - scell (1/2/3/4) added
    verify_ue_scell_status  ue_id=1  num_of_scells=4
    stop_ue_big_data_traffic  ue_id=1
    sleep  10

    CB006139_Change_MaxNumOfSCellAlloc  cell_id=6  value=250
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=10
    sleep  10
    # check scell_status - scell added (1/2/3/4/5)
    verify_ue_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1
    #stop_log_collection
    [Teardown]     HAZ TC02 Get SCF Internal Id By Scout    no_ute=False

*** Keywords ***
CB006139_Change_maxNumOfSCellAlloc
    [Arguments]  ${cell_id}  ${value}
    @{gnb_para_list}          Create List    maxNumOfSCellAlloc
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    @{gnb_value_list}         Create List    ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}

CB006139_Change_sCellInactivityReleaseTimer
    [Arguments]  ${cell_id}  ${value}
    @{gnb_para_list}          Create List    sCellInactivityReleaseTimer
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
    @{gnb_value_list}         Create List    ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}