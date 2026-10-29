*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag_ca_04}  ca_04

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag_ca_04}

CB006139_CA_04
# CB006139_CA_04_B2_A1_measurement_behaviour_when_UE_has_reached_maximum_CCs_or_no_compatible_SCells_to_add
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    # start_log_collection    cell_id=2

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=1
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    # Step8-9: UE send EventA1 for scell addition
      # Decrease DL Data Transmission
    stop_ue_dl_data_traffic  ue_id=1  trf_id=3
    start_ue_dl_data_traffic  ue_id=1  trf_id=1  dl_rate=50
    start_ue_dl_data_traffic  ue_id=1  trf_id=2  dl_rate=50

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2  report_on_leave=False
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s

    # Step10: Change maxNumOfSCellAlloc for Cell-5 to not allow Cell-5 added as SCell
    CB006139_Change_maxNumOfSCellAlloc  cell_id=5  value=0
    sleep  10

    # Step10-11: Increase Data Transmission to add Cell-3 as Scell, but Cell-4 not SCell, it's difficult to control this
    # (The step will be removed from CRT)-------------------------------------------
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
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}

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

    ${value}    Counter Operation    operation=collect_counter_and_check_rule   product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139