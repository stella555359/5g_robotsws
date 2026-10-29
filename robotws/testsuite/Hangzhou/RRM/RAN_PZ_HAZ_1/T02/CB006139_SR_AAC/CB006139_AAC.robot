*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag}  aac

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag}


Load_Delta_Configuration
    ${delta_plan_03_04}  set variable  delta_plan_03_04.json
    CB006139_Delta_Commission   file_name=${delta_plan_03_04}

CB006139_AAC_03_04
# CB006139_AAC_03_CA_Time of usability_Scell_Change_DL
# CB006139_AAC_04_CA_Time of usability_Scell_Change_UL
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    ${delta_plan_03_04}  set variable  delta_plan_03_04.json
    CB006139_Delta_Commission   file_name=${delta_plan_03_04}

    start_log_collection    cell_id=2

    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule34_1.txt
    ...                                                     wait_for_next_counter_generate=${TRUE}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_03_04  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    log to console  \nStart to trigger NR Measurement Report A1 for FDD SCell Addition========================================
    ${meas_conf}  CB006139_Get_UE_NR_Measurement_Configuraiton  ue_id=1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s

    log to console  \nStart to trigger FDD SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    log to console  \nSCells activated=========================================================================
    ${start_time}=  CB006139_Get_Current_Time
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    log to console  \nStart to trigger NR Measurement Report A1 for TDD SCell Addition========================================
    ${meas_conf}  CB006139_Get_UE_NR_Measurement_Configuraiton  ue_id=1
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=76 phycell_id=52
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s

    ${end_time}=  CB006139_Get_Current_Time
    ${duration}=  Evaluate  ${end_time}-${start_time}
    log to console  \nPCELL_DL_2_SCELL_CONFIG_DUR_SA/PCELL_UL_0_SCELL_CONFIG_DUR_SA shoul be greater than ${duration}
    ${start_time}  Set Variable  ${end_time}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule34_2.txt
    ...                                                     wait_for_next_counter_generate=${False}

    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    detach_ue_with_power_off  ue_id=1
    ${end_time}=  CB006139_Get_Current_Time
    ${duration}=  Evaluate  ${end_time}-${start_time}
    log to console  \nPCELL_DL_3_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA shoul be greater than ${duration}

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139


CB006139_AAC_01
# [1]CB006139_AAC_01_CA_Time of usability_One_Shot_Scell_Addition_Intra_gNB_DL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    mue_detach_with_power_off    ue_id_start=1    ue_id_end=7
    delete_rlq_profile

    start_log_collection    cell_id=2

    Log to Console  Wait for new counter period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule1_1.txt
    ...                                                     wait_for_next_counter_generate=${True}

    FOR  ${num}  IN RANGE  1  7  1
        CB006139_Change_UE_Location  ue_id=${num}  enb_id=2  cell_id=2
        CB006139_Change_UE_Capability  ue_capability=ue_capability_${num}cc  ue_id=${num}
    END

    mue_attach_and_activate_pdu    ue_id_start=1    ue_id_end=7
    FOR  ${num}  IN RANGE  1  7  1
        start_ue_big_data_traffic  ue_id=${num}  dl_rate=300  ul_rate=30
    END
    sleep  180
    FOR  ${num}  IN RANGE  1  7  1
        ${scell_num}=   evaluate    ${num}-1
        verify_ue_dl_scell_status  ue_id=${num}  num_of_scells=${scell_num}
    END
    sleep  180

    FOR  ${num}  IN RANGE  1  7  1
        stop_ue_big_data_traffic  ue_id=${num}
    END
    sleep  5
    FOR  ${num}  IN RANGE  1  7  1
        ${scell_num}=   evaluate    ${num}-1
        verify_ue_dl_scell_status  ue_id=${num}  num_of_scells=${scell_num}
    END

    delete_rlq_profile
    mue_detach_with_power_off    ue_id_start=1    ue_id_end=7

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    Log to Console  Wait for new counter period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule1_2.txt
    ...                                                     wait_for_next_counter_generate=${True}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139

CB006139_AAC_02
# [1]CB006139_AAC_02_CA_Time of usability_One_Shot_Scell_Addition_Intra_gNB_UL
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    mue_detach_with_power_off    ue_id_start=1    ue_id_end=3
    delete_rlq_profile

    start_log_collection    cell_id=2

    Log to Console  Wait for new counter period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule2_1.txt
    ...                                                     wait_for_next_counter_generate=${True}

    FOR  ${num}  IN RANGE  1  3  1
        CB006139_Change_UE_Location  ue_id=${num}  enb_id=2  cell_id=2
        CB006139_Change_UE_Capability  ue_capability=ue_capability_${num}cc  ue_id=${num}
    END

    mue_attach_and_activate_pdu    ue_id_start=1    ue_id_end=3
    FOR  ${num}  IN RANGE  1  3  1
        start_ue_big_data_traffic  ue_id=${num}  dl_rate=300  ul_rate=30
    END
    sleep  180
    FOR  ${num}  IN RANGE  1  3  1
        ${scell_num}=   evaluate    ${num}-1
        verify_ue_ul_scell_status  ue_id=${num}  num_of_scells=${scell_num}
    END
    sleep  180

    FOR  ${num}  IN RANGE  1  3  1
        stop_ue_big_data_traffic  ue_id=${num}
    END
    sleep  5
    FOR  ${num}  IN RANGE  1  3  1
        ${scell_num}=   evaluate    ${num}-1
        verify_ue_ul_scell_status  ue_id=${num}  num_of_scells=${scell_num}
    END

    delete_rlq_profile
    mue_detach_with_power_off    ue_id_start=1    ue_id_end=3

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}


    Log to Console  Wait for new counter period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule2_2.txt
    ...                                                     wait_for_next_counter_generate=${True}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139


CB006139_AAC_05
# [1]CB006139_AAC_05_CA_Time of usability_Stepwise_Scell_Release
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    ${scell_list}  create list  1  3  5  6  7
    ${duration_list}  create list  0  0  0  0  0

    start_log_collection    cell_id=2

    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule5.txt
    ...                                                     wait_for_next_counter_generate=${TRUE}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=30
    sleep  5
    log to console  \nSCells activated=========================================================================
    ${start_time}=  CB006139_Get_Current_Time
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    FOR  ${num}  IN RANGE  5  0  -1
        sleep  60
        log to console  \nStart to trigger scell-${num} release due to RLQ======================================
        trigger_scell_rlq_release  ue_id=1  scell_id=${num}
        log to console  \nSCell-${num} Released===================================================================
        ${end_time}=  CB006139_Get_Current_Time
        ${duration}=  Evaluate  ${end_time}-${start_time}
        ${scell_num}=   Evaluate    ${num}-1
        Set List Value  ${duration_list}  ${scell_num}  ${duration}
        ${start_time}  Set Variable  ${end_time}
        detrigger_scell_rlq_release  ue_id=1  scell_id=${num}
        CB006139_Change_maxNumOfSCellAlloc  cell_id=${scell_list}[${scell_num}]  value=0
        verify_ue_dl_scell_status  ue_id=1  num_of_scells=${scell_num}
    END

    log to console  ${duration_list}
    delete_rlq_profile
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    stop_log_collection
    CB006139_Change_maxNumOfSCellAlloc_All  value=250

CB006139_AAC_10
# [1]CB006139_AAC_10_CA_Time of usability_Stepwise SCell Addition_Intra_gNB_CA
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection    cell_id=2

    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule10.txt
    ...                                                     wait_for_next_counter_generate=${TRUE}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 250 to 0===========================
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=0

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nStart to trigger SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=10
    sleep  10
    log to console  \nSCells activated=========================================================================
    ${start_time}=  CB006139_Get_Current_Time
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    trigger_scell_rlq_release  ue_id=1  scell_id=4
    log to console  \nSCell-4 Released===================================================================
    ${end_time}=  CB006139_Get_Current_Time
    ${duration}=  Evaluate  ${end_time}-${start_time}
    ${start_time}  Set Variable  ${end_time}
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    delete_rlq_profile
    log to console  \nPCELL_DL_4_SCELL_CONFIG_DUR_SA shoul be greater than ${duration}

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 0 to 250===========================
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=250

    log to console  \nStart to trigger SCell Addition==========================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=30
    sleep  10
    log to console  \nSCells activated===================================================================
    ${end_time}=  CB006139_Get_Current_Time
    ${duration}=  Evaluate  ${end_time}-${start_time}
    ${start_time}  Set Variable  ${end_time}
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    log to console  \nPCELL_DL_3_SCELL_CONFIG_DUR_SA shoul be greater than ${duration}

    log to console  ${duration_list}
    delete_rlq_profile
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    ${end_time}=  CB006139_Get_Current_Time
    ${duration}=  Evaluate  ${end_time}-${start_time}
    log to console  \nPCELL_DL_5_SCELL_CONFIG_DUR_SA shoul be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139

CB006139_AAC_09
# [1]CB006139_AAC_9_CA_Time of usability_RRC_Inactive_State_Transition
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    # CB006139_Change_srbinactivitytimer  20
    CB006139_Send_RRC_Inactivate_Command  ue_id=1
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    start_log_collection    cell_id=2

#######################  RRC Connected State to Inactivate State  #######################################
    log to console  Wait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule9_1.txt
    ...                                                     wait_for_next_counter_generate=${True}

    attach_ue_and_activate_pdu  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    stop_ue_big_data_traffic  ue_id=1
    sleep  65
    CB006139_Check_UE_State  ue_id=1  ue_state=UE_INACTIVE

    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

###################  Check SCell Counter Change to 0 after RRC State to Inactivate State  ###################
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule9_2.txt
    ...                                                     wait_for_next_counter_generate=${True}

    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

#######################  RRC Inactivate State to RRC Connected State  #######################################
    log to console  \nWait for next 5min counter measure period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     cudu_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule9_1.txt
    ...                                                     wait_for_next_counter_generate=${True}

    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    stop_ue_big_data_traffic  ue_id=1
    sleep  65
    CB006139_Check_UE_State  ue_id=1  ue_state=UE_INACTIVE
    detach_ue_with_power_off  ue_id=1

    log to console  \nWait for next 5min counter measure period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139


CB006139_AAC_06
# CB006139_AAC_06_CA_Time of usability_F1AP_UE_context_release_for_SCell_release_Inter_gNB_HO
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    start_log_collection    cell_id=2

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
    ${start_time}  CB006139_Get_Current_Time
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Verify Counters Values after UE Handover to simulated gNB
    log to console  \nStart to trigger NR Measurement Report A3 For Intra-Freq Ho======================================================
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A3
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=35 phycell_id=62 nrsrp_nr=50
    ...                   pass_regexp=XN Handover Successfully completed
    ...                   timeout=5s
    log to console  \n Intra-Freq Handover Successfully
    ${end_time}  CB006139_Get_Current_Time
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
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A3  report_on_leave=true
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=35 phycell_id=52 nrsrp_nr=50
    ...                   pass_regexp=XN Handover Successfully completed
    ...                   timeout=5s
    log to console  \n Intra-Freq Handover Successfully

    ${start_time}  CB006139_Get_Current_Time
    sleep  180

    detach_ue_with_power_off  ue_id=1

    ${end_time}    CB006139_Get_Current_Time
    ${duration}    Evaluate    ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139

CB006139_AAC_07
# CB006139_AAC_07_CA_Time of usability_F1AP_UE_context_release_for_SCell_release_Inter_RAT_HO
    # Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

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
    ${start_time}  CB006139_Get_Current_Time
    sleep  180
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Verify Counters Values after UE Handover to simulated eNB
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A2
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
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=300  event_type=B2
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=B2 srsrp_nr=36 phycell_id=11 nrsrp_nr=19 nrsrq_nr=17
    ...                   pass_regexp=IRAT Handover from NR to EUTRA completed
    ...                   timeout=5s
    log to console  \n Inter-RAT Handover from NR to EUTRAN Successfully!
    ${end_time}  CB006139_Get_Current_Time
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

    ${start_time}  CB006139_Get_Current_Time
    sleep  180

    detach_ue_with_power_off  ue_id=1

    ${end_time}    CB006139_Get_Current_Time
    ${duration}    Evaluate    ${end_time}-${start_time}
    log to console  \n PCELL_DL_5_SCELL_CONFIG_DUR_SA/PCELL_UL_1_SCELL_CONFIG_DUR_SA should be greater than ${duration}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    log to console  \n${value}

    [Teardown]  Teardown_for_CB006139

*** Keywords ***
CB006139_Change_maxNumOfSCellAlloc_All
    [Arguments]  ${value}
    @{gnb_para_list}          Create List    maxNumOfSCellAlloc  maxNumOfSCellAlloc  maxNumOfSCellAlloc
    ...                                      maxNumOfSCellAlloc  maxNumOfSCellAlloc
    @{gnb_mo_list}            Create List    MRBTS-1/NRBTS-1/NRCELL-1  MRBTS-1/NRBTS-1/NRCELL-3  MRBTS-1/NRBTS-1/NRCELL-5
    ...                                      MRBTS-1/NRBTS-1/NRCELL-6  MRBTS-1/NRBTS-1/NRCELL-7
    @{gnb_value_list}         Create List    ${value}  ${value}  ${value}  ${value}  ${value}
    CB006139_DA_Configuration  ${gnb_para_list}  ${gnb_mo_list}  ${gnb_value_list}