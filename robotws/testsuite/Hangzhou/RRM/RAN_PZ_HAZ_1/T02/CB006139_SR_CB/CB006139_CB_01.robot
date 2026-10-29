*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

# Test Setup         Setup_for_CB006139
# Test Teardown      Teardown_for_CB006139

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${config_tag_cb_01}  cb_01

*** Test Cases ***
Load_Configuration
    Setup_for_CB006139  config_tag=${config_tag_cb_01}
CB006139_CB_01
# CB006139_CB_01_B1_Buffer_based_stepwise_SCell_addition_with_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # Key parameter: NRCELL-dlSCellConfigLevelNum=150, a4Fr1SupervisionTimer=10000, a4RetryTimerMultCa=1
    Setup_eGate_Env
    detach_ue_with_power_off  ue_id=1
    delete_rlq_profile

    # start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_6cc  ue_id=1

    # 5G_PM_2125
    Wait_for_Next_5min_Period
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${CURDIR}/counter_rule_cb01.txt
    ...                                                     wait_for_next_counter_generate=${False}

    # Step1-4: UE send A4 for SCell-1(Cell-6) and SCell-2(Cell-1) Addition
    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=56

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=51

    # Step5  Increase DL Data Transmission to Trigger SCell-1 and SCell-2 Addition
    start_ue_big_data_traffic  ue_id=1  dl_rate=450  ul_rate=50
    sleep  5
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2
    sleep  5
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=635616  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}
    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=392410  event_type=A4  report_on_leave=True
    Should Be Equal  ${meas_id}  ${None}

    # Step6-7: UE send A4 for SCell-3(Cell-3) and SCell-4(Cell-5) Addition
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55

    # Step8-9:  Increase DL Data Transmission to Trigger SCell-3 Addition But Scell-4 not added as SCell
    stop_ue_big_data_traffic  ue_id=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=300  ul_rate=50
    sleep  30
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    # need wait data rate is stable, otherwise it will impact scell addition timing. Need fine-tune this together with
    # NRCELL-dlSCellConfigLevel and NRCELL-dlSCellConfigLevelNum to ensure only Scell-3 added as Scell, but SCell-4 not
    sleep  30
    # Need retreive measurement id for A4 again, due to A4 maybe released after a4Fr1SupervisionTimer expired
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=55

    # Increase Data Transmission slowly to ensure only Scell-3 added as Scell, but SCell-4 not added as SCell
    # It's difficult to control this, will do some adaption for CRT
    # FOR  ${i}  IN RANGE  1  10
    #     ${rate}=  Evaluate  ${i}*10
    #     start_ue_dl_data_traffic  ue_id=1  trf_id=5  dl_rate=${rate}
    #     start_ue_dl_data_traffic  ue_id=1  trf_id=6  dl_rate=${rate}
    #     ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=3
    #     IF  ${scell_status} == ${True}  Exit For LOOP
    # END
    # sleep  2
    # ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=3
    # IF  ${scell_status} == ${False}
    #     CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=53
    #     FOR  ${i}  IN RANGE  1  10
    #         ${rate}=  Evaluate  ${i}*10
    #         start_ue_dl_data_traffic  ue_id=1  trf_id=7  dl_rate=${rate}
    #         start_ue_dl_data_traffic  ue_id=1  trf_id=8  dl_rate=${rate}
    #         ${scell_status}  check_ue_dl_scell_configured_status  ue_id=1  scell_id=3
    #         IF  ${scell_status} == ${True}  Exit For LOOP
    #     END
    # END
    # verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    # CRT - Increase Data Transmission to ensure Scell-3 and SCell-4 added as Scell,
    start_ue_big_data_traffic  ue_id=1  dl_rate=1200  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=4
    sleep  10

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=640608  event_type=A4  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    # Comment below 4 line codes for CRT
    # ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=427970
    # Should Not Be Equal  ${meas_id}  ${None}
    # ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=516750  event_type=A4  report_on_leave=True
    # Should Be Equal  ${meas_id}  ${None}

    detach_ue_with_power_off  ue_id=1

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

    # [Teardown]  Teardown_for_CB006139

CB006139_CB_01_MUE
# CB006139_CB_01_B1_Buffer_based_stepwise_SCell_addition_with_A4_measurement_based_Scells
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_174857

    ${ue_total}    Evaluate  list(range(1, 41))
    ${ue_feature}  Evaluate  list(range(1, 4))
    ${ue_background_nonvonr}  Evaluate  list(range(4, 36))
    ${ue_background_vonr}  Evaluate  list(range(36, 41))

    # Key parameter: NRCELL-dlSCellConfigLevelNum=150, a4Fr1SupervisionTimer=10000, a4RetryTimerMultCa=1
    Setup_eGate_Env

    mue_detach_with_power_off  @{ue_total}
    delete_rlq_profile
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=sim_trace uec=1 protocol=nr_rrc on

    mue_change_ue_location    @{ue_total}    enb_id=2  cell_id=2
    mue_change_ue_capability  @{ue_feature}  ue_capability=ue_capability_6cc
    mue_change_ue_capability  @{ue_background_nonvonr}  ue_capability=ue_capability_1cc
    mue_change_ue_capability  @{ue_background_vonr}  ue_capability=ue_capability_1cc

    start_log_collection    cell_id=2

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
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=300  ul_rate=50
    END

    # Step6-7: UE send A4 for SCell-3(Cell-3) and SCell-4(Cell-5) Addition
    FOR  ${ue_id}  IN  @{ue_feature}
        CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=427970
        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=427970
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=53

        ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=${ue_id}  nrarfcn=516750  event_type=A4  report_on_leave=True
        Should Not Be Equal  ${meas_id}  ${None}
        CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=${ue_id}  meas_id=${meas_id}  phycell_id=55

        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=1200  ul_rate=50
        sleep  10

        CB006139_CB_Reverify_UE_DL_SCell_Status  ue_id=${ue_id}  num_of_scells=4
        sleep  5
        verify_ue_ul_scell_status  ue_id=1  num_of_scells=1

        ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=${ue_id}  nrarfcn=640608
        Should Not Be Equal  ${meas_id}  ${None}

        stop_ue_big_data_traffic  ue_id=${ue_id}
        start_ue_big_data_traffic  ue_id=${ue_id}  dl_rate=150  ul_rate=50
    END

    mue_detach_with_power_off  @{ue_total}

    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0

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
