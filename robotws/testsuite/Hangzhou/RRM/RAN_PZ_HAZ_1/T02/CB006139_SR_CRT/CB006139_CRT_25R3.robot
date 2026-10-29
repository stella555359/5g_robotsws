*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Test Cases ***
CB006139_DA_03
# USCB006139-DA#B4 Step-wise SCell Addition accompanied with CSI-RS downgrade in PCell
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_162778

    ${config_tag}  set variable  da_01_05
    Setup_for_CB006139  config_tag=${config_tag}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_03_05  ue_id=1

    start_log_collection

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 250 to 0===========================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=0
    CB006139_Change_sCellInactivityReleaseTimer  cell_id=5  value=1
    sleep  30

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5
    log to console  \nStart to trigger SCell Addition====================================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=600   ul_rate=50
    sleep  30
    log to console  \nSCells activated===================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # release TDD cell-5 (Scell-4)
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    log to console  \nSCell-4 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    log to console  \nStart to change "MaxNumOfSCellAlloc" value of Cell-7 from 0 to 250===========================
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=7  value=250

    log to console  \nStart to trigger step-wise SCell Addition==========================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  60
    log to console  \nSCells activated===================================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

CB006139_DA_09
# USCB006139-DA#B8 Additional feature interactions - UE SRS capability
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_162777

    ${config_tag}  set variable  da_09_11
    Setup_for_CB006139  config_tag=${config_tag}

    ${delta_plan_da_09}  set variable  delta_plan_da_09.json
    CB006139_Delta_Commission   file_name=${delta_plan_da_09}

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_09_11  ue_id=1

    start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5
    log to console  \nStart to trigger SCell Addition==============================
    start_ue_big_data_traffic  ue_id=1  dl_rate=600   ul_rate=50
    sleep  20
    log to console  \nSCells activated=============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    stop_ue_big_data_traffic  ue_id=1
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=100
    start_ue_ul_data_traffic  ue_id=1  trf_id=1  ul_rate=50
    log to console  \nStart to trigger scell release due to RLQ===================
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep  5
    log to console  \nSCell-2 Released!============================================
    delete_rlq_profile
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    log to console  \nStart to trigger step-wise Scell Addition====================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800
    sleep  60
    log to console  \nSCell activated==============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    sleep  10

    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    [Teardown]  Teardown_for_CB006139

CB006139_DA_12
# USCB006139-DA#B9 Step-wise SCell Addition accompanied with aCSI release in PCell
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_162779

    ${config_tag}  set variable  da_12_13
    Setup_for_CB006139  config_tag=${config_tag}

    ${delta_plan_da_12}  set variable  delta_plan_da_12.json
    CB006139_Delta_Commission   file_name=${delta_plan_da_12}

    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell-7 to 0
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=0
    CB006139_Change_sCellInactivityReleaseTimer  cell_id=3  value=1

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=6
    CB006139_Change_UE_Capability  ue_capability=ue_capability_da_12  ue_id=1

    start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5
    log to console  \nStart to trigger SCell Addition=============================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    log to console  \nSCells activated============================================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    stop_ue_big_data_traffic  ue_id=1
    log to console  \nSCell-3 Released===================================================================
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    log to console  \nStart to change "maxNumOfSCellAlloc" of Cell-7 to 250
    CB006139_Change_maxNumOfSCellAlloc  cell_id=7  value=250
    log to console  \nStart to trigger step-wise Scell Addition===================================
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  60
    log to console  \nSCell activated==============================================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

CB006139_DA_06_Stepwise_SCell_Addition_accompanied_with_refinement_beam_disabling
    [Documentation]
    ...    author: Wu Guoliang
    [Tags]    QC_164165

    Run  sudo ip addr add 10.0.1.30/24 dev eth3
    Run  sudo ip addr add 10.0.1.31/24 dev eth3

    Setup_for_CB006139  config_tag=da_06
    CB006139_Change_MaxNumOfSCellAlloc  cell_id=6  value=0
    CB006139_Change_sCellInactivityReleaseTimer  cell_id=1  value=1
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=5

    start_log_collection

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep  10
    # check scell_status - scell (1/2/3/4) added
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    stop_ue_big_data_traffic  ue_id=1
    sleep  10

    CB006139_Change_MaxNumOfSCellAlloc  cell_id=6  value=250
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=10
    sleep  60
    # check scell_status - scell added (1/2/3/4/5)
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    stop_ue_big_data_traffic  ue_id=1
    sleep  10
    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

# CB006139_CA_01
# # CB006139_CA_01_B1_Buffer_based_stepwise_SCell_addition_with_A1_measurement_based_Scells
#     [Documentation]
#     ...    author: Liu AnAn
#     [Tags]    QC_174861

#     ${config_tag}  set variable  ca_01
#     Setup_for_CB006139  config_tag=${config_tag}

#     start_log_collection

#     CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
#     CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

#     # PM_2113/PM_1631
#     Wait_for_Next_5min_Period
#     Counter Operation    operation=start_collect_counter    product_type=gnb
#     ...                                                     bts_index=0
#     ...                                                     counter_rule=${CURDIR}/counter_rule_ca01.txt
#     ...                                                     wait_for_next_counter_generate=${False}

#     #Step1-5:  UE send EventA1 for scell addition
#     attach_ue_and_activate_pdu  ue_id=1
#     sleep  5

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
#     sleep  2

#     start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
#     sleep  5
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
#     sleep  5
#     verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

#     #Step5-7  UE send EventA2 for scell-1 release
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Be Equal  ${meas_id}  ${None}
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=1 scell_rsrp=49
#     sleep  5
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
#     sleep  5
#     verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

#     #Step8-11: UE send EventA1 for scell-1 addition
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
#     Should Be Equal  ${meas_id}  ${None}
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
#     sleep  5
#     start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
#     sleep  30
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
#     sleep  5
#     verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

#     detach_ue_with_power_off  ue_id=1

#     Wait_for_Next_5min_Period
#     ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

#     [Teardown]  Teardown_for_CB006139

CB006139_CA_04
# CB006139_CA_04_B2_A1_measurement_behaviour_when_UE_has_reached_maximum_CCs_or_no_compatible_SCells_to_add
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181229

    ${config_tag}  set variable  ca_04
    Setup_for_CB006139  config_tag=${config_tag}

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_ca_04  ue_id=1
    CB006139_Change_maxNumOfSCellAlloc  cell_id=5  value=250

    # PM_2113/PM_1631
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_ca04.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-5: UE send EventA1 to add Scell-1 and SCell-2(Cell-5)
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  5
    ${start_time}  CB006139_Get_Current_Time
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    # Step6-7 UE send EventA2 for scell-2(Cell-5) release
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=2 scell_rsrp=49
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    # Step8-9: UE send EventA1 for scell addition
      # Decrease DL Data Transmission
    stop_ue_dl_data_traffic  ue_id=1  trf_id=3
    # start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=50   # Before PR854289
    # start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=50   # Before PR854289
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=10
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2  report_on_leave=False
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5

    # Step10: Change maxNumOfSCellAlloc for Cell-5 to not allow Cell-5 added as SCell
    CB006139_Change_maxNumOfSCellAlloc  cell_id=5  value=0
    sleep  10

    # Step10-11: Increase Data Transmission to add Cell-3 as Scell, but Cell-4 not SCell, it's difficult to control this
    # (Need do some adaption for CRT)-------------------------------------------
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=150
    sleep  5
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=150
    sleep  5
    FOR  ${i}  IN RANGE  1  15
        sleep  2
        ${rate}=  Evaluate  ${i}*10
        start_ue_dl_data_traffic  ue_id=1  trf_id=3  dl_rate=${rate}
        ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=2
        IF  ${scell_status} == ${True}  Exit For LOOP
    END
    # Skip to check dl scell number due to difficult to control to add one scell only
    # verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  10

    # ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A2  report_on_leave=False
    # Should Not Be Equal  ${meas_id}  ${None}
    # ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    # Should Not Be Equal  ${meas_id}  ${None}

    # Post: Increase DL Data Transmission to add Cell-4 as SCell
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=437090  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule   product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CA_08
# CB006139_CA_08_B5_A1_event_measurement_based_step-wise_SCell_Addition for UE already configured with SCells...
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181228

    ${config_tag}  set variable  ca_08
    Setup_for_CB006139  config_tag=${config_tag}

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    # PM_2113/PM_1631
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_ca08.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-9: UE send EventA1 for scell addition
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=100
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    # Step 10-11 Deactivated SCell-5
    create_rlq_profile
    trigger_scell_rlq_release  ue_id=1  scell_id=5
    sleep  10
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=5
    Should Be Equal  ${scell_status}  ${False}
    delete_rlq_profile

    # Step 13-15, Deactivated SCell-2 and SCell-4, and SCell-4 is released, but SCell-1/3 still Activated
    log to console  \nStart to reduce DL Data Transmission
    FOR  ${trf_id}  IN RANGE  12  2  -1
        Log to Console  \nUE1 Stop trf_id=${trf_id} DL Data Service
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_stop ue=1 pdu=1 qfi=1 trf_id=${trf_id} dir=dl
    END
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=150
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=50
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    ${scell_status}=  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
    Should Be Equal  ${scell_status}  ${False}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A2  report_on_leave=False
    Should Be Equal  ${meas_id}  ${None}
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=2
    Should Be Equal  ${scell_status}  ${False}
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=1
    Should Be Equal  ${scell_status}  ${True}
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=3
    Should Be Equal  ${scell_status}  ${True}

    # Step16-20: SCell-2 is reactivated after increasing data transmission
    # but SCell-4 not configured as A1 entry condition not meet
    log to console  \nUE Report A1 with Entry Condition for SCell Addition - Step 16
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5

    log to console  \nUE Report A1 with Leaving Condition - Step 17
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=50 phycell_id=52
    sleep  5

    log to console  \nStart to increase DL data transmission - Step 19
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=2
    Should Be Equal  ${scell_status}  ${True}
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # Step 21-24: SCell-5 still not be activated due to RLQ deactivation, but SCell-4 added back as SCell again.
    log to console  \nUE Report A1 with Entry Condition for SCell Addition - Step 22
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  20

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=5
    Should Be Equal  ${scell_status}  ${False}
    ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=5
    Should Be Equal  ${scell_status}  ${True}

    delete_rlq_profile
    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule   product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

# CB006139_CA_08_WR
# # CB006139_CA_08_B5_A1_event_measurement_based_step-wise_SCell_Addition for UE already configured with SCells...
#     [Documentation]
#     ...    author: Liu AnAn
#     [Tags]    QC_181228

#     ${config_tag}  set variable  ca_08
#     Setup_for_CB006139  config_tag=${config_tag}

#     start_log_collection

#     CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
#     CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

#     # PM_2113/PM_1631
#     Wait_for_Next_5min_Period
#     Counter Operation    operation=start_collect_counter    product_type=gnb
#     ...                                                     bts_index=0
#     ...                                                     counter_rule=${CURDIR}/counter_rule_ca08.txt
#     ...                                                     wait_for_next_counter_generate=${False}

#     # Step1-9: UE send EventA1 for scell addition
#     attach_ue_and_activate_pdu  ue_id=1
#     sleep  5

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
#     sleep  5
#     start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=100
#     sleep  5
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
#     sleep  5
#     verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

#     # Step 10-11 Deactivated SCell-5
#     create_rlq_profile
#     trigger_scell_rlq_release  ue_id=1  scell_id=5
#     sleep  10
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=5
#     Should Be Equal  ${scell_status}  ${False}
#     delete_rlq_profile

#     # Step 13-15, Deactivated SCell-2 and SCell-4, and SCell-4 is released, but SCell-1/3 still Activated
#     log to console  \nStart to reduce DL Data Transmission
#     FOR  ${trf_id}  IN RANGE  12  2  -1
#         Log to Console  \nUE1 Stop trf_id=${trf_id} DL Data Service
#         ute_wtssim.Execute Egate Command
#         ...    cmd=trf_data_stop ue=1 pdu=1 qfi=1 trf_id=${trf_id} dir=dl
#     END
#     #start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=100
#     #start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=10
#     stop_ue_big_data_traffic  ue_id=1
#     sleep  15
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
#     #sleep  15
#     #verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

#     ${scell_status}=  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
#     Should Be Equal  ${scell_status}  ${False}
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A2  report_on_leave=False
#     Should Be Equal  ${meas_id}  ${None}
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=2
#     Should Be Equal  ${scell_status}  ${False}
#     start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
#     sleep  5
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=1
#     Should Be Equal  ${scell_status}  ${True}
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=3
#     Should Be Equal  ${scell_status}  ${True}

#     # Step16-20: SCell-2 is reactivated after increasing data transmission
#     # but SCell-4 not configured as A1 entry condition not meet
#     log to console  \nUE Report A1 with Entry Condition for SCell Addition - Step 16
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     #${output}    Airphone Operation    operation=send_common_command
#     #...                   product_type=${None}
#     #...                   traffic_info_dic=${None}
#     #...                   tag=${None}
#     #...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
#     #sleep  5

#     log to console  \nUE Report A1 with Leaving Condition - Step 17
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=50 phycell_id=52
#     sleep  5

#     log to console  \nStart to increase DL data transmission - Step 19
#     start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
#     sleep  10
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=2
#     Should Be Equal  ${scell_status}  ${True}
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

#     # Step 21-24: SCell-5 still not be activated due to RLQ deactivation, but SCell-4 added back as SCell again.
#     log to console  \nUE Report A1 with Entry Condition for SCell Addition - Step 22
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
#     sleep  20

#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
#     ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=5
#     Should Be Equal  ${scell_status}  ${False}
#     ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=5
#     Should Be Equal  ${scell_status}  ${True}

#     delete_rlq_profile
#     detach_ue_with_power_off  ue_id=1

#     Wait_for_Next_5min_Period
#     ${value}    Counter Operation    operation=collect_counter_and_check_rule   product_type=gnb    bts_index=0    cudu_index=0

#     [Teardown]  Teardown_for_CB006139

# CB006139_CB_01
# # CB006139_CB_01_B1_Buffer_based_stepwise_SCell_addition_with_A4_measurement_based_Scells
#     [Documentation]
#     ...    author: Liu AnAn
#     [Tags]    QC_174857

#     # Key parameter: NRCELL-dlSCellConfigLevelNum=150, a4Fr1SupervisionTimer=10000, a4RetryTimerMultCa=1
#     ${config_tag}  set variable  cb_01
#     Setup_for_CB006139  config_tag=${config_tag}

#     ${output}    Airphone Operation    operation=send_common_command
#     ...                   product_type=${None}
#     ...                   traffic_info_dic=${None}
#     ...                   tag=${None}
#     ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

#     start_log_collection

#     CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
#     CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

#     # 5G_PM_2125
#     Wait_for_Next_5min_Period
#     Counter Operation    operation=start_collect_counter    product_type=gnb
#     ...                                                     bts_index=0
#     ...                                                     counter_rule=${CURDIR}/counter_rule_cb01.txt
#     ...                                                     wait_for_next_counter_generate=${False}

#     # Step1-4: UE send A4 for SCell-1(Cell-6) and SCell-2(Cell-1) Addition
#     attach_ue_and_activate_pdu  ue_id=1
#     sleep  5

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A4  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=56

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51

#     # Step5  Increase DL Data Transmission to Trigger SCell-1 and SCell-2 Addition
#     start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
#     sleep  5
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
#     sleep  5
#     verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A4  report_on_leave=True
#     Should Be Equal  ${meas_id}  ${None}
#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
#     Should Be Equal  ${meas_id}  ${None}

#     # Step6-7: UE send A4 for SCell-3(Cell-3) and SCell-4(Cell-5) Addition
#     ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A4  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55

#     # Step8-9:  Increase DL Data Transmission to Trigger SCell-3 Addition But Scell-4 not added as SCell
#     stop_ue_big_data_traffic  ue_id=1
#     start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
#     sleep  30
#     start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
#     # need wait data rate is stable, otherwise it will impact scell addition timing. Need fine-tune this together with
#     # NRCELL-dlSCellConfigLevel and NRCELL-dlSCellConfigLevelNum to ensure only Scell-3 added as Scell, but SCell-4 not
#     sleep  30
#     # Need retreive measurement id for A4 again, due to A4 maybe released after a4Fr1SupervisionTimer expired
#     ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

#     ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A4  report_on_leave=True
#     Should Not Be Equal  ${meas_id}  ${None}
#     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55

#     # CRT - Increase Data Transmission to ensure Scell-3 and SCell-4 added as Scell
#     start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
#     sleep  10
#     verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
#     sleep  10

#     # ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A4  report_on_leave=True
#     ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=640608
#     Should Not Be Equal  ${meas_id}  ${None}

#     detach_ue_with_power_off  ue_id=1

#     Wait_for_Next_5min_Period
#     ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

#     [Teardown]  Teardown_for_CB006139

CB006139_CB_04
# CB006139_CB_04_B2_Buffer_based_stepwise_SCell_addition_with_A1_and_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181237

    ${config_tag}  set variable  cb_04
    Setup_for_CB006139  config_tag=${config_tag}

    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=3

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb04.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-5: UE send A1 to add Cell-5/6/7 as SCell
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    # Step6-9: UE send A4 for SCell-1/3 and Cell-1/3 added as SCell
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    IF  ${meas_id} == ${None}
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    END
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
    sleep  10
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A4  report_on_leave=True
    IF  ${meas_id} == ${None}
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    END
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  30
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_06
# CB006139_CB_06_B3_behaviour_at_the_expiration_of_supervision_timer_and_retry_timer_when_CB006139_is_enabled
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181236

    ${config_tag}  set variable  cb_04
    Setup_for_CB006139  config_tag=${config_tag}

    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb06.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-5: UE send A1 to add Cell-5/6/7 as SCell
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    # start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50  # Before PR854289
    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}

    # Step6-9: add Cell-1(Scell-4) and Cell-3(Scell-5) as Scell in CRT
    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50

    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=427970
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    # Step10-13: At the expiration of supervision timer/At the expiration of retry timer, already checked in previous steps
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}

    # In CRT, to report A2 for SCell-5 release to meet the requirement
    # i.e. only Cell-1(Scell-4) added as Scell, but Cell-3(Scell-5) not added as SCell
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=5 scell_rsrp=49
    sleep  10

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_07
# CB006139_CB_07_B4_A4_measurement_configuration_behaviour_during_partial_SCell_release
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181235

    ${config_tag}  set variable  cb_04
    Setup_for_CB006139  config_tag=${config_tag}

    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb07.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-5: UE send A1 to add Cell-5/6/7 as SCell
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Step6-9: add Cell-1(Scell-4) and Cell-3(Scell-5) as Scell in CRT
    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50

    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=427970
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    # Step10-13: Send A2 report to SCell-5 and later send A2 report to SCell-4 to check partial_SCell_release
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=5 scell_rsrp=49
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=4 scell_rsrp=49
    sleep  10

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Wait for retry expiry
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}

    # Wait for supervision timer expiry
    sleep  10
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_08
# CB006139_CB_08_B5_A4_measurement_configuration_behaviour_when_UE_has_reached_maximum_CCs_or_no_compatible_SCells_to_add
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_183799

    ${config_tag}  set variable  cb_04
    Setup_for_CB006139  config_tag=${config_tag}

    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cb_08  ue_id=1
    CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=1
    CB006139_Change_dlSCellConfigLevel  cell_id=2  value=1

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb08.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-5: UE send A1 to gNB, but due to BC limitation, only Cell-5 and Cell-7 are added as SCell
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    # Step6-9: UE send A4 for Cell-1 and Cell-1 added as SCell
    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    #Step 10-11: Verify A4 measurement for F5(Cell-3) are deactivated
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    stop_ue_big_data_traffic  ue_id=1
    sleep  10

    #Plus B5-ALT1, step 12-19
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=2 scell_rsrp=49
    sleep  5
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Be Equal  ${meas_id}  ${None}

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CA_01_MUE
# CB006139_CA_01_B1_Buffer_based_stepwise_SCell_addition_with_A1_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_174861

    ${config_tag}  set variable  ca_01
    Setup_for_CB006139  config_tag=${config_tag}

    ${ue_total}    Evaluate  list(range(1, 41))
    ${ue_feature}  Evaluate  list(range(1, 6))
    ${ue_background_nonvonr}  Evaluate  list(range(6, 36))
    ${ue_background_vonr}  Evaluate  list(range(36, 41))

    start_log_collection

    mue_change_ue_location    @{ue_total}    enb_id=2  cell_id=2
    mue_change_ue_capability  @{ue_feature}  ue_capability=ue_capability_6cc
    mue_change_ue_capability  @{ue_background_nonvonr}  ue_capability=ue_capability_iphone13e
    mue_change_ue_capability  @{ue_background_vonr}  ue_capability=ue_capability_oneplus10pro

    mue_attach_and_activate_pdu  @{ue_background_nonvonr}
    mue_start_dl_data_service  @{ue_background_nonvonr}  dl_rate=5
    mue_start_ul_data_service  @{ue_background_nonvonr}  ul_rate=1
    mue_attach_and_activate_pdu  @{ue_background_vonr}
    mue_start_vonr_service    @{ue_background_vonr}

    # PM_2113/PM_1631
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_ca01_mue.txt
    ...                                                     wait_for_next_counter_generate=${False}

    #Step1-5:  UE send EventA1 for scell addition
    mue_attach_and_activate_pdu  @{ue_feature}
    sleep  5

    FOR  ${ue_id}  IN  @{ue_feature}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=126990  event_type=A1  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        ${output}    Airphone Operation    operation=send_common_command
        ...                   product_type=${None}
        ...                   traffic_info_dic=${None}
        ...                   tag=${None}
        ...                   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
        sleep  2

        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=150  ul_rate=5
        sleep  10
        verify_ue_dl_scell_status  ue_id=${ue_id}  num_of_scells=5
    END

    #Step5-7  UE send EventA2 for scell-1 release
    FOR  ${ue_id}  IN  @{ue_feature}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=126990  event_type=A1  report_on_leave=True
        Should Be Equal  ${meas_id}  ${None}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=392410  event_type=A2  report_on_leave=False
        Should Not Be Equal  ${meas_id}  ${None}
        ${output}    Airphone Operation    operation=send_common_command
        ...                   product_type=${None}
        ...                   traffic_info_dic=${None}
        ...                   tag=${None}
        ...                   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=1 scell_rsrp=49
        sleep  5
        verify_ue_dl_scell_status  ue_id=${ue_id}  num_of_scells=4
    END

    #Step8-11: UE send EventA1 for scell-1 addition
    FOR  ${ue_id}  IN  @{ue_feature}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=392410  event_type=A2  report_on_leave=False
        Should Be Equal  ${meas_id}  ${None}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=126990  event_type=A1  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        ${output}    Airphone Operation    operation=send_common_command
        ...                   product_type=${None}
        ...                   traffic_info_dic=${None}
        ...                   tag=${None}
        ...                   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
        sleep  5
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=900  ul_rate=10
        sleep  30
        verify_ue_dl_scell_status  ue_id=${ue_id}  num_of_scells=5
        stop_ue_big_data_traffic  ue_id=${ue_id}
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=150  ul_rate=10
    END

    mue_detach_with_power_off  @{ue_total}

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_01_MUE
# CB006139_CB_01_B1_Buffer_based_stepwise_SCell_addition_with_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_174857

    ${config_tag}  set variable  cb_01
    Setup_for_CB006139  config_tag=${config_tag}

    ${ue_total}    Evaluate  list(range(1, 41))
    ${ue_feature}  Evaluate  list(range(1, 4))
    ${ue_background_nonvonr}  Evaluate  list(range(4, 36))
    ${ue_background_vonr}  Evaluate  list(range(36, 41))

    # Key parameter: NRCELL-dlSCellConfigLevelNum=150, a4Fr1SupervisionTimer=10000, a4RetryTimerMultCa=1
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    mue_change_ue_location    @{ue_total}    enb_id=2  cell_id=2
    mue_change_ue_capability  @{ue_feature}  ue_capability=ue_capability_6cc
    mue_change_ue_capability  @{ue_background_nonvonr}  ue_capability=ue_capability_iphone13e
    mue_change_ue_capability  @{ue_background_vonr}  ue_capability=ue_capability_oneplus10pro

    start_log_collection

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb01_mue.txt
    ...                                                     wait_for_next_counter_generate=${False}

    mue_attach_and_activate_pdu  @{ue_background_nonvonr}
    mue_start_dl_data_service  @{ue_background_nonvonr}  dl_rate=5
    mue_start_ul_data_service  @{ue_background_nonvonr}  ul_rate=1
    mue_attach_and_activate_pdu  @{ue_background_vonr}
    mue_start_vonr_service    @{ue_background_vonr}

    # Step1-4: UE send A4 for SCell-1(Cell-6) and SCell-2(Cell-1) Addition
    FOR  ${ue_id}  IN  @{ue_feature}
        attach_ue_and_activate_pdu  ue_id=${ue_id}
        sleep  5

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=635616
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=635616
        # ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=635616  event_type=A4  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=56

        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=392410  event_type=A4  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=51

        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=600  ul_rate=50
        sleep  10

        # Step5  Increase DL Data Transmission to Trigger SCell-1 and SCell-2 Addition
        # start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=450  ul_rate=50
        CB006139_CB_Reverify_UE_DL_SCell_Status  ue_id=${ue_id}  num_of_scells=2
        sleep  2
        verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=635616  event_type=A4  report_on_leave=True
        Should Be Equal  ${meas_id}  ${None}
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=392410  event_type=A4  report_on_leave=True
        Should Be Equal  ${meas_id}  ${None}

        stop_ue_big_data_traffic  ue_id=${ue_id}
        sleep  5
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=300  ul_rate=50
    END

    # Step6-7: UE send A4 for SCell-3(Cell-3) and SCell-4(Cell-5) Addition
    FOR  ${ue_id}  IN  @{ue_feature}
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=427970
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=427970
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=53
        # start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=1200  ul_rate=50
        # sleep  2

        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=516750  event_type=A4  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=55
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=1500  ul_rate=50
        sleep  10

        CB006139_CB_Reverify_UE_DL_SCell_Status  ue_id=${ue_id}  num_of_scells=4
        sleep  5
        verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=640608
        Should Not Be Equal  ${meas_id}  ${None}

        stop_ue_big_data_traffic  ue_id=${ue_id}
        sleep  5
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=150  ul_rate=50
    END

    mue_detach_with_power_off  @{ue_total}

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CG_12
# [1]CB006139_CG_12 IWK4  Interaction with CB008246 to select SCell during stepwise addition that supports High Reliability
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    ${config_tag}  set variable  cg_12
    Setup_for_CB006139  config_tag=${config_tag}

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_12  ue_id=1
    create_rlq_profile

    smf_config_additional_qfi  add_qosflow=12  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-3: Cell F1/2/3 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=2  trf_id=1  dl_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # Step 4-8: Trigger RLQ for Cell F1 and after sCellExcludelistTimerFr1 expires, restore RLQ for Cell F1
    trigger_scell_rlq_release  ue_id=1  scell_id=1
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    detrigger_scell_rlq_release  ue_id=1  scell_id=1

    stop_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1
    sleep  15
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=1  dl_rate=900   ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    smf_config_reset
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    [Teardown]  Teardown_for_CB006139

CB006139_CG_15
# [1]CB006139_CG_15 IWK5 Interaction with CB009059 to restrict stepwise addition or buffer monitoring activation
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    ${config_tag}  set variable  cg_15
    Setup_for_CB006139  config_tag=${config_tag}

    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    create_rlq_profile

    # Step 1: UE attach and activate PDU session with multiple DRB-1/2/3
    smf_config_additional_qfi  add_qosflow=12,13  amf_id=1
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step 1-5: Cell F1/2/3 added as SCell
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1  dl_rate=175
    start_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=3  trf_id=1  dl_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    # Step 5: Trigger SCell Release Inactivity Timer expired for Cell-1
    stop_ue_dl_data_traffic_enh  ue_id=1  pdu=1  qfi=1  trf_id=1
    sleep  15
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # Step 6: remove DRB-1/3 and add new DRB-4 but failed due to gNB-DU failure
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    1
    Log to Console  \n Remove QOS Flow mapping to DRB-1 and DRB-3
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=14 qosflows_to_del=12,15 by=amf

    sleep  10
    start_ue_big_data_traffic_enh  ue_id=1  pdu=1  qfi=3  dl_rate=900  ul_rate=10
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    detach_ue_with_power_off  ue_id=1
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0

    [Teardown]  Teardown_for_CB006139

CB006139_CG_08
# [1]CB006139_CG_08 B13 Measurement profile selection for A2 configuration for SCell change
# [1]CB006139_CG_09 B13 SCell change during stepwise SCell addition
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    ${config_tag}  set variable  cg_08
    Setup_for_TMOUS  config_tag=${config_tag}

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=8
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_08  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    # Step2: UE report A1 to add FDD Cell F1 and F2 as SCell
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=75
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=58  rsrp=76

    start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=396970  event_type=A2  report_on_leave=false  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=125290  event_type=A2  report_on_leave=false  rsrp=50
    Should Not Be Equal  ${meas_id}  ${None}

    # Step 6: UE report A1 for SCell Addition and SCell Change
    ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=80
    Should Not Be Equal  ${meas_id_1}  ${None}
    ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=false  rsrp=80
    Should Not Be Equal  ${meas_id_2}  ${None}
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id_1}  phycell_id=58  rsrp=81
    CB006139_Send_EventA1_For_SCell_Addition  ue_id=1  meas_id=${meas_id_2}  phycell_id=58  rsrp=81

    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    ${meas_id_1}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=true  rsrp=80
    Should Be Equal  ${meas_id_1}  ${None}
    ${meas_id_2}  CB006139_Get_NR_Meas_Config_Id_enh2  ue_id=1  nrarfcn=387630  event_type=A1  report_on_leave=false  rsrp=80
    Should Be Equal  ${meas_id_2}  ${None}

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

CB006139_CG_10
# [1]CB006139_CG_10 IWK1 interworking with CB006449 2CC UL CA
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    ${config_tag}  set variable  cg_10
    Setup_for_CB006139  config_tag=${config_tag}

    start_log_collection

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=8
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cg_10  ue_id=1
    create_rlq_profile

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  1

    trigger_scell_rlq_release   ue_id=1  scell_id=3
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=3
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  1

    stop_ue_big_data_traffic  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
    # sleep  40

    trigger_scell_rlq_release   ue_id=1  scell_id=4
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=4
    stop_ue_big_data_traffic  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=150  ul_rate=50
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=50
    trigger_scell_rlq_release   ue_id=1  scell_id=5
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=5

    stop_ue_big_data_traffic  ue_id=1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    activate_phr_override  ue_id=1

    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    # There is limitation with AP, when DL only SCell-1/2 added back, UL SCell-1/2 also show as configured
    # This problem is fixed by AP soons
    # verify_ue_ul_scell_status  ue_id=1  num_of_scells=2
    # ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=1
    # Should Be Equal  ${scell_status}  ${False}
    # ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=2
    # Should Be Equal  ${scell_status}  ${False}

    deactivate_phr_override  ue_id=1
    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

*** Keywords ***
CB006139_CB_Wait_EventA4_For_SCell_Addition
    [Arguments]  ${ue_id}  ${nrarfcn}
    log to console  \nWait for EventA4 Configured for SCell Addition
    FOR  ${i}  IN RANGE  1  11
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=${nrarfcn}  event_type=A4  report_on_leave=True
        IF  ${meas_id} != ${None}  Exit For LOOP
        sleep  1
    END

    ${result}  Set Variable  ${meas_id}

    [Return]  ${result}

CB006139_CB_Send_EventA4_For_Scell_Addition
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}
    log to console  \nSend Event A4 Report for SCell Addition
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    ...                   pass_regexp=EGATE>
    ...                   timeout=2s

CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition
    [Arguments]  ${ue_id}  ${nrarfcn}
    log to console  \nWait for EventA4 Removed for SCell Addition
    FOR  ${i}  IN RANGE  1  11
        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=${nrarfcn}  event_type=A4  report_on_leave=True
        IF  ${meas_id} == ${None}  Exit For LOOP
        sleep  1
    END

    ${result}  Set Variable  ${meas_id}

    [Return]  ${result}

CB006139_CB_Reverify_UE_DL_SCell_Status
    [Arguments]  ${ue_id}  ${num_of_scells}

    FOR  ${num}  IN RANGE  11
        ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
        ${scell_status}=  get_ue_dl_scell_status  ue_id=${ue_id}
        ${cell_list}=  Get Regexp Matches  ${scell_status}  (CellIndex-[0-9][\\s]+[0-9].*\\n)
        ${cell_num}=  Get Length  ${cell_list}
        IF  ${cell_num} == ${num_of_cells}
            log to console  \n${scell_status}
            Exit For LOOP
        END
        sleep  2
    END
    should be equal  ${num_of_cells}  ${cell_num}

CB006139_Send_EventA1_For_SCell_Addition
    [Arguments]  ${ue_id}  ${meas_id}  ${phycell_id}  ${rsrp}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} phycell_id=${phycell_id}
    ...  pass_regexp=EGATE>
    ...  timeout=5s

CB006139_Send_EventA2_For_SCell_Release
    [Arguments]  ${ue_id}  ${meas_id}  ${scell_id}
    ${output}    Airphone Operation    operation=send_common_command
    ...  product_type=${None}
    ...  traffic_info_dic=${None}
    ...  tag=${None}
    ...  cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 scell=${scell_id} scell_rsrp=49
    ...  pass_regexp=EGATE>
    ...  timeout=5s

start_ue_dl_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

start_ue_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=1s

start_ue_dl_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1  ${dl_rate}=150  ${ul_rate}=10
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service: dl_rate=${dl_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...   cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl mbps=${dl_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=3s
    Log to Console  \nUE-${ue_id} Start pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service: ul_rate=${ul_rate}
    Run Keyword And Ignore Error
    ...  ute_wtssim.Execute Egate Command
    ...  cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=ul mbps=${ul_rate} seconds=3600
    ...  pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    ...  timeout=3s

stop_ue_dl_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}

stop_ue_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

stop_ue_dl_ul_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${trf_id}=1
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} DL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${trf_id} dir=dl
    # ...    pass_regexp= Stopped.*Internal traffic on Ue:${ue_id}
    Log to Console  \nUE-${ue_id} Stop pdu=${pdu} qfi=${qfi} trf_id=${trf_id} UL Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul
    # ...    pass_regexp= Stopping.*Internal traffic on Ue:${ue_id}

start_ue_big_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1  ${dl_rate}=450  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+1
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=dl mbps=150 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=dl mbps=150 seconds=3600
        # ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//10+1
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        log to console  \nue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=ul mbps=10 seconds=3600
        ute_wtssim.Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} qfi=${qfi} trf_id=${i} dir=ul mbps=10 seconds=3600
        # ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic_enh
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1
    Log to Console  \nUE-${ue_id} Stop Data Service for qfi=${qfi}
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=dl
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=${pdu} qfi=${qfi} dir=ul

stop_ue_all_data_traffic_enh
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop All Data Service
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id}

smf_config_additional_qfi
    [Arguments]  ${add_qosflow}  ${amf_id}=1
    Log to Console  \n ${add_qosflow} will be added to activate during ICS
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=${amf_id} additional_qosflows_to_activate=${add_qosflow}

smf_config_reset
    [Arguments]  ${amf_id}=1
    Log to Console  \n SMF Configuration Reset
    ute_wtssim.Execute Egate Command
    ...    cmd=smf_param id=${amf_id} reset

trigger_qosflow_release
    [Arguments]  ${ue_id}=1  ${pdu}=1  ${qfi}=1
    Log to Console  \nUE-${ue_id} Trigger QoS Flow Release for pdu=${pdu} qfi=${qfi}
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=${qfi} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message.*successfully
    ...    timeout=20s

activate_phr_override
    [Arguments]  ${ue_id}
    Log to Console  \nActivate UE-${ue_id} PHR override
    ute_wtssim.Execute Egate Command
    ...  cmd=phr_override_testmode_nr profile_id=6 phr_mode=Fixed phr_start=10 phr_min=10 phr_max=10 pc_max=23
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override profile_id=6 action=activate

deactivate_phr_override
    [Arguments]  ${ue_id}
    Log to Console  \nDeactivate UE-${ue_id} PHR override
    ute_wtssim.Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=phr_override profile_id=6 action=deactivate
    ute_wtssim.Execute Egate Command
    ...  cmd=phr_override_testmode_nr profile_id=6 delete=yes