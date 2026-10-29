*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag_ca_08}  ca_08

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag_ca_08}

CB006139_CA_08
# CB006139_CA_08_B5_A1_event_measurement_based_step-wise_SCell_Addition for UE already configured with SCells...
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection    cell_id=2

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    sleep  2
    log to console  \nUE Report A1 with Leaving Condition - Step 17
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=50 phycell_id=52
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    sleep  2

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    sleep  20

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    ${scell_status}  check_ue_dl_scell_schedule_status  ue_id=1  scell_id=5
    Should Be Equal  ${scell_status}  ${False}
    ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=5
    Should Be Equal  ${scell_status}  ${True}

    delete_rlq_profile
    detach_ue_with_power_off  ue_id=1

    ${value}    Counter Operation    operation=collect_counter_and_check_rule   product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139