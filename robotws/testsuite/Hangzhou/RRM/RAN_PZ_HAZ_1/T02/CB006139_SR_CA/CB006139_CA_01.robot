*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag_ca_01}  ca_01

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag_ca_01}

CB006139_CA_01
# CB006139_CA_01_B1_Buffer_based_stepwise_SCell_addition_with_A1_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    # start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    # PM_2113/PM_1631
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_ca01.txt
    ...                                                     wait_for_next_counter_generate=${False}

    #Step1-5:  UE send EventA1 for scell addition
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
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    #Step5-7  UE send EventA2 for scell-1 release
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=1 scell_rsrp=49
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0

    #Step8-11: UE send EventA1 for scell-1 addition
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
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
    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    detach_ue_with_power_off  ue_id=1

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139

CB006139_CA_01_MUE
# CB006139_CA_01_B1_Buffer_based_stepwise_SCell_addition_with_A1_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_174861

    ${ue_total}    Evaluate  list(range(1, 41))
    ${ue_feature}  Evaluate  list(range(1, 6))
    ${ue_background_nonvonr}  Evaluate  list(range(6, 36))
    ${ue_background_vonr}  Evaluate  list(range(36, 41))

    Setup_eGate_Env

    mue_detach_with_power_off  @{ue_total}
    delete_rlq_profile

    # start_log_collection    cell_id=2

    mue_change_ue_location    @{ue_total}    enb_id=2  cell_id=2
    mue_change_ue_capability  @{ue_feature}  ue_capability=ue_capability_6cc
    mue_change_ue_capability  @{ue_background_nonvonr}  ue_capability=ue_capability_1cc
    mue_change_ue_capability  @{ue_background_vonr}  ue_capability=ue_capability_1cc

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
        # sleep  5
        # verify_ue_ul_scell_status  ue_id=${ue_id}  num_of_scells=1
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
        # sleep  5
        # verify_ue_ul_scell_status  ue_id=${ue_id}  num_of_scells=0
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
        # sleep  5
        # verify_ue_ul_scell_status  ue_id=${ue_id}  num_of_scells=1
    END

    mue_detach_with_power_off  @{ue_total}

    Wait_for_Next_5min_Period
    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139