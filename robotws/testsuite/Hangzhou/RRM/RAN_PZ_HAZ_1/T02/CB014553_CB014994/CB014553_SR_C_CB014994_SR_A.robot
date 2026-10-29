*** Settings ***
Documentation
...                 author:  Guo Qianqian

Resource    ./Resource_CB014994.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource    ../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout

# Test Setup         Setup_for_CB014994
# Test Teardown      Teardown_for_CB014994

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ     CLOUD_5G_I_[MP][MP]_AP_[LOOO]

#*** Variables ***

*** Test Cases ***
[1]CB014994_SR_12_A-B2_Successful_UE_state_transition_from_CONNECTED_to_INACTIVE_triggered_by_UEAssistanceInformation
    [Documentation]
    ...    author: Guo Qianqian
    ...    UE1 and UE2 use the same UE capability.
    ...    UE1(support RRC Inactive) mapped to NRUEPROFILE-1 via chipsetid; UE1 mapped to NRUEPROFILE-2 via IMEISV;
    ...    UE1 mapped to NRUEPROFILE-3 via imeisvtac;UE1 mapped to NRUEPROFILE-5 via imesvtac-?
    ...    UE2(support RRC Inactive) mapped to NRUEPROFILE-1 via chipsetid; mapped to NRUEPROFILE-4 via IMEISV;
    ...    UE2 mapped to NRUEPROFILE-5 via imesvtac-?.
    ...    NRBTS/RRCINACT_UEPROFILE-1 configured with nrUeProfileDN=MRBTS/NRBTS/NRUEPROFILE-2;
    ...    rrcInactStateAllowed=True.
    ...    NRBTS.maxUeRrcInactTimeS=60min;NRBTS.t380=30min;NRBTS.maxUeRrcInactTime=60min;
    ...    actRrcReleasePreference=true;NRBTS.outOfConnectedPreference=inactive;
    ...    DRB14:drbRrcInactInactivityTimerSA=65s;drbInactivityTimerSA=75s;
    ...    NRBTS.srbinactivitytimerSA=300s;

    [Tags]    CRT    CASE12
    Load_Configuration
    #Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1-2
    delete_rlq_profile
    Log to Console  \n Change_UE_Location to cell3
    Execute Egate Command    cmd=ue_change_location id=1-2 enb=2 cell=3
    #log to console    \n Start log: emil+syslog+snapshot
    #start_log_collection    cell_id=3
#######################  RRC Connected State to Inactivate State  #######################################
    #log to console  \n Wait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_case12.txt
    ...                                                     wait_for_next_counter_generate=${True}
    log to console    \nEnable IMEISV for all UEs
    Execute Egate Command    cmd=amf_dl_nas_transport_param id=1 ue=all include_masked_imeisv=on
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=all include_masked_imeisv=on
    Execute Egate Command    cmd=amf_param id=1 send_ics_registration=on
    Log to Console  \n Pre-condition for trigger RRC_INACTIVE
    CB014994_Send_RRC_Inactivate_Command    ue_id=all
    log to console  \n attach UE1 and UE2 with PDU
    Execute Egate Command    cmd=ue_register id=1-2
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    sleep  2
    Execute Egate Command    cmd=set_pdu_param ue=1-2 pdu=1 trf_type=internal
    ...    pass_regexp=EGATE>
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1-2 nwslice=1 gw=1
    ...    pass_regexp=rrcReconfigurationComplete
    sleep  20
    log to console    \n Trigger UE to RRC_INACTIVE based on UE assistance information
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=1 PreferredRRCState=inactive
    ...    pass_regexp=UE1: Is INACTIVE
    sleep  10
    Execute Egate Command    cmd=ue_assistance_send_nr ue_id=2 PreferredRRCState=inactive
    ...    pass_regexp=EGATE>
    sleep  10
    log to console    \n Check UE1 state
    CB014994_Check_UE_State  ue_id=1  ue_state=UE_INACTIVE
    log to console    \n Check UE2 state
    CB014994_Check_UE_State  ue_id=2  ue_state=IDLE
    Execute Egate Command    cmd=exit
    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}
    [Teardown]  Teardown_for_CB014994

[1]CB014994_SR_13_A-B3_from_CONNECTED_to_RRC_INACTIVE_based_on_RRCINACT_UEPROFILE_with_empty_imeisvList_or_empty_chipsetIdList
    [Documentation]
    ...    author: Guo Qianqian
    ...    UE1(support RRC Inactive) mapped to NRUEPROFILE-1 via chipsetid; mapped to NRUEPROFILE-2 via IMEISV;
    ...    UE1 mapped to NRUEPROFILE-3 via chipsetid and IMEISV.
    ...    UE40(support RRC Inactive, with empty IMEISV and empty Chipset ID) mapped to NRUEPROFILE-0;
    ...    NRBTS/RRCINACT_UEPROFILE-1 configured with nrUeProfileDN=MRBTS/NRBTS/NRUEPROFILE-0;
    ...    rrcInactStateAllowed=False.
    ...    NRBTS.maxUeRrcInactTimeS=60min;
    [Tags]    CRT    CASE13
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1,40
    delete_rlq_profile
    log to console    \nEnable IMEISV for UE1 and UE2
    Enable_imeisv_for_UEs    ue_id=all
    # CB014994_Change_srbinactivitytimer  20
    CB014994_Send_RRC_Inactivate_Command  ue_id=all
    CB014994_Change_UE_Location  ue_id=1,40  enb_id=2  cell_id=3
    log to console    \n Start log: emil+syslog+snapshot
    start_log_collection    cell_id=3

    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)>=180
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)>=180
    ${rule_list}    Create List    ${rule1}  ${rule2}

    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}

    attach_ue_and_activate_pdu  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    ${start_time}  CB014994_Get_Current_Time
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Verify Counters Values after UE Handover to simulated gNB
    log to console  \nStart to trigger NR Measurement Report A3 For Intra-Freq Ho======================================================
    ${meas_id}  CB014994_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A3
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=35 phycell_id=62 nrsrp_nr=50
    ...                   pass_regexp=XN Handover Successfully completed
    ...                   timeout=5s
    log to console  \n Intra-Freq Handover Successfully
    ${end_time}  CB014994_Get_Current_Time
    ${duration}  Evaluate  ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    # Verify counter values during UE stay in simulated gNB
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)==0
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)==0
    ${rule_list}    Create List    ${rule1}  ${rule2}
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    # Verify Counter Values after UE Handover from simulated gNB
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)>=180
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)>=180
    ${rule_list}    Create List    ${rule1}  ${rule2}
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}
    log to console  \nStart to trigger NR Measurement Report A3 For Intra-Freq Ho======================================================
    ${meas_id}  CB014994_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A3  report_on_leave=true
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=35 phycell_id=52 nrsrp_nr=50
    ...                   pass_regexp=XN Handover Successfully completed
    ...                   timeout=5s
    log to console  \n Intra-Freq Handover Successfully

    ${start_time}  CB014994_Get_Current_Time
    sleep  180

    detach_ue_with_power_off  ue_id=1

    ${end_time}    CB014994_Get_Current_Time
    ${duration}    Evaluate    ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB014994

CB014994_AAC_07
# CB014994_AAC_07_CA_Time of usability_F1AP_UE_context_release_for_SCell_release_Inter_RAT_HO
    # Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB014994_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB014994_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    start_log_collection    cell_id=2

    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)>=185
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)>=185
    ${rule_list}    Create List    ${rule1}  ${rule2}
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}

    attach_ue_and_activate_pdu  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    ${start_time}  CB014994_Get_Current_Time
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Verify Counters Values after UE Handover to simulated eNB
    ${meas_id}  CB014994_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A2
    log to console  \nStart to trigger NR Measurement Report A2=====================================================================
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 phycell_id=52 srsrp_nr=31
    ...                   pass_regexp=rrcReconfigurationComplete
    ...                   timeout=5s
    sleep  5
    log to console  \nStart to trigger Handover from NR to EUTRAN======================================================
    ${meas_id}  CB014994_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=300  event_type=B2
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=B2 srsrp_nr=36 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...                   pass_regexp=IRAT Handover from NR to EUTRA completed
    ...                   timeout=5s
    log to console  \n Inter-RAT Handover from NR to EUTRAN Successfully!
    ${end_time}  CB014994_Get_Current_Time
    ${duration}  Evaluate  ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}
    sleep  5

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    # Verify counter values during UE stay in simulated eNB
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)==0
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)==0
    ${rule_list}    Create List    ${rule1}  ${rule2}
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    # Verify Counter Values after UE Handover from simulated eNB
    ${rule1}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00091;
    ...         Counter rule: sum(M55118C00091)>=180
    ${rule2}    Catenate
    ...         Distname: All;
    ...         Counter: M55118C00094;
    ...         Counter rule: sum(M55118C00094)>=180
    ${rule_list}    Create List    ${rule1}  ${rule2}
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${rule_list}
    ...                                                     wait_for_next_counter_generate=${True}
    log to console  \nStart to trigger Handover from EUTRAN to NR======================================================
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=gnb_trigger_inter_rat_handover_to_5g ue=1 target_gnb=2 target_cell=2 plmn=311:489
    ...                   pass_regexp=Inter-eNB handover from ENB-\\d+\.\\d+ to EXT_ENB-\\d+\.\\d+ performed
    ...                   timeout=5s
    log to console  \n Handover from EUTRAN to NR Successfully!

    ${start_time}  CB014994_Get_Current_Time
    sleep  180

    detach_ue_with_power_off  ue_id=1

    ${end_time}    CB014994_Get_Current_Time
    ${duration}    Evaluate    ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB014994

*** Keywords ***
Load_Configuration
    Setup_for_IntergNB  config_tag=2gnb

CB014994_Change_maxNumOfSCellAlloc_All
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    maxNumOfSCellAlloc  maxNumOfSCellAlloc  maxNumOfSCellAlloc
    ...                                      maxNumOfSCellAlloc  maxNumOfSCellAlloc
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1  MRBTS-1/NRBTS-1/NRCELL-3  MRBTS-1/NRBTS-1/NRCELL-5
    ...                                      MRBTS-1/NRBTS-1/NRCELL-6  MRBTS-1/NRBTS-1/NRCELL-7
    @{gnb_value_list}         Create List    ${value}  ${value}  ${value}  ${value}  ${value}
    CB014994_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}