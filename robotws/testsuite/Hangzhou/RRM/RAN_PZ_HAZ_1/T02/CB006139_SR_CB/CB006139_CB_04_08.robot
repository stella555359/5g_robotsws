*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag_cb_04}  cb_04

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag_cb_04}

CB006139_CB_04
# CB006139_CB_04_B2_Buffer_based_stepwise_SCell_addition_with_A1_and_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection    cell_id=2

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  2
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    # Step6-9: UE send A4 for SCell-1/3 and Cell-1/3 added as SCell
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=427970  event_type=A4  report_on_leave=True
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=5

    detach_ue_with_power_off  ue_id=1

    Wait_for_Next_5min_Period
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_06
# CB006139_CB_06_B3_behaviour_at_the_expiration_of_supervision_timer_and_retry_timer_when_CB006139_is_enabled
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=120

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}

    # Step6-9: UE send A4 for SCell-1/3 and Cell-1 added as SCell, but Cell-3 not due to buffer status cond not meet
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    # Increase Data Transmission slowly to ensure only Cell-1(Scell-4) added as Scell, but Cell-3(Scell-5) not added as SCell
    # It's difficult to control this, will do some adaption for CRT
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
    FOR  ${i}  IN RANGE  1  15
        ${rate}=  Evaluate  ${i}*10
        start_ue_dl_data_traffic  ue_id=1  trf_id=10  dl_rate=${rate}
        start_ue_dl_data_traffic  ue_id=1  trf_id=11  dl_rate=${rate}
        ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
        IF  ${scell_status} == ${True}  Exit For LOOP
    END
    sleep  10
    ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
    IF  ${scell_status} == ${False}
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
        FOR  ${i}  IN RANGE  1  15
            ${rate}=  Evaluate  ${i}*10
            start_ue_dl_data_traffic  ue_id=1  trf_id=12  dl_rate=${rate}
            start_ue_dl_data_traffic  ue_id=1  trf_id=13  dl_rate=${rate}
            ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
            IF  ${scell_status} == ${True}  Exit For LOOP
        END
    END

    stop_ue_big_data_traffic  ue_id=1
    sleep  1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # Step10-13: At the expiration of supervision timer/At the expiration of retry timer, already checked in previous steps
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}

    detach_ue_with_power_off  ue_id=1

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    [Teardown]  Teardown_for_CB006139

CB006139_CB_07
# CB006139_CB_07_B4_A4_measurement_configuration_behaviour_during_partial_SCell_release
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1
    CB006139_Change_dlSCellConfigLevelNum  cell_id=2  value=120

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=126990  event_type=A1  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A2
    Should Not Be Equal  ${meas_id}  ${None}

    # Step6-9: UE send A4 for SCell-1/3 and Cell-1 added as SCell, but Cell-3 not due to buffer status cond not meet
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    # Increase Data Transmission slowly to ensure only Cell-1(Scell-4) added as Scell, but Cell-3(Scell-5) not added as SCell
    # It's difficult to control this, will do some adaption for CRT
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
    FOR  ${i}  IN RANGE  1  15
        ${rate}=  Evaluate  ${i}*10
        start_ue_dl_data_traffic  ue_id=1  trf_id=10  dl_rate=${rate}
        start_ue_dl_data_traffic  ue_id=1  trf_id=11  dl_rate=${rate}
        ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
        IF  ${scell_status} == ${True}  Exit For LOOP
    END
    sleep  10
    ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
    IF  ${scell_status} == ${False}
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51
        FOR  ${i}  IN RANGE  1  15
            ${rate}=  Evaluate  ${i}*10
            start_ue_dl_data_traffic  ue_id=1  trf_id=12  dl_rate=${rate}
            start_ue_dl_data_traffic  ue_id=1  trf_id=13  dl_rate=${rate}
            ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=4
            IF  ${scell_status} == ${True}  Exit For LOOP
        END
    END

    stop_ue_big_data_traffic  ue_id=1
    sleep  1
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4

    # Step10-13: Send A2 report to SCell-4
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A2  report_on_leave=False
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 scell=4 scell_rsrp=49
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s

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
    [Tags]    QC_

    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    # start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_cb_08  ue_id=1

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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
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
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=392410
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51

    start_ue_big_data_traffic  ue_id=1  dl_rate=1500  ul_rate=50
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
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s

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