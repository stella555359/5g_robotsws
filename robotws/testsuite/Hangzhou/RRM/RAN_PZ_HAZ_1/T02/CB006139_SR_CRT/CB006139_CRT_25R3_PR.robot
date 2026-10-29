*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Test Cases ***
Load_Configuration
    ${config_tag}  set variable  cb_01
    Setup_for_CB006139  config_tag=${config_tag}
    # ${delta_plan}  set variable  delta_plan.json
    # CB006139_Delta_Commission   file_name=${delta_plan}

Test_3
    @{configs}  Create List  ca_01  ca_04  ca_08  cb_01  cb_04  cg_10  cg_12  cg_15  da_01_05  da_06  da_09_11  da_12_13

    FOR  ${config_tag}  IN  @{configs}
        log to console  \n\n=================== Start to run configuration: ${config_tag} ===================
        Setup_for_CB006139  config_tag=${config_tag}
    END

CB006139_CB_01_MUE
# CB006139_CB_01_B1_Buffer_based_stepwise_SCell_addition_with_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_174857

    # ${config_tag}  set variable  cb_01
    # Setup_for_CB006139  config_tag=${config_tag}
    Setup_eGate_Env

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

    # start_log_collection

    # 5G_PM_2125
    # Wait_for_Next_5min_Period
    # Counter Operation    operation=start_collect_counter    product_type=gnb
    # ...                                                     bts_index=0
    # ...                                                     counter_rule=${CURDIR}/counter_rule_cb01_mue.txt
    # ...                                                     wait_for_next_counter_generate=${False}

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

    # Wait_for_Next_5min_Period
    # Wait_for_Next_5min_Period
    # ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139


CB006139_CA_04
# CB006139_CA_04_B2_A1_measurement_behaviour_when_UE_has_reached_maximum_CCs_or_no_compatible_SCells_to_add
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181229

    # ${config_tag}  set variable  ca_04
    # Setup_for_CB006139  config_tag=${config_tag}

    # start_log_collection
    Setup_eGate_Env

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

    # [Teardown]  Teardown_for_CB006139

CB006139_CG_10
# [1]CB006139_CG_10 IWK1 interworking with CB006449 2CC UL CA
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env

    # start_log_collection

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
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=20
    trigger_scell_rlq_release   ue_id=1  scell_id=5
    sleep  1
    detrigger_scell_rlq_release  ue_id=1  scell_id=5

    stop_ue_big_data_traffic  ue_id=1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  1
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    # activate_phr_override  ue_id=1

    sleep  5
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    sleep  5

    # There is limitation with AP, when DL only SCell-1/2 added back, UL SCell-1/2 also show as configured
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1
    # ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=1
    # Should Be Equal  ${scell_status}  ${False}
    # ${scell_status}  check_ue_ul_scell_schedule_status  ue_id=1  scell_id=2
    # Should Be Equal  ${scell_status}  ${False}

    detach_ue_with_power_off  ue_id=1

    # [Teardown]  Teardown_for_CB006139

CB006139_CA_08
# CB006139_CA_08_B5_A1_event_measurement_based_step-wise_SCell_Addition for UE already configured with SCells...
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_181228

    # ${config_tag}  set variable  ca_08
    # Setup_for_CB006139  config_tag=${config_tag}
    Setup_eGate_Env

    # start_log_collection  log_type=syslog+emil+snapshot+tti

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

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

    # [Teardown]  Teardown_for_CB006139

Test_2
    [Documentation]
    ...    author: Liu AnAn

    # dlSCellConfigLevelNum=1/a4Fr1SupervisionTimer=2000/a4RetryTimer=1 - concurrent issue
    # dlSCellConfigLevelNum=3/a4Fr1SupervisionTimer=10000/a4RetryTimer=10 - L2RT crash
    Setup_eGate_Env
    # CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=1
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    # start_log_collection
    # Wait_for_Next_5min_Period
    ${test_start_time}   CB006139_Get_Current_Time
    # Counter Operation    operation=start_collect_counter    product_type=gnb
    # ...                                                     bts_index=0
    # ...                                                     counter_rule=${CURDIR}/counter_rule_cb01.txt
    # ...                                                     wait_for_next_counter_generate=${False}

    detach_ue_with_power_off  ue_id=1
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  3
    FOR  ${i}  IN RANGE  1  2
        log to console  \n----------------Round ${i}--------------------

        # attach_ue_and_activate_pdu  ue_id=1
        # sleep  3
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=635616
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=635616
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=56
        start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
        # start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=427970
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
        # start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=516750
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=516750
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55
        # start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
        sleep  2
        Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=640608
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=640608
        Should Not Be Equal  ${meas_id}  ${None}

        stop_ue_big_data_traffic  ue_id=1
        # sleep  30
        # start_ue_big_data_traffic  ue_id=1  dl_rate=1500  ul_rate=50
        # sleep  10
        # stop_ue_big_data_traffic  ue_id=1

        # sleep  15   -PR value
        sleep  300
        # detach_ue_with_power_off  ue_id=1
    END

    detach_ue_with_power_off  ue_id=1
    ${test_end_time}  CB006139_Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    # Wait_for_Next_5min_Period
    # Wait_for_Next_5min_Period
    # ${value}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139

Test
    [Documentation]
    ...    author: Liu AnAn

    # dlSCellConfigLevelNum=1/a4Fr1SupervisionTimer=2000/a4RetryTimer=1 - concurrent issue
    # dlSCellConfigLevelNum=3/a4Fr1SupervisionTimer=10000/a4RetryTimer=10 - L2RT crash
    Setup_eGate_Env
    # CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=1
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    # start_log_collection
    # Wait_for_Next_5min_Period
    ${test_start_time}   CB006139_Get_Current_Time
    # Counter Operation    operation=start_collect_counter    product_type=gnb
    # ...                                                     bts_index=0
    # ...                                                     counter_rule=${CURDIR}/counter_rule_cb01.txt
    # ...                                                     wait_for_next_counter_generate=${False}

    detach_ue_with_power_off  ue_id=1
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    attach_ue_and_activate_pdu  ue_id=1
    sleep  3
    FOR  ${i}  IN RANGE  1  2
        log to console  \n----------------Round ${i}--------------------

        # attach_ue_and_activate_pdu  ue_id=1
        # sleep  3
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=635616
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=635616
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=56
        start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
        start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=427970
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
        start_ue_big_data_traffic  ue_id=1  dl_rate=900  ul_rate=50
        sleep  2
        # stop_ue_big_data_traffic  ue_id=1
        # Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=516750
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=516750
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55
        start_ue_big_data_traffic  ue_id=1  dl_rate=1500  ul_rate=50
        sleep  2
        Run Keyword and Ignore Error  verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
        # sleep  5

        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=392410
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
        start_ue_big_data_traffic  ue_id=1  dl_rate=1500  ul_rate=50
        sleep  2

        stop_ue_big_data_traffic  ue_id=1
        # sleep  10
        # CB006139_Check_Measurement

        # start_ue_big_data_traffic  ue_id=1  dl_rate=1500  ul_rate=50
        # sleep  10

        # stop_ue_big_data_traffic  ue_id=1

        # sleep  15   -PR value
        sleep  300
        # detach_ue_with_power_off  ue_id=1
    END

    detach_ue_with_power_off  ue_id=1
    ${test_end_time}  CB006139_Get_Current_Time
    ${test_duration}  Evaluate  ${test_end_time} - ${test_start_time}
    Log to Console  \nTest duration: ${test_duration} seconds
    # Wait_for_Next_5min_Period
    # Wait_for_Next_5min_Period
    # ${value}    Counter Operation    operation=collect_counter_and_calculate    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139

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

CB006139_Check_Measurement
    ${nrarfcn_pci}  Create Dictionary    635616=56  392410=51  427970=53  516750=55
    FOR  ${nrarfcn}  IN  @{nrarfcn_pci}
        ${pci}=  Get From Dictionary  ${nrarfcn_pci}  ${nrarfcn}
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=${nrarfcn}
        IF  '${meas_id}' != ${None}
            CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=${pci}
        END
        start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
        sleep  5
    END