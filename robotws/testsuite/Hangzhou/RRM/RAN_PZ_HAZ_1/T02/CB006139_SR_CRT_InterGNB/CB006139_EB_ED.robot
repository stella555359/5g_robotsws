*** Settings ***
Documentation
...                 author:  Liu AnAn

Resource    ./Resource_CB006139.robot

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_[LO][LO]_AP_[LOO]

*** Test Cases ***
CB006139_EB_01
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_177540

    ${config_tag}  set variable  eb
    Setup_for_CB006139_InterGNB  config_tag=${config_tag}

    detach_ue_with_power_off  ue_id=1

    start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_7cc  ue_id=1

    # Disable CA
    ${delta_plan_intergnb_ca_disable}  set variable  delta_plan_intergnb_ca_disable.json
    CB006139_Delta_Commission   file_name=${delta_plan_intergnb_ca_disable}

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nIncrease DL Data Transmission==============================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900   ul_rate=50
    sleep  10
    log to console  \nSCell not configured due to Inter-gNB CA Disabled==============================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=0
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  10

    detach_ue_with_power_off  ue_id=1

    # Enable CA
    ${delta_plan_intergnb_ca_enable}  set variable  delta_plan_intergnb_ca_enable.json
    CB006139_Delta_Commission   file_name=${delta_plan_intergnb_ca_enable}

    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nIncrease DL Data Transmission==============================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900   ul_rate=50
    sleep  10
    log to console  \nSCell configured due to Inter-gNB CA Enabled==============================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  10

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

CB006139_ED_01
    [Documentation]
    ...    author: Liu AnAn
    [Tags]    QC_

    # Setup_eGate_Env

    ${config_tag}  set variable  ed
    Setup_for_CB006139_InterGNB  config_tag=${config_tag}

    detach_ue_with_power_off  ue_id=1

    start_log_collection    cell_id=2

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=2
    CB006139_Change_UE_Capability  ue_capability=ue_capability_7cc  ue_id=1

    # Enable ED parameters
    ${delta_plan_intergnb_ca_ed}  set variable  delta_plan_intergnb_ca_ed.json
    CB006139_Delta_Commission   file_name=${delta_plan_intergnb_ca_ed}

    attach_ue_and_activate_pdu  ue_id=1
    sleep  5

    ${meas_id}  CB006139_Get_NR_Meas_Config_Id  ue_id=1  nrarfcn=368430  event_type=A1  report_on_leave=True
    Should Not Be Equal  ${meas_id}  ${None}
    ${output}    Airphone Operation    operation=send_common_command
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=ue_measurement_send_nr id=1 meas_id=${meas_id} event=A1 srsrp_nr=71 phycell_id=52
    ...                   pass_regexp=EGATE>
    ...                   timeout=5s
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=50
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=2

    CB006139_CB_Wait_EventA4_Removed_For_SCell_Addition  ue_id=1  nrarfcn=640608
    ${meas_id}  CB006139_CB_Wait_EventA4_For_SCell_Addition  ue_id=1  nrarfcn=640608
    CB006139_CB_Send_EventA4_For_Scell_Addition  ue_id=1  meas_id=${meas_id}  phycell_id=58

    start_ue_big_data_traffic  ue_id=1  dl_rate=1800  ul_rate=50
    sleep  10

    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3

    detach_ue_with_power_off  ue_id=1

    [Teardown]  Teardown_for_CB006139

CB006139_EB_08
    [Documentation]
    ...    author: Shuangfeng.f.sun
    [Tags]    QC_181238
    # Setup_eGate_Env

    ${config_tag}  set variable  eb_B9
    Setup_for_CB006139_InterGNB  config_tag=${config_tag}

    detach_ue_with_power_off  ue_id=1

    start_log_collection    cell_id=1

    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=1
    CB006139_Change_UE_Capability  ue_capability=ue_capability_2T2F_B9  ue_id=1
    # Enable CA
    ${delta_plan_intergnb_ca_enable}  set variable  delta_plan_intergnb_ca_enable.json
    CB006139_Delta_Commission   file_name=${delta_plan_intergnb_ca_enable}
    attach_ue_and_activate_pdu  ue_id=1
    log to console  \nIncrease DL Data Transmission==============================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900   ul_rate=0
    sleep  10
    log to console  \nSCell configured due to Inter-gNB CA Enabled==============================
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    verify_ue_ul_scell_status  ue_id=1  num_of_scells=0
    sleep  10
    verify_ue_dl_scell_status  ue_id=1  num_of_scells=3
    stop_ue_big_data_traffic  ue_id=1
    sleep  20
    log to console  \nIncrease DL Data Transmission==============================
    start_ue_big_data_traffic  ue_id=1  dl_rate=900   ul_rate=0
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